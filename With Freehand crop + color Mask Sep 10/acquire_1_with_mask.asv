function y = acquire(video_file)

if ischar(video_file),
    display(['Loading file ' video_file]);
    v = VideoReader(video_file);
else
    v = video_file;
end

outputVideo = VideoWriter('segment_vid_hsv-g.avi');

numFrames = v.NumberOfFrames;

display(['Total frames: ' num2str(numFrames)]);
Resize='on';


display(['Total frames: ' num2str(numFrames)]);

y = zeros(1, numFrames);

%(1)Either set training images again or(2) use previously trained histogram model
%Step - Call main training function to return hist avg [Only once]
     %  hist_avg= main_training();        (1)
        hist_avg    ;                   % (2)
        
% sum only those pixel values which have non-zero intensity values 
for i=1:numFrames,
 frame = read(v, i);
      
        %%BEGIN IMAGE READING - fullImageFileName

        % Read in image into an array.
        i                                                      %display i 
        rgbImage = frame; 
       
        imageHsv = rgb2hsv(rgbImage);
        % Extract out the color bands from the original image
        % into 3 separate 2D arrays, one for each color component.
        %LChannel = lab_Image(:, :, 1); 
        %aChannel = lab_Image(:, :, 2); 
        %bChannel = lab_Image(:, :, 3); 
        
        HChannel = imageHsv(:, :, 1);
        SChannel = imageHsv(:, :, 2);
        VChannel = imageHsv(:, :, 3);
    if i==1 
        % Display the lab images.
        figure;
        subplot(2, 4, 1);
        imshow(rgbImage);
        subplot(2, 4, 2);
        imshow(HChannel, []);
        title('H Channel');
        subplot(2, 4, 3);
        imshow(SChannel, []);
        title('S Channel');
        subplot(2, 4, 4);
        imshow(VChannel, []);
        title('V Channel');
    end
 %Step -  Get threshold from user maybe
        
  %Step - call main testing part on video frame to return seg image
        imtest_skin=main_testing(rgbImage,hist_avg);
        
        if i==1
            subplot(2, 4, 5);
            imshow(imtest_skin, []);
            title('Segmented Img');
        end
        %Write each Image to video for output video of matching color
        %regions
     %   outputVideo = VideoWriter('matching_regions_video_out.avi');
     
     
        open(outputVideo);
        seg_img = imtest_skin;
        
        
        writeVideo(outputVideo,seg_img);

        % Consider various channels for mean img value for final y
        seg_img=im2double(seg_img);
        rgb_seg_img=hsv2rgb(seg_img);
           
       
 %      hueImage = seg_img(:,:, 1);        %Extract only Hue channel
 %      meanHueImg = mean2(hueImage);
       
       greenImage = rgb_seg_img(:,:,1);     %Extract only Green channel
       meanGreenImg = mean2(greenImage);
       
       if i==1                              %Plot the channel image
            subplot(2, 4, 6);
            imshow(greenImage, []);
            title('Segmented Green channel Img');
       end
       
       
 y(i)=meanGreenImg;
 
end
 close(outputVideo);
 figure();
 plot(y);
 y;

