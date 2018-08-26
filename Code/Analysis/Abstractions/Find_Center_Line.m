function [V12,V21,BW,closeBW] = Find_Center_Line(Im,closeBW)
	
	Dxy = 25;
	
	Im = Im(:,:,1);
	[Sr,Sc,Sz] = size(Im);
	% ImP = zeros(Sr,Sc);
	
	% Nv = numel(Workspace.Workspace.Vertices);
	% R = 100; % 400.*Workspace.Workspace.User_Input.Scale_Factor;
	
	% V = [Workspace.Workspace.Vertices.Coordinate];
	% Xv = V(1:2:end-1);
	% Yv = V(2:2:end);
	
	% Angles = (1:360)';
	% Perim = [R.*cosd(Angles) , R.*sind(Angles)];
	% Lp = length(Angles);
	
	%
	if(nargin == 1)
		BW = imbinarize(Im,0.3);
		se = strel('disk',90);
		closeBW = imclose(BW,se);
	else
		BW = zeros(Sr,Sc);
	end
	ImP = bwperim(closeBW);
	% figure; imshow(closeBW);
	
	[Nr,Nc] = Find_Blank_Boundaries(Im);
	
	
	
	[Fc1_Y,Fc1_X] = find(ImP(:,Nc(1):Nc(1)+Dxy)); % Find non-zero pixel in the BW image along the first non-empty column from the left.
	[Fc2_Y,Fc2_X] = find(ImP(:,Nc(2)-Dxy:Nc(2))); % Find non-zero pixel in the BW image along the first non-empty column from the right.
	
	[Fr1_Y,Fr1_X] = find(ImP(Nr(1):Nr(1)+Dxy,:)); % Find non-zero pixel in the BW image along the first non-empty row from the bottom.
	[Fr2_Y,Fr2_X] = find(ImP(Nr(2)-Dxy:Nr(2),:)); % Find non-zero pixel in the BW image along the first non-empty column from the top.
	
	% Translation back to the image coordinates:
	Fc1_X = Fc1_X+Nc(1)-1;
	Fc2_X = Fc2_X+Nc(2)-Dxy-1;
	Fr1_Y = Fr1_Y+Nr(1)-1;
	Fr2_Y = Fr2_Y+Nr(2)-Dxy-1;
	
	% if(any(Fc1_X < 1) || any(Fc2_X > Sc) || any(Fr1_Y < 1) || any(Fr2_Y > Sr))
	if(any(Fr1_X < 1) || any(Fr2_X > Sr) || any(Fc1_Y < 1) || any(Fc2_Y > Sc))
		V12 = [];
		V21 = [];
		disp('Coordinates Exceed Image Boundaries');
		return;
	end
	
	Fc1 = sub2ind([Sr,Sc],Fc1_Y,Fc1_X);
	Fc2 = sub2ind([Sr,Sc],Fc2_Y,Fc2_X);
	Fr1 = sub2ind([Sr,Sc],Fr1_Y,Fr1_X);
	Fr2 = sub2ind([Sr,Sc],Fr2_Y,Fr2_X);
	
	C = {Fc1',Fc2',Fr1',Fr2'};
	L = cellfun(@length,C);
	[L,I] = sort(L,'descend');
	
	C = [C{I(1)},C{I(2)}];
	
	ImP2 = ImP;
	ImP2(C) = 0;
	
	CC_ImP2 = bwconncomp(ImP2);
	
	if(length(CC_ImP2.PixelIdxList) < 2)
		V12 = [];
		V21 = [];
		disp('Could Not Detect 2 Objects.');
		return;
	end
	
	[C1_Y,C1_X] = ind2sub([Sr,Sc],CC_ImP2.PixelIdxList{1});
	[C2_Y,C2_X] = ind2sub([Sr,Sc],CC_ImP2.PixelIdxList{2});
	
	V12 = zeros(length(C1_Y),2);
	for i=1:length(C1_Y)
		D = ( (C1_X(i) - C2_X).^2 + (C1_Y(i) - C2_Y).^2 ).^(.5);
		F = find(D == min(D));
		
		% A2 = [C2_X(F(1)),C2_Y(F(1))];
		V12(i,:) = [mean([C1_X(i),C2_X(F(1))]) , mean([C1_Y(i),C2_Y(F(1))])];
	end
	
	V21 = zeros(length(C2_Y),2);
	for i=1:length(C2_Y)
		D = ( (C2_X(i) - C1_X).^2 + (C2_Y(i) - C1_Y).^2 ).^(.5);
		F = find(D == min(D));
		
		% A2 = [C2_X(F(1)),C2_Y(F(1))];
		V21(i,:) = [mean([C2_X(i),C1_X(F(1))]) , mean([C2_Y(i),C1_Y(F(1))])];
	end
	
	% assignin('base','V12',V12);
	% assignin('base','V21',V21);

	
	if(0)
		
		figure; imshow(ImP2);
		% figure; imshow(ImP);
		
		% hold on; plot(Fc1_X,Fc1_Y,'.r');
		% hold on; plot(Fc2_X,Fc2_Y,'.r');
		% hold on; plot(Fr1_X,Fr1_Y,'.r');
		% hold on; plot(Fr2_X,Fr2_Y,'.r');
		
		hold on;
		% plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);
		scatter(V12(:,1),V12(:,2),10,jet(size(V12,1)),'filled');
		
		% plot(V21(:,1),V21(:,2),'.g','MarkerSize',30);
		scatter(V21(:,1),V21(:,2),10,jet(size(V21,1)),'filled');
	end
	
	%{
	ImP = rescale(ImP);
	BW = imbinarize(ImP,0.6);
	%}
	
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
end