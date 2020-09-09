function Workspace = Analyze_Vertex_Morphology(Workspace,Im_branchpoints)
	
	Plot1 = 0;
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	
	% assignin('base','Workspace',Workspace);
	% assignin('base','Im_branchpoints',Im_branchpoints);
	
	[Im_Rows,Im_Cols] = size(Workspace.Im_BW);
	
	Vr = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Radius_Vector;
	N = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Cirle_Res;
	Min_Center_Radius = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Min_Radius;
	Center_Frame_Size = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Frame_Size;
	Centers_Scan_Res = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Scan_Res;
	
	Theta = linspace(0,2*pi,N);
	
	% Im_Cropped_Half_Size = 30*Scale_Factor; % 30 micrometers.
	
	Circles_X = Vr' * cos(Theta); % A vector of circle coordinates.
	Circles_Y = Vr' * sin(Theta); % ". radii * angles = [N,1] x [1,M] = [N,M]. Each row contains the x or y coordinates for a single radii.
	
	Potential_Centers_X = -Center_Frame_Size:Centers_Scan_Res:+Center_Frame_Size;
	Potential_Centers_Y = -Center_Frame_Size:Centers_Scan_Res:+Center_Frame_Size;
	Potential_Centers_XY = combvec(Potential_Centers_X,Potential_Centers_Y);
	
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
	
	for i=1:numel(Workspace.Vertices) % For each approximate center.
		if(Workspace.Vertices(i).Order >= 3) % If it's a junction.
			[New_Cxy,Rc] = Find_Vertex_Center(Workspace.Im_BW,Workspace.Vertices(i).Coordinate,Vr,Circles_X,Circles_Y,Potential_Centers_XY,Im_Rows,Im_Cols,Min_Center_Radius);
		elseif(Workspace.Vertices(i).Order == 1) % If it's a tip.
			New_Cxy = Workspace.Vertices(i).Coordinate; % Do not correct the center of end-point.
			Rc = 0; % Vertex center radius. Tips are assigned with a 0 radius.
		end
		Rectangles = Find_Vertex_Angles(Workspace,New_Cxy,Rc,Scale_Factor,Workspace.Vertices(i).Order,Im_Rows,Im_Cols);
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