function q = CBOF_match( im_d,img,dm,win,gama_c,gama_r )
%CBOF_MATCH 此处显示有关此函数的摘要
%   此处显示详细说明
r=win;
CBOFmoder = zeros(r,r);
for i=1:r
    for j=1:r
        T = sqrt(( i - (r+1)/2 )^2 + ( j - (r+1)/2 )^2);
        CBOFmoder( i , j ) = exp(-T/gama_r);
    end
end
[im_h,im_w]=size(im_d);
d_resolve=zeros(1,dm);
for m=(1+(win-1)/2):(im_h-(win-1)/2)
   for n=(1+(win-1)/2):(im_w-(win-1)/2) 
        if im_d(m,n)==-1            
            w_l=(img((m-(win-1)/2):(m+(win-1)/2),(n-(win-1)/2):(n+(win-1)/2),1)-img(m,n,1)).^2+...
            (img((m-(win-1)/2):(m+(win-1)/2),(n-(win-1)/2):(n+(win-1)/2),2)-img(m,n,2)).^2+...
            (img((m-(win-1)/2):(m+(win-1)/2),(n-(win-1)/2):(n+(win-1)/2),3)-img(m,n,3)).^2;
            w_l=sqrt(w_l);
            w_l=exp(-w_l/gama_c).*CBOFmoder;
            for d=1:dm
                d_resolve(1,d)=sum(sum(w_l.*(img((m-(win-1)/2):(m+(win-1)/2),(n-(win-1)/2):(n+(win-1)/2))==d)));
            end
            [~,im_d(m,n)]=max(d_resolve,[],2);
        end
   end
 end
q=im_d;
end

