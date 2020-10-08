function Data = Vertices_Analysis_Index(Data)
	
	% assignin('base','Workspace_Pre_0',Data);
	
	CB_BW_Threshold = Data.Parameters.Cell_Body.BW_Threshold;
	
    Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
    % Scale_Factor = Data.User_Input.Scale_Factor;
	
	[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Data.Info.Files.Raw_Image{1},CB_BW_Threshold,Scale_Factor,0); % Detect cell-body. Data.Image0
	[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(Data.Info.Files.Raw_Image{1},CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,0);
	
	% assignin('base','CB_Vertices',CB_Vertices);
	
	Data.Info.Files.Binary_Image{1}(CB_Pixels) = 0; % Delete cell-body pixels. TODO: use the CB to find the outsets of the branches connected to it.
	Data.Info.Files.Binary_Image{1}(Pixels0) = 0;
	Data.Info.Files.Binary_Image{1}(Pixels1) = 1;
	[Y,X] = ind2sub(size(Data.Info.Files.Raw_Image{1}),CB_Pixels);
	Data.CB(1).Center = [mean(X),mean(Y)];
	Data.CB.Area = length(CB_Pixels)*Scale_Factor;
	Data.CB.Mean_Intensity = mean(Data.Info.Files.Raw_Image{1}(CB_Pixels));
	Data.CB.Vertices = CB_Vertices;
	% [CBy,CBx] = ind2sub(size(Im1),CB_Pixels);
	% return;
	
	[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints,Im_Skel_Rad] = Pixel_Trace_Post_Proccessing(Data.Info.Files.Binary_Image{1},Scale_Factor); % Skeletonization. Data.Im_BW
	[Data.Vertices,Data.Segments] = Segment_Skeleton(Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints,Im_Skel_Rad);
	
    Data = Match_Vertex_Rects_To_Segments_Skel(Data);	
    
	% assignin('base','Wi_1_5',Data);
	
	Data = Analyze_Vertex_Morphology(Data,Im1_branchpoints);
	
	Data.Vertices = Match_CB_Vertices(Data.Vertices,CB_Vertices);
	
	% assignin('base','Workspace_Pre_1',Data);
	% assignin('base','CB_Vertices',CB_Vertices);
	
	% To test the skeleton:
	%{
	figure; imshow(Im1_NoiseReduction);
	for s=1:numel(Data.Segments)
		[y,x] = ind2sub(size(Im1_NoiseReduction),Data.Segments(s).Skeleton_Linear_Coordinates);
		hold on; plot(x,y,'.','MarkerSize',30,'Color',rand(1,3));
	end
	[Y,X] = find(Im1_branchpoints); hold on; plot(X,Y,'.k','MarkerSize',30);
	%}
end