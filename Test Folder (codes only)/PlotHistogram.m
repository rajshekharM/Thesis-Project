	
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


