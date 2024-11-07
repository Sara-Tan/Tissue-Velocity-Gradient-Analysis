function [cell2grid_assignment, n_row, n_col, sq_xy_t0] = ...
    velo_grad_helper__create_partition(centroids, height, width)
% Helper function to create partition

%% Compute number of rows and columns based on inputs
[x_min, x_max] = bounds(centroids(:,1,1));
[y_min, y_max] = bounds(centroids(:,1,2));
x_bound = round([x_min, x_max] + [-2, 2]);
y_bound = round([y_min, y_max] + [-2, 2]);

n_col = round(diff(x_bound) / width);
n_row = round(diff(y_bound) / height);


%% Compute coordinates for the partitions
sq_corner_xs = linspace(x_bound(1), x_bound(2), n_col+1);
sq_corner_ys = linspace(y_bound(1), y_bound(2), n_row+1);

[Xs, Ys] = meshgrid((sq_corner_xs(1:end-1) + sq_corner_xs(2:end))/2, ...
    (sq_corner_ys(1:end-1) + sq_corner_ys(2:end))/2);
Xs = Xs(:);
Ys = Ys(:);
sq_xy_t0 = [Xs, Ys];


%% Compute the cell-to-grid assignment
delta_x = sq_corner_xs(2) - sq_corner_xs(1);
delta_y = sq_corner_ys(2) - sq_corner_ys(1);

get_index = @(xy) n_row * (floor((xy(:,1) - sq_corner_xs(1)) / delta_x)) + ...
    (floor((xy(:,2) - sq_corner_ys(1)) / delta_y)+1);

tmp_check_for_get_index = get_index(sq_xy_t0);
assert(all(tmp_check_for_get_index' == 1:(n_row*n_col)))

cell2grid_assignment = get_index(squeeze(centroids(:,1,:)));
