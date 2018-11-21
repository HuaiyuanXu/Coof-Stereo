clear;%��������ռ�����б���
clc;%�������ڵ����ݣ��Թ��������е�ȫ���������κ�Ӱ��

%ѡ��ͼ��
im_num=3;    %tsukuba:1  venus:2  teddy:3  cones:4
%�����ݶ�ƥ����۱���ϵ��  0.89
alpha_grad=0.89;
%������ɫƥ����۽ض�ֵ
thres_color=0.0275;
%�����ݶ�ƥ����۽ض�ֵ
thres_grad=0.0078;
%���ñ�Ե���ش���ֵ
cost_border=0.012;
%���������˲����ڳߴ����
win_radius=9;
%���������˲�epsilonֵ
epsilon=0.0001;
%���ü�Ȩ��ֵ�˲����ڳߴ����
win_median_radius=9;
%���ü�Ȩ��ֵ�˲�sigmaֵ
sigma_c=0.1;
sigma_p=14.1;
%�쳣���ڽ�ƥ�䴰�ڴ�С
r1=25; 
%DSI�����ֵ
fai=0;
%CBOF���㲻�ȶ�����Ӳ����
gama_c=0.51;  %��ɫ����
gama_r=0.0915;  %λ�þ���
CBOF_window=3;  %���ڴ�С
r=CBOF_window;
CBOFmoder = zeros(r,r);
for i=1:r
    for j=1:r
        T = sqrt(( i - (r+1)/2 )^2 + ( j - (r+1)/2 )^2);
        CBOFmoder( i , j ) = exp(-T/gama_r);
    end
end

%����ͼ�����
switch (im_num)
    case 1
        %��������Ӳ�ֵ
        disp_max=15;
        %�����Ӳ�ͼ�Ŵ����
        scale=16;
        %��ȡͼ���
        iml_rgb=double(imread('datum\1\dataset\tsukuba\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\tsukuba\im6.ppm'))/255;
        %��ȡ��ʵ�Ӳ�ͼ
        im_disp_true=imread('datum\1\dataset\tsukuba\disp2.pgm');
        %��ȡ���۷�Χͼ
        im_eva_all=imread('datum\1\dataset\tsukuba\all.png');
    case 2
        %��������Ӳ�ֵ
        disp_max=32;
        %�����Ӳ�ͼ�Ŵ����
        scale=8;
        %��ȡͼ���
        iml_rgb=double(imread('datum\1\dataset\venus\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\venus\im6.ppm'))/255;
        %��ȡ��ʵ�Ӳ�ͼ
        im_disp_true=imread('datum\1\dataset\venus\disp2.pgm');
        %��ȡ���۷�Χͼ
        im_eva_all=imread('datum\1\dataset\venus\all.png');
    case 3
        %��������Ӳ�ֵ
        disp_max=59;
        %�����Ӳ�ͼ�Ŵ����
        scale=4;
        %��ȡͼ���
        iml_rgb=double(imread('datum\1\dataset\teddy\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\teddy\im6.ppm'))/255;
        %��ȡ��ʵ�Ӳ�ͼ
        im_disp_true=imread('datum\1\dataset\teddy\disp2.pgm');
        %��ȡ���۷�Χͼ
        im_eva_all=imread('datum\1\dataset\teddy\all.png')/255;
    case 4
        %��������Ӳ�ֵ
        disp_max=59;
        %�����Ӳ�ͼ�Ŵ����
        scale=4;
        %��ȡͼ���
        iml_rgb=double(imread('datum\1\dataset\cones\im2.ppm'))/255;
        imr_rgb=double(imread('datum\1\dataset\cones\im6.ppm'))/255;
        %��ȡ��ʵ�Ӳ�ͼ
        im_disp_true=imread('datum\1\dataset\cones\disp2.pgm');
        %��ȡ���۷�Χͼ
        im_eva_all=imread('datum\1\dataset\cones\all.png');

end
%��rgbͼ��ת��Ϊ�Ҷ�ͼ��
iml_gray=rgb2gray(iml_rgb);
imr_gray=rgb2gray(imr_rgb);
%��ȡͼ��ߴ�
[im_h,im_w,~]=size(iml_rgb);

%����rgbͼ����
iml_rgb_mirror=flipdim(iml_rgb,2);
imr_rgb_mirror=flipdim(imr_rgb,2);
%����Ҷ�ͼ��x�����ݶ�ͼ��
iml_gray_grad_x=gradient(iml_gray);
imr_gray_grad_x=gradient(imr_gray);
%�����ݶ�ͼ����
iml_gray_grad_x_mirror=flipdim(iml_gray_grad_x,2);
imr_gray_grad_x_mirror=flipdim(imr_gray_grad_x,2);
%�����ʼCostVolume
cost_volume_l=ones(im_h,im_w,disp_max)*cost_border;
cost_volume_r=ones(im_h,im_w,disp_max)*cost_border;
for d=1:disp_max
    %��ͼ
    imr_rgb_shift=[ones(im_h,d,3) imr_rgb(:,1:im_w-d,:)];
    color_diff=sum(abs(iml_rgb-imr_rgb_shift),3)/3;   
    imr_gray_grad_x_shift=[ones(im_h,d) imr_gray_grad_x(:,1:im_w-d)];
    grad_diff=abs(iml_gray_grad_x-imr_gray_grad_x_shift);
    cost_volume_l(:,:,d)=(1-alpha_grad).*min(color_diff,thres_color)+alpha_grad.*min(grad_diff,thres_grad);
    %��ͼ
    iml_rgb_mirror_shift=[ones(im_h,d,3) iml_rgb_mirror(:,1:im_w-d,:)];
    color_diff=sum(abs(imr_rgb_mirror-iml_rgb_mirror_shift),3)/3;   
    iml_gray_grad_x_mirror_shift=[ones(im_h,d) iml_gray_grad_x_mirror(:,1:im_w-d)];
    grad_diff=abs(imr_gray_grad_x_mirror-iml_gray_grad_x_mirror_shift);
    cost_volume_r(:,:,d)=flipdim((1-alpha_grad).*min(color_diff,thres_color)+alpha_grad.*min(grad_diff,thres_grad),2);          
end
clear iml_gray imr_gray iml_rgb_mirror iml_gray_grad_x imr_gray_grad_x iml_gray_grad_x_mirror imr_gray_grad_x_mirror;
clear imr_rgb_shift iml_rgb_mirror_shift color_diff imr_gray_grad_x_shift iml_gray_grad_x_mirror_shift grad_diff;


%����ͼ�˲�
%�����˲�
params.sigma_s=9;
params.sigma_oc=10;
sigma_oc=100;
iml_gray=rgb2gray(iml_rgb)*255;
iml_gray=int32(iml_gray);
coc_mat=GetCoOcurMat(iml_gray, sigma_oc);%���ɹ�������
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





        
        
        