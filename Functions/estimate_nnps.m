function [NNPS_radial,freq,NNPS] = estimate_nnps(Z_uni,mAsVals,pixelSize_mm,systemName)
%--------------------------------------------------------------------------
% estimate_nnps
%
% Estimates the normalized noise power spectrum (NNPS) from homogeneous
% calibration images.
%
% The NNPS is estimated independently for every exposure condition using a
% homogeneous ROI selected according to the EUREF quality control protocol.
% The selected ROI is detrended, divided into overlapping 256×256 sub-ROIs
% (50% overlap), and the ensemble-averaged power spectral density (PSD) is
% normalized by the square of the mean signal.
%
% INPUTS
%
%   Z_uni          : Stack of homogeneous calibration images
%                    (rows × cols × number_of_images)
%
%   pixelSize_mm   : Detector pixel size [mm]
%
%   showFigure     : true  -> display NNPS curves
%                    false -> no figure (default)
%
% OUTPUTS
%
%   NNPS_radial    : Radially averaged NNPS for every exposure condition
%
%   freq           : Spatial-frequency vector (mm^-1)
%
%   NNPS           : Two-dimensional NNPS maps
%
%--------------------------------------------------------------------------

if nargin < 3
    showFigure = false;
end

%% ------------------------------------------------------------------------
% Colors
% -------------------------------------------------------------------------

colorGE      = [0.0000 0.4470 0.7410];
colorSiemens = [0.8500 0.3250 0.0980];

if strcmpi(systemName,'Siemens')
    lineColor = colorSiemens;    
    fMax =  4*10^-5;
    fMin =  3*10^-7;
else
    lineColor = colorGE;
    fMax = 4*10^-6;
    fMin = 3*10^-8;
end

%% ------------------------------------------------------------------------
% ROI definition
% -------------------------------------------------------------------------

roiSize_mm = 100;
roiSize_px = round(roiSize_mm/pixelSize_mm);

[M,N,NumImages] = size(Z_uni);

row0 = round(M/2)-floor(roiSize_px/2);
col0 = round(N/2)-floor(roiSize_px/2);

%% ------------------------------------------------------------------------
% Parameters
% -------------------------------------------------------------------------

subROI_size = 256;

step = subROI_size/2;      % 50% overlap

%% ------------------------------------------------------------------------
% Loop over all exposure conditions
% -------------------------------------------------------------------------

for n = 1:NumImages

    %% ------------------------------------------------------------
    % Extract homogeneous ROI
    %% ------------------------------------------------------------

    img_roi = Z_uni(...
        row0:row0+roiSize_px-1,...
        col0:col0+roiSize_px-1,...
        n);

    %% ------------------------------------------------------------
    % Mean signal
    %% ------------------------------------------------------------

    L = mean(img_roi(:));

    %% ------------------------------------------------------------
    % Detrending
    %% ------------------------------------------------------------

    aux = dct2(img_roi);

    Ncoef = 10;

    mask = ([0:Ncoef]+[0:Ncoef]')>Ncoef;

    aux(1:Ncoef+1,1:Ncoef+1) = ...
        aux(1:Ncoef+1,1:Ncoef+1).*mask;

    img_det = idct2(aux);

    %% ------------------------------------------------------------
    % PSD estimation
    %% ------------------------------------------------------------

    [Mroi,Nroi] = size(img_det);

    count = 0;

    clear PSD

    for i = 1:step:(Mroi-subROI_size+1)

        for j = 1:step:(Nroi-subROI_size+1)

            count = count+1;

            SubROI = img_det(...
                i:i+subROI_size-1,...
                j:j+subROI_size-1);

            SubROI = SubROI - mean(SubROI(:));

            PSD(:,:,count) = abs(fft2(SubROI)).^2;

        end

    end

    %% ------------------------------------------------------------
    % Ensemble-average PSD
    %% ------------------------------------------------------------

    psd = (pixelSize_mm^2/numel(SubROI))*mean(PSD,3);

    NNPS(:,:,n) = psd/L^2;

    %% ------------------------------------------------------------
    % Radial average
    %% ------------------------------------------------------------

    NNPS_shift = fftshift(NNPS(:,:,n));

    [Ny,Nx] = size(NNPS_shift);

    fx = (-Nx/2:Nx/2-1)/(Nx*pixelSize_mm);
    fy = (-Ny/2:Ny/2-1)/(Ny*pixelSize_mm);

    [Fx,Fy] = meshgrid(fx,fy);

    Fr = sqrt(Fx.^2+Fy.^2);

    df = 1/(Nx*pixelSize_mm);

    freq = (0:df:max(fx)).';

    NNPS_radial(:,n) = zeros(length(freq)-1,1);

    for k = 1:length(freq)-1

        mask = Fr>=freq(k) & ...
               Fr<freq(k+1) & ...
               Fx~=0 & ...
               Fy~=0;

        if any(mask(:))

            NNPS_radial(k,n) = mean(NNPS_shift(mask));

        else

            NNPS_radial(k,n) = NaN;

        end

    end

end

freq = freq(1:end-1);

%% ------------------------------------------------------------------------
% Plot NNPS
% -------------------------------------------------------------------------

figure(...
    'Color','w',...
    'Units','centimeters',...
    'Position',[11.8798    3.4925   13.7319   10.0542]);

%hold on
box on
grid on

markers = {'o','s','^','d','v'};

h = gobjects(length(mAsVals),1);

% Plot only frequencies above 1 mm^-1
idx = find(freq>=1,1);

for d = 1:length(mAsVals)

    h(d)=semilogy(...
        freq(idx:end),...
        NNPS_radial(idx:end,d),...
        '-',...
        'Color',lineColor,...
        'LineWidth',1.2,...
        'Marker',markers{d},...
        'MarkerFaceColor',lineColor,...
        'MarkerEdgeColor','k',...
        'MarkerSize',6,...
        'MarkerIndices',1:6:length(freq(idx:end))), hold on;


end

xlabel('Spatial frequency (mm^{-1})')
ylabel('NNPS')

set(gca,...
    'FontSize',11,...
    'LineWidth',1.2,...
    'YScale','log',...
    'GridAlpha',0.20)

xlim([1 round(max(freq))])

legend(...
    flipud(h),...
    flipud(compose('%.1f mAs',mAsVals(:))),...
    'Location','northeast',...
    'Box','on');
axis([1 round(max(freq)) fMin fMax])
grid on

set(gca,...
    'FontSize',12,...
    'LineWidth',1.2,...
    'GridAlpha',0.20)


end