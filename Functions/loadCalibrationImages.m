function [Z_real, info] = loadCalibrationImages(dataDir, System,mAsVals,kVpVals,rls_selected)
%--------------------------------------------------------------------------
% loadCalibrationImages
%
% Loads calibration (flat-field) images acquired at different mAs values.
%
% INPUTS:
%   dataDir : base directory containing the calibration folders
%   mAsVals : vector with mAs values (e.g. [18 25 36 50 100])
%
% OUTPUTS:
%   Cal  : calibration image stack (H x W x N), double
%   info : cell array with DICOM metadata for each image
%--------------------------------------------------------------------------

nImg = numel(mAsVals);
info = cell(nImg,1);

for k = 1:nImg

    % Folder corresponding to current mAs
    folderName = fullfile(dataDir, [System '\' num2str(kVpVals) 'kVp_' num2str(mAsVals(k)) 'mAs']);
    fileList = dir(folderName);

    % Remove directories and hidden files
    fileList = fileList(~[fileList.isdir]);

    if isempty(fileList)
        error('No DICOM files found in folder: %s', folderName);
    end

    % Read first DICOM file
    filePath = fullfile(folderName, fileList(rls_selected).name);
    info{k} = dicominfo(filePath);

    if strcmpi(info{k}.ImageLaterality,'R')

        img = flip(double(dicomread(info{k})),2);
    else
        img = double(dicomread(info{k}));
    end

    if k == 1
        [H,W] = size(img);
        Z_real = zeros(H, W, nImg);
    end

    Z_real(:,:,k) = img;

end

end
