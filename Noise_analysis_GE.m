close all
clear
clc

%% Load parameters
load("Noise Parameters\GE\Parameters_GE_DM.mat")

%% Colors (used throughout the paper)

% colorStructural = [0.4940 0.1840 0.5560];   % Purple
% colorQuantum    = [0.4660 0.6740 0.1880];   % Green
% colorElectronic = [0.6350 0.0780 0.1840];   % Dark red

colorElectronic = [1 0 0];   % Red
colorQuantum    = [0.1660 0.540 0.1880];   % Verde
colorStructural = [0.4940 0.1840 0.5560];   % Roxo


%% Exposure information
roiMean = [1551.0011;
           2148.4544;
           3088.6145;
           4284.1466;
           8494.8964] - tau;

mAsVals = [18 25 36 50 100];

FIT=fit(roiMean,mAsVals','poly1');


%% Signal range
y_signal=0:20000;           
y_mAs = FIT(y_signal);

%% Mean quantum coefficient
rows = floor(size(xi_qi,1)/2) + (-49:50);
cols = 601:700;

%xi_q = mean(xi_qi(rows,cols),'all');

%% Variance of each component

varS = (xi_s^2).*y_signal.^2;
varQ = xi_q.*y_signal;
varE = xi_e^2.*ones(size(y_signal));

varTotal = varS + varQ + varE;

%% Relative contribution

relS = varS./varTotal;
relQ = varQ./varTotal;
relE = varE./varTotal;


mAsMin = 0;
mAsMax = 130;
VarMin = 0;
VarMax = 240;


%% ============================================================
%% FIGURE 1 - Relative contribution
%% ============================================================

figure('Color','w','Position',[ 120   288   464   332])

%hold on
box on


plot(y_mAs,100*relS,...
    '-',...
    'Color',colorStructural,...
    'LineWidth',2), hold on

plot(y_mAs,100*relQ,...
    '--',...
    'Color',colorQuantum,...
    'LineWidth',2)

plot(y_mAs(1:50:end),100*relE(1:50:end),...
    ':',...
    'Color',colorElectronic,...
    'LineWidth',2.5)

xlabel('Tube current-time product (mAs)')
ylabel('Fraction of total variance (%)')

legend({'Structural','Quantum','Electronic'},...
       'Location','best',...
       'Box','off')

ylim([0 100])
axis([mAsMin mAsMax 0 100])

%title('Relative Contribution of Each Noise Component')

set(gca,'FontSize',12,'LineWidth',1.2)
grid on

%% ============================================================
%% FIGURE 2 - Ratio between components
%% ============================================================

ratioQE = varQ./varE;
ratioSQ = varS./varQ;
ratioSE = varS./varE;

f=figure('Color','w','Position',[ 120   288   464   332])

box on
grid on

semilogy(y_mAs,ratioQE,...
    'k-',...
    'LineWidth',2),hold on

semilogy(y_mAs(2:end),ratioSQ(2:end),...
    'k--',...
    'LineWidth',2)

semilogy(y_mAs(1:200:end),ratioSE(1:200:end),...
    'k.',...
    'LineWidth',2)

yline(1,...
    ':',...
    'Equal Variance','FontSize',12,...
    'Color',[0.3010 0.5450 0.6330],...% Ciano
    'LineWidth',2.5);

xlabel('Tube current-time product (mAs)')
ylabel('Variance ratio')

legend({'Quantum / Electronic',...
        'Structural / Quantum',...
        'Structural / Electronic',...
        'Equal variance'},...
        'Location','northwest',...
        'Box','off')

%title('Ratio Between Noise Components')

set(gca,...
    'FontSize',12,...
    'LineWidth',1.2)

axis([mAsMin mAsMax 10^-2 10^3])


%% ============================================================
%% Transition points
%% ============================================================

[~,idxQE] = min(abs(ratioQE-1));
[~,idxSQ] = min(abs(ratioSQ(2:end)-1));
[~,idxSE] = min(abs(ratioSE-1));

fprintf('\n');
fprintf('=============================================\n');
fprintf('Noise Component Transition Points\n');
fprintf('=============================================\n');

fprintf('Quantum = Electronic : mAs = %.1f\n',y_mAs(idxQE));
fprintf('Structural = Quantum : mAs = %.1f\n',y_mAs(idxSQ+1));
fprintf('Structural = Electronic : mAs = %.1f\n',y_mAs(idxSE));

fprintf('\n');

%% ============================================================
%% Table printed in MATLAB
%% ============================================================
percS = interp1(y_signal,100*relS,roiMean);
percQ = interp1(y_signal,100*relQ,roiMean);
percE = interp1(y_signal,100*relE,roiMean);
ResultsTable = table( ...
    mAsVals(:),...
    roiMean,...
    percS,...
    percQ,...
    percE,...
    'VariableNames',{'mAs',...
                     'MeanSignal',...
                     'StructuralPercent',...
                     'QuantumPercent',...
                     'ElectronicPercent'});

disp(ResultsTable)