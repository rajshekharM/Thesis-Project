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
