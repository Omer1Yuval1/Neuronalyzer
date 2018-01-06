function Cxy = Find_CB_Center(Workspace1)
	
	% Convert to BW and do opening & closing:
	I1 = im2bw(Workspace1.Image0,Workspace1.Parameters(1).Cell_Body(1).BW_Threshold);
	sec = strel('disk',ceil(Workspace1.Parameters(1).Cell_Body(1).Open_Close_Disk/Workspace1.User_Input.Scale_Factor));
	% sec = strel('disk',5); % TODO: Use scalebar.
	I3 = imopen(I1,sec); % I2 = bwareaopen(I1,5);
	% I3 = imclose(I2,sec); % BW image in which only the cell body pixels are 1.
	
	% disp(ceil(Workspace1.Parameters(1).Cell_Body(1).Open_Close_Disk/Workspace1.User_Input.Scale_Factor));
	
	I3a = I3;
	CC3 = bwconncomp(I3);
	Cs = size(CC3.PixelIdxList{1,1},1);
	Ci = 1;
	for i=2:numel(CC3.PixelIdxList) % Find the largesr component.
		if(size(CC3.PixelIdxList{1,i},1) > Cs)
			Cs = size(CC3.PixelIdxList{1,i},1);
			Ci = i;
		end
	end % TODO: use cellfun?
	
	assignin('base','CC3',CC3);
	
	[Cy,Cx] = ind2sub(size(I1),CC3.PixelIdxList{1,Ci});
	Cxy = [mean(Cx),mean(Cy)];
	
	% TODO: delete (just use the largest one).
	for i=1:numel(CC3.PixelIdxList) % Delete all the other components.
		if(i == Ci)
			continue;
		end
		I3a(CC3.PixelIdxList{1,i}) = 0;
	end % TODO: use cellfun?
	
	
	if(1)
		figure(1);
		imshow(Workspace1.Image0);
		hold on;
		plot(Cx,Cy,'.g');
		plot(Cxy(1),Cxy(2),'.r');
	end
	if(0) % Display the cell body:
		figure(2);
		imshow(I3);
		
		figure(3);
		imshow(I3a);
	end
	
end