function Workspace1 = Map_Branches(Workspace1,Order1)
	
	Max_Angle_Diff = Workspace1.Parameters.Menorah_Orders.Max_Angle_Diff1;
	Min_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_Segment_Length;
	
	Segments1 = Workspace1.Segments;
	Bi = numel(Workspace1.Branches);
	
	Fs = find([Workspace1.Segments.Order] == Order1); % Find all segments (of order Order1).
	
	while (length(Fs) > 0) % For each segment (of order Order1).
			
		F1 = find([Workspace1.Segments.Vertex2] == Workspace1.Segments(Fs(1)).Vertex1); % Find the segments to which this segment is connected to.
		if(length(find([Workspace1.Segments(F1).Order] == Order1) > 0)) % If one of them is of the same order,
			Fs(1) = []; % Delete the current segment from Fs (it will be mapped anyway, it's just not the 1st segment of a branch).
			continue;
		end
		
		Bi = Bi + 1;
		Workspace1.Branches(Bi).Branch_Index = Bi;
		Workspace1.Branches(Bi).Order = Order1;
		Workspace1.Branches(Bi).Vertices =  Workspace1.Segments(Fs(1)).Vertex1; % Workspace1.Segments(Fs(1)).Vertex1;
		Workspace1.Branches(Bi).Length = 0;
		
		Segment_Index = Workspace1.Segments(Fs(1)).Segment_Index;
		Vertex_Index = Workspace1.Segments(Fs(1)).Vertex2;
		Angle1 = Workspace1.Segments(Fs(1)).Line_Angle;
		Fs(1) = [];
		
		if(Order1 < 2) % TODO: delete, cannot happen.
			Workspace1.Branches(Bi).Menorah = 0;
		elseif(length(F1) > 0 && Workspace1.Segments(F1(1)).Menorah > 0)
			Workspace1.Branches(Bi).Menorah = Workspace1.Segments(F1(1)).Menorah;
		else % A 2nd+ branch order connected to the 1st (or 1.5) order.
			Workspace1.Branches(Bi).Menorah = max([Workspace1.Segments.Menorah]) + 1; % Create a new menorah index.
		end
		
		[Vertices_Arr,Segments_Arr] = Map_Branch(Workspace1.Segments,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1);
			
		for si=1:length(Segments_Arr) % Update the order of the chosen sets.
			Workspace1.Segments(Segments_Arr(si)).Order = Order1;
			Workspace1.Segments(Segments_Arr(si)).Menorah = Workspace1.Branches(Bi).Menorah;
			Fv = find([Workspace1.Vertices.Vertex_Index] == Vertices_Arr(si)); % Find the row numbers of each vertex.
			Workspace1.Vertices(Fv).Menorah = Workspace1.Branches(Bi).Menorah;
			
			Workspace1.Vertices(Fv).Order = str2num([num2str(floor(Order1)),num2str(floor(Order1)),num2str(ceil(Order1))]);
			
			Workspace1.Branches(Bi).Segments = [Workspace1.Branches(Bi).Segments,Workspace1.Segments(Segments_Arr(si)).Segment_Index];
			Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];
			Workspace1.Branches(Bi).Length = Workspace1.Branches(Bi).Length + Workspace1.Segments(Segments_Arr(si)).Length;					
			Workspace1.Branches(Bi).Rectangles = [Workspace1.Branches(Bi).Rectangles,Workspace1.Segments(Segments_Arr(si)).Rectangles];
		end
	end
	
end