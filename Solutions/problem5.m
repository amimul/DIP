%{

%}
clear all
image = imread('/Users/xuefanyong/Documents/GitHub/DIP/Solutions/images/book_cover.jpg');
image = im2double(image);
[row,col] = size(image);

image_f = fft2(image);
h=blurring_degradation(row,col,0.1,0.1,1);
k=h.*image_f;
image_t = ifft2(k);
image_i=wiener_filter(k,h,0);
figure,imshow(image_i,[]);

image__ = double(im2uint8(abs(image_t))) + gaussian_noise(row,col,0,2);
figure();
imshow(image__,[]);
%{
subplot(131);
imshow(image);
filter = blurring_degradation(2*row,2*col,0.1,0.1,1);
image_ = transfer(image,filter);
subplot(132);
imshow(image_,[]);


%}
function h = blurring_degradation(row,col,a,b,T)
    h = double(zeros(row,col));
    for u  = 1:row
        for v = 1:col
            h(u,v) = T/(pi*(u*a+v*b))*sin(pi*(u*a+v*b))*exp(-1i*pi*(u*a+v*b));
        end
    end
end

function image_t=transfer(image,fliter)
    [row,col]=size(image);
    image_f = fft2(image,2*row,2*col);
    image_f = fftshift(image_f);
    image_t = image_f.*fliter;
    image_t = ifftshift(image_t);
    image_t = ifft2(image_t);
    image_t = image_t(1:row,1:col);
    image_t = abs(image_t);
end

% gaussian noise
function n = gaussian_noise(row,col,ex,sigma)
    n_ = rand([row col]);
    n = n_;
    for r = 1:row
        if mod(col,2)==0
            for c = 1:2:col
                n(r,c) = sqrt(-2*log(n_(r,c)))*cos(2*pi*n_(r,c+1));
                n(r,c+1) = sqrt(-2*log(n_(r,c)))*sin(2*pi*n_(r,c+1));
            end
        else
            for c = 1:2:col-1
                n(r,c) = sqrt(-2*log(n_(r,c)))*cos(2*pi*n_(r,c+1));
                n(r,c+1) = sqrt(-2*log(n_(r,c)))*sin(2*pi*n_(r,c+1));
            end
            n(r,col) = sqrt(-2*log(n_(r,c)))*cos(2*pi*n_(r,1));
        end
    end
    n = n*double(sigma);
    n = n+ex;
end
function image_ = inverse_filter(g,h)
    image_ = g./h;
    image_ = ifft2(image_);
    image_ = abs(image_);
end

function image_ = wiener_filter(g,h,k)
    image_ = ((conj(h).*h)./((conj(h).*h)+k)).*g./h;
    image_ = ifft2(image_);
    image_ = abs(image_);
end