function Binary_Image = Update_Binary_Image(Im_CNN,Binary_Image,Min_Object_Size,Reset_Flag)
	
	if(Reset_Flag)
		Binary_Image = zeros(size(Im_CNN));
		Binary_Image(Im_CNN == "Neuron") = 1; % Set to 1 pixels that are above the preset threshold.
	end
	
	% Delete sub-threshold objects from the binary image:
	CC = bwconncomp(Binary_Image); % Find connected components in the binary image.
	Nc = cellfun(@length,CC.PixelIdxList); % Number of connected objects.
	Fc = find(Nc <= Min_Object_Size); % Find sub-threshold object sizes.
	for c=Fc % For each sub-threshold object.
		Binary_Image(CC.PixelIdxList{1,c}) = 0; % Set the object's pixels to 0.
	end
end