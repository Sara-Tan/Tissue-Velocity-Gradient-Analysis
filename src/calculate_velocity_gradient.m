function calculate_velocity_gradient(working_dir)
% Quantification of tissue velocity gradient for tracked cell.
%
%
% Input Data:
% 	- handCorrection.tif/.png     : A segmented mask from the first time point, generated using Tissue Analyzer.
% 	                              : Used to extract cell height and width information for grid partitioning.
%   - centroid_data.mat           : Contains a variable named centroids, which holds the coordinates for the centroids of all tracked cells across all time points.
%                                   Size of centroids: (number of cells) x (number of time points) x 2
% 	                                    - centroids(i_cell, j_time, 1) for x-coordinate
% 	                                    - centroids(i_cell, j_time, 2) for y-coordinate
% Ensure that all input files are located in the same directory.
% 
% Execution:
%   - Run the script calculate_velocity_gradient.m to begin the calculation.
% 
% Output Data:
%   - Two CSV Files               : Instantaneous and average velocity gradients for (?v_x)/?y.
%                                 : Instantaneous and average velocity gradients for (?v_y)/?x.



% Input imaging time interval
time_interval_min = 15;
assert(time_interval_min > 0, 'Invalid time interval');


%% Checking inputs
if ~exist('working_dir', 'var') || ~exist(working_dir, 'dir')
    working_dir = uigetdir('', 'Pick the folder for tissue velocity gradient quantification');
    if ~ischar(working_dir)
        disp('Invalid selection. Code terminating')
        return
    end
end
cd(working_dir);


%% Retrieving cell centroid coordinates from previous analysis
centroid_data_file = fullfile(working_dir, 'centroid_data.mat');
assert(exist(centroid_data_file, 'file') > 0, 'The directory must contain centroid_data.mat')
tmp_data = load('centroid_data', 'centroids');
assert(isfield(tmp_data, 'centroids'), 'Error in centroid_data.mat, does not contain centriods');
centroids = tmp_data.centroids;
assert(ndims(centroids) == 3);
assert(size(centroids, 3) == 2);

% remove NaN cells
nan_cell_mask = any(isnan(centroids(:,:,end)),2);
centroids = centroids(~nan_cell_mask, :,:);


%% Calculate the width and height for partition
% find the handCorrection file with the right extension
files = dir(fullfile(working_dir, 'handCorrection.*'));
matched_files = {files.name};
matched_files = matched_files(endsWith(matched_files, {'.png', '.tif'}));
assert(length(matched_files) == 1, '1 handCorrection.* file required, %d found.', length(matched_files))

mask_image_path = fullfile(working_dir, matched_files{1});
[~, cell_labels_img, ~] = preprocess_mask(mask_image_path);

% calculate the average width and height
stats = regionprops(cell_labels_img, 'BoundingBox', 'Area');
bboxes = cell2mat({stats.BoundingBox}');
width = mean(bboxes(:, 3));
height = mean(bboxes(:, 4));
% scale to attain correct average area
ratio = height/width;
height = sqrt(mean([stats.Area]) * ratio);
width = height/ratio;
assert(ismembertol(width*height, mean([stats.Area]), 1e-5));


%% obtain the xy coordinates for each grid element
[cell2grid_assignments, n_row, n_col, grid_xy_t0] = ...
    velo_grad_helper__create_partition(centroids, height, width);

[grid_xys] = velo_grad_helper__calculate_grid_xy(...
    centroids, grid_xy_t0, cell2grid_assignments, n_row, n_col);


%% Calculate displacement, velocity, and velocity gradients
grid_disps = grid_xys(:,:,2:end, :) - grid_xys(:,:,1:end-1, :);
t_delta_hr = time_interval_min / 60;

n_times = size(centroids, 2);

delta_x0 = grid_xys(1,2,1,1) - grid_xys(1,1,1,1);
delta_y0 = grid_xys(2,1,1,2) - grid_xys(1,1,1,2);

grid_drx_dx = (grid_disps(1:end-1, 2:end,:,1) - grid_disps(1:end-1, 1:end-1,:,1))/delta_x0;
grid_dry_dx = (grid_disps(1:end-1, 2:end,:,2) - grid_disps(1:end-1, 1:end-1,:,2))/delta_x0;
grid_drx_dy = (grid_disps(2:end, 1:end-1,:,1) - grid_disps(1:end-1, 1:end-1,:,1))/delta_y0;
grid_dry_dy = (grid_disps(2:end, 1:end-1,:,2) - grid_disps(1:end-1, 1:end-1,:,2))/delta_y0;

grid_dvx_dx = grid_drx_dx / t_delta_hr;
grid_dvy_dx = grid_dry_dx / t_delta_hr;
grid_dvx_dy = grid_drx_dy / t_delta_hr;
grid_dvy_dy = grid_dry_dy / t_delta_hr;

%% Store data into CSV file
for i_cell = {'dvx_dy', 'dvy_dx'}
    var_str = i_cell{1};
    var = eval(['grid_' var_str]);
    var = reshape(var, [], n_times-1);
    
    var_space_average = mean(abs(var), "omitnan");
    data = num2cell(var_space_average);
    data{2, 1} = mean(var_space_average, "omitnan");
    
    dlmcell_for_labelled_data(sprintf('velocity_gradient_%s.csv', var_str), ...
        data, 'component \ time', 1:(n_times-1), {['Instantaneous ' var_str], ['Average ' var_str]});
    % disp(data{2,1})
end
