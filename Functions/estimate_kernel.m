function [K_N, psd] = estimate_kernel(Z_uni,pixelSize_mm,showFigure)
%--------------------------------------------------------------------------
% estimate_kernel
%
% Estimates the normalized spatial correlation kernel from homogeneous
% calibration images.
%
% The kernel is estimated from the image acquired at the Automatic Exposure
% Control (AEC) level (4th acquisition), since the spatial correlation
% properties are assumed to be independent of exposure.
%
% A homogeneous ROI of 100 × 100 mm is selected according to the EUREF
% quality control protocol. The ROI is detrended, divided into overlapping
% 256 × 256 sub-ROIs (50% overlap), and the ensemble-averaged power
% spectral density (PSD) is used to estimate the normalized spatial
% correlation kernel.
%
% INPUTS
%
%   Z_uni          : Stack of homogeneous calibration images
%                    (rows × cols × number_of_images)
%
%   pixelSize_mm   : Detector pixel size [mm]
%
%   showFigure     : Logical variable
%                    true  -> display estimated kernel
%                    false -> no figure (default)
%
% OUTPUTS
%
%   K_N            : Normalized spatial correlation kernel
%
%   psd            : Two-dimensional power spectral density (AEC image)
%
% NOTE
%
% According to the acquisition protocol adopted in this toolbox, the fourth
% calibration image corresponds to the Automatic Exposure Control (AEC)
% acquisition.
%--------------------------------------------------------------------------

if nargin < 3
    showFigure = false;
end

%% ------------------------------------------------------------------------
% ROI definition
% -------------------------------------------------------------------------

roiSize_mm = 100;
roiSize_px = round(roiSize_mm/pixelSize_mm);

[M,N,~] = size(Z_uni);

row0 = round(M/2)-floor(roiSize_px/2);
col0 = round(N/2)-floor(roiSize_px/2);

AEC_index = 4;

img_roi = Z_uni(...
    row0:row0+roiSize_px-1,...
    col0:col0+roiSize_px-1,...
    AEC_index);

%% ------------------------------------------------------------------------
% Detrending
% -------------------------------------------------------------------------

aux = dct2(img_roi);

Ncoef = 10;

mask = ([0:Ncoef]+[0:Ncoef]')>Ncoef;

aux(1:Ncoef+1,1:Ncoef+1) = ...
    aux(1:Ncoef+1,1:Ncoef+1).*mask;

img_det = idct2(aux);

%% ------------------------------------------------------------------------
% PSD estimation
% -------------------------------------------------------------------------

subROI_size = 256;

step = subROI_size/2;      % 50% overlap

[Mroi,Nroi] = size(img_det);

count = 0;

PSD = [];

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

%% ------------------------------------------------------------------------
% Ensemble-average PSD
% -------------------------------------------------------------------------

psd = (pixelSize_mm^2/numel(SubROI))*mean(PSD,3);

%% ------------------------------------------------------------------------
% Kernel estimation
% -------------------------------------------------------------------------

k = fftshift(ifft2(sqrt(psd)));

K = abs(k);

K_N = K ./ norm(K(:));

%% ------------------------------------------------------------------------
% Display results
% -------------------------------------------------------------------------

if showFigure

    f=figure(...
        'Color','w',...
        'Units','centimeters',...
        'Position',[2 2 14 14.5]);

    %% ------------------------------------------------------------
    % Kernel image
    %% ------------------------------------------------------------

    subplot(2,1,1)

    cropSize = 100;
    
    [max_val, linear_idx] = max(K_N(:)); 
    [row, ~] = ind2sub(size(K_N), linear_idx);
    center_value = row;

    imagesc(K_N)

    axis image

    colormap(gray)

    colorbar

    title('Normalized spatial correlation kernel')

    %% ------------------------------------------------------------
    % Central profile
    %% ------------------------------------------------------------

    subplot(2,1,2)

    profile = K_N(center_value,:);

    x = -size(K_N,1)/2:size(K_N,1)/2 - 1;

    fitKernel = fit(x',profile','gauss1');

    xfit = linspace(min(x),max(x),2000);

    plot(x,...
        profile,...
        'o',...
        'MarkerFaceColor',[0 0.4470 0.7410],...
        'MarkerEdgeColor','k',...
        'MarkerSize',4);

    hold on

    plot(xfit,...
        fitKernel(xfit),...
        '--',...
        'Color',[0 0.4470 0.7410],...
        'LineWidth',2);

    grid on
    box on

    xlabel('Pixel')
    ylabel('Normalized amplitude')

    xlim([-5 5])
    ylim([0 1.00])

    set(gca,...
        'FontSize',11,...
        'LineWidth',1.2)

end

end