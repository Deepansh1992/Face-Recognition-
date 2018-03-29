% preapering data base %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dio = digitalio('parallel','LPT1');
% lines = addlines(dio,0:7,'out');
% cahnge 
clear all
close all
clc
s=0;
count=1;
for n=1:10
        i_new=imread(['D:\Study\Matlab Programs\Major project\Processed image 2\person ' num2str(n) '\s1.jpg']);
        %i_new2 = rgb2ycbcr(i_new);
        i = rgb2gray(i_new);
        subplot(2,5,count)
        
        count=count+1;
        imshow(i)
        if count==5
            title('Face training images database')
        end
        [rows cols]=size(i);
        i_row(:,n)=double(i(:)); %#ok<SAGROW>
        s=s+double(i(:));
end
mean_face=s/10;


for n=1:10
    a(:,n)=double(i_row(:,n)) - mean_face; %#ok<SAGROW>
end
[v d]=eig(a'*a);
u=a*v;

figure;
for n=1:10
    for j=1:cols
        eig_image(1:rows,j)=u((j-1)*rows+1 : j*rows,n); %#ok<SAGROW>
    end
    subplot(2,5,n)
    imshow(uint8(eig_image))
    if n==10
            title('Eigen Ghostly faces')
    end
end

w=(u'*a);


% getting target image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vid=videoinput('winvideo',2,'YUY2_640x480');
start(vid)
preview(vid);
pause(5)
ycbcr=getsnapshot(vid);
rgb=ycbcr2rgb(ycbcr);

I_test= double(ycbcr);

[rows cols plts] = size(I_test); 
rowsum = 0;
colsum = 0;
count = 0;
for i = 1: rows
    for j= 1 : cols
        dist = sqrt((I_test(i,j,2)-118)^2+(I_test(i,j,3)-140)^2);
        if dist>10
            rgb(i,j,:)= 0;
        else
            rowsum=rowsum+i;
            colsum=colsum+j;
            count = count+1;
        end 
    end
end
rowmean= rowsum/count;
colmean= colsum/count;
imshow(rgb)
face = imresize(rgb(rowmean-146:rowmean+148,colmean-223:colmean+169),[100 80]); 
hold on
plot(colmean,rowmean,'*r')
figure;imshow(face)
title ('target face')
I = face;
figure, imshow(I);
title('test image')
A=double(I(:)) - mean_face;
[V D]=eig(A'*A);
W=u'*A;



% image matching  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n=1:10
    Z(n)=sqrt(sum((w(:,n)-W).^2)); %#ok<SAGROW>
end
[a b]=min(Z);
a
b
if a > 1.e+07
    disp('Image not matched to Database');
else
disp(['Image matched to database : ' num2str(b)]);
figure;
subplot(1,2,1)
imshow(I)
title('Target Image')
subplot(1,2,2)
imshow(['D:\Study\Matlab Programs\Major project\Processed image 2\person ' num2str(b) '\s1.jpg'])
title('Matched image from database')
% putvalue(logical([0 0 0 0 0 1 0 0]));
% disp('Access Authorized the door is oppening')
stop(vid)
end





