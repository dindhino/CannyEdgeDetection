function [out] = gaussian(I)
    m=5; n=5;
    filter = gaussianf(7,1,m,n);
    [out] = imfilter(I,filter);
end