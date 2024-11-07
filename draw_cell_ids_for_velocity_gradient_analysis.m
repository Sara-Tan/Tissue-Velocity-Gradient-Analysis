function draw_cell_ids_for_velocity_gradient_analysis
% A wrapper script to draw cell_ids using an existing function

if ~exist('image_path', 'var') || ~exist(image_path, 'file')
    [image_name, image_dir] = uigetfile('*.tif;*.png', 'Select image to draw cell_ids');
    if ~ischar(image_name)
        disp('Invalid selection. Code terminating')
        return
    end
    image_path = fullfile(image_dir, image_name);
end

[working_dir, name_prefix, extension] = fileparts(image_path);
cd(working_dir)

data = load('centroid_data.mat', 'centroids');
lightness = 0.2;
draw_cell_ids_on_image(image_path, data.centroids, true, @(m) lines(m)*(1-lightness) + lightness)
