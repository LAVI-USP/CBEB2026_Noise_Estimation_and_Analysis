function [SNR_PP_ERROR,SNR_M_ERROR,CI,SNR_PA_Real,SNR_PA_Sim,SNR_Real_F,SNR_Sim_F] = eval_snr(SNR_Real,SNR_Sim,numProj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
for p=1:numProj
    [X,Y]=meshgrid(1:size(SNR_Real,2),1:size(SNR_Real,1));
    F_Real=fit([X(:),Y(:)],SNR_Real(:),'poly22');
    F_Sim=fit([X(:),Y(:)],SNR_Sim(:),'poly22');
    SNR_Real_F=F_Real(X,Y);
    SNR_Sim_F=F_Sim(X,Y);
    
    SNR_PP_ERROR(p)=100*mean2(abs(SNR_Real_F-SNR_Sim_F)./(SNR_Real_F));
end

SNR_M_ERROR=mean(SNR_PP_ERROR);
[~,~,CI] = ttest(SNR_PP_ERROR);

SNR_PA_Real = mean(SNR_Real,1)';
SNR_PA_Sim = mean(SNR_Sim,1)';

end

