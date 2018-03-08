function Workspace = Vertices_Analysis_Index(Workspace)
	
	% assignin('base','Workspace_Pre_0',Workspace);
	
	CB_BW_Threshold = Workspace.Parameters.Cell_Body.BW_Threshold;
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	
	[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
	[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,0);
	
	% assignin('base','CB_Vertices',CB_Vertices);
	
	Workspace.Im_BW(CB_Pixels) = 0; % Delete cell-body pixels. TODO: use the CB to find the outsets of the branches connected to it.
	Workspace.Im_BW(Pixels0) = 0;
	Workspace.Im_BW(Pixels1) = 1;
	[Y,X] = ind2sub(size(Workspace.Image0),CB_Pixels);
	Workspace.CB(1).Center = [mean(X),mean(Y)];
	Workspace.CB.Area = length(CB_Pixels)*Scale_Factor;
	Workspace.CB.Mean_Intensity = mean(Workspace.Image0(CB_Pixels));
	Workspace.CB.Vertices = CB_Vertices;
	% [CBy,CBx] = ind2sub(size(Im1),CB_Pixels);
	% return;
	
	[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints,Im_Skel_Rad] = Pixel_Trace_Post_Proccessing(Workspace.Im_BW);
	[Workspace.Vertices,Workspace.Segments] = Segment_Skeleton(Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints,Im_Skel_Rad);
	% Workspace.Vertices = Analyze_Vertex_Morphology(Workspace.Vertices,Workspace.Segments,Workspace.Im_BW,Im1_branchpoints,Scale_Factor);
	Workspace = Analyze_Vertex_Morphology(Workspace,Im1_branchpoints);
	
	Workspace.Vertices = Match_CB_Vertices(Workspace.Vertices,CB_Vertices);
	
	% assignin('base','Workspace_Pre_1',Workspace);
	assignin('base','CB_Vertices',CB_Vertices);
end