function calibrate_screen

tlc = [1,134]; % top-left corner (y,x);
sz = [122,180]; % size (y,x);

t = tlc(1);
b = tlc(1)+sz(1);
l = tlc(2);
r = tlc(2)+sz(2);

I0 = ones(180,320,3);
% I0(t,l:r,:) = 0;
% I0(b,l:r,:) = 0;
% I0(t:b,l,:) = 0;
% I0(t:b,r,:) = 0;

figure(1)
image(I0)

% get the figure and axes handles
 hFig = gcf;
 hAx  = gca;
 % set the figure to full screen
 set(hFig,'units','normalized','outerposition',[0.75 0.54 0.6 0.5]); %(Move left, Move up, Cut width, Cut height)
 % set the axes to full screen
 set(hAx,'Unit','normalized','Position',[0 0 1 1]);
 % hide the toolbar
 set(hFig,'menubar','none')
 % to hide the title
 set(hFig,'NumberTitle','off');

cam = webcam('HD 720P Webcam');

img = snapshot(cam);

clear('cam');

figure(2)
imagesc(img)
title('Double-click on the top-left corner')
hold on

[xtl,ytl] = getpts;
figure(2)
title('Double-click on the bottom-right corner')
[xbr,ybr] = getpts;

C = [[xtl,ytl];[xbr,ybr]];

scr = [xtl,ytl;xbr,ytl;xbr,ybr;xtl,ybr;xtl,ytl];

figure(2)
plot(scr(:,1),scr(:,2),'r');
title('Screen coordinates saved')
hold off

A = img(ytl:ybr,xtl:xbr,:);

save('manually_calibrated_corners','C')
save('reference_image','A')
