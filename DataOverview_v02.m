%% THIS CODE ALLOWS TO FIND THE VIDEO-MECHANICAL DATA TIME OFFSETS
clear; close all; clc
%% graphics
% available_graphics_toolkits   % OCTAVE
% graphics_toolkit('gnuplot');  % OCTAVE

%% parameters to be changed
shiftGMT_h = 5;           % hour shift between GMT and Austin time
r1_m       = 0.5*15e-3;   % sample outer radius, m
r2_m       = 0.5*3e-3;    % sample inner radius, m
TimeOff_s  = 0-0;           % time offset between video and mechanical data

%% parameters not to be changed
CorrK      = 27.3937;     % coefficient to correct the torque
fil        = 21;          % filter for moving average

%114.8-83.5252; % offset between video and mechanical data

% %% Load calibration from a txt file (NOT USED)
% disp('Loading calibration...');
% calraw = dlmread(fullfile('.','CalibrationFiles','CaliFileSN505106_cal.txt'),';'); % load the calibration
% for n=1:5
%  cal.Slope(n)     = calraw(n+1,2);
%  cal.Intercept(n) = calraw(n+1,3);
% end

%% get video times
vidFiles   = dir(fullfile(".","SlomoVideo","*.mov"));
CamUnix_s = sscanf([vidFiles.name],"slomo_%d_%d.mov");
FileN     = CamUnix_s(2:2:end);
CamUnix_s = CamUnix_s(1:2:end)-shiftGMT_h*3600-TimeOff_s;

%% load mechanical data
files = dir(fullfile('.','MechanicalData','00*.mat'));
for n = 1:length(files)
    fprintf('Loading mechanical data, file %d/%d...\n',n,length(files));
    dataS = load(fullfile('.','MechanicalData',files(n).name));
    if n==1
        data = dataS.dataallRaw;
        t_s  = dataS.timeall;
        StartUnix_s=dataS.Start_Posix_s;
        cal.Slope=dataS.calibration.Slope;
        cal.Intercept=dataS.calibration.Intercept;
    else
        data = [data;dataS.dataallRaw];
        t_s  = [t_s;dataS.timeall];
    end
end

%% apply calibrations to data
t_s             = t_s+StartUnix_s;
data            = movmean(data,fil);
M_Nm            = (data(:,1)+1.4789e-1).*cal.Slope(1)+cal.Intercept(1);
F_N             = (data(:,2)-1.86021e-4).*cal.Slope(2)+cal.Intercept(2);
F_N             = F_N- (CorrK*M_Nm);
Rot1_deg        = data(:,3).*cal.Slope(3)+cal.Intercept(3);
Rot2_deg        = data(:,4).*cal.Slope(4)+cal.Intercept(4);
VDisp_m         = data(:,5).*cal.Slope(5)+cal.Intercept(5);
Motor           = data(:,6);
Pressure        = data(:,7);
Trigger         = data(:,8);
clear data dataS

%% plot all separated data (data are shown decimated for speed)
figure
DCf=50;
set(gcf,'position',[200 100 1400 1000]);
ax(1)=subplot(3,2,1);                     % plot force
plot(t_s(1:DCf:end)-t_s(1),F_N(1:DCf:end));
xlabel('Unix time, s');
ylabel('Force, N');
title('Normal force applied to the sample');
ax(2)=subplot(3,2,2);                     % plot torque
plot(t_s(1:DCf:end)-t_s(1),M_Nm(1:DCf:end));
xlabel('Unix time, s');
ylabel('Torque, Nm');
title('Torque applied to the sample');
ax(3)=subplot(3,2,3);                     % plot rotation
plot(t_s(1:DCf:end)-t_s(1),Rot1_deg (1:DCf:end)); hold on
plot(t_s(1:DCf:end)-t_s(1),Rot2_deg (1:DCf:end));
xlabel('Unix time, s');
ylabel('Rotation, deg');
title('Bottom sample rotation');
legend('Sensor 1','Sensor 2');
ax(4)=subplot(3,2,4);                     % plot vertical displacement
plot(t_s(1:DCf:end)-t_s(1),VDisp_m(1:DCf:end));
xlabel('Unix time, s');
ylabel('Vertical disp., mm');
title('Vertical displacement of the vertical sample');
ax(5)=subplot(3,2,5);                     % plot motor pulses
plot(t_s(1:DCf:end)-t_s(1),Motor(1:DCf:end));
xlabel('Unix time, s');
ylabel('Motor pulse');
title('Each negative pulse is a 0.2 deg rotation of the motor');
ax(6)=subplot(3,2,6);                     % plot video trigger
plot(t_s(1:DCf:end)-t_s(1),Trigger(1:DCf:end));
xlabel('Unix time, s');
ylabel('Video trigger');
title('Each negative pulse is the acquisition of a video');
linkaxes(ax,'x');

%% calculate stresses and friction
Area_m2         = pi*(r1_m^2 - r2_m^2);
NormalStress_Pa = F_N./Area_m2;
ShearStress_Pa  = 3*M_Nm./(pi*2*(r1_m^3-r2_m^3));
Friction        = ShearStress_Pa./NormalStress_Pa;

%% plot
figure
set(gcf,'position',[300 100 800 600]);
disp('Plot data');
plot(t_s(1:10:end)-t_s(1),Friction(1:10:end));
%xlim([t_s(1),t_s(end)]); % limit the x axis
xlim([0 t_s(end)-t_s(1)]); % limit the x axis
xlabel('time, s');
ylabel('friction ({\mu})');
title(sprintf('Friction. Start at Unix time %0.3f s, %s',t_s(1), datetime(t_s(1),'ConvertFrom','posix')));
%title(sprintf('Video triggers. Start at Unix time %0.3f s, %s',t_s(1), ctime(t_s(1)))); % OCTAVE
saveas(gcf,'test.png')

%% plot
figure
set(gcf,'position',[400 100 800 600]);
disp('Plot data');
plot(t_s(1:10:end)-t_s(1), Trigger(1:10:end)); hold on
scatter(CamUnix_s-t_s(1),zeros(size(CamUnix_s)),30,'r','filled');
text(CamUnix_s-t_s(1),zeros(size(CamUnix_s))-0.1,num2str(FileN));
%xlim([t_s(1),t_s(end)]); % limit the x axis
%xlim([0 t_s(end)-t_s(1)]); % limit the x axis
xlabel('time, s');
title(sprintf('Video triggers. Start at Unix time %0.3f s, %s',t_s(1), datetime(t_s(1),'ConvertFrom','posix')));
%title(sprintf('Video triggers. Start at Unix time %0.3f s, %s',t_s(1), ctime(t_s(1)))); % OCTAVE
legend("Video Triggers","Video Times")
disp(sprintf('Dataset starts at UNIX time %0.3f s',t_s(1)))
disp(sprintf('Camera-mechanical data time shift %0.3f s',TimeOff_s))
drawnow
save("Mechanical.mat","t_s","Pressure","Trigger","VDisp_m","NormalStress_Pa","ShearStress_Pa","Friction","Rot2_deg","Rot1_deg","CamUnix_s","FileN","Motor","TimeOff_s");