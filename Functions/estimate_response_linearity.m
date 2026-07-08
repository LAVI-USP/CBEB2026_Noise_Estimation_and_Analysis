function [g,tau, mu, current] = estimate_response_linearity(Z, info, roiSize, roiDistCW,showFigure)
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
    % DAK_uGy(k) = info{k}.EntranceDoseInmGy;
end

% Linear regression: \mu versus exposure(mAs)
p = polyfit(current, mu, 1);
%p = polyfit(DAK_uGy, E_ROI, 1);

g = p(1);
tau = p(2);


%% Plot detector response

if showFigure

    figure(...
        'Color','w',...
        'Units','centimeters',...
        'Position',[2 2 11 8]);
    hold on;
    box on;
    grid on;

    scatter(current,...
        mu,...
        70,...
        'filled',...
        'MarkerFaceColor',[0 0.4470 0.7410],...
        'MarkerEdgeColor','k');

    xFit = linspace(min(current),max(current),200);

    yFit = polyval(p,xFit);

    plot(xFit,...
        yFit,...
        '--',...
        'Color',[0 0.4470 0.7410],...
        'LineWidth',2);

    xlabel('Exposure (mAs)')
    ylabel('Mean pixel value, $\mu$','Interpreter','latex')

    title('Detector response linearity')

    set(gca,...
        'FontSize',12,...
        'LineWidth',1.2)

end
end
