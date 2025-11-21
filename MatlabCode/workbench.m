%Input：Point cloud of cylindrical pile foundation reference plane (P_baseline); Reconstructed PCD (P_biof); Radius of pile (Baseline_radius)

%Output: Fouling average thickness (Biof_thickness_average); Fouling max thickness (Biof_thickness_max); 
% Fouling area (Biof_area); Fouling volume (Biof_volume); Matrix A (Fouling thickness, z).

%Function: Segment Fouling PCD from Reconstructed PCD (P_biof), and then use cylindrical downsampling algorithm 
%for feature extraction (Biof_thickness_average, Biof_thickness_max, et al).

%note: the threhold of angular resolution and height resolution can impact
%the results of biofouling area and volume, so we need to choose
%appropriate value based on multi-try.

% Input:
P_biof = load('G:\LaboratoryTestData-txt\S2-reg-9.15.txt');
P_baseline = load('G:\S2-baseline-real.txt');
Baseline_radius = 0.0995;%radius of the pile
angle_res = 1;   % angular resolution
height_res = 0.01; % height resolution
angle_res = (angle_res*2*pi)/360; % radian system-bsaed angle resolution

% Algorithm segment Fouling PCD from Reconstructed PCD (P_biof), and then use cylindrical downsampling algorithm 
% for feature extraction (Biof_thickness_average, Biof_thickness_max, et al).
[ExtractedBiofFeature, A] = Reconstruction3DPCDProgress_new(P_baseline, P_biof, Baseline_radius, angle_res, height_res);

% draw the picture of PCD P_biof 
figure;
scatter3(P_biof(:,1), P_biof(:,2), P_biof(:,3), 3, P_biof(:, 4:6)/255, 'filled');
hold on;
scatter3(P_baseline(:,1), P_baseline(:,2), P_baseline(:,3), 1, P_baseline(:, 4:6)/255, 'filled');
axis equal;
title('P-reconstruction');

% save the matrix [Biof_thickness_average, Biof_thickness_max, et al].
save('G:\Outputdata-outdoor\Results.txt', 'A', '-ascii');