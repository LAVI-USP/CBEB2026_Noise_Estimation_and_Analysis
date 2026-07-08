close all; clear; clc;

%% Paths and acquisition parameters
addpath('Functions')

dataDir = 'Uniform images\';
%dataDir = 'Simulated Uniform images\';

%System = 'Siemens'; mAsVals = [4 11 20 40 80]; kVpVals = 26; pixelSize_mm = 0.083; %For Siemens systems. Obs: AEC dose = 40 mAs (Siemens)
System = 'GE'; mAsVals = [18 25 36 50 100]; kVpVals = 34; pixelSize_mm = 0.1; % For GE Pristina systems. Obs: AEC dose = 50 mAs (GE)

roiSize_mm   = 10; %This ROI location follows as described in EUREF
roiDistCW_mm = 60; %This ROI location follows as described in EUREF

roiSize_px = roiSize_mm / pixelSize_mm;
roiDistCW_px = roiDistCW_mm / pixelSize_mm;
rls_selected = 1;

plotImages = 1;

%% Load calibration images
[Z_img, info] = loadCalibrationImages(dataDir, System,mAsVals,kVpVals,rls_selected);

%% STEP 1 : Estimate gain(g) and tau
[g,tau, mu, current] = estimate_response_linearity(Z_img, info, roiSize_px, roiDistCW_px,plotImages);

%% STEP 2 : Estimate xi_s, xi_q and xi_e
[xi_s,xi_q,xi_e]= estimate_xi_s_xi_q_xi_e(Z_img, tau, roiSize_px, roiDistCW_px,plotImages);

%% STEP 3 : Estimate xi_q(i) map
[xi_qi] = estimate_xi_qi_map(Z_img,tau, xi_e, xi_s,plotImages);

%% STEP 4 : Estimate correlation kernel
[K_N, psd] = estimate_kernel(Z_img,pixelSize_mm,plotImages); 

%% PLOT PA SNR and NNPS
[snrPA] = plot_snr_profiles(Z_img, mAsVals, pixelSize_mm, System);

[NNPS_radial,freq,NNPS] = estimate_nnps(Z_img, mAsVals, pixelSize_mm,System);


if 1
    save(['Noise Parameters\' System '\Parameters_' System '_DM.mat'],'tau','xi_s','xi_q','xi_qi','xi_e','K_N')
end
