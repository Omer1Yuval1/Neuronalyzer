function [ImP,BW,closeBW] = Find_Center_Line(Workspace)
	
	
	Im = Workspace.Workspace.Image0;
	Im = Im(:,:,1);
	[Sr,Sc,Sz] = size(Im);
	ImP = zeros(Sr,Sc);
	
	Nv = numel(Workspace.Workspace.Vertices);
	R = 100; % 400.*Workspace.Workspace.User_Input.Scale_Factor;
	
	V = [Workspace.Workspace.Vertices.Coordinate];
	Xv = V(1:2:end-1);
	Yv = V(2:2:end);
	
	Angles = (1:360)';
	Perim = [R.*cosd(Angles) , R.*sind(Angles)];
	Lp = length(Angles);
	
	%{
	for x=1:size(ImP,2)
		for y=1:size(ImP,1)
			Dxy = ( (x - Xv).^2 + (y - Yv).^2 ).^.5;
			Perim_i = Perim + [x,y]; % Traslate circle coordinates to the current center (pixel).
			Fp = find([Perim_i(:,1)] <= Sc & [Perim_i(:,1)] > 1 & [Perim_i(:,2)] <= Sr & [Perim_i(:,2)] > 1); % Find circle coordinates within the image boundaries.
			
			ImP(y,x) = length(find(Dxy < R)) ./ (length(Fp) ./ Lp); % Save the # of vertices as the pixel value. Multiply by the portion of the circle that is within the image boundaries.
			% ImP(y,x) = ImP(y,x) + Im(y,x) ./ 10;
		end
	end
	%}
	
	%
	BW = imbinarize(Im,0.3);
	se = strel('disk',90);
	closeBW = imclose(BW,se);
	% figure; imshow(closeBW);
	
	%{
	[Fy,Fx] = find(closeBW);
	
	for x=1:size(ImP,2)
		for y=1:size(ImP,1)
			
			Dxy = ( (x - Fx).^2 + (y - Fy).^2 ).^.5;
			
			Perim_i = Perim + [x,y]; % Traslate circle coordinates to the current center (pixel).
			Fp = find([Perim_i(:,1)] <= Sc & [Perim_i(:,1)] > 1 & [Perim_i(:,2)] <= Sr & [Perim_i(:,2)] > 1); % Find circle coordinates within the image boundaries.
			
			ImP(y,x) = length(find(Dxy < R)) ./ (length(Fp) ./ Lp); % Save the # of 1-pixels as the pixel value. Multiply by the portion of the circle that is within the image boundaries.
			% ImP(y,x) = ImP(y,x) + Im(y,x) ./ 10;
		end
	end
	% BW = imbinarize(ImP,0.6); % figure; imshow(BW);
	%}
	
	ImP = rescale(ImP);
	BW = imbinarize(ImP,0.6);
	%}
end