clear; close all; clc
AE=load("AE.mat");
Mech=load("Mechanical.mat");
%% change
AEoff=0.0563;
Window_s=[2 8];

%% 
AE.t_s=[0:length(AE.dataAE(:,1))-1]'.*AE.dt_s+AE.t0_s-AEoff;
wnd_s=AE.t0_s+Window_s;
IDAE=find(AE.t_s>=wnd_s(1) & AE.t_s<=wnd_s(2));
IDMech=find(Mech.t_s>=wnd_s(1) & Mech.t_s<=wnd_s(2));
t_s=AE.t_s(IDAE);
AE.dataNormFilt=movmean(single(AE.dataAE)./max(single(AE.dataAE)),1);
AEsig=single(AE.dataAE((IDAE),2));
Mech.Friction=movmean(Mech.Friction,101);

figure
set(gcf,'position',[100 100 1200 400]);
plot(Mech.t_s(IDMech)-AE.t0_s,Mech.Friction(IDMech),...
    AE.t_s(IDAE)-AE.t0_s,AE.dataNormFilt(IDAE,2),...
    AE.t_s(IDAE)-AE.t0_s,AE.dataNormFilt(IDAE,3)); hold on
scatter(Mech.CamUnix_s(2)-AE.t0_s-AEoff,zeros(size(Mech.CamUnix_s(2))),30,'r','filled');
text(Mech.CamUnix_s(2)-AE.t0_s-AEoff,zeros(size(Mech.CamUnix_s(2)))-0.1,num2str(Mech.FileN(2)));
xlabel('time, s');
legend('Friction','AE','Video #');
grid on
drawnow