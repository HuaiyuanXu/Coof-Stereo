function imgf=CoOcurFilterGray(img, params,coc_mat)

sigma_s=params.sigma_s;
sigma_oc=params.sigma_oc;
if isfloat(img)%如果是单精度浮点型，转换成32位整型
    img=int32(round(img));
end

% coc_mat=GetCoOcurMat(img, sigma_oc);%生成共生矩阵

win_size=3*sigma_s;
win_halfsize=ceil(win_size/2);%求出窗口半径
win_size=win_halfsize*2+1;
[xx, yy]=meshgrid(-win_halfsize:win_halfsize, -win_halfsize:win_halfsize);
w_s=exp(-(xx.^2+yy.^2)/(2*sigma_s*sigma_s));%计算窗口内各像素离中心像素的距离因子
w_s=w_s(:);

img_pad=padarray(img, [win_halfsize, win_halfsize], 0, 'both');%图像的边缘扩张，上下左右两边都扩张win_halfsize，填0
[nrow, ncol]=size(img_pad);
imgf=img;
for i=1:(nrow-win_size+1)
    for j=1:(ncol-win_size+1)
         img_sub=img_pad(i:i+win_size-1, j:j+win_size-1);
         w_oc=coc_mat(img_sub(:)+1,img_sub(win_halfsize+1, win_halfsize+1)+1);%这里不明白为什么要给每个像素的值+1
         w=w_oc.*w_s;
         imgf(i,j)=sum(double(img_sub(:)).*w)/(sum(w)+eps);%这里不明白在编程时为什么在分母中加上最小浮点数精度        
    end
end














