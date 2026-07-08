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

% Second-order polynomial fit: Var_ROI versus (E_ROI - tau)
P2 = polyfit(mu_l,sigma2_var,2);

% Structural noise standard deviation
xi_s = sqrt(P2(1));

% Quantum noise variance
xi_q = (P2(2));

% Electronic noise standard deviation
xi_e = sqrt(P2(3));

%% Plot figures

if showFigure

    figure('Color','w',...
           'Units','centimeters',...
           'Position',[2 2 11 8]);

    hold on
    box on
    grid on

    scatter(mu_l,...
            sigma2_var,...
            70,...
            'filled',...
            'MarkerFaceColor',[0 0.4470 0.7410],...
            'MarkerEdgeColor','k');

    xFit = linspace(min(mu_l),max(mu_l),300);

    yFit = polyval(P2,xFit);

    plot(xFit,...
         yFit,...
         '--',...
         'LineWidth',2,...
         'Color',[0 0.4470 0.7410]);

    xlabel('Linearized mean pixel value, \mu_l')
    ylabel('Sample variance')

    set(gca,...
        'FontSize',11,...
        'LineWidth',1.2)

end

end
