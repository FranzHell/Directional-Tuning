% Time resolved tuning
% Exemplary analysis of single neuron spike 
%
%
% - assumes data mat file to be loaded; 
% - expects struct 'SparseFormat' to exist
%
% (0) Dec 30, 2005
%
% nawrot@neurobiologie.fu-berlin.de
% addpath('./m_functions')

clear all;
list = {
'E:\data analysis course\nawrot_data_selected\data_selected\joe097-5-C3-MO.mat';
'E:\data analysis course\nawrot_data_selected\data_selected\joe108-4-C3-MO.mat';
'E:\data analysis course\nawrot_data_selected\data_selected\joe108-7-C3-MO.mat';
'E:\data analysis course\nawrot_data_selected\data_selected\joe147-1-C3-MO.mat';
'E:\data analysis course\nawrot_data_selected\data_selected\joe151-1-C3-MO.mat';

}
for i=1:length(list)
load(cell2mat(list(i)))
TimeUnitsMS=SparseFormat.TimeResolutionMS;

% Paramters of Analysis:
TMS=2000;
WindowWidthMS=100;

% 0. assign variables
TimeUnitsMS=SparseFormat.TimeResolutionMS;
T=TMS/TimeUnitsMS;

% 1. construct avg spike train for each direction and std
for dir=1:6;
    TrialAverage(:,dir)=mean(full(SparseFormat.Data{dir}(1:T,:)),2);
end
Tmax=size(TrialAverage,1);
TMSmax=Tmax*TimeUnitsMS;

% 2. perform moving window average for each direction
%[F,t]=EX_boxcar(TrialAverage,TimeUnitsMS,WindowWidthMS);

% 3. measure time resolved signal to noise SNR
% - needs moving average for all trials and direction
MeanSubtractedRates = [];
for dir = 1:6
    % estimate single trial rates
    [R{dir},t] = EX_boxcar(full(SparseFormat.Data{dir}(1:T,:)),TimeUnitsMS,WindowWidthMS);
    % trial averaged rate
    F(:,dir) = mean(R{dir},2);
    MeanSubtractedRates = [MeanSubtractedRates, R{dir}-repmat(F(:,dir),1,size(R{dir},2))];
end
% signal to noise
signal = var(F,[],2); 
noise = var(MeanSubtractedRates,[],2);
SNR = signal./noise;

t = t+SparseFormat.CutIntervalMS(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure
figure(127*i)

pos_a = [0.1 0.7 0.7 0.23]
pos_b = [0.1 0.4 0.7 0.23]
pos_c = [0.1 0.1 0.7 0.23]
% color map direction / time
ax1 = axes
set(ax1,'pos',pos_a)
%pos = get(gca,'position');
set(gca,'xlim',[0 TMSmax]+SparseFormat.CutIntervalMS(1),'ylim',[.5 6.5])
set(gca,'box','on')
set(gca,'color',[.8 .8 .8])
ylabel('Direction')
title (['T = ',num2str(WindowWidthMS),'ms']);
hold on
imagesc(t,1:6,F')
% color bar
cb=colorbar
axes(cb)
ylabel('Rate (1/s)')
% rescale axes
set(ax1,'pos',pos_a)

% signal and noise
ax2 = axes;
set(ax2,'pos',pos_b)
set(gca,'xlim',[0 TMSmax]+SparseFormat.CutIntervalMS(1))
set(gca,'box','on')
ylabel('Variance (1/s^2)')
hold on
l = line([0 0],get(gca,'ylim'),'color',[.6 .6 .6],'linew',2);
sig = plot(t,signal);
noi = plot(t,noise,'k');
legend([sig,noi],{'signal','noise'})

% SNR
ax3 = axes
set(ax3,'pos',pos_c)
set(gca,'xlim',[0 TMSmax]+SparseFormat.CutIntervalMS(1))
set(gca,'box','on')
xlabel('Time (ms)')
ylabel('SNR')
hold on
plot(t,SNR)
l = line([0 0],get(gca,'ylim'),'color',[.6 .6 .6],'linew',2);
legend(l,SparseFormat.CutTriggerNames)

print -dpdf -loose TimeResolvedAnalysisExample.pdf
end

