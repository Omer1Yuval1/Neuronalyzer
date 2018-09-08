function [Final_Curve,Approved] = Find_Center_Line(Im,BW)
	
	% D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\DEG_for_Menorah_analyser_Filtered_Format_Names
	
	% TODO:
		% Get rid of very small objects (see image 6 BW).
		% Detect the 2 longest perimeter lines after deleting perimeter pixels.
		% Then delete those and find the other two. also determine the connectivity (vertices) between all 4.
		% Finally, for the 2 short ones, take the mid pixels and use them to divide the whole perimenter into two sub-parts.
		% Then do the distance thing.
	
	Approved = 0;
	Final_Curve = [];
	Distances_STD_Threshold = 10;
	Eval_Factor = 4;
	
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
	
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	% Convert grayscale to BW and close to get a single blob:
	Max_Obj_Size = 20; % TODO: scale.
	if(nargin == 1)
		BW = imbinarize(Im,0.3); % Grayscale to BW.
	end
	BW = bwareaopen(BW,Max_Obj_Size); % Getting rid of small objects.
	
	se = strel('disk',90);
	closeBW = imclose(BW,se);
	
	ImP = bwperim(closeBW); % figure; imshow(closeBW);
	
	% Find the inner-most rows and columns for which the std is 0:
	[Nr,Nc] = Find_Blank_Boundaries(closeBW);
	
	% Find perimeter pixels along the first non-empty (with some tolerance Dxy)...:
	[Fc1_Y,Fc1_X] = find(ImP(:,Nc(1):Nc(1)+Dxy)); % ...column from the left.
	[Fc2_Y,Fc2_X] = find(ImP(:,Nc(2)-Dxy:Nc(2))); % ...column from the right.
	[Fr1_Y,Fr1_X] = find(ImP(Nr(1):Nr(1)+Dxy,:)); % ...row from the bottom.
	[Fr2_Y,Fr2_X] = find(ImP(Nr(2)-Dxy:Nr(2),:)); % ...row from the top.
	
	% Translation back to the image coordinates (the other 4 were used in full (:) and do not need conversion):
	Fc1_X = Fc1_X+Nc(1)-1;
	Fc2_X = Fc2_X+Nc(2)-Dxy-1;
	Fr1_Y = Fr1_Y+Nr(1)-1;
	Fr2_Y = Fr2_Y+Nr(2)-Dxy-1;
	
	% If any of the above coordinates exceeds the image boundaries, terminate:
	if(any(Fr1_X < 1) || any(Fr2_X > Sr) || any(Fc1_Y < 1) || any(Fc2_Y > Sc))
		V12 = [];
		V21 = [];
		figure(1); clf(1);
		disp('Coordinates Exceed Image Boundaries');
		return;
	end
	
	% Convert edge perimenter coordinates to linear indices:
	Fc1 = sub2ind([Sr,Sc],Fc1_Y,Fc1_X);
	Fc2 = sub2ind([Sr,Sc],Fc2_Y,Fc2_X);
	Fr1 = sub2ind([Sr,Sc],Fr1_Y,Fr1_X);
	Fr2 = sub2ind([Sr,Sc],Fr2_Y,Fr2_X);
	
	% Now temporarily erase those *edge* perimeter pixels and find all other objects that form:
	ImP_No_Edges = ImP;
	ImP_No_Edges(Fc1) = 0;
	ImP_No_Edges(Fc2) = 0;
	ImP_No_Edges(Fr1) = 0;
	ImP_No_Edges(Fr2) = 0;
	CC_ImP_No_Edges = bwconncomp(ImP_No_Edges);
	
	if(length(CC_ImP_No_Edges.PixelIdxList) < 2)
		V12 = [];
		V21 = [];
		figure(1); clf(1);
		disp('Could Not Detect 2 Objects.');
		return;
	end
	
	% Sort perimeter objects by size and find the two largest ones (the two longitudinal perimeter curves):
	L = cellfun(@length,CC_ImP_No_Edges.PixelIdxList);
	[L,I] = sort(L,'descend');
	Two_Longest_Perims = [CC_ImP_No_Edges.PixelIdxList{I(1)}',CC_ImP_No_Edges.PixelIdxList{I(2)}'];
	ImP2 = ImP;
	ImP2(Two_Longest_Perims) = 0;
	
	ImP_Two_Longest_Perims = zeros(Sr,Sc);
	ImP_Two_Longest_Perims(Two_Longest_Perims) = 1;
	
	CC_ImP2 = bwconncomp(ImP2); % Find the the two smaller perimeter parts.
	[y1,x1] = ind2sub([Sr,Sc],CC_ImP2.PixelIdxList{1}); % Convert to subscripts.
	[y2,x2] = ind2sub([Sr,Sc],CC_ImP2.PixelIdxList{2}); % ".
	Mxy1 = [mean(x1),mean(y1)]; % Mean coordinate.
	Mxy2 = [mean(x2),mean(y2)]; % ".
	
	D1 = Distance_Func(Mxy1(1),Mxy1(2),x1,y1);
	D2 = Distance_Func(Mxy2(1),Mxy2(2),x2,y2);
	F1 = find(D1 == min(D1));
	F2 = find(D2 == min(D2));
	Pxy1 = [x1(F1),y1(F1)]; % The coordinate of the connected object closest to the mean coordinate.
	Pxy2 = [x2(F2),y2(F2)]; % ".
	
	ImP_Final = ImP;
	ImP_Final(Pxy1(2),Pxy1(1)) = 0;
	ImP_Final(Pxy2(2),Pxy2(1)) = 0;
	CC_Final = bwconncomp(ImP_Final);
	CC_Final = bwconncomp(ImP_Two_Longest_Perims);
	
	[C1_Y,C1_X] = ind2sub([Sr,Sc],CC_Final.PixelIdxList{1}); % The coordinates of the first final perimeter object.
	[C2_Y,C2_X] = ind2sub([Sr,Sc],CC_Final.PixelIdxList{2}); % The coordinates of the second final perimeter object.
	
	V12 = zeros(length(C1_Y),2);
    D12 = zeros(length(C1_Y),1);
	for i=1:length(C1_Y)
		D = ( (C1_X(i) - C2_X).^2 + (C1_Y(i) - C2_Y).^2 ).^(.5);
		F = find(D == min(D));
		D12(i) = D(F(1));
		% A2 = [C2_X(F(1)),C2_Y(F(1))];
		V12(i,:) = [mean([C1_X(i),C2_X(F(1))]) , mean([C1_Y(i),C2_Y(F(1))])];
	end
	
	% Note: this is currently not used:
	V21 = zeros(length(C2_Y),2);
	for i=1:length(C2_Y)
		D = ( (C2_X(i) - C1_X).^2 + (C2_Y(i) - C1_Y).^2 ).^(.5);
		F = find(D == min(D));
		
		% A2 = [C2_X(F(1)),C2_Y(F(1))];
		V21(i,:) = [mean([C2_X(i),C1_X(F(1))]) , mean([C2_Y(i),C1_Y(F(1))])];
	end
	
	Final_Curve = [ [Pxy1(1),Pxy1(2)] ; V12 ; [Pxy2(1),Pxy2(2)]];
	Fit_Object = cscvn(Final_Curve'); % Fit a cubic spline.
	Final_Curve = fnval(Fit_Object,linspace(Fit_Object.breaks(1),Fit_Object.breaks(end),Eval_Factor.*size(Final_Curve,1)))';
	
	if(std(D12) < Distances_STD_Threshold)
		Approved = 1;
	end
	
	%{
	figure(1);
	clf(1);
	subplot(1,3,1);
	imshow(Im);
	hold on; plot(Final_Curve(:,1),Final_Curve(:,2),'r','LineWidth',3);
	hold on; plot(C1_X,C1_Y,'.m','MarkerSize',10);
	hold on; plot(C2_X,C2_Y,'.m','MarkerSize',10);
	hold on; plot(x1,y1,'.b','MarkerSize',10);
	hold on; plot(x2,y2,'.b','MarkerSize',10);
	
	subplot(1,3,2);
	imshow(BW);
	hold on; scatter(V12(:,1),V12(:,2),10,jet(size(V12,1)),'filled'); % plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);		
	hold on; scatter(V21(:,1),V21(:,2),10,jet(size(V21,1)),'filled'); % plot(V21(:,1),V21(:,2),'.g','MarkerSize',30);
	title(num2str(Approved),'FontSize',30);
	
	subplot(1,3,3);
	imshow(closeBW);
	hold on; plot(C1_X,C1_Y,'.m','MarkerSize',10);
	hold on; plot(C2_X,C2_Y,'.m','MarkerSize',10);
	hold on; plot(x1,y1,'.b','MarkerSize',10);
	hold on; plot(x2,y2,'.b','MarkerSize',10);
	
	hold on; plot(Final_Curve(:,1),Final_Curve(:,2),'--r','LineWidth',3);
	
	hold on; plot([mean(x1),mean(x2)],[mean(y1),mean(y2)],'.k','MarkerSize',30);
	hold on; plot([Pxy1(1),Pxy2(1)],[Pxy1(2),Pxy2(2)],'.g','MarkerSize',30);
	
	% if(~isempty(V12) && ~isempty(V21))
		% hold on; scatter(V12(:,1),V12(:,2),10,jet(size(V12,1)),'filled'); % plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);
		% hold on; scatter(V21(:,1),V21(:,2),10,jet(size(V21,1)),'filled'); % plot(V21(:,1),V21(:,2),'.g','MarkerSize',20);
	% end
	
	% waitforbuttonpress;
	%}
	
	% assignin('base','V12',V12);
	% assignin('base','V21',V21);
	
	
	if(0)
		
		figure; imshow(ImP2);
		% figure; imshow(ImP);
		
		% hold on; plot(Fc1_X,Fc1_Y,'.r');
		% hold on; plot(Fc2_X,Fc2_Y,'.r');
		% hold on; plot(Fr1_X,Fr1_Y,'.r');
		% hold on; plot(Fr2_X,Fr2_Y,'.r');
		
	end
	
	
	
	%{ **** Old Approach ****
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