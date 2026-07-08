function [snrMap, snrPA] = EvalSNR(Img,filSize)
%snrMap -> Mapa de SNR para cada projeção (com bordas removidas)
%snrPA -> SNR referente ao profile Postero-Anterior
% Definido aqui para facilitar o cálculo do corte
h = fspecial('average', filSize);

mean_mAs = imfilter(Img(:,:,:), h, 'symmetric');
mean_mAs2 = imfilter(Img(:,:,:).^2, h, 'symmetric');
var_mAs = mean_mAs2 - mean_mAs.^2;

% SNR calculation completo
snrMapFull = squeeze(mean_mAs ./ sqrt(var_mAs));

% --- CORTE DO PADDING ---
% Calcula quantos pixels da borda estão "contaminados"
border = floor(filSize / 2); 

% Remove as bordas de todas as projeções (ajusta as dimensões X e Y)
% Mantém a terceira dimensão (projeções) intacta
snrMap = snrMapFull(border+1:end-border, border+1:end-border, :);
% ------------------------

% Se você quiser o snrPA baseado apenas na área válida:
snrPA = mean(snrMap(:,:), 1);

end