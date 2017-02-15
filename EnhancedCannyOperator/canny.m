% Name: Dindin Dhino Alamsyah
% NIM : 1301144360
% TA-RMB

% Input Parameters: 
% img = gambar yang mau di proses
% sigma = standar deviasi untuk gaussian
% window_size = ukuran kernel gaussian 
% threshold = dipake abis non-maximum suppression

% img=imread('stegoimage.bmp');
img=imread('coverimage.bmp');
sigma = 2; 
window_size = 4;
threshold = 0.1; 


% resize gambar biar gakegedean trs convert ke grayscale
resized_img = imresize(img, [512 NaN]);
resized_img_db = im2double(resized_img);
resized_gray_image=rgb2gray(resized_img_db);

% simpan size gambarnya buat non-maxima suppression 
[rows, cols] = size(resized_gray_image);

% Step 1: 
% filter gambar pake gaussian buat x sama y trs di smoothing pake gaussian
gaussian_x= fspecial('gaussian', [1 window_size], sigma);
gaussian_y= fspecial('gaussian', [window_size 1], sigma);
smoothed_image = conv2(gaussian_x, gaussian_y, resized_gray_image, 'same');
figure, imshow(smoothed_image), title('Step 1: Image Smoothing using Gaussian Filters');
pause;

% Step 2
% itung gradient magnitude sama gradient direction
sobel_filter = fspecial('sobel');   
img_dy = imfilter(smoothed_image, sobel_filter, 'conv');
img_dx = imfilter(smoothed_image, sobel_filter', 'conv'); 
grad_mag = sqrt(img_dx.^2+img_dy.^2);
grad_direction = atan2(img_dy, img_dx);

figure, imshow(grad_mag), title('Step 2: Gradient Magnitude');
pause;

figure, imshow(grad_direction), title('Step 2 : Gradient direction of the smoothed image before gradient direction was rounded to one of  0, 45, 90, and 135 degrees');
pause;

% Step 3
% Non max suppression

% Step 3a
% deketin setiap sudut di grad_direction matriks.
% Sudut grad_direction tersebut dibulatkan ke bawah atau ke atas
% untuk masing-masing sudut: 0, 45, 90, atau 135.
% sudut dibulatkan ke dalam 22,5 derajat, arah forward sama reverse.
grad_direction = (grad_direction * 180)/pi; 
approximated_grad_direction = zeros(rows, cols);
for row = 1:rows
    for col = 1:cols
        
        if((grad_direction(row,col) > -22.5 && grad_direction(row,col) < 22.5) || (grad_direction(row,col) > 157.5 && grad_direction(row,col) < -157.5))
            approximated_grad_direction(row,col) = 0;
        end
        if((grad_direction(row,col) > 22.5 && grad_direction(row,col) < 67.5) || (grad_direction(row,col) > -157.5 && grad_direction(row,col) < -112.5))
            approximated_grad_direction(row,col) = 45;
        end
        if((grad_direction(row,col) > 67.5 && grad_direction(row,col) < 112.5) || (grad_direction(row,col) > -112.5 && grad_direction(row,col) < -67.5))
            approximated_grad_direction(row,col) = 90;
        end
        if((grad_direction(row,col) > 112.5 && grad_direction(row,col) < 157.5) || (grad_direction(row,col) > -67.5 && grad_direction(row,col) < -22.5))
            approximated_grad_direction(row,col) = 135;
        end
    end
end

figure, imshow(approximated_grad_direction), title('Step 2 : Gradient direction of the smoothed image after gradient direction was rounded to one of  0, 45, 90, and 135 degrees');
pause;

% Step 3b
% non-maximum suppression. 
% mengetahui arah gradien dari pixel
% pixel gradien magintude dibandingkan ke tetangga sepanjang normal ke arah gradien
% kalau besar gradien lebih kecil dari kedua tetangga, besar gradien pixelnya diubah jadi 0 
local_maxima = zeros(rows,cols);
for row = 2:rows-1
    for col = 2:cols-1

        switch(approximated_grad_direction(row,col))
            
            case 0
                if(grad_mag(row,col) > grad_mag(row, col+1) && grad_mag(row,col) > grad_mag(row, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end 
            case 45
                if(grad_mag(row,col) > grad_mag(row+1, col+1) && grad_mag(row,col) > grad_mag(row-1, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end
             
            case 90
                if(grad_mag(row,col) > grad_mag(row, col+1) && grad_mag(row,col) > grad_mag(row, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end
                
            case 135
                if(grad_mag(row,col) > grad_mag(row-1, col+1) && grad_mag(row,col) > grad_mag(row+1, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end
            otherwise
                %do nothing
        end 
            
    end
end

% Step 4: bandingin gambar suppressed/non suppressed sama threshold. 
% kalo grad magnitude lebih kecil dari threshold, ubah jadi 0
local_maxima_with_threshold = local_maxima;
if threshold > 0
    for row = 1:rows
        for col = 1: cols
            if(local_maxima_with_threshold(row,col) < threshold)
                local_maxima_with_threshold(row,col)=0;
            end
        end
    end
end

figure, imshow(local_maxima_with_threshold), title('Step 3 : Suppressed/non suppressed pixels image with or without threshold')
pause;

% convert gambar non-suppressed sama suppressed jadi citra biner
level=graythresh(local_maxima_with_threshold);
canny_image=im2bw(local_maxima_with_threshold,level);
figure, imshow(canny_image), title('Step 4: Edge Detection');