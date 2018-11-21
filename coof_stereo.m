clear;%清除工作空间的所有变量
clc;%清除命令窗口的内容，对工作环境中的全部变量无任何影响

%选定图像
im_num=3;    %tsukuba:1  venus:2  teddy:3  cones:4
%设置梯度匹配代价比例系数  0.89
alpha_grad=0.89;
%设置颜色匹配代价截断值
thres_color=0.0275;
%设置梯度匹配代价截断值
thres_grad=0.0078;
%设置边缘像素代价值
cost_border=0.012;
%设置引导滤波窗口尺寸参数
win_radius=9;
%设置引导滤波epsilon值
epsilon=0.0001;
%设置加权中值滤波窗口尺寸参数
win_median_radius=9;
%设置加权中值滤波sigma值
sigma_c=0.1;
sigma_p=14.1;
%异常点邻近匹配窗口大小
r1=25; 
%DSI检查阈值
fai=0;
%CBOF计算不稳定点的视差参数
gama_c=0.51;  %颜色距离
gama_r=0.0915;  %位置距离
CBOF_window=3;  %窗口大小
r=CBOF_window;
CBOFmoder = zeros(r,r);
for i=1:r
    for j=1:r
        T = sqrt(( i - (r+1)/2 )^2 + ( j - (r+1)/2 )^2);
        CBOFmoder( i , j ) = exp(-T/gama_r);
    end
end

%设置图像参数
switch (im_num)
    case 1
        %设置最大视差值
        disp_max=15;
        %设置视差图放大比例
        scale=16;
        %读取图像对
        iml_rgb=double(imread('datum\1\dataset\tsukuba\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\tsukuba\im6.ppm'))/255;
        %读取真实视差图
        im_disp_true=imread('datum\1\dataset\tsukuba\disp2.pgm');
        %读取评价范围图
        im_eva_all=imread('datum\1\dataset\tsukuba\all.png');
    case 2
        %设置最大视差值
        disp_max=32;
        %设置视差图放大比例
        scale=8;
        %读取图像对
        iml_rgb=double(imread('datum\1\dataset\venus\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\venus\im6.ppm'))/255;
        %读取真实视差图
        im_disp_true=imread('datum\1\dataset\venus\disp2.pgm');
        %读取评价范围图
        im_eva_all=imread('datum\1\dataset\venus\all.png');
    case 3
        %设置最大视差值
        disp_max=59;
        %设置视差图放大比例
        scale=4;
        %读取图像对
        iml_rgb=double(imread('datum\1\dataset\teddy\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\teddy\im6.ppm'))/255;
        %读取真实视差图
        im_disp_true=imread('datum\1\dataset\teddy\disp2.pgm');
        %读取评价范围图
        im_eva_all=imread('datum\1\dataset\teddy\all.png')/255;
    case 4
        %设置最大视差值
        disp_max=59;
        %设置视差图放大比例
        scale=4;
        %读取图像对
        iml_rgb=double(imread('datum\1\dataset\cones\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\cones\im6.ppm'))/255;
        %读取真实视差图
        im_disp_true=imread('datum\1\dataset\cones\disp2.pgm');
        %读取评价范围图
        im_eva_all=imread('datum\1\dataset\cones\all.png');

end
%将rgb图像转换为灰度图像
iml_gray=rgb2gray(iml_rgb);
imr_gray=rgb2gray(imr_rgb);
%获取图像尺寸
[im_h,im_w,~]=size(iml_rgb);

%计算rgb图像镜像
iml_rgb_mirror=flipdim(iml_rgb,2);
imr_rgb_mirror=flipdim(imr_rgb,2);
%计算灰度图像x方向梯度图像
iml_gray_grad_x=gradient(iml_gray);
imr_gray_grad_x=gradient(imr_gray);
%计算梯度图像镜像
iml_gray_grad_x_mirror=flipdim(iml_gray_grad_x,2);
imr_gray_grad_x_mirror=flipdim(imr_gray_grad_x,2);
%计算初始CostVolume
cost_volume_l=ones(im_h,im_w,disp_max)*cost_border;
cost_volume_r=ones(im_h,im_w,disp_max)*cost_border;
for d=1:disp_max
    %左图
    imr_rgb_shift=[ones(im_h,d,3) imr_rgb(:,1:im_w-d,:)];
    color_diff=sum(abs(iml_rgb-imr_rgb_shift),3)/3;   
    imr_gray_grad_x_shift=[ones(im_h,d) imr_gray_grad_x(:,1:im_w-d)];
    grad_diff=abs(iml_gray_grad_x-imr_gray_grad_x_shift);
    cost_volume_l(:,:,d)=(1-alpha_grad).*min(color_diff,thres_color)+alpha_grad.*min(grad_diff,thres_grad);
    %右图
    iml_rgb_mirror_shift=[ones(im_h,d,3) iml_rgb_mirror(:,1:im_w-d,:)];
    color_diff=sum(abs(imr_rgb_mirror-iml_rgb_mirror_shift),3)/3;   
    iml_gray_grad_x_mirror_shift=[ones(im_h,d) iml_gray_grad_x_mirror(:,1:im_w-d)];
    grad_diff=abs(imr_gray_grad_x_mirror-iml_gray_grad_x_mirror_shift);
    cost_volume_r(:,:,d)=flipdim((1-alpha_grad).*min(color_diff,thres_color)+alpha_grad.*min(grad_diff,thres_grad),2);          
end
clear iml_gray imr_gray iml_rgb_mirror iml_gray_grad_x imr_gray_grad_x iml_gray_grad_x_mirror imr_gray_grad_x_mirror;
clear imr_rgb_shift iml_rgb_mirror_shift color_diff imr_gray_grad_x_shift iml_gray_grad_x_mirror_shift grad_diff;


%代价图滤波
%共生滤波
params.sigma_s=9;
params.sigma_oc=10;
sigma_oc=100;
iml_gray=rgb2gray(iml_rgb)*255;
iml_gray=int32(iml_gray);
coc_mat=GetCoOcurMat(iml_gray, sigma_oc);%生成共生矩阵
cost_volume_l_coo=ones(im_h,im_w,disp_max);
for d=1:disp_max
    cost_volume_l_pick=cost_volume_l(:,:,d);
    cost_volume_l_coo(:,:,d)=CoOcurFilter(cost_volume_l_pick/max(cost_volume_l_pick(:))*200, params,coc_mat);
end
figure(3);set(gcf, 'position',[200 200 1200 600])
for d=1:6
    aaaaaa=cost_volume_l_coo(:,:,d);
    subplot(2,3,d);
    imshow(uint8(aaaaaa/max(aaaaaa(:))*255));
end
[~,im_disp_l_coo]=min(cost_volume_l_coo,[],3);
im_disp_l_coo=uint8(im_disp_l_coo.*scale);
figure(4)
imshow(im_disp_l_coo);
im_disp_error1_coo=bitor(abs(double(im_disp_true)-double(im_disp_l_coo))<=(1*scale),im_eva_all==0);
im_disp_error1_coo=uint8(im_disp_error1_coo);
error_rate1_coo=sum(sum(im_disp_error1_coo==0))/sum(sum(im_eva_all==1));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





        
        
        