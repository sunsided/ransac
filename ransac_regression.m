N = 2;                      % only two points are needed to determine a linear regression
epsilon = 0.08;             % distance of the error bounds
RANSAC_iterations = 100;    % number of RANSAC iterations

% fetch random data
data = random_data();

%% RANSAC iterations

% RANSAC iteration; start with empty consensus set
current_consensus_set = [,];
selected_upper_bound_offset = [];
selected_lower_bound_offset = [];
h = waitbar(0, 'Running RANSAC ...');
for ransac_iteration=1:RANSAC_iterations
    
    % RANSAC specific
    % select N distinct random points
    while true
        indices = randi([1 size(data,2)],1,N);
        A = data(:,indices(1));
        B = data(:,indices(2));
        if A ~= B
            break;
        end
    end

    % test criterion
    % determine the line between both points
    vector = [(B-A)/norm(B-A); 0];
    offset = [A; 0];

    % test criterion
    % determine orthogonal vector and error bound offsets
    % all in homogenous coordinates
    ortho = [-vector(2); vector(1); 0];
    upper_bound_offset = offset + ortho*epsilon;
    lower_bound_offset = offset - ortho*epsilon;

    
    % test criterion
    % check all data points against the error bounds
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
    
    
    % RANSAC specific
    % register the consensus set if it is larger than the 
    % current consensus set
    if candidate > size(current_consensus_set,2) 
        current_consensus_set = consensus_set(:,1:candidate);
        
        selected_vector = vector;
        selected_offset = offset;
        selected_upper_bound_offset = upper_bound_offset;
        selected_lower_bound_offset = lower_bound_offset;
    end

    waitbar(ransac_iteration/RANSAC_iterations, h);
end
close(h);

% RANSAC specific
% regress within the consensus set
p = polyfit(current_consensus_set(1,:), current_consensus_set(2,:), 1);
x = [0, 1];
y = polyval(p, x);


%% Plot

% plot the noise
close all;
figure; hold on;
plot(data(1,:), data(2,:), '+', 'Color', [0.8 0.8 0.8]);
axis square;
xlim([0 1]);
ylim([0 1]);

% plot the selected points and the line-under-test
plot([selected_offset(1) selected_offset(1)+selected_vector(1)], [selected_offset(2) selected_offset(2)+selected_vector(2)], 'm--');
plot([selected_upper_bound_offset(1) selected_upper_bound_offset(1)+selected_vector(1)], [selected_upper_bound_offset(2) selected_upper_bound_offset(2)+selected_vector(2)], 'm:');
plot([selected_lower_bound_offset(1) selected_lower_bound_offset(1)+selected_vector(1)], [selected_lower_bound_offset(2) selected_lower_bound_offset(2)+selected_vector(2)], 'm:');

% plot consensus set
plot(current_consensus_set(1,:), current_consensus_set(2,:), '+', 'Color', [0.6 0.6 0.8]);

% plot regression
plot(x, y, 'g', 'LineWidth', 2);


% simple 1D-polyfitting
p = polyfit(data(1,:), data(2,:), 1);
x = [0, 1];
y = polyval(p, x);

% plot the fit
plot(x, y, 'r');