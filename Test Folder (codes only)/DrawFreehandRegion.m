	
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
