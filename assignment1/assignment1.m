%% Read PCD
baseCloud = readPcd('data/0000000000.pcd');
otherCloud = readPcd('data/0000000001.pcd');

%baseCloud = [0,0;cosd(45),sind(45)]
%otherCloud = [0,0; cosd(40), sind(40)];

d = size(baseCloud, 2);

% Compute base centroid
baseCentroid = computeCentroid(baseCloud);

% Create base cloud
baseCloudPrime = translateCloud(baseCloud, -baseCentroid);

% Create target cloud
[targetCloud, minima] = computeClosestCloud(baseCloud, otherCloud);

counter = 0;
while ( mean(minima) > 0.0012 && counter < 20 )
    % Compute centroid
    targetCentroid = computeCentroid(targetCloud);
    % Create target cloud
    targetCloudPrime = translateCloud(targetCloud, -targetCentroid);

    % Compute A matrix
    A = baseCloudPrime' * targetCloudPrime;

    % SVD decomposition
    [U, S, V] = svd(A);

    % Rotation Matrix
    R = U * V'

    % Translation Matrix
    T = baseCentroid - targetCentroid * R

    % Move Target Cloud
    testCloud = (R * otherCloud')'
    otherCloud = translateCloud((R * otherCloud')', T)
    
    % Compute new distance
    [targetCloud, minima] = computeClosestCloud(baseCloud, otherCloud);
    counter = counter + 1
    pause
end