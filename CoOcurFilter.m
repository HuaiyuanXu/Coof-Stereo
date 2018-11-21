function imgf=CoOcurFilter(img, params,coc_mat)
nchl=size(img, 3);
img_min=min(img(:));
if (img_min<0)
    img=img+img_min;
end
if nchl==1
    imgf=CoOcurFilterGray(img, params,coc_mat);
else
    imgf=CoOcurFilterColor(img, params);
end