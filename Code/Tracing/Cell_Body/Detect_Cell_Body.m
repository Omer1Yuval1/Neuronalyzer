function [CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Im,GS2BW_Threshold,Scale_Factor,Plot1)
	
	Perimeter_Connectivity = 4;
	% GS2BW_Threshold = 0.9;
	Open_Close_Disk = 1.5;
	Dilation_STREL_Size = 10;
	
	% Convert to BW and do opening & closing:
	I1 = im2bw(Im,GS2BW_Threshold);
	sec = strel('disk',ceil(Open_Close_Disk/Scale_Factor)); % TODO: Use scalebar.
	I2 = imopen(I1,sec); % I2 = bwareaopen(I1,5);
	I3 = imclose(I2,sec); % BW image in which only the cell body pixels are 1.
	
	I3a = I3;
	CC3 = bwconncomp(I3);
	
	if(length(CC3.PixelIdxList))
		Cs = size(CC3.PixelIdxList{1,1},1);
		Ci = 1;
		for i=2:numel(CC3.PixelIdxList) % Find the largest component.
			if(size(CC3.PixelIdxList{1,i},1) > Cs)
				Cs = size(CC3.PixelIdxList{1,i},1);
				Ci = i;
			end
		end
		for i=1:numel(CC3.PixelIdxList) % Delete all the other components.
			if(i == Ci)
				continue;
			end
			I3a(CC3.PixelIdxList{1,i}) = 0;
		end
		I3a = imdilate(I3a,strel('square',Dilation_STREL_Size)); % Dilate the CB object to extend its perimeter a little bit.
		
		% Find the perimeter pixels:
		I4 = bwperim(I3a,Perimeter_Connectivity); % Perimeter pixels.
		[rows,cols] = find(I4==1); % Coordinates of all 1-pixels in the perimeter image (I4).
		CB_Perimeter = [cols,rows];
		CB_Perimeter_Ind = find(I4==1); % Linear indices of all 1-pixels in the perimeter image (I4).
		
		% CB_Pixels = CC3.PixelIdxList{1,Ci};
		CB_Pixels = find(I3a == 1);
	else
		CB_Pixels = [];
		CB_Perimeter = [];
	end
	
	if(Plot1)
		figure;
		imshow(Im);
		set(gca,'YDir','normal');
	end
	
	if(Plot1)
		hold on;
		[CBy,CBx] = ind2sub(size(Im),CB_Pixels);
		plot(CBx,CBy,'.g');
		plot(cols,rows,'.b');
		figure(1);
		
		D = 60;
		CB_Center = [mean(CB_Perimeter(:,1)),mean(CB_Perimeter(:,2))];
		axis([CB_Center(1)-D,CB_Center(1)+D,CB_Center(2)-D,CB_Center(2)+D]);
	end
	
	if(Plot1 == 3)
		% Display the cell body:
		% figure(2);
		% imshow(I3);
		% imshow(I1);
		% return;
		
		% The image without the cell body: 
		F = find(I3 == 1);
		I6 = Im;
		I6(F) = 0;
	end
	
end