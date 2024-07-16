%% Opens the acoustic emissions data
clear; close all; clc;
dirname=fullfile('.','AEdata');
load(fullfile(dirname,'settings.mat'));
baseName=["channelA_","channelB_","channelC_"];
dataAE=[];
for m=1:length(baseName)
    channel(m).AE=[];
    channel(m).t_s=[];
    files=dir(fullfile(dirname,[baseName{m} '*.bin']));
    N = sscanf([files.name],[baseName{m} '%d.bin']);
    [N, id]=sort(N);
    files=files(id);
    for n=1:length(N)
        fid=fopen(fullfile(dirname,files(n).name),'r');
        data = int16(fread(fid,'int16'));
        dt_s=double(actualSampleInterval)/1e9;
        t_s    = double([0:length(data)-1]).*dt_s+Start_Posix_s(N(n));
        channel(m).AE=[channel(m).AE;data];
        channel(m).t_s=[channel(m).t_s;t_s'];
        fclose(fid);
        disp(sprintf('Open %s file %d/%d...',baseName{m},n,length(N)));
    end
    plot(channel(m).t_s(1:20:end)-channel(m).t_s(1),channel(m).AE(1:20:end)); hold on 
    dataAE=[dataAE channel(m).AE];   
end
disp('Plot...');
title(sprintf('AE. Start at Unix time %0.3f s, %s',channel(m).t_s(1), datetime(channel(m).t_s(1),'ConvertFrom','posix')));
xlabel('time, s');
ylabel('counts');
drawnow
t0_s=channel(m).t_s(1);
save('AE.mat',"dataAE","dt_s","t0_s");
