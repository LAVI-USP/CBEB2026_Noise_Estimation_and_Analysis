function [g,tau, mu, current,In_mGy] = estimate_response_linearity(Z, info, roiSize, roiDistCW,showFigure)
%--------------------------------------------------------------------------
% estimate_response_linearity
%
% Estimates the detector response linearity from homogeneous calibration
% images acquired at different exposure levels. The detector offset (tau)
% is obtained as the intercept of a linear regression between the mean
% pixel value measured within a homogeneous ROI and the tube current-time
% product (mAs).
%
% The selected ROI follows the EUREF quality control protocol, consisting
% of a square region located near the chest wall in a homogeneous area of
% the detector.
%
% INPUTS
%   Z         : Stack of homogeneous calibration images
%               (rows × cols × number_of_images)
%
%   info      : Cell array containing the acquisition metadata for each
%               image. The following fields are required:
%                   - ExposureInuAs
%                   - EntranceDoseInmGy (optional)
%
%   roiSize   : ROI size in pixels
%
%   roiDistCW : Distance from the chest wall to the left border of the ROI
%               (pixels)
%
%   showFigure : Logical variable.
%                true  -> plot quadratic regression
%                false -> no figure (default)
%
% OUTPUTS
%   g         : Estimated detector gain (pixel value/mAs)
%
%   tau       : Estimated detector offset (pixel value)
%
%   mu     : Mean pixel value (\mu) measured within the ROI for each exposure
%
%   current   : Tube current-time product (mAs) corresponding to each image
%
% NOTE
% The current implementation estimates the detector response using mAs as
% the exposure metric. If detector air kerma (DAK) measurements are
% available, the regression can be performed using DAK instead by replacing
% the regression variable.
%--------------------------------------------------------------------------

if nargin < 5
    showFigure = false;
end

nImg = size(Z,3);
mu = zeros(nImg,1);
current = zeros(nImg,1);

for k = 1:nImg
    img = Z(:,:,k);

    roi = img( ...
        floor(end/2)-roiSize/2+1 : floor(end/2)+roiSize/2, ...
        1+roiDistCW : roiDistCW + roiSize );

    mu(k) = mean(roi(:));
    current(k) = info{k}.ExposureInuAs / 1000; % uAs -> mAs
    % Uncomment if DAK is available
    In_mGy(k) = info{k}.EntranceDoseInmGy;
end

%% Linear regression

% Convert to column vectors
current = current(:);
In_mGy = In_mGy(:);
mu = mu(:);

% Linear model:
% mu = g * current + tau

%mdl = fitlm(current,mu);
mdl = fitlm(In_mGy,mu);

%% Detector gain and offset

g   = mdl.Coefficients.Estimate(2);
tau = mdl.Coefficients.Estimate(1);

%% Goodness of fit

R2 = mdl.Rsquared.Ordinary;

%% 95% confidence intervals

CI_all = coefCI(mdl,0.05);

% Row 1 = intercept (tau)
% Row 2 = slope (g)

CI.tau = CI_all(1,:);
CI.g   = CI_all(2,:);

%% Display

fprintf('\n');
fprintf('=============================================\n');
fprintf('Detector Response Linearity\n');
fprintf('=============================================\n');

fprintf('Gain (g)      = %.4f gray-levels/mGy\n',g);
fprintf('95%% CI        = [%.4f, %.4f]\n',CI.g(1),CI.g(2));

fprintf('Offset (tau)  = %.4f gray-levels\n',tau);
fprintf('95%% CI        = [%.4f, %.4f]\n',CI.tau(1),CI.tau(2));

fprintf('R^2           = %.5f\n',R2);
fprintf('\n');


%% Plot

if showFigure

    figure('Color','w',...
        'Position',[250 285 477 365]);

    hold on
    box on
    grid on

    scatter(In_mGy,mu,...
        55,...
        'filled',...
        'MarkerEdgeColor','k');

    xfit = linspace(min(In_mGy),max(In_mGy),200);
    yfit = predict(mdl,xfit');

    plot(xfit,yfit,...
        'k-',...
        'LineWidth',1.5);

    xlabel('Tube current-time product (mAs)')
    ylabel('Mean pixel value')

    set(gca,...
        'FontSize',12,...
        'LineWidth',1.2)

end

end