function header_and_data = dlmcell_for_labelled_data(...
    filename, data, header_1_1_label, col_label, row_label)
% Wrapper of dlmcell to include column and row labels

%% Check inputs
if ~exist('col_label', 'var')
    col_label = '';
end
if ~exist('row_label', 'var')
    row_label = '';
end


%% Compile the data for dlmcell
header_and_data = cell(size(data,1)+1, size(data,2)+1);
header_and_data(2:end,2:end) = data;
header_and_data{1,1} = header_1_1_label;

if ~isempty(col_label)
    if ~iscell(col_label)
        col_label = num2cell(col_label);
    end
    header_and_data(1, 2:end) = col_label;
end

if ~isempty(row_label)
    if ~iscell(row_label)
        row_label = num2cell(row_label);
    end
    header_and_data(2:end, 1) = row_label;
end

dlmcell(filename, header_and_data, ',')
