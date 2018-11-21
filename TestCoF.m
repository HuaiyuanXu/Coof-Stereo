clear; close all;clc

% gray-image filtering
params.sigma_s=5;
params.sigma_oc=10;
img1=imread('C:\Users\HuaiyuanXu\Desktop\近五年\2017CVPR\传统\共生矩阵滤波\CoOccurFilter-master\images\1025disp_l_f3.bmp');
img1=double(img1(:,:,1));
img1f2=CoOcurFilter(img1, params);

% % color-image filtering
% params.sigma_s=7;
% params.sigma_oc=10;
% params.quant_level=64;
% img2=imread('images\58060_rs.jpg');
% img2=double(img2);
% img2f1=ImgFiltering(img2, 'gaussian', 7, 1.5);
% img2f2=CoOcurFilter(img2, params);
% 
figure(1);set(gcf, 'position',[200 200 1200 600])
subplot(2,3,1);imagesc(img1,[0,255]);colormap(gray)
title('Original Gray Image')
subplot(2,3,3);imagesc(img1f2,[0,255]);colormap(gray)
title('Result of CoF Filtering')




