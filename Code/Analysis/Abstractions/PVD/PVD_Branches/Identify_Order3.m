function Workspace1 = Identify_Order3(Workspace1)
	
	Order1 = 3;
	Max_Angle_Diff = Workspace1.Parameters.Menorah_Orders.Max_Angle_Diff3;
	Min_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_Segment_Length;
	% Min_Terminal_Segment_Length = 10; % In micrometers.
	Max_Terminal_Segment_Orientaion = Workspace1.Parameters.Menorah_Orders.Max_Terminal_Segment_Orientaion;
	Max_First_Segment_Orientaion = Workspace1.Parameters.Menorah_Orders.Max_First_Segment_Orientaion;
	Min_First_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_First_Segment_Length;
	
	Bi = numel(Workspace1.Branches);
	
	F1 = find([Workspace1.Vertices.Order] == 223 | [Workspace1.Vertices.Order] == 233 | [Workspace1.Vertices.Order] == 234); % Find all vertices along the 2nd order branches.
	% Fs = Workspace1.Segments(find([Workspace1.User_Input.Manual_Menorah_Orders] == Order1)).;
	% F1 = [Fv,Fs];
	
	for i=1:length(F1)
		F2 = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(F1(i)).Vertex_Index & ([Workspace1.Segments.Order] == 0 | [Workspace1.Segments.Order] == Order1)); % For each vertex, find the segments connected to it.
		for j=1:length(F2) % For each 3rd order branch (first segment of each branch).
			
			if(Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) == 0)
				if(Workspace1.Segments(F2(j)).Length > Min_Segment_Length && abs(Workspace1.Segments(F2(j)).Orientation) > Max_First_Segment_Orientaion)
					continue;
				end
			elseif(Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) > 0 && Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) ~= Order1)
				continue;
			end
			
			Segment_Index = Workspace1.Segments(F2(j)).Segment_Index;
			Vertex_Index = Workspace1.Segments(F2(j)).Vertex2;
			Angle1 = Workspace1.Segments(F2(j)).Line_Angle;
			Workspace1.Segments(F2(j)).Order = Order1;
			
			Bi = Bi + 1;
			M = Workspace1.Vertices(F1(i)).Menorah;
			Workspace1.Branches(Bi).Branch_Index = Bi;
			Workspace1.Branches(Bi).Order = Order1;
			Workspace1.Branches(Bi).Length = 0;
			Workspace1.Branches(Bi).Menorah = M;
			Workspace1.Branches(Bi).Segments = [];
			Workspace1.Branches(Bi).Vertices = Workspace1.Segments(F2(j)).Vertex1;
			Workspace1.Branches(Bi).Rectangles = [];
			
			[Vertices_Arr,Segments_Arr] = Map_Branch(Workspace1.Segments,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1);
			
			for si=1:length(Segments_Arr) % Update the order of the chosen sets.
				
				si1 = Segments_Arr(si);
				
				if(Workspace1.User_Input.Manual_Menorah_Orders(Segments_Arr(si)) > 0) % If the user assigned the same order to this segment.
					Manual_Flag = 1;
				else
					Manual_Flag = 0;
				end
				
				if(si > 1 && ~Manual_Flag && abs(Workspace1.Segments(si1).Orientation) > Max_Terminal_Segment_Orientaion)
					Fv = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(si1).Vertex1);
					Workspace1.Vertices(Fv).Order = 344;
					Workspace1.Vertices(Fv).Menorah = M;
					Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];					
					break;
				end
				
				Workspace1.Segments(si1).Order = Order1;
				Workspace1.Segments(si1).Menorah = M;
				Fv = find([Workspace1.Vertices.Vertex_Index] == Vertices_Arr(si));
				if(si == length(Segments_Arr)) % If it's the last segment in Segments_Arr.
					Workspace1.Vertices(Fv).Order = 344;
				else
					Workspace1.Vertices(Fv).Order = 334;
				end
				Workspace1.Vertices(Fv).Menorah = M;
				
				Workspace1.Branches(Bi).Segments = [Workspace1.Branches(Bi).Segments,Workspace1.Segments(si1).Segment_Index];
				Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];
				Workspace1.Branches(Bi).Length = Workspace1.Branches(Bi).Length + Workspace1.Segments(si1).Length;					
				Workspace1.Branches(Bi).Rectangles = [Workspace1.Branches(Bi).Rectangles,Workspace1.Segments(si1).Rectangles];
			end
		end
		
		if(length(F2) > 0) % TODO: check why there's a case in which a vertex has no segments.
			% For each 1st vertex, check if it's a 234 vertex:
			if(length(find([Workspace1.Segments(F2).Order] == Order1 | [Workspace1.Segments(F2).Order]) == Order1+.5) <= 1) % If only one of the 1st segments belongs to the 3rd order.
				Workspace1.Vertices(find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(F2(1)).Vertex1)).Order = 234; % this means that it's a 234 vertex.
			end
		end
	end
	
end