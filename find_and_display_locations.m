function find_and_display_locations

wrong_ones = [1,4];

marg = 0; % margin for bounding boxes
b_thr = 0.1; % background elimination threshold
t_thr = 0.65; % text isolation threshold
bl_thr = 0.30; % blob identification threshold

load('manually_calibrated_corners') % C
xtl = C(1,1);
ytl = C(1,2);
xbr = C(2,1);
ybr = C(2,2);
load('reference_image') % A

figure(1)
image(ones(180,320,3))
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

X = zeros(size(A,1),size(A,2));
for i = 1:20

img = snapshot(cam); % Take picture

img = img(ytl:ybr,xtl:xbr,:); % cut out projected portion

diff = mat2gray(img)-mat2gray(A); 
D = sum(abs(diff),3); % absolute value of difference between picture and background (e.g. what has changed)

Ir = img(:,:,1);
Ig = img(:,:,2);
Ib = img(:,:,3);
Ir(D<b_thr*max(diff(:)))=255;
Ig(D<b_thr*max(diff(:)))=255;
Ib(D<b_thr*max(diff(:)))=255;
I = cat(3,Ir,Ig,Ib); % Keep only image sections that have changed

I0 = mat2gray(sum(I,3));
I0(I0<t_thr*max(I0(:))) = 0;
I0(I0>t_thr*max(I0(:))) = 1;
I0 = 1-I0;
% I0 = imgaussfilt(I0, 2);
[gx,gy] = gradient(I0);
% I0 = gx.^2+gy.^2;

fm = ones(20,20);
C = (1/(size(fm,1)*size(fm,2)))*conv2(I0,fm,'same'); % convolve with square flat kernel

figure(6)
subplot(1,2,1)
imagesc(I0)
subplot(1,2,2)
imagesc(C)

Xi = zeros(size(I0));
Xi(I0>6*C) = 1;
X = X+Xi;

end

X(X<0.5*max(X(:)))=0;

fm1 = ones(150,30);
C = (1/(size(fm1,1)*size(fm1,2)))*conv2(X,fm1,'same');

fx = ones(2,size(C,2));
fy = ones(size(C,1),2);

Ex = (1/(size(fx,1)*size(fx,2)))*conv2(X,fx,'same');
Ey = (1/(size(fy,1)*size(fy,2)))*conv2(X,fy,'same');

C(C<bl_thr*max(C(:))) = 0;
C(C>bl_thr*max(C(:))) = 1;

figure(4)
subplot(1,2,1)
imagesc(X)
subplot(1,2,2)
imagesc(C)

L = bwlabel(C);
B = zeros(max(L(:)),4);

figure(3)
imagesc(img)
hold on

for i = 1:max(L(:))
    
    Ci = C;
    Ci(L~=i)=0;
    bi  = regionprops(Ci,'BoundingBox');
    bbi = bi.BoundingBox;
    bbi(1) = bbi(1)-marg;
    bbi(2) = bbi(2)-marg;
    bbi(3) = bbi(3)+marg;
    bbi(4) = bbi(4)+marg;
    B(i,:) = [bbi(1),bbi(2),bbi(1)+bbi(3),bbi(2)+bbi(4)]; % [xi,yi,xf,yf]
    
    cori = [bbi(1),bbi(2);bbi(1)+bbi(3),bbi(2);bbi(1)+bbi(3),bbi(2)+bbi(4);bbi(1),bbi(2)+bbi(4);bbi(1),bbi(2)];
    
    figure(3)
    plot(cori(:,1),cori(:,2),'r')
    hold on
    
end

figure(3)
hold off

% DISPLAY ON PROJECTOR

tlc = [1,134]; % top-left corner (y,x);

sz_pr = [122,180]; % size of projected portion of image (y,x);
sz_cam = [size(A,1),size(A,2)]; % size of cropped camera image [y,x];
pix_sz = 1./(sz_cam./sz_pr); % projector pixel size in camera pixel size [y,x];
B
B(:,1) = round(pix_sz(2)*B(:,1));
B(:,3) = round(pix_sz(2)*B(:,3));
B(:,2) = round(pix_sz(1)*B(:,2));
B(:,4) = round(pix_sz(1)*B(:,4));

[~,Binde] = sort(B(:,1));
Idisp = zeros(sz_pr(1),sz_pr(2),3);

ni = 0;

for i = Binde'
    ni = ni+1;
    sel = abs(ni-wrong_ones);
    
    if min(sel)==0
        Idisp(max(B(i,2),1):min(B(i,4),sz_pr(1)),max(B(i,1),1):min(B(i,3),sz_pr(1)),1) = 1;
    else
        Idisp(max(B(i,2),1):min(B(i,4),sz_pr(1)),max(B(i,1),1):min(B(i,3),sz_pr(1)),2) = 1;
    end
end

Ifull = zeros(180,320,3);
Ifull(tlc(1):tlc(1)+sz_pr(1)-1,tlc(2):tlc(2)+sz_pr(2)-1,:) = Idisp;

figure(5)
image(Idisp)

figure(1)
image(Ifull)
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