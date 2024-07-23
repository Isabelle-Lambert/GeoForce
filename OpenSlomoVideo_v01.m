clear; close all; clc
%pkg load video
%graphics_toolkit('fltk'); % use in OCTAVE
fileName='slomo_1710365511_27.mov';
r = VideoReader(fullfile('.','SlomoVideo',fileName));
im = [];
n=1;
figure
set(gcf,'position',[100 100 800 400]);
colormap(gray);
disp("Showing video...");
while (r.hasFrame())
   frm(n).img = readFrame(r);
   frm(n).img = rgb2gray(frm(n).img);
   valImg(n)=sum(frm(n).img(:))./numel(frm(n).img);
   if (isempty (im))
     im = image (frm(n).img);
     axis off;
     axis equal;
     tlt=title(sprintf('Frame: %d/%d',n,r.NumberOfFrames));
   else
     set (im, "cdata", frm(n).img);
     set (tlt, "string",sprintf('Frame: %d/%d',n,r.NumberOfFrames));
   end
   %drawnow
   n=n+1;
end

%% show how frames change
valImgSmooth=movmean(valImg,21);
figure
set(gcf,'position',[200 100 800 600],'name','Brightness value');
plot(valImg); hold on
plot(valImgSmooth);
xlabel('Frame #');
ylabel('Dark <--- Brightness value ---> Bright');
title(sprintf("%s frames values (1 frame = 0.1 ms)",r.name),'interpreter','none');
legend('Raw frame values sum','Smoothed frame values sum','loaction','best');
grid on
saveas(gcf,'frameValues.png');


%% create images from selected frames
selFrames=[3899:3909];
figure
set(gcf,'position',[300 100 800 400]);
colormap(gray);
for n=selFrames
    frameName=sprintf('%s_%d.png',r.name(1:end-4),n);
    frameFile=fullfile('.','SlomoVideo','frames',frameName);
    image (frm(n).img);
    title(frameName,'interpreter','none');
    xlabel('x, pixels');
    ylabel('y, pixels');
    drawnow
    disp(['Saving ' frameFile]);
    saveas(gcf,frameFile);
end


