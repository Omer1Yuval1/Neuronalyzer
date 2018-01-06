function Find_Worm_Longitudinal_Axis(Workspace)
	
	% Better_Skeletonization_Threshold = 1000;
	BW_Threshold = 0.5;
	
	Im_BW = imbinarize(Workspace.Workspace.Image0,BW_Threshold);
	[R,C] = size(Im_BW);
	
	se = strel('disk',20);
	ImD1 = imdilate(Im_BW,se);
	ImD2 = imdilate(ImD1,se);
	
	ImBlob = ImD2;
	
	% Im_Axis = bwmorph(imclose(ImBlob,strel('disk',100)),'thin',inf);
	% [Y,X] = find(Im_Axis);
	% assignin('base','Im_Axis',Im_Axis);
	% figure; imshow(Im_Axis);
	Im_Axis2 = bwmorph(imclose(ImBlob,strel('disk',100)),'skel',inf);
	[Y,X] = find(Im_Axis2);
	
	figure(1);
	imshow(Workspace.Workspace.Image0);
	% imshow(ImBlob);

	hold on;
	plot(X,Y,'.g','LineWidth',2);
	
	return;
	
	% ImS1 = bwmorph(ImD2,'thin',Inf);
	% ImS2 = bwmorph(ImS1,'thin',Inf);
	% [Fy,Fx] = find(ImS2);
	% [Im1_thin,Im_Skel_Rad] = skeleton(ImD2);
	% ImS2 = bwmorph((Im1_thin > Better_Skeletonization_Threshold),'skel',inf);
	% [Fy,Fx] = find(ImS2);
	% figure; imshow(ImS2);
	% return;
	figure;
		subplot(1,2,1);
			imshow(Workspace.Workspace.Image0);
			% hold on;
			% plot(Fx,Fy,'LineWidth',3);
			hold on;
			for r=1:R
				Mx = nanmean(find(ImD2(r,:)));
				hold on;
				plot(Mx,r,'.r','MarkerSize',20);
			end
		subplot(1,2,2);
			imshow(ImD2);
			
	% Vertices = Workspace.Workspace.Vertices;
	% Junctions = Vertices(find([Vertices.Vertex_Index] > 0));
	% J = [Junctions.Coordinate];
	% Junctions = [J(1:2:end)' , J(2:2:end)'];
	% Tips = Vertices(find([Vertices.Vertex_Index] < 0));
	% T = [Tips.Coordinate];
	% Tips = [T(1:2:end)' , T(2:2:end)'];
	% Im = Workspace.Workspace.Image0;
	% ImBlob = ImD2;
	
end