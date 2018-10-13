rgb_img=imread('testing images\vlc5.png');
imtest=rgb_img;
seg_img=segmentskin(imtest, hist_avg);
seg_img=im2double(seg_img);
rgb_seg_img=hsv2rgb(seg_img);


g_seg_img=rgb_seg_img(:,:,2);       
[nrows ncols] = size(g_seg_img);
amp=0;
count=0;
 for ii = 1:nrows
   for jj = 1:ncols
      if(g_seg_img(ii,jj) > 0) 
         count=count+1;
         amp(count)=g_seg_img(ii,jj);
      end
   end
 end
 
 y=mean(amp(:))
 