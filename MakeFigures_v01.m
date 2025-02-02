clear; close all; clc
AE=load("AE.mat");
Mech=load("Mechanical.mat");
AEoff=0.0770;

AE.t_s=[0:length(AE.dataAE(:,1))-1]'.*AE.dt_s+AE.t0_s-AEoff;
AE.dataNormFilt=movmean(single(AE.dataAE)./max(single(AE.dataAE)),5);
figure
set(gcf,'position',[100 100 1400 1000]);

figure(1);
plot(Mech.t_s-AE.t0_s,Mech.Friction,AE.t_s-AE.t0_s,AE.dataNormFilt(:,2)); hold on
scatter(Mech.CamUnix_s-AE.t0_s-AEoff,zeros(size(Mech.CamUnix_s)),30,'r','filled');
text(Mech.CamUnix_s-AE.t0_s-AEoff,zeros(size(Mech.CamUnix_s))-0.1,num2str(Mech.FileN));
xlabel('time, s');
title(sprintf('Dataset begins at UNIX time %0.5f s', AE.t0_s));
xlim([13.1 14.1]);
grid on
legend('Friction','AE (norm.)','Video #');

% figure(2);
% wnd_s=1710347465.71576+[13.1 14.1];
% IDAE=find(AE.t_s>=wnd_s(1) & AE.t_s<=wnd_s(2));
% IDMech=find(Mech.t_s>=wnd_s(1) & Mech.t_s<=wnd_s(2));
% plot(Mech.t_s(IDMech)-AE.t0_s,Mech.Friction(IDMech),AE.t_s(IDAE)-AE.t0_s,AE.dataNormFilt(IDAE,2)); hold on
% scatter(Mech.CamUnix_s(2)-AE.t0_s-AEoff,zeros(size(Mech.CamUnix_s(2))),30,'r','filled');
% text(Mech.CamUnix_s(2)-AE.t0_s-AEoff,zeros(size(Mech.CamUnix_s(2)))-0.1,num2str(Mech.FileN(2)));
% xlabel('time, s');
% legend('Friction','AE','Video #');
% grid on
drawnow