clear all;
outputVideo = VideoWriter('matching_seg_video_LAB_adapt.avi');
v = VideoReader('test_video_3Oct.mp4');
fps=30;
numFrames = v.NumberOfFrames;

display(['Total frames: ' num2str(numFrames)]);
Resize='on';

t = zeros(1, numFrames);    %Save tolerance values
y = zeros(1, numFrames);

% sum only those pixel values which have non-zero intensity values 
for i=1:numFrames,
 frame = read(v, i);
 
 if i==1
        % Continue with the demo.  Do some initialization stuff.
        fontSize = 14;
        figure;
        % Maximize the figure. 
        set(gcf, 'Position', get(0, 'ScreenSize')); 
        set(gcf,'name','Color match for Heart Rate','numbertitle','off') 


        %%BEGIN IMAGE READING - fullImageFileName

        % Read in image into an array.
        i                                                           %display i 
        rgbImage = frame; 
        [rows columns numberOfColorBands] = size(rgbImage); 


        % Display the original image.
        h1 = subplot(3, 4, 1);
        imshow(rgbImage);
        drawnow; % Make it display immediately. 

        %Define MASK ROI for FIRST FRAME only

        % Let user outline region over rgb image.
    % 	[xCoords, yCoords, roiPosition] = DrawBoxRegion(h1);  % Draw a box.
        mask = DrawFreehandRegion(h1, rgbImage);  % Draw a freehand, irregularly-shaped region.

        % Mask the image.
        maskedRgbImage = bsxfun(@times, rgbImage, cast(mask, class(rgbImage)));
        % Display it.
        subplot(3, 4, 5);
        imshow(maskedRgbImage);
        title('User drawn ROI', 'FontSize', fontSize); 

        % Convert image from RGB colorspace to lab color space.
        cform = makecform('srgb2lab');
        lab_Image = applycform(im2double(rgbImage),cform);

        % Extract out the color bands from the original image
        % into 3 separate 2D arrays, one for each color component.
        LChannel = lab_Image(:, :, 1); 
        aChannel = lab_Image(:, :, 2); 
        bChannel = lab_Image(:, :, 3); 

        % Display the lab images.
        subplot(3, 4, 2);
        imshow(LChannel, []);
        title('L Channel', 'FontSize', fontSize);
        subplot(3, 4, 3);
        imshow(aChannel, []);
        title('a Channel', 'FontSize', fontSize);
        subplot(3, 4, 4);
        imshow(bChannel, []);
        title('b Channel', 'FontSize', fontSize);

        % Get the average lab color value.
        [LMean, aMean, bMean] = GetMeanLABValues(LChannel, aChannel, bChannel, mask);

 
        % Make uniform images of only that one single LAB color.
        LStandard = LMean * ones(rows, columns);
        aStandard = aMean * ones(rows, columns);
        bStandard = bMean * ones(rows, columns);

        % Create the delta images: delta L, delta A, and delta B.
        deltaL = LChannel - LStandard;
        deltaa = aChannel - aStandard;
        deltab = bChannel - bStandard;

        % Create the Delta E image.
        % This is an image that represents the color difference.
        % Delta E is the square root of the sum of the squares of the delta images.
        deltaE = sqrt(deltaL .^ 2 + deltaa .^ 2 + deltab .^ 2);

        % Mask it to get the Delta E in the mask region only.
        maskedDeltaE = deltaE .* mask;
        % Get the mean delta E in the mask region
        % Note: deltaE(mask) is a 1D vector of ONLY the pixel values within the masked area.
        meanMaskedDeltaE = mean(deltaE(mask));
        % Get the standard deviation of the delta E in the mask region
        stDevMaskedDeltaE = std(deltaE(mask));
        message = sprintf('mean LAB = (%.2f, %.2f, %.2f).\nmean Delta E in the masked ROI = %.2f +/- %.2f',...
            LMean, aMean, bMean, meanMaskedDeltaE, stDevMaskedDeltaE);	


        % Display the Delta E image - the delta E over the entire image.
        subplot(3, 4, 7);
        imshow(deltaE, []);
        caption = sprintf('Color Match image -\n darker = match with ROI');
        title(caption, 'FontSize', fontSize);

        % Plot the histograms of the Delta E color difference image,
        % both within the masked region, and for the entire image.
        PlotHistogram(deltaE(mask), deltaE, [3 4 8], 'Histogram: DeltaE - ROI & Complete Img.');

        %message = sprintf('%s\n\nRegions close in color to the color you picked\nwill be dark in the Delta E image.\n', message);
        %msgboxw(message);

        % Find out how close the user wants to match the colors.
        prompt = {sprintf('Enter difference between pixels within Delta E range(from the average color in users ROI to whole Image):')};
        dialogTitle = 'Enter Delta E Tolerance (default- mean+ 2 std dev';
        numberOfLines = 1;
        % Set the default tolerance to be the mean delta E in the masked region plus two standard deviations.
        strTolerance = sprintf('%.1f', meanMaskedDeltaE + 3 * stDevMaskedDeltaE);
        defaultAnswer = {strTolerance};  % Suggest this number to the user.
        response = inputdlg(prompt, dialogTitle, numberOfLines, defaultAnswer);
        % Update tolerance with user's response.
        tolerance = str2double(cell2mat(response));
        t(i)=tolerance; 
        % Let them interactively select the threshold with the threshold() m-file.
        % (Note: This is a separate function in a separate file in my File Exchange.)
    % 	threshold(deltaE);

        % Place a vertical bar at the threshold location.
    %	handleToSubPlot8 = subplot(3, 4, 8);  % Get the handle to the plot.
    %	PlaceVerticalBarOnPlot(handleToSubPlot8, tolerance, [0 .5 0]);  % Put a vertical red line there.

        % Find pixels within that delta E.
        binaryImage = deltaE <= tolerance;
        subplot(3, 4, 9);
        imshow(binaryImage, []);
        title('Matching Colors Mask', 'FontSize', fontSize);

        % Mask the image with the matching colors and extract those pixels.
        matchingColors = bsxfun(@times, rgbImage, cast(binaryImage, class(rgbImage)));
        subplot(3, 4, 10);
        imshow(matchingColors);
        caption = sprintf('Matching Colors (Delta E < %.1f)', tolerance);
        title(caption, 'FontSize', fontSize);
        
        %Write each Image to video for output video of matching color
        %regions
     %   outputVideo = VideoWriter('matching_regions_video_out.avi');
        open(outputVideo);
        img = matchingColors;
        writeVideo(outputVideo,img);

        % Mask the image with the NON-matching colors and extract those pixels.
        nonMatchingColors = bsxfun(@times, rgbImage, cast(~binaryImage, class(rgbImage)));
        subplot(3, 4, 11);
        imshow(nonMatchingColors);
        caption = sprintf('Non-Matching Colors (Delta E > %.1f)', tolerance);
        title(caption, 'FontSize', fontSize);

        y(i)=mean2(matchingColors);
    
 elseif i>1 
        i
        
        rgbImage = frame;                              %display i 
        % Mask the image.
  %      maskedMatchingRegions = bsxfun(@times, rgbImage, cast(mask, class(rgbImage)));

        % Convert image from RGB colorspace to lab color space.
        cform = makecform('srgb2lab');
        lab_Image = applycform(im2double(rgbImage),cform);
    
        
        % Extract out the color bands from the original image
        % into 3 separate 2D arrays, one for each color component.
        LChannel = lab_Image(:, :, 1); 
        aChannel = lab_Image(:, :, 2); 
        bChannel = lab_Image(:, :, 3); 


        % Get the average lab color value of matching colors pixels.
      [LMean, aMean, bMean] = GetMeanLABValues(LChannel, aChannel, bChannel, binaryImage);
 %       LMean = mean2(lab_matchingColors(:,:,1))
 %       aMean = mean2(lab_matchingColors(:,:,2))
 %       bMean = mean2(lab_matchingColors(:,:,3))
        

        % Make uniform images of only that one single LAB color.
        LStandard = LMean * ones(rows, columns);
        aStandard = aMean * ones(rows, columns);
        bStandard = bMean * ones(rows, columns);

        % Create the delta images: delta L, delta A, and delta B.
        deltaL = LChannel - LStandard;
        deltaa = aChannel - aStandard;
        deltab = bChannel - bStandard;

        % Create the Delta E image.
        % This is an image that represents the color difference.
        % Delta E is the square root of the sum of the squares of the delta images.
        deltaE = sqrt(deltaL .^ 2 + deltaa .^ 2 + deltab .^ 2);
    
    if i<5
        figure();
        subplot(3,2,1);
        imshow(deltaE,[]);
    end
 % Mask the deltaE image with matching colors region from previous frame
 % binaryImage is the previous frame's matching color region mask
    masked_deltaE_matching_regions = bsxfun(@times,deltaE, cast(binaryImage, class(deltaE)));  
    if i<5  
        subplot(3,2,2);
        imshow(binaryImage);
        subplot(3,2,3);
        imshow(masked_deltaE_matching_regions);
    end  
    
       meanMatchingcolors = mean2(deltaE(binaryImage));  
  %    meanMaskedDeltaE = mean(deltaE(mask));    %1st frame
       stDevMatchingcolors = std2(deltaE(binaryImage));
  %    stDevMaskedDeltaE = std(deltaE(mask));    %1st frame
       
     % add previous frame's tolerance
      
       
       tolerance_new = meanMatchingcolors + 2* stDevMatchingcolors;
      
       tolerance_mem=fps*5;    % for 5 second memory of threshold in system
       if(i>tolerance_mem)
            sum_tolerance=sum(t(i-(tolerance_mem):i));
            meantolerance=sum_tolerance/(tolerance_mem);
           % 60 means 60 last frames or last 2 seconds memory    
       else
            sum_tolerance=sum(t);
            meantolerance=sum_tolerance/i-1;
       end 
        tolerance = (meantolerance+tolerance_new)/2;
        t(i)=tolerance;
        
 %     strTolerance = sprintf('%.1f', meanMaskedDeltaE + 3 * stDevMaskedDeltaE);   
    
        % Find pixels within that delta E.
        binaryImage = deltaE <= tolerance;

        % Mask the image with the matching colors and extract those pixels.
        matchingColors = bsxfun(@times, rgbImage, cast(binaryImage, class(rgbImage)));
        %subplot(3, 4, 10);
        %imshow(matchingColors);
       if i<5
         subplot(3,2,4);
         imshow(binaryImage);
         subplot(3,2,5);
         imshow(matchingColors);

       end
        %Write each Image to video for output video of matching color
        %regions
        open(outputVideo);
        img = matchingColors;
        writeVideo(outputVideo,img);
        
        y(i)=mean2(matchingColors);
            
  end
  
end
 close(outputVideo);
 figure();
 plot(y);
 y;

% ---------- End of main function ---------------------------------



