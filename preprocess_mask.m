function [final_mask_img, cell_labels_img, num_cells] = preprocess_mask(mask_image_path)
% Prepare the mask (handCorrection from Tissue Analyzer) for subsequent analysis

mask_img = imread(mask_image_path);
% Convert image to binary
if ndims(mask_img) == 3
    mask_img = rgb2gray(mask_img);
    mask_img = imbinarize(mask_img);
else
    mask_img = imbinarize(mask_img);
end

% Deal with segmented mask border from TA
mask_img = padarray(mask_img(2:end-1,2:end-1),[1 1], 'replicate', 'both');
diag_dil = bwmorph(mask_img,'diag');

% Label all connected components
img_dist = bwdist(~diag_dil);
img_seg = watershed(img_dist);
final_mask_img = img_seg == 0;
img_inv = ~final_mask_img;
clear_im = imclearborder(img_inv,8);
[cell_labels_img,num_cells] = bwlabel(clear_im,8);
