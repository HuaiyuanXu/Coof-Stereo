function imgf=CoOcurFilterGray(img, params,coc_mat)

sigma_s=params.sigma_s;
sigma_oc=params.sigma_oc;
if isfloat(img)%����ǵ����ȸ����ͣ�ת����32λ����
    img=int32(round(img));
end

% coc_mat=GetCoOcurMat(img, sigma_oc);%���ɹ�������

win_size=3*sigma_s;
win_halfsize=ceil(win_size/2);%������ڰ뾶
win_size=win_halfsize*2+1;
[xx, yy]=meshgrid(-win_halfsize:win_halfsize, -win_halfsize:win_halfsize);
w_s=exp(-(xx.^2+yy.^2)/(2*sigma_s*sigma_s));%���㴰���ڸ��������������صľ�������
w_s=w_s(:);

img_pad=padarray(img, [win_halfsize, win_halfsize], 0, 'both');%ͼ��ı�Ե���ţ������������߶�����win_halfsize����0
[nrow, ncol]=size(img_pad);
imgf=img;
for i=1:(nrow-win_size+1)
    for j=1:(ncol-win_size+1)
         img_sub=img_pad(i:i+win_size-1, j:j+win_size-1);
         w_oc=coc_mat(img_sub(:)+1,img_sub(win_halfsize+1, win_halfsize+1)+1);%���ﲻ����ΪʲôҪ��ÿ�����ص�ֵ+1
         w=w_oc.*w_s;
         imgf(i,j)=sum(double(img_sub(:)).*w)/(sum(w)+eps);%���ﲻ�����ڱ��ʱΪʲô�ڷ�ĸ�м�����С����������        
    end
end














