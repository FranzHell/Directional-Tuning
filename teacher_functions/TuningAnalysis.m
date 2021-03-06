% TuningAnalysis
%
%
% Exemplary analysis of single neuron spike rate tuning in a fixed 
% time interval. Plots tuning curve and tuning vector, calculates signal to
% noise ration SNR (see EX_snr.m).
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
close all;

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

for dir = 1:6
[t,j] = find(full(SparseFormat.Data{dir}));

datal{dir} = full(SparseFormat.Data{dir});
data = full(SparseFormat.Data{dir});
figure(2+length(list)*2);
subplot(6,1,dir)
EX_dotdisplay(data,TimeUnitsMS);
figure(1+length(list)*2);
subplot(6,1,dir)
plot(t,j,'.','color','k')
figure(3+length(list)*2)
subplot(6,1,dir)
EX_psth(data,TimeUnitsMS,20)
end


% define analysis window
wMS=[800 1200];

% 0. assign variables
TimeUnitsMS=SparseFormat.TimeResolutionMS;
w=floor(wMS/TimeUnitsMS);
w(1)=w(1)+1;
TMS=diff(wMS);

% spike count
dir_idx=[];
rate=[];
for dir=1:6;
    Rate{dir}=sum(full(SparseFormat.Data{dir}(w(1):w(2),:)),1)/TMS*1000;
    rate=[rate;Rate{dir}'];
    dir_idx=[dir_idx;ones(size(Rate{dir},2),1)*dir];
    MeanRate(dir)=mean(Rate{dir});
    %x=[x;Rate{dir}'-MeanRate(dir)];
end

snr=EX_snr(dir_idx,rate);
disp(['Signal To Noise Ratio (SNR) is : ',num2str(snr,3)])

% we have 6 directions defined as direction 1 through 6
directions=[1,2,3,4,5,6];
% define polar coordinates in radian (Bogenmass) for the 6 directions
theta=(directions-1)./6*2*pi;
% transform to cartesian coordinates for compass plot
[x,y]=pol2cart(theta,MeanRate);
% voctorial sum
X=sum(x);
Y=sum(y);

% ------------------------------------------------------
% Figure
figure(27*i)
set(gcf,'name',SparseFormat.InputFileName)
% tunig curve
subplot(2,2,1)
set(gca,'box','on')
set(gca,'xtick',[directions,directions(end)+1])
set(gca,'xtickl',[directions,directions(1)])
xlabel('Direction')
ylabel('Rate  (1/s)')
title('Tuning Curve')
hold on
% plot rate for individual trials for all directions
for dir=1:6
    plot(dir,Rate{dir},'.','color','k')
end
% repeat 1 direction = 0 degree at  360 degree 
plot(7,Rate{1},'.','color','k')
% plot mean rates in blue
pl=plot([directions,directions(end)+1],[MeanRate,MeanRate(1)], ...
    '.-','color','b','linew',2);
legend(pl,['SNR = ',num2str(snr,3)]);

% compass plot
hold off

subplot(2,2,2);

pol=polar(0,max(MeanRate));

title('Vector Plot')
hold on
pa=patch(x,y,[.7 .7 .7]);
set(pa,'edgec',[.7 .7 .7])
alpha(0.5);
c1=compass(x,y);
set(c1,'color','k','linew',1);
c2=compass(X,Y);
set(c2,'color','b','linew',2);


%
axes
set(gca,'vis','off','pos',[0 0 1 1])
set(gca,'xlim',[0 1],'ylim',[0 1])
text(0.5,1,[SparseFormat.InputFileName,' ',SparseFormat.CutTriggerNames],'vert','top','horiz','cent','fontw','b');

print -dpdf -loose TuningCurveExample.pdf
end
