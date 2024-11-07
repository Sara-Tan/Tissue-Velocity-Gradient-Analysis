function draw_cell_ids_on_image(image_path, xy_coordinates, is_stack_image, colour_map_func)
% Draw/overlay cell ids on image for visualisation.
%

%% Check input
if ~exist(image_path, 'file')
    disp('Invalid image path!')
    return
end
if ~exist('is_stack_image', 'var')
    is_stack_image = false;
end
if ~exist('colour_map_func', 'var')
    colour_map_func = @lines;
end
if ~is_stack_image
    % Reshape data to support all use cases
    assert(ndims(xy_coordinates) == 2)
    xy_coordinates = reshape(xy_coordinates, [], 1, 2);
end

assert(ndims(xy_coordinates) == 3)
assert(size(xy_coordinates, 3) == 2)

n_times = size(xy_coordinates, 2);
n_cells = size(xy_coordinates, 1);

if is_stack_image
    % Check image dimensions
    assert(n_times > 1)
    assert(n_times == numel(imfinfo(image_path)))
end


%% Process image
% Initialise variables
[working_dir, name_prefix, ~] = fileparts(image_path);
result_image_path = fullfile(working_dir, [name_prefix '-cell_ids.tif']);
fig = figure;
fig.WindowState = 'maximized';
fig.ToolBar = 'none';
cmap = colour_map_func(n_cells);

for i_time = 1:n_times
    pcp_img = imread(image_path, i_time);
    hold off
    imshow(pcp_img,[])
    % resize image to maximise output quality
    fig.WindowState = 'maximized';
    hold on
    
    for j_cell = 1:n_cells
        centroid = squeeze(xy_coordinates(j_cell, i_time, :));
        plot(centroid(1), centroid(2), '*', 'Color', cmap(j_cell, :));
        h = text(centroid(1) + 2, centroid(2) + 3, num2str(j_cell));
        set(h,'Color',cmap(j_cell, :) ,'FontSize',10,'FontWeight','bold');
    end
    
    im_data = frame2im(getframe(fig));
    if i_time == 1
        % Create/overwrite image for first timepoint
        imwrite(im_data, result_image_path, 'compression', 'none')
    else
        imwrite(im_data, result_image_path, 'WriteMode', 'append', 'compression', 'none')
    end
end
