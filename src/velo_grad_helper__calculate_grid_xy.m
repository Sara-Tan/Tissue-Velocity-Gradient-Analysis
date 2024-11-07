function [grid_xy_all_times] = velo_grad_helper__calculate_grid_xy(...
    centroids, sq_xy_t0, cell2grid_assignment, n_row, n_col)
% Helper function to calculate the xy coordinates of the grid elements based
% on the average displacement of cells.

%% Check input
n_sq = length(sq_xy_t0);
assert(n_row * n_col == n_sq);

%% Calculate the displacement of grid elements
n_times = size(centroids, 2);
sq_inst_displacements = NaN(n_sq, n_times-1, 2);
centroids_displacements = centroids(:,2:end, :) - centroids(:,1:end-1, :);
sq_without_centroids = [];

for i = 1:n_sq
    centroid_ids = find(cell2grid_assignment == i);
    if isempty(centroid_ids)
        sq_without_centroids = [sq_without_centroids, i];
        continue
    end
    tmp_disps = centroids_displacements(centroid_ids, :, :);
    sq_inst_displacements(i, :, :) = mean(tmp_disps, 1);
end

if ~isempty(sq_without_centroids)
    % Sanity check for grid elements without centroids
    assert(sum(isnan(sq_inst_displacements(:,1,1))) == length(sq_without_centroids))
end

%% Calculate the coordinates based on displacements
grid_xy_all_times = zeros(n_sq, n_times, 2);
grid_xy_all_times(:,1, :) = sq_xy_t0;
grid_xy_all_times(:, 2:end, :) = grid_xy_all_times(:, 1, :) + cumsum(sq_inst_displacements, 2);
grid_xy_all_times = reshape(grid_xy_all_times, n_row, n_col, n_times, 2);
