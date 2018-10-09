function y = acquire(video_file)

if ischar(video_file),
    display(['Loading file ' video_file]);
    v = VideoReader(video_file);
else
    v = video_file;
end

numFrames = v.NumberOfFrames;

display(['Total frames: ' num2str(numFrames)]);
Resize='on';
%Choose color plane 
prompt = {'Enter 1/2/3 for Color Plane : 1. RED 2.GREEN 3.BLUE'};
dlg_title = 'Color Plane (RGB) choice';
num_lines = 1;
defaultans = {'2'};

answer = inputdlg(prompt,dlg_title,num_lines,defaultans,Resize);
  
color_ch = str2double(answer(1));

y = zeros(1, numFrames);

% sum only those pixel values which have non-zero intensity values 
for i=1:numFrames,
    if(mod(i,100)==0)
    display(['Processing ' num2str(i) '/' num2str(numFrames)]);
    end
    frame = read(v, i);
    
    if color_ch==1
        colorPlane = frame(:, :, 1);
    elseif color_ch==2
        colorPlane = frame(:, :, 2);
    elseif color_ch==3
        colorPlane = frame(:, :, 3);
    end    
            
    if(i==1) 
        figure();
        fontSize = 16;
        % Read in the image frame to be cropped
        grayImage = colorPlane;
        subplot(2, 3, 1);
        imshow(grayImage, []);
        title('Original Image', 'FontSize', fontSize);
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
        message = sprintf('Left click and hold to select area.\n Lift the mouse button to finish');
        uiwait(msgbox(message));
        hFH = imfreehand();
        % Create a binary image ("mask") from the ROI object.
        binaryImage = hFH.createMask();
        % Display the freehand mask.
        subplot(2, 3, 2);
        imshow(binaryImage);
        title('Binary mask of the region', 'FontSize', fontSize);
        % Calculate the area, in pixels, that they drew.
        numberOfPixels1 = sum(binaryImage(:))
        % Another way to calculate it that takes fractional pixels into account.
        numberOfPixels2 = bwarea(binaryImage)
        % Get coordinates of the boundary of the freehand drawn region.
        structBoundaries = bwboundaries(binaryImage);
        xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
        coloum = xy(:, 2); % Columns.
        row = xy(:, 1); % Rows.
        subplot(2, 3, 1); % Plot over original image.
        hold on; % Don't blow away the image.
        plot(coloum, row, 'LineWidth', 2);
        % Burn line into image by setting it to 255 wherever the mask is true.
        burnedImage = grayImage;
        burnedImage(binaryImage) = 255;
        % Display the image with the mask "burned in."
        subplot(2, 3, 3);
        imshow(burnedImage);
        caption = sprintf('New image with\nmask burned into image');
        title(caption, 'FontSize', fontSize);
        % Mask the image and display it.
        % Will keep only the part of the image that's inside the mask, zero outside mask.
        blackMaskedImage = grayImage;
        blackMaskedImage(~binaryImage) = 0;
        subplot(2, 3, 4);
        imshow(blackMaskedImage);
        title('Masked Outside Region', 'FontSize', fontSize);
        % Calculate the mean
        mean_pixel_value = mean(blackMaskedImage(binaryImage));
        % Report results.
        y(i)=mean_pixel_value;
        
        message = sprintf('Mean value within drawn area = %.3f\nNumber of pixels = %d\nArea in pixels = %.2f', ...
        mean_pixel_value, numberOfPixels1, numberOfPixels2);
        msgbox(message);
        % Now do the same but blacken inside the region.
        insideMasked = grayImage;
        insideMasked(binaryImage) = 0;
        subplot(2, 3, 5);
        imshow(insideMasked);
        title('Masked Inside Region', 'FontSize', fontSize);
        % Now crop the image.
        topLine = min(coloum);
        bottomLine = max(coloum);
        leftColumn = min(y);
        rightColumn = max(y);
        width = bottomLine - topLine + 1;
        height = rightColumn - leftColumn + 1;
        croppedImage = imcrop(blackMaskedImage, [topLine, leftColumn, width, height]);
        % Display cropped image.
        subplot(2, 3, 6);
        imshow(croppedImage);
        title('Cropped Image', 'FontSize', fontSize);

    else

       % Read in the new image frame to be cropped
        grayImage = colorPlane;
        % Will keep only the part of the image that's inside the mask, zero outside mask.
        blackMaskedImage = grayImage;
        blackMaskedImage(~binaryImage) = 0;
       
        % Calculate the mean
        % Report results.
        mean_pixel_value = mean(blackMaskedImage(binaryImage));
       
        y(i)=mean_pixel_value;
        if(mod(i,100)==0)
            y(i)
        end
        
    %    message = sprintf('Mean value within drawn area = %.3f\nNumber of pixels = %d\nArea in pixels = %.2f', ...
    %    meanGL, numberOfPixels1, numberOfPixels2);
    %    msgbox(message);
     
    end
    
     %       y(i) = sum(sum(colorPlane)) / (size(frame, 1) * size(frame, 2));   
end


display('Signal acquired.');
display(' ');
display(['Sampling rate is ' num2str(v.FrameRate) '. You can now run process on your_signal_variable, ' num2str(v.FrameRate) ')']);


