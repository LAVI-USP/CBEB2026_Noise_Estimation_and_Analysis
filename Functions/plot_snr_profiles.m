function [snrPA] = plot_snr_profiles(Z_uni, mAsVals, pixelSize_mm, systemName, windowSize)
%--------------------------------------------------------------------------
% plot_snr_profiles
%
% Computes and displays posterior-anterior (PA) signal-to-noise ratio (SNR)
% profiles from homogeneous calibration images acquired at different
% exposure levels.
%
% Local SNR maps are estimated using a sliding-window approach. The SNR
% values are averaged along the detector width to obtain a one-dimensional
% posterior-anterior (PA) profile. All profiles are normalized by the
% maximum SNR value among all exposure conditions.
%
% INPUTS
%
%   Z_uni          : Stack of homogeneous calibration images
%                    (rows × cols × number_of_images)
%
%   mAsVals        : Exposure levels (mAs)
%
%   pixelSize_mm   : Detector pixel size [mm]
%
%   systemName     : Detector manufacturer
%                    ('Siemens' or 'GE')
%
%   windowSize     : Sliding-window size (pixels)
%                    (default = 32)
%
% OUTPUTS
%
%   snrPA          : Posterior-anterior SNR profiles
%
%--------------------------------------------------------------------------

if nargin < 5
    windowSize = 32;
end

%% ------------------------------------------------------------------------
% Colors
% -------------------------------------------------------------------------

colorGE      = [0.0000 0.4470 0.7410];
colorSiemens = [0.8500 0.3250 0.0980];

if strcmpi(systemName,'Siemens')
    lineColor = colorSiemens;
else
    lineColor = colorGE;
end

%% ------------------------------------------------------------------------
% Markers
% -------------------------------------------------------------------------

markers = {'o','s','^','d','v'};

%% ------------------------------------------------------------------------
% Estimate PA-SNR profiles
% -------------------------------------------------------------------------

for d = 1:size(Z_uni,3)

    [~,snrPA(:,:,d)] = EvalSNR( ...
        Z_uni(:,:,d),...
        windowSize);

end

snrMax = max(snrPA(:));

%% ------------------------------------------------------------------------
% Create figure
% -------------------------------------------------------------------------

figure(...
    'Color','w',...
    'Units','centimeters',...
    'Position',[11.8798    3.4925   13.7319   10.0542]);

hold on
box on
grid on

%% ------------------------------------------------------------------------
% Plot SNR profiles
% -------------------------------------------------------------------------

x = (1:size(snrPA,2))*pixelSize_mm;

h = gobjects(length(mAsVals),1);

for d = 1:length(mAsVals)

    h(d) = plot(...
        x(1:3:end-49),...
        snrPA(1,50:3:end,d)./snrMax,...
        '-',...
        'Color',lineColor,...
        'LineWidth',1.5,...
        'Marker',markers{d},...
        'MarkerIndices',50:50:length(x)-50,...
        'MarkerFaceColor',lineColor,...
        'MarkerEdgeColor','k',...
        'MarkerSize',6);

end

%% ------------------------------------------------------------------------
% Figure properties
% -------------------------------------------------------------------------

xlabel('Distance from chest wall (mm)')

ylabel('Normalized SNR')

axis([0 190 0.15 1.35])

legend(...
    flipud(h),...
    flipud(compose('%.1f mAs',mAsVals(:))),...
    'Location','northeast',...
    'Box','on');

set(gca,...
    'FontSize',12,...
    'LineWidth',1.2,...
    'GridAlpha',0.20)
