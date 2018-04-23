function Workspace = Analyze_Vertex_Morphology(Workspace,Im_branchpoints)
	% function Vertices = Analyze_Vertex_Morphology(Vertices,Segments,Im_BW,Im_branchpoints,Scale_Factor)
	
	Plot1 = 0;
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	
	if(0)
		assignin('base','Workspace',Workspace);
		assignin('base','Im_branchpoints',Im_branchpoints);
	end
	
	% TODO: Move to the parameters func:
	[Im_Rows,Im_Cols] = size(Workspace.Im_BW);
	Vr = .1:.01:5; % Radii (of increasing concentric circles) vector for junction center detection.
	N = 500*Scale_Factor;
	Min_Center_Radius = 4*Scale_Factor;
	Theta = linspace(0,2*pi,N);
	Center_Frame_Size = 5*Scale_Factor; % [6.5]. Neighborhood to test new potential centers around the approximated center. ~2.3 pixels for Scale_Factor=50/140.
	Centers_Scan_Res = .25*Scale_Factor; % vertical\horizontal distance between potential centers. ~0.35 pixels for Scale_Factor=50/140.
	Im_Cropped_Half_Size = 30*Scale_Factor; % 30 micrometers.
	
	if(Plot1)
		[Yb,Xb] = find(Im_branchpoints);
		% close all;
		figure(1);
		imshow(Workspace.Im_BW);
		set(gca,'YDir','normal');
		hold on;
		% imshow(Input);
		% hold on;
		% plot(Xb,Yb,'.b','MarkerSize',10); % The approximate center.
	end
	
	% Delete_Vertices = [];
	Segments_Vertices = [Workspace.Segments.Vertices];
	Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)'];
	
	% parfor i=1:length(Yb) % For each approximate center.
	% for i=25 % For each approximate center (row number).
	for i=1:numel(Workspace.Vertices) % For each approximate center.
		if(Workspace.Vertices(i).Order >= 3) % If it's a junction.
			[New_Cxy,Rc] = Find_Vertex_Center(Workspace.Im_BW,Workspace.Vertices(i).Coordinate,Theta,Vr,Center_Frame_Size,Centers_Scan_Res,Im_Rows,Min_Center_Radius);
		elseif(Workspace.Vertices(i).Order == 1) % If it's a tip.
			New_Cxy = Workspace.Vertices(i).Coordinate; % Do not correct the center of end-point.
			Rc = 0; % Vertex center radius. Tips are assigned with a 0 radius.
		end
		Rectangles = Find_Vertex_Angles(Workspace.Im_BW,New_Cxy,Rc,Scale_Factor,Workspace.Vertices(i).Order,Im_Rows,Im_Cols);
		
		% [Workspace,Rectangles] = Match_Vertex_Rects_To_Segments(Workspace,i,Rectangles,Segments_Vertices);
		
		Workspace.Vertices(i).Coordinate = New_Cxy;
		Workspace.Vertices(i).Rectangles = Rectangles;
		Workspace.Vertices(i).Center_Radius = Rc;
		
		% assignin('base','Rectangles',Rectangles);		
		if(Plot1 && numel(Rectangles) == 0)
			disp(['No peaks found for vertex ',num2str(Workspace.Vertices(i).Vertex_Index)]);
		end
	end
	
	% assignin('base','Vertices1',Vertices);
end