function DeltaE()
%GITHUB VERSION

outputVideo = VideoWriter('matching_regions_video_out.avi');
v = VideoReader('time_cropped_video.avi');

numFrames = v.NumberOfFrames;

display(['Total frames: ' num2str(numFrames)]);
Resize='on';
%Choose color plane 
prompt = {'(Not USEFUL IN THIS - Enter 1/2/3 for Color Plane : 1. RED 2.GREEN 3.BLUE'};
dlg_title = 'Color Plane (RGB) choice';
num_lines = 1;
defaultans = {'2'};

answer = inputdlg(prompt,dlg_title,num_lines,defaultans,Resize);
  
color_ch = str2double(answer(1));

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

        % Get box coordinates and get mean within the box.
    % 	x1 = round(roiPosition(1));
    % 	x2 = round(roiPosition(1) + roiPosition(3) - 1);
    % 	y1 = round(roiPosition(2));
    % 	y2 = round(roiPosition(2) + roiPosition(4) - 1);
    % 	
    % 	LMean = mean2(LChannel(y1:y2, x1:x2))
    % 	aMean = mean2(aChannel(y1:y2, x1:x2))
    % 	bMean = mean2(bChannel(y1:y2, x1:x2))

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

        blackMaskedImage = matchingColors;
        blackMaskedImage(~binaryImage) = 0;
        y(i)=mean(matchingColors(binaryImage))
    
 elseif i>1 
        i
        rgbImage = frame;                              %display i 
        % Mask the image.
        maskedRgbImage = bsxfun(@times, rgbImage, cast(mask, class(rgbImage)));

        % Convert image from RGB colorspace to lab color space.
        cform = makecform('srgb2lab');
        lab_Image = applycform(im2double(rgbImage),cform);

        % Extract out the color bands from the original image
        % into 3 separate 2D arrays, one for each color component.
        LChannel = lab_Image(:, :, 1); 
        aChannel = lab_Image(:, :, 2); 
        bChannel = lab_Image(:, :, 3); 


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

  
    %USE PREVIOUS TOLERANCE 
   
        % Find pixels within that delta E.
        binaryImage = deltaE <= tolerance;

        % Mask the image with the matching colors and extract those pixels.
        matchingColors = bsxfun(@times, rgbImage, cast(binaryImage, class(rgbImage)));
        %subplot(3, 4, 10);
        %imshow(matchingColors);
     
        %Write each Image to video for output video of matching color
        %regions
        open(outputVideo);
        img = matchingColors;
        writeVideo(outputVideo,img);
        
        blackMaskedImage = matchingColors;
        blackMaskedImage(~binaryImage) = 0;
        y(i)=mean(matchingColors(binaryImage));
            
  end
  
end
 close(outputVideo);
 figure();
 plot(y);
 y;
return

% ---------- End of main function ---------------------------------


%-----------------------------------------------------------------------------
function [xCoords, yCoords, roiPosition] = DrawBoxRegion(handleToImage)
	try
	% Open a temporary full-screen figure if requested.
	enlargeForDrawing = true;
	axes(handleToImage);
	if enlargeForDrawing
		hImage = findobj(gca,'Type','image');
		numberOfImagesInside = length(hImage);
		if numberOfImagesInside > 1
			imageInside = get(hImage(1), 'CData');
		else
			imageInside = get(hImage, 'CData');
		end
		hTemp = figure;
		hImage2 = imshow(imageInside, []);
		[rows columns NumberOfColorBands] = size(imageInside);
		set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
	end
	
	txtInfo = sprintf('Draw a box over the unstained fabric by clicking and dragging over the image.\nDouble click inside the box to finish drawing.');
	text(10, 40, txtInfo, 'color', 'r', 'FontSize', 24);

    % Prompt user to draw a region on the image.
	msgboxw(txtInfo);
	
	% Erase all previous lines.
	if ~enlargeForDrawing
		axes(handleToImage);
% 		ClearLinesFromAxes(handles);
	end
	
	hBox = imrect;
	roiPosition = wait(hBox);
	roiPosition
	% Erase all previous lines.
	if ~enlargeForDrawing
		axes(handleToImage);
% 		ClearLinesFromAxes(handles);
	end

	xCoords = [roiPosition(1), roiPosition(1)+roiPosition(3), roiPosition(1)+roiPosition(3), roiPosition(1), roiPosition(1)];
	yCoords = [roiPosition(2), roiPosition(2), roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4), roiPosition(2)];

	% Plot the mask as an outline over the image.
	hold on;
	plot(xCoords, yCoords, 'linewidth', 2);
	close(hTemp);
	catch ME
		errorMessage = sprintf('Error running DrawRegion:\n\n\nThe error message is:\n%s', ...
			ME.message);
		WarnUser(errorMessage);
	end
	return; % from DrawRegion
	
%-----------------------------------------------------------------------------
function [mask] = DrawFreehandRegion(handleToImage, rgbImage)
try
	fontSize = 14;
	% Open a temporary full-screen figure if requested.
	enlargeForDrawing = true;
	axes(handleToImage);
	if enlargeForDrawing
		hImage = findobj(gca,'Type','image');
		numberOfImagesInside = length(hImage);
		if numberOfImagesInside > 1
			imageInside = get(hImage(1), 'CData');
		else
			imageInside = get(hImage, 'CData');
		end
		hTemp = figure;
		hImage2 = imshow(imageInside, []);
		[rows columns NumberOfColorBands] = size(imageInside);
		set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
	end
	
	message = sprintf('Left click and hold to begin drawing (same as before)\n Lift mouse button to finish ');
	text(10, 40, message, 'color', 'r', 'FontSize', fontSize);

    % Prompt user to draw a region on the image.
	uiwait(msgbox(message));
	
	% Now, finally, have the user freehand draw the mask in the image.
	hFH = imfreehand();

	% Once we get here, the user has finished drawing the region.
	% Create a binary image ("mask") from the ROI object.
	mask = hFH.createMask();
	
	% Close the maximized figure because we're done with it.
	close(hTemp);

	% Display the freehand mask.
	subplot(3, 4, 5);
	imshow(mask);
	title('Binary mask of ROI', 'FontSize', fontSize);
	
	% Mask the image.
	maskedRgbImage = bsxfun(@times, rgbImage, cast(mask,class(rgbImage)));
	% Display it.
	%subplot(3, 4, 6);
	%imshow(maskedRgbImage);
catch ME
	errorMessage = sprintf('Error running DrawFreehandRegion:\n\n\nThe error message is:\n%s', ...
		ME.message);
	WarnUser(errorMessage);
end
return; % from DrawFreehandRegion

%-----------------------------------------------------------------------------
% Get the average lab within the mask region.
function [LMean, aMean, bMean] = GetMeanLABValues(LChannel, aChannel, bChannel, mask)
try
	LVector = LChannel(mask); % 1D vector of only the pixels within the masked area.
	LMean = mean(LVector);
	aVector = aChannel(mask); % 1D vector of only the pixels within the masked area.
	aMean = mean(aVector);
	bVector = bChannel(mask); % 1D vector of only the pixels within the masked area.
	bMean = mean(bVector);
catch ME
	errorMessage = sprintf('Error running GetMeanLABValues:\n\n\nThe error message is:\n%s', ...
		ME.message);
	WarnUser(errorMessage);
end
return; % from GetMeanLABValues

%==========================================================================================================================
function WarnUser(warningMessage)
	uiwait(warndlg(warningMessage));
	return; % from WarnUser()
	
%==========================================================================================================================
function msgboxw(message)
	uiwait(msgbox(message));
	return; % from msgboxw()
	
%==========================================================================================================================
% Plots the histograms of the pixels in both the masked region and the entire image.
function PlotHistogram(maskedRegion, doubleImage, plotNumber, caption)
try
	fontSize = 14;
	subplot(plotNumber(1), plotNumber(2), plotNumber(3)); 

	% Find out where the edges of the histogram bins should be.
	maxValue1 = max(maskedRegion(:));
	maxValue2 = max(doubleImage(:));
	maxOverallValue = max([maxValue1 maxValue2]);
	edges = linspace(0, maxOverallValue, 100);

	% Get the histogram of the masked region into 100 bins.
	pixelCount1 = histc(maskedRegion(:), edges);

	% Get the histogram of the entire image into 100 bins.
	pixelCount2 = histc(doubleImage(:), edges);

	% Plot the  histogram of the entire image.
	plot(edges, pixelCount2, 'b-');
	
	% Now plot the histogram of the masked region.
	% However there will likely be so few pixels that this plot will be so low and flat compared to the histogram of the entire
	% image that you probably won't be able to see it.  To get around this, let's scale it to make it higher so we can see it.
	gainFactor = 1.0;
	maxValue3 = max(max(pixelCount2));
	pixelCount3 = gainFactor * maxValue3 * pixelCount1 / max(pixelCount1);
	hold on;
	plot(edges, pixelCount3, 'r-');
	title(caption, 'FontSize', fontSize);
	
	% Scale x axis manually.
	xlim([0 edges(end)]);
	legend('Whole Img', 'Mask ROI');
	
catch ME
	errorMessage = sprintf('Error running PlotHistogram:\n\n\nThe error message is:\n%s', ...
		ME.message);
	WarnUser(errorMessage);
end
return; % from PlotHistogram

%=====================================================================
% Shows vertical lines going up from the X axis to the curve on the plot.
function lineHandle = PlaceVerticalBarOnPlot(handleToPlot, x, lineColor)
	try
		% If the plot is visible, plot the line.
		if get(handleToPlot, 'visible')
			axes(handleToPlot);  % makes existing axes handles.axesPlot the current axes.
			% Make sure x location is in the valid range along the horizontal X axis.
			XRange = get(handleToPlot, 'XLim');
			maxXValue = XRange(2);
			if x > maxXValue
				x = maxXValue;
			end
			% Erase the old line.
			%hOldBar=findobj('type', 'hggroup');
			%delete(hOldBar);
			% Draw a vertical line at the X location.
			hold on;
			yLimits = ylim;
			lineHandle = line([x x], [yLimits(1) yLimits(2)], 'Color', lineColor, 'LineWidth', 3);
			hold off;
		end
	catch ME
		errorMessage = sprintf('Error running PlaceVerticalBarOnPlot:\n\n\nThe error message is:\n%s', ...
			ME.message);
		WarnUser(errorMessage);
end
	return;	% End of PlaceVerticalBarOnPlot


