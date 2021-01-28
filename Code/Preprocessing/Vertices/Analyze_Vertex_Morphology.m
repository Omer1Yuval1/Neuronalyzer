function Data = Analyze_Vertex_Morphology(Data,Im_branchpoints)
	
	Plot1 = 0;
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	Rect_Length = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Length; % Scaled and given in pixels.
	
	% assignin('base','Data',Data);
	% assignin('base','Im_branchpoints',Im_branchpoints);
	
	[Im_Rows,Im_Cols] = size(Data.Info.Files(1).Binary_Image);
	
	Vr = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Radius_Vector;
	N = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Cirle_Res;
	Min_Center_Radius = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Min_Radius;
	Center_Frame_Size = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Frame_Size;
	Centers_Scan_Res = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Center_Scan_Res;
	
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
		imshow(Data.Info.Files(1).Binary_Image);
		set(gca,'YDir','normal');
		hold on;
		% imshow(Input);
		% hold on;
		% plot(Xb,Yb,'.b','MarkerSize',10); % The approximate center.
	end
	
	for i=1:numel(Data.Vertices) % For each approximate center.
		if(Data.Vertices(i).Order >= 3) % If it's a junction.
			
			Ls = nan(1,numel(Data.Vertices(i).Rectangles));
			for r=1:numel(Data.Vertices(i).Rectangles) % For each pre-defined skeleton direction (= segment connected to this vertex).
				seg_row = Data.Vertices(i).Rectangles(r).Segment_Row;
				Ls(r) = length(Data.Segments(seg_row).Skeleton_Linear_Coordinates); % Number of skeleton pixels (approximate segment length).
			end
			
			if(all(Ls >= Rect_Length)) % If all segments are above a length threshold.
				Cxy = [Data.Vertices(i).X,Data.Vertices(i).Y];
				[New_Cxy,Rc] = Find_Vertex_Center(Data.Info.Files(1).Binary_Image,Cxy,Vr,Circles_X,Circles_Y,Potential_Centers_XY,Im_Rows,Im_Cols,Min_Center_Radius);
			else % Otherwise, use the original skeleton center and a radius of 0.
				New_Cxy = [Data.Vertices(i).X,Data.Vertices(i).Y]; % Do not correct the center of end-point.
				Rc = 0; % Vertex center radius. Tips are assigned with a 0 radius.
			end
		elseif(Data.Vertices(i).Order == 1) % If it's a tip.
			New_Cxy = [Data.Vertices(i).X,Data.Vertices(i).Y]; % Do not correct the center of end-point.
			Rc = 0; % Vertex center radius. Tips are assigned with a 0 radius.
        end
        
		Rectangles = Find_Vertex_Angles(Data,i,New_Cxy,Rc,Scale_Factor,Im_Rows,Im_Cols);
		% [Data,Rectangles] = Match_Vertex_Rects_To_Segments(Data,i,Rectangles,Segments_Vertices);
		
		Data.Vertices(i).X = New_Cxy(1);
		Data.Vertices(i).Y = New_Cxy(2);
		Data.Vertices(i).Rectangles = Rectangles;
		Data.Vertices(i).Center_Radius = Rc;
		
		% assignin('base','Rectangles',Rectangles);		
		if(Plot1 && numel(Rectangles) == 0)
			disp(['No peaks found for vertex ',num2str(Data.Vertices(i).Vertex_Index)]);
		end
	end
	
	% assignin('base','Vertices1',Vertices);
end