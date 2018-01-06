function Workspace1 = Identify_Order2(Workspace1)
	
	Order1 = 2;
	Max_Angle_Diff = Workspace1.Parameters.Menorah_Orders.Max_Angle_Diff2;
	Min_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_Segment_Length;
	Max_Distance_From_Tertiary = Workspace1.Parameters.Menorah_Orders.Max_Distance_From_Tertiary;
	Max_Tertiary_Orientation = Workspace1.Parameters.Menorah_Orders.Max_Tertiary_Orientation;
	Min_Orientation = Workspace1.Parameters.Menorah_Orders.Min_Orientation;
	
	Bi = numel(Workspace1.Branches);
	
	F1 = find([Workspace1.Vertices.Order] == 112 | [Workspace1.Vertices.Order] == 20); % Find all vertices along the 1st order branches.
	
	for i=1:length(F1) % For each vertex along the 1st order branches.
		F2 = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(F1(i)).Vertex_Index & ([Workspace1.Segments.Order] == 0 | [Workspace1.Segments.Order] == Order1)); % For each vertex, find the segments connected to it.
		for j=1:length(F2)
			
			if(Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) > 0 && Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) ~= Order1)
				continue;
			end
			
			Segment_Index = Workspace1.Segments(F2(j)).Segment_Index;
			Vertex_Index = Workspace1.Segments(F2(j)).Vertex2;
			Angle1 = Workspace1.Segments(F2(j)).Line_Angle;
			
			Bi = Bi + 1;
			M = max([Workspace1.Branches.Menorah]) + 1;
			Workspace1.Branches(Bi).Branch_Index = Bi;
			Workspace1.Branches(Bi).Order = Order1;
			Workspace1.Branches(Bi).Length = 0; % Workspace1.Segments(F2(j)).Length;
			Workspace1.Branches(Bi).Menorah = M;
			Workspace1.Branches(Bi).Segments = []; % Workspace1.Branches(Bi).Segments = Segment_Index;
			Workspace1.Branches(Bi).Vertices = Workspace1.Segments(F2(j)).Vertex1;
			Workspace1.Branches(Bi).Rectangles = []; % Workspace1.Segments(F2(j)).Rectangles;
			% if(Workspace1.Vertices(F1(i)).Order == 20)
				Workspace1.Vertices(F1(i)).Menorah = M;
			% end
			
			[Vertices_Arr,Segments_Arr] = Map_Branch(Workspace1.Segments,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1);
			
			for si=1:length(Segments_Arr) % Update the order of the chosen set.
				
				Lv = Workspace1.Vertices(find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(Segments_Arr(si)).Vertex2)).Distance_From_Primary;
				F3 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(Segments_Arr(si)).Vertex2);
				
				if(Workspace1.User_Input.Manual_Menorah_Orders(Segments_Arr(si)) > 0) % If the user assigned the same order to this segment.
					Manual_Flag = 1; % Use this flag to force the algorithm to use this segment in the current branch.
				else
					Manual_Flag = 0;
				end
				
				if(si > 1 && ~Manual_Flag && (abs(Workspace1.Segments(Segments_Arr(si)).Orientation) < Min_Orientation && Workspace1.Segments(Segments_Arr(si)).Length > Min_Segment_Length))
					Fv = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(Segments_Arr(si)).Vertex1);
					Workspace1.Vertices(Fv).Order = 233;
					Workspace1.Vertices(Fv).Menorah = M;
					Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];					
					break;
				end
				
				Workspace1.Segments(Segments_Arr(si)).Order = Order1;
				Workspace1.Segments(Segments_Arr(si)).Menorah = M;
				Fv = find([Workspace1.Vertices.Vertex_Index] == Vertices_Arr(si));
				if(si == length(Segments_Arr)) % If it's the last segment in Segments_Arr.
					Workspace1.Vertices(Fv).Order = 233;
				else
					Workspace1.Vertices(Fv).Order = 223;
				end
				Workspace1.Vertices(Fv).Menorah = M;
				
				Workspace1.Branches(Bi).Segments = [Workspace1.Branches(Bi).Segments,Workspace1.Segments(Segments_Arr(si)).Segment_Index];
				Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];
				Workspace1.Branches(Bi).Length = Workspace1.Branches(Bi).Length + Workspace1.Segments(Segments_Arr(si)).Length;
				
				% assignin('base','B1',Workspace1.Branches(Bi).Rectangles);
				% assignin('base','S1',Workspace1.Segments(Segments_Arr(si)).Rectangles);
				% assignin('base','W1',Workspace1);
				
				Workspace1.Branches(Bi).Rectangles = [Workspace1.Branches(Bi).Rectangles,Workspace1.Segments(Segments_Arr(si)).Rectangles];
			end
		end
	end
	
end