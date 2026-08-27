function [xi_s,xi_q,xi_e] = estimate_xi_s_xi_q_xi_e(Z_uni, tau, roiSize, roiDistCW,showFigure)
%--------------------------------------------------------------------------
% estimate_noise_parameters
%
% Estimates the structural, quantum, and electronic noise parameters of the
% quadratic noise model from homogeneous calibration images acquired at
% different exposure levels.
%
% The estimation is based on the relationship between the sample variance
% and the linearized mean pixel value measured within a homogeneous ROI.
% According to the quadratic noise model,
%
%   sigma^2 = xi_s^2*mu_l^2 + xi_q*mu_l + xi_e^2
%
% where:
%   xi_s : structural noise parameter
%   xi_q : quantum noise parameter
%   xi_e : electronic noise parameter
%
% The sample variance is estimated from detrended images, whereas the mean
% pixel value is estimated from the original images after detector offset
% correction.
%
% INPUTS
%   Z_uni      : Stack of homogeneous calibration images
%
%   tau        : Detector offset estimated from the detector response
%
%   roiSize    : ROI size (pixels)
%
%   roiDistCW  : Distance from chest wall (pixels)
%
%   showFigure : Logical variable.
%                true  -> plot quadratic regression
%                false -> no figure (default)
%
% OUTPUTS
%   xi_s       : Structural noise parameter
%
%   xi_q       : Quantum noise parameter
%
%   xi_e       : Electronic noise parameter
%
%   mu_l       : Linearized mean pixel value for each image
%
%   sigma2_var : Sample variance for each image
%--------------------------------------------------------------------------

if nargin<5
    showFigure = false;
end

nImg = size(Z_uni,3);
mu_l = zeros(nImg,1);
sigma2_var  = zeros(nImg,1);

for k = 1:nImg
    % Remove constant offset
    img = Z_uni(:,:,k) - tau;

    % Detrending using low-frequency DCT coefficient suppression
    aux = dct2(img);
    N = 10;
    Nmask = [0:N] + [0:N]' > N;
    aux(1:N+1,1:N+1) = aux(1:N+1,1:N+1) .* Nmask;
    img_det = idct2(aux);

    % ROI for mean estimation (signal expectation)
    roi_mean = img( ...
        floor(end/2)-roiSize/2+1 : floor(end/2)+roiSize/2, ...
        1+roiDistCW : roiDistCW + roiSize );

    % ROI for variance estimation (noise)
    roi_var = img_det( ...
        floor(end/2)-roiSize/2+1 : floor(end/2)+roiSize/2, ...
        1+roiDistCW : roiDistCW + roiSize );

    mu_l(k) = mean(roi_mean(:));
    sigma2_var(k)  = var(roi_var(:));
end

%% Prepare data

mu_l = mu_l(:);
sigma2_var = sigma2_var(:);

%% Quadratic regression

mdl = fitlm(mu_l,sigma2_var,...
    'poly2');

%% Regression coefficients

% fitlm stores:
%
%   coefficient 1 -> intercept
%   coefficient 2 -> linear term
%   coefficient 3 -> quadratic term

a0 = mdl.Coefficients.Estimate(1);
a1 = mdl.Coefficients.Estimate(2);
a2 = mdl.Coefficients.Estimate(3);

%% Noise parameters

xi_e = sqrt(a0);
xi_q = a1;
xi_s = sqrt(a2);

%% Goodness of fit

R2 = mdl.Rsquared.Ordinary;

%% 95% confidence intervals

CI_all = coefCI(mdl,0.05);

% Intercept
CI.a0 = CI_all(1,:);

% Linear coefficient
CI.a1 = CI_all(2,:);

% Quadratic coefficient
CI.a2 = CI_all(3,:);

%% Confidence intervals for noise parameters

% Since xi_e = sqrt(a0) and xi_s = sqrt(a2),
% transform the confidence limits accordingly.

CI.xi_e = sqrt(CI.a0);
CI.xi_q = CI.a1;
CI.xi_s = sqrt(CI.a2);

%% Display

fprintf('\n');
fprintf('=============================================\n');
fprintf('Quadratic Noise Model\n');
fprintf('=============================================\n');

fprintf('xi_s = %.6f\n',xi_s);
fprintf('95%% CI = [%.6f, %.6f]\n',...
    CI.xi_s(1),CI.xi_s(2));

fprintf('xi_q = %.6f\n',xi_q);
fprintf('95%% CI = [%.6f, %.6f]\n',...
    CI.xi_q(1),CI.xi_q(2));

fprintf('xi_e = %.6f\n',xi_e);
fprintf('95%% CI = [%.6f, %.6f]\n',...
    CI.xi_e(1),CI.xi_e(2));

fprintf('R^2 = %.5f\n',R2);

fprintf('\n');

end