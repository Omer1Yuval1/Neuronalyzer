function Workspace1 = Identify_Order4(Workspace1)
	
	Order1 = 4;
	Max_Angle_Diff = Workspace1.Parameters.Menorah_Orders.Max_Angle_Diff4;
	Min_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_Segment_Length;
	
	Bi = numel(Workspace1.Branches);
	
	F1 = find([Workspace1.Vertices.Order] == 334 | [Workspace1.Vertices.Order] == 233 | [Workspace1.Vertices.Order] == 344 | [Workspace1.Vertices.Order] == 234); % Find all vertices along the 1st order branches.
	for i=1:length(F1)
		F2 = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(F1(i)).Vertex_Index & ([Workspace1.Segments.Order] == 0 | [Workspace1.Segments.Order] == Order1)); % For each vertex, find the segments connected to it.
		
		for j=1:length(F2)
			
			if(Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) > 0 && Workspace1.User_Input.Manual_Menorah_Orders(F2(j)) ~= Order1)
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
			Workspace1.Branches(Bi).Segments = [];
			Workspace1.Branches(Bi).Vertices = Workspace1.Segments(F2(j)).Vertex1;
			Workspace1.Branches(Bi).Length = 0;
			Workspace1.Branches(Bi).Menorah = M;
			Workspace1.Branches(Bi).Rectangles = [];
			
			[Vertices_Arr,Segments_Arr] = Map_Branch(Workspace1.Segments,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1);
			
			% if(Bi == 80)
				% display(Vertices_Arr);
				% display(Segments_Arr);
			% end
			
			for si=1:length(Segments_Arr) % Update the order of the chosen sets.
				Workspace1.Segments(Segments_Arr(si)).Order = Order1;
				Workspace1.Segments(Segments_Arr(si)).Menorah = M;
				Fv = find([Workspace1.Vertices.Vertex_Index] == Vertices_Arr(si));
				Workspace1.Vertices(Fv).Menorah = M;
				
				% if(si > 1)
					Workspace1.Vertices(Fv).Order = 445;
				% end
				
				Workspace1.Branches(Bi).Segments = [Workspace1.Branches(Bi).Segments,Workspace1.Segments(Segments_Arr(si)).Segment_Index];
				Workspace1.Branches(Bi).Vertices = [Workspace1.Branches(Bi).Vertices,Workspace1.Vertices(Fv).Vertex_Index];
				Workspace1.Branches(Bi).Length = Workspace1.Branches(Bi).Length + Workspace1.Segments(Segments_Arr(si)).Length;					
				Workspace1.Branches(Bi).Rectangles = [Workspace1.Branches(Bi).Rectangles,Workspace1.Segments(Segments_Arr(si)).Rectangles];
			end
		end
	end
	
end