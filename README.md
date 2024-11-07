# Quantification of tissue velocity gradient for tracked cell
Tested on ![MATLAB](https://img.shields.io/badge/MATLAB-R2020a-blue.svg)

## Input Data:
- **handCorrection.tif/.png**
  - A segmented mask from the first time point, generated using Tissue Analyzer.
  - Used to extract cell height and width information for grid partitioning.
- **centroid_data.mat**
  - Contains a variable named `centroids`, which holds the coordinates for the centroids of all tracked cells across all time points.
  - Size of `centroids`: (number of cells) x (number of time points) x 2
    - `centroids(i_cell, j_time, 1)` for x-coordinate
    - `centroids(i_cell, j_time, 2)` for y-coordinate

*Ensure that all input files are located in the same directory.*


## Execution
Run the script [`calculate_velocity_gradient.m`](src/calculate_velocity_gradient.m) to begin the calculation.


## Output Data
- Two CSV Files:
  - Instantaneous and average velocity gradients for $\frac{dv_x}{dy}$.
  - Instantaneous and average velocity gradients for $\frac{dv_y}{dx}$.
