function Workspace1 = Identify_Order15(Workspace1)
	
	Order1 = 1.5;
	CB_Max_Angle = Workspace1.Parameters.Menorah_Orders.CB_Max_Angle;
	Angle_Diff_Threshold_11 = Workspace1.Parameters.Menorah_Orders.Angle_Diff_Threshold_11;
	Min_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_Segment_Length1;
	Max_Angle_Diff = Workspace1.Parameters.Menorah_Orders.Max_Angle_Diff1;
	Bi = numel(Workspace1.Branches);
	
	Array15 = [];
	F1 = find([Workspace1.Vertices.Order] == 112); % Find all primary vertices.
	for ii=1:length(F1) % For each Primary vertex.
		
		F2 = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(F1(ii)).Vertex_Index & [Workspace1.Segments.Order] ~= 1); % For each vertex, find the segments connected to it.
		for j=1:length(F2) % For each segment that is not a primary segment but is connected to a primary vertex.
			
			% TODO: Use the derivative of the fit or the coordinates of the closest 1st order branch.
			F3 = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(F1(ii)).Vertex_Index & [Workspace1.Segments.Order] == 1); % Find the closest 1st order segments.
			if(length(F3) == 0)
				continue;
			end
			if(Workspace1.Segments(F3(1)).Length < Min_Segment_Length && Workspace1.Segments(F3(1)).Vertex2 > 0) % If the 1st order segment is too short or terminal,
				F3 = find([Workspace1.Segments.Vertex1] == Workspace1.Segments(F3(1)).Vertex2 & [Workspace1.Segments.Order] == 1); % take the next 1st order segment,
			end
			%%%%%%%%%%%
			
			A1 = abs( mod(Workspace1.Segments(F2(j)).Line_Angle,180) - mod(Workspace1.Segments(F3(1)).Line_Angle,180));
			if(A1 < Angle_Diff_Threshold_11 || A1 > 180-Angle_Diff_Threshold_11)
				% Array15(end+1) = Workspace1.Segments(F2(j)).Segment_Index;
				Array15(end+1) = F2(j); % Segment row number.
				Workspace1.Vertices(F1(ii)).Order = 111;
			end
		end
	end
	
	for i=1:length(Array15) % For each vertex if Array15.
		
		Segment_Index = Workspace1.Segments(Array15(i)).Segment_Index; % The 1st segment of the i primary branch.
		Vertex_Index = Workspace1.Segments(Array15(i)).Vertex2; % The 2nd vertex of the 1st segment of the i primary branch.
		Angle1 = Workspace1.Segments(Array15(i)).Line_Angle; % The Line_Angle of the 1st segment of the i primary branch.
		
		Bi = Bi + 1;
		Workspace1.Branches(Bi).Branch_Index = Bi;
		Workspace1.Branches(Bi).Order = Order1;
		Workspace1.Branches(Bi).Vertices = Workspace1.Segments(Array15(i)).Vertex1; % For the 1st segment of each 1st order branch, the 1st vertex is always Vertex1.
		Workspace1.Branches(Bi).Length = 0;
		Workspace1.Branches(Bi).Menorah = 0;
		Workspace1.Branches(Bi).Rectangles = [];
		
		[Vertices_Arr,Segments_Arr] = Map_Branch(Workspace1.Segments,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,1.5);
		
		for si=1:length(Segments_Arr) % Update the order of the chosen sets.
			
			Workspace1.Segments(Segments_Arr(si)).Order = Order1;
			
			Workspace1.Segments(Segments_Arr(si)).Menorah = 0;
			Fv = find([Workspace1.Vertices.Vertex_Index] == Vertices_Arr(si));
			Workspace1.Vertices(Fv).Order = 112;
			Workspace1.Vertices(Fv).Menorah = 0;
			
			Workspace1.Branches(Bi).Segments = [Workspace1.Branches(Bi).Segments,Workspace1.Segments(Segments_Arr(si)).Segment_Index];
			Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];
			Workspace1.Branches(Bi).Length = Workspace1.Branches(Bi).Length + Workspace1.Segments(Segments_Arr(si)).Length;					
			Workspace1.Branches(Bi).Rectangles = [Workspace1.Branches(Bi).Rectangles,Workspace1.Segments(Segments_Arr(si)).Rectangles];
		end
		
	end
	
end