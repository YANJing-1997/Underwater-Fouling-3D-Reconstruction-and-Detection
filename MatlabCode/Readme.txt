if you want to segment the fouling PCD from reconstructed PCD and calculate the fouling feature, you can open the "workbench" file based on MATLAB.

Algorithm: Reconstruction3DPCDProgress_new
Input: Point cloud of cylindrical pile foundation reference plane (P_baseline); Reconstructed PCD (P_biof); Radius of pile (Baseline_radius)
Output: Fouling average thickness (Biof_thickness_average); Fouling max thickness (Biof_thickness_max); Fouling area (Biof_area); Fouling volume (Biof_volume); Matrix A (Fouling thickness, z).
Function: Segment Fouling PCD from Reconstructed PCD (P_biof), and then use cylindrical downsampling algorithm for feature extraction (Biof_thickness_average, Biof_thickness_max, et al).