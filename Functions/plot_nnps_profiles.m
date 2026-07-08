function [NNPS,f] = plot_nnps_profiles(Z_uni, pixelSize_mm, mAsVals, systemName, showFigure, subROI_size)
%--------------------------------------------------------------------------
% plot_nnps_profiles
%
% Estimates and displays the one-dimensional normalized noise power
% spectrum (NNPS) obtained from homogeneous calibration images acquired at
% different exposure levels.
%
% The NNPS is estimated independently for each exposure condition using the
% methodology implemented in NPS_FAB. The resulting one-dimensional spectra
% are displayed on a logarithmic scale to facilitate comparison between
% exposure levels.
%
% INPUTS
%
%   Z_uni          : Stack of homogeneous calibration images
%
%   pixelSize_mm   : Detector pixel size [mm]
%
%   mAsVals        : Tube current-time product values (mAs)
%
%   systemName     : 'Siemens' or 'GE'
%
%   showFigure     : true  -> display NNPS curves
%                    false -> do not display figures
%
%   subROI_size    : Sub-ROI size used for NNPS estimation (default = 128)
%
% OUTPUTS
%
%   NNPS           : Radial NNPS for every exposure condition
%
%   f              : Spatial-frequency vector (mm^-1)
%
%--------------------------------------------------------------------------

if nargin < 5
    showFigure = true;
end

if nargin < 6
    subROI_size = 128;
end

%% ------------------------------------------------------------------------
% Standard colors
% -------------------------------------------------------------------------

colorGE      = [0.0000 0.4470 0.7410];
colorSiemens = [0.8500 0.3250 0.0980];

if strcmpi(systemName,'Siemens')

    lineColor = colorSiemens;
    fMin = 3e-7;
    fMax = 1e-4;

else

    lineColor = colorGE;
    fMin = 3e-8;
    fMax = 2e-6;

end

%% ------------------------------------------------------------------------
% Marker styles
% -------------------------------------------------------------------------

markers = {'o','s','^','d','v'};

%% ------------------------------------------------------------------------

[Mroi,Nroi] = size(img_det);
count = 0;

PSD = [];

for i = 1:step:(Mroi-subROI_size+1)

    for j = 1:step:(Nroi-subROI_size+1)

        count = count+1;

        Sub_ROI = img_det(...
            i:i+subROI_size-1,...
            j:j+subROI_size-1);

        Sub_ROI = Sub_ROI - mean(Sub_ROI(:));

        PSD(:,:,count) = abs(fft2(Sub_ROI)).^2;

    end

end

%% Ensemble average

psd = (pixelSize_mm^2 / numel(Sub_ROI)) * mean(PSD,3);
NNPS = psd / L^2;

%% ------------------------------------------------------------------------
% Display results
% -------------------------------------------------------------------------

if showFigure

    figure(...
        'Color','w',...
        'Units','centimeters',...
        'Position',[11.8798    3.4925   12.5412    9.2075]);

    hold on
    box on
    grid on

    h = gobjects(length(mAsVals),1);

    ind = find(f>=1,1);

    for k = 1:length(mAsVals)

        h(k)=semilogy(...
            f(ind:3:end),...
            NNPS(1,ind:3:end,k),...
            '-',...
            'Color',lineColor,...
            'LineWidth',1.5,...
            'Marker',markers{k},...
            'MarkerIndices',1:length(f(ind:3:end)),...
            'MarkerFaceColor',lineColor,...
            'MarkerEdgeColor','k',...
            'MarkerSize',5);

    end

    xlabel('Spatial frequency (mm^{-1})')

    ylabel('NNPS')

    axis([1 round(max(f)) fMin fMax])

    legend(...
        flipud(h),...
        flipud(compose('%d mAs',mAsVals(:))),...
        'Location','northeast',...
        'Box','on')

    set(gca,...
        'YScale','log',...
        'FontSize',11,...
        'LineWidth',1.2,...
        'GridAlpha',0.20)

end

end