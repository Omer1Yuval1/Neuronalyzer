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
	Distances_STD_Threshold = 12;
	Eval_Factor = .5; % 4;
	Small_Objects_Max_Size = 20; % TODO: scale.
	First_Closing_Radius = 40;
	Second_Closing_Radius = 90;
	SmoothingParameter = 1000;
	
	Dxy = 25; % Margin tolerance for the detection of edge perimeter pixels.
	
	Im = Im(:,:,1);
	[Sr,Sc,Sz] = size(Im);
	
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	% Convert grayscale to BW and close to get a single blob:
	if(nargin == 1)
		BW = imbinarize(Im,0.3); % Grayscale to BW.
	end
	BW = bwareaopen(BW,Small_Objects_Max_Size); % Getting rid of small objects.
	
	% First closing to connect the neuron's branches without connecting them to other, non-neuron objects:
	se = strel('disk',First_Closing_Radius);
	closeBW_1 = imclose(BW,se);
	closeBW_2 = bwareafilt(closeBW_1,1); % Getting rid of those non-neuron objects.
	
	% Second closing to form a large and smooth blob:
	se = strel('disk',Second_Closing_Radius);
	closeBW = imclose(closeBW_2,se);
	
	ImP = bwperim(closeBW); % figure; imshow(closeBW);
	
	% Find the inner-most rows and columns for which the std is 0:
	[Nr,Nc] = Find_Blank_Boundaries(Im); % closeBW,BW
	
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
	ImP2(Two_Longest_Perims) = 0; % Only the short edges.
	
	ImP_Two_Longest_Perims = zeros(Sr,Sc);
	ImP_Two_Longest_Perims(Two_Longest_Perims) = 1;
	
	CC_ImP2 = bwconncomp(ImP2); % Find the the two smaller perimeter objects.
	[y1,x1] = ind2sub([Sr,Sc],CC_ImP2.PixelIdxList{1}); % Convert to subscripts.
	[y2,x2] = ind2sub([Sr,Sc],CC_ImP2.PixelIdxList{2}); % ".
	Mxy1 = [mean(x1),mean(y1)]; % Mean coordinate.
	Mxy2 = [mean(x2),mean(y2)]; % ".
	
	D1 = Distance_Func(Mxy1(1),Mxy1(2),x1,y1); % The distance of each object coordinate from the mean coordinate.
	D2 = Distance_Func(Mxy2(1),Mxy2(2),x2,y2); % ".
	F1 = find(D1 == min(D1));
	F2 = find(D2 == min(D2));
	Pxy1 = [x1(F1(1)),y1(F1(1))]; % The coordinate of the connected object closest to the mean coordinate.
	Pxy2 = [x2(F2(1)),y2(F2(1))]; % ".
	
	% TODO: what is this for:
	%{
	ImP_Final = ImP;
	ImP_Final(Pxy1(2),Pxy1(1)) = 0;
	ImP_Final(Pxy2(2),Pxy2(1)) = 0;
	CC_Final = bwconncomp(ImP_Final);
	%}
	CC_Final = bwconncomp(ImP_Two_Longest_Perims); % TODO: I think this is redundant. Those two object are found separately before.
	
	[C1_Y,C1_X] = ind2sub([Sr,Sc],CC_Final.PixelIdxList{1}); % The coordinates of the first final perimeter object.
	[C2_Y,C2_X] = ind2sub([Sr,Sc],CC_Final.PixelIdxList{2}); % The coordinates of the second final perimeter object.
	
	% Order the pixels of the objects from one end-point to the other, and such that the directionalities of the two objects match:
	Im_Perimeter1 = false(Sr,Sc);
	Im_Perimeter2 = false(Sr,Sc);
	Im_Perimeter1(CC_Final.PixelIdxList{1}) = 1;
	Im_Perimeter2(CC_Final.PixelIdxList{2}) = 1;
	[P0y_1,P0x_1] = find(bwmorph(Im_Perimeter1,'endpoints')); % Find the coordinates of the two endpoints of the 1st connected perimeter object.
	[P0y_2,P0x_2] = find(bwmorph(Im_Perimeter2,'endpoints')); % Find the coordinates of the two endpoints of the 2nd connected perimeter object.
	D21 = ( (P0x_2 - P0x_1(1)).^2 + (P0y_2 - P0y_1(1)).^2).^(.5); % The distances of the endpoints in object two from the 1st (arbitrary) enpoint in object 1.
	F21 = find(D21 == min(D21)); % Finding the closest tip (to have the same directionality).
	Pixels_List_1 = Order_Connected_Pixels(Im_Perimeter1,[P0x_1(1),P0y_1(1)]);
	Pixels_List_2 = Order_Connected_Pixels(Im_Perimeter2,[P0x_2(F21(1)),P0y_2(F21(1))]);
	C1_X = Pixels_List_1(:,1);
	C1_Y = Pixels_List_1(:,2);
	C2_X = Pixels_List_2(:,1);
	C2_Y = Pixels_List_2(:,2);
	%
	
	V = zeros(length(C1_Y),2);
    D12 = zeros(length(C1_Y),1);
    D21 = zeros(length(C1_Y),1);
    D = zeros(length(C1_Y),1);
    D_Diff = zeros(length(C1_Y),1);
	for i=1:length(C1_Y)
		d = ( (C1_X(i) - C2_X).^2 + (C1_Y(i) - C2_Y).^2 ).^(.5);
		F1 = find(d == min(d));
		D12(i) = d(F1(1));
		Cxy1 = [mean([C1_X(i),C2_X(F1(1))]) , mean([C1_Y(i),C2_Y(F1(1))])]; % The mean coordinate with the closest perimenter pixel on the other side.
		
		d = ( (C2_X(F1(1)) - C1_X).^2 + (C2_Y(F1(1)) - C1_Y).^2 ).^(.5);
		F2 = find(d == min(d)); % Now find the minimal distance from the pixel on the chosen other side.
		D21(i) = d(F2(1));
		Cxy2 = [mean([C2_X(F1(1)),C1_X(F2(1))]) , mean([C2_Y(F1(1)),C1_Y(F2(1))])];
		
		V(i,:) = mean([Cxy1 ; Cxy2]);
		D(i) = mean([D12(i),D21(i)]);
		D_Diff(i) = abs(D12(i) - D21(i));
	end
	
	Final_Curve = [ [Pxy1(1),Pxy1(2)] ; V ; [Pxy2(1),Pxy2(2)]]; % [N,2].
		
	Fit_Object = cscvn(Final_Curve'); % Fit a cubic spline.
	Final_Curve = fnval(Fit_Object,linspace(Fit_Object.breaks(1),Fit_Object.breaks(end),Eval_Factor.*size(Final_Curve,1)))';
	
	% Smoothing:
	Final_Curve = smoothn(num2cell(Final_Curve,1),SmoothingParameter);
	Final_Curve = horzcat(Final_Curve{:});
	Final_Curve = [ [Pxy1(1),Pxy1(2)] ; Final_Curve ; [Pxy2(1),Pxy2(2)]]; % [N,2].
	
	Final_Curve_Plot = Final_Curve; % Used to plot the final curve in case it gets deleted because the analysis fails.
	
	if(std(D_Diff) < Distances_STD_Threshold)
		Approved = 1;
	else
		Final_Curve = [];
	end
	% disp(std(D));
	
	% Plot the result:
	%{
	figure(1);
	clf(1);
	subplot(1,3,1);
	imshow(Im);
	hold on; plot(Final_Curve_Plot(:,1),Final_Curve_Plot(:,2),'r','LineWidth',3);
	hold on; plot(C1_X,C1_Y,'.m','MarkerSize',10);
	hold on; plot(C2_X,C2_Y,'.m','MarkerSize',10);
	hold on; plot(x1,y1,'.b','MarkerSize',10);
	hold on; plot(x2,y2,'.b','MarkerSize',10);
	title(['D = ',num2str(std(D))]);
	
	subplot(1,3,2);
	imshow(BW);
	hold on; scatter(V(:,1),V(:,2),10,jet(size(V,1)),'filled'); % plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);		
	title(['Is Approved: ',num2str(Approved)],'FontSize',30);
	
	subplot(1,3,3);
	imshow(closeBW);
	hold on; plot(C1_X,C1_Y,'.m','MarkerSize',10);
	hold on; plot(C2_X,C2_Y,'.m','MarkerSize',10);
	hold on; plot(x1,y1,'.b','MarkerSize',10);
	hold on; plot(x2,y2,'.b','MarkerSize',10);
	
	hold on; scatter(Final_Curve_Plot(:,1),Final_Curve_Plot(:,2),20,jet(size(Final_Curve_Plot,1)),'filled'); % hold on; plot(Final_Curve_Plot(:,1),Final_Curve_Plot(:,2),'--r','LineWidth',3);
	
	hold on; plot([mean(x1),mean(x2)],[mean(y1),mean(y2)],'.k','MarkerSize',30);
	hold on; plot([Pxy1(1),Pxy2(1)],[Pxy1(2),Pxy2(2)],'.g','MarkerSize',30);
	
	title(['D-Diff = ',num2str(std(D_Diff))]);
	
	% if(~isempty(V12) && ~isempty(V21))
		% hold on; scatter(V12(:,1),V12(:,2),10,jet(size(V12,1)),'filled'); % plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);
		% hold on; scatter(V21(:,1),V21(:,2),10,jet(size(V21,1)),'filled'); % plot(V21(:,1),V21(:,2),'.g','MarkerSize',20);
	% end
	
	% waitforbuttonpress;
	%}
	
	% assignin('base','V12',V12);
	% assignin('base','V21',V21);
	
	%} End of plotting code.
end