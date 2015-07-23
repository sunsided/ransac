% Erste Iteration von RANSAC, um Verhalten zu zeigen

N = 2;      % only two points are needed to determine a linear regression
epsilon = 0.1;   % distance of the error bounds

% fetch random data
data = random_data();

% select N distinct random points
while true
    indices = randi([0 size(data,2)],1,N);
    A = data(:,indices(1));
    B = data(:,indices(2));
    if A ~= B
        break;
    end
end

% determine the line between both points
vector = [(B-A)/norm(B-A); 0];
offset = [A; 0];

% determine orthogonal vector and error bound offsets
% all in homogenous coordinates
ortho = [-vector(2); vector(1); 0];
upper_bound_offset = offset + ortho*epsilon;
lower_bound_offset = offset - ortho*epsilon;

% select all points on the right of the upper bound
M = size(data,2);
consensus_set = nan(size(data));
candidate = 0;
for i=1:M
    % check upper bound
    point = [data(:,i); 0] - upper_bound_offset; % homogenous coordinate
    cpv = cross(vector, point);
    upper_direction = cpv(3) < 0;
    
    % check lower bound
    point = [data(:,i); 0] - lower_bound_offset; % homogenous coordinate
    cpv = cross(vector, point);
    lower_direction = cpv(3) < 0;
    
    % register candidate
    if upper_direction ~= lower_direction
        candidate = candidate + 1;
        consensus_set(:,candidate) = data(:,i);
    end
end
consensus_set = consensus_set(:,1:candidate);

% plot the noise
close all;
figure; hold on;
plot(data(1,:), data(2,:), '+');
axis square;
xlim([0 1]);
ylim([0 1]);

% plot the selected points and the line-under-test
plot(A(1), A(2), 'ro');
plot(B(1), B(2), 'ro');
plot([offset(1) offset(1)+vector(1)], [offset(2) offset(2)+vector(2)], 'r');
%plot([offset(1) offset(1)+ortho(1)], [offset(2) offset(2)+ortho(2)], 'm:');
plot([upper_bound_offset(1) upper_bound_offset(1)+vector(1)], [upper_bound_offset(2) upper_bound_offset(2)+vector(2)], 'm:');
plot([lower_bound_offset(1) lower_bound_offset(1)+vector(1)], [lower_bound_offset(2) lower_bound_offset(2)+vector(2)], 'm:');

% plot consensus set
plot(consensus_set(1,:), consensus_set(2,:), 'm+');