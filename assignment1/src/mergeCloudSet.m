function [resultCloud, TRarr, TTarr] = mergeCloudSet(filename, sampleMethod, sampleSize, matchMethod, startNr, stepNr, endNr)
% MERGECLOUDSET Load and merge point cloud datasets
%    [ALLCLOUDS, TRARR, TTARR] = MERGECLOUDSET(FILENAME, SAMPLEMETHOD,
%    SAMPLESIZE, MATCHMETHOD, START, STEP, END) loads point cloud datasets
%    using START:STEP:END filtering and saves the resulting merged set to a
%    file (a random subset of it to allow for visualization efforts). The
%    function returns also the set of uniquely merged point clouds
%    ALLCLOUDS and the rotation and translation matrices TRARR and TTARR
%    used in the process. SAMPLEMETHOD and SAMPLESIZE are parameters used
%    for the merging of individual clouds. SAMPLEMETHOD can be either
%    'none', 'random' or 'normal'. If it is not 'none', then SAMPLESIZE
%    identifies the number of samples that are extracted. MATCHMETHOD can
%    be either 'brute' or 'flann' and determines how we look for close
%    points.

% Default sampleSize value
if nargin < 1
    filename = 'mergedCloud.pcd';
end

if nargin < 2
    sampleMethod = 'normal';
end

if nargin < 3
    sampleSize = 8000;
end

if nargin < 4
    matchMethod = 'flann';
end

if nargin < 5
    startNr = 0;
    stepNr = 1;
    endNr = 65;
end

frameIDs = startNr:stepNr:endNr;
n = numel(frameIDs);

% Variable for all clouds
cloudIDs = cell(n,1);

% Get all cloud IDs
for i=1:n,
    cloudIDs{i} = sprintf('%.10d', frameIDs(i));
end

% Init memory
resultCloud = cell(1,n);
TRarr = zeros(3, 3, n);
TTarr = zeros(1, 3, n);

% Here we hold all clouds while we wait for rotate/translate them.
resultCloud{1} = readCloud(cloudIDs{1}, true);

% Loop over all cloud paths
for i=2:n,
    frameIDs(i)
    % Get cloud merging results
    [resultCloud{i}, TRarr(:, :, i), TTarr(:, :, i), error] = mergeClouds(resultCloud{i-1}, cloudIDs{i}, sampleMethod, sampleSize, matchMethod);
    disp(error);
end

% Finally merge everything
result = [];
TR = eye(3,3);
TT = zeros(1,3);
for i=1:n-1
    result = [result; translateCloud(resultCloud{i} * TR, TT)];
    TR = TRarr(:, :, i+1) * TR;
    TT = translateCloud(TTarr(:, :, i+1) * TR, TT);
end
result = [result; translateCloud(resultCloud{n} * TR, TT)];

resultIDs = randsample(size(result,  1), sampleSize * n);
% Save resultCloud to pcd file
savepcd(filename, result(resultIDs,:)');
end
