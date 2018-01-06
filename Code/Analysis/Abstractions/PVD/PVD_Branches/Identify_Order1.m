function Workspace1 = Identify_Order1(Workspace1)
	
	Order1 = 1;
	CB_Max_Angle = Workspace1.Parameters.Menorah_Orders.CB_Max_Angle;
	Angle_Diff_Threshold_11 = Workspace1.Parameters.Menorah_Orders.Angle_Diff_Threshold_11;
	Min_Segment_Length = Workspace1.Parameters.Menorah_Orders.Min_Segment_Length1;
	Max_Angle_Diff = Workspace1.Parameters.Menorah_Orders.Max_Angle_Diff1;
	
	% Find the cell body segments and classify them into 1st and 2nd order:
		V1 = find([Workspace1.Vertices.Vertex_Order] == -1); % Row numbers of CB vertices. (NOT the same as the 'Order' field).
		S1 = []; % zeros(size(V1,2),2); % Array of segments rows, Line_Angle and width.
		S2 = [];
		for i=1:length(V1) % For each cell body vertex.
			Workspace1.Vertices(V1(i)).Order = 10;
			Workspace1.Vertices(V1(i)).Menorah = 0;
			F1 = find([Workspace1.Segments.Vertex1] == V1(i) & ([Workspace1.Segments.Order] == 0 | [Workspace1.Segments.Order] == 1)); % Find the row # of the segment.			
			% if(~isempty(F1) && Workspace1.Segments(F1(1)).Length > Min_Segment_Length) % TODO: Check why CB rects are not deleted when the segment is too short.
			if(~isempty(F1)) % TODO: Check why CB rects are not deleted when the segment is too short.
				A_CB = min(Workspace1.Segments(F1(1)).Line_Angle,360-Workspace1.Segments(F1(1)).Line_Angle); % calc the angle diff between the segment and 0\360.
				if(length(V1) == 2 || A_CB < CB_Max_Angle || A_CB > 180-CB_Max_Angle ) ... % Check if the segment is almost-horizontal. TODO: improve the case of length(V1) = 2.
					S1(end+1,1) = F1(1); % Row number of a segment.
					S1(end,2) = A_CB; % Add only almost-horizontal segments.
					S1(end,3) = Workspace1.Segments(F1(1)).Width; % Add only almost-horizontal segments.
				else
					S2(end+1) = F1(1);
				end
			else
				F2 = find([Workspace1.Segments.Vertex1] == V1(i));
				if(length(F2) > 0)
					S2(end+1) = F2(1);
				end
			end
		end
		
		switch(size(S1,1))
			case 0
				Primary_Array = [];
			case 1
				Primary_Array = S1(1,1);
			case 2
				Primary_Array = [S1(1,1) S1(2,1)]; % CB segments rows numbers.
			otherwise			
				S1 = sortrows(S1,-3); % Sort by the segment width.
				Primary_Array = [S1(1,1) S1(2,1)]; % CB segments rows numbers.
				S2 = [S2,S1(3:end,1)'];
		end
		
		for j=1:length(S2)
			Workspace1.Vertices(find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(S2(j)).Vertex1)).Order = 20;
		end
	% % %
	% Use the straight orientation and the width of the segments in order to trace the primary branch (order 1):
	i = 0;
	while length(Primary_Array) > 0 % For each cell body branch.
		i = i + 1;
		
		Segment_Index = Workspace1.Segments(Primary_Array(1)).Segment_Index; % The 1st segment of the i primary branch.
		Vertex_Index = Workspace1.Segments(Primary_Array(1)).Vertex2; % The 2nd vertex of the 1st segment of the i primary branch.
		Angle1 = Workspace1.Segments(Primary_Array(1)).Line_Angle; % The Line_Angle of the 1st segment of the i primary branch.
		
		Workspace1.Branches(i).Branch_Index = i;
		
		Workspace1.Branches(i).Order = Order1;
		
		Workspace1.Branches(i).Vertices = Workspace1.Segments(Primary_Array(1)).Vertex1; % For the 1st segment of each 1st order branch, the 1st vertex is always Vertex1.
		Workspace1.Branches(i).Length = 0;
		Workspace1.Branches(i).Menorah = 0;
		Workspace1.Branches(i).Rectangles = [];
		
		[Vertices_Arr,Segments_Arr] = Map_Branch(Workspace1.Segments,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,1);
		
		for si=1:length(Segments_Arr) % Update the order of the chosen sets.
			
			Workspace1.Segments(Segments_Arr(si)).Order = Order1;
			
			Workspace1.Segments(Segments_Arr(si)).Menorah = 0;
			Fv = find([Workspace1.Vertices.Vertex_Index] == Vertices_Arr(si));
			Workspace1.Vertices(Fv).Order = 112;
			Workspace1.Vertices(Fv).Menorah = 0;
			
			Workspace1.Branches(i).Segments = [Workspace1.Branches(i).Segments,Workspace1.Segments(Segments_Arr(si)).Segment_Index];
			Workspace1.Branches(i).Vertices = [Workspace1.Branches(i).Vertices,Workspace1.Vertices(Fv).Vertex_Index];
			Workspace1.Branches(i).Length = Workspace1.Branches(i).Length + Workspace1.Segments(Segments_Arr(si)).Length;					
			Workspace1.Branches(i).Rectangles = [Workspace1.Branches(i).Rectangles,Workspace1.Segments(Segments_Arr(si)).Rectangles];
		end
		
		Primary_Array(1) = [];
		
	end
	
end