function Find_Longitudinal_Axis_Segments(Workspace1,Cxy)
	
	% Find the segments\tips closest to the CB center point.
	F1 = find([Workspace1.Vertices.Vertex_Index] < 0); % Find all tips.
	
	D1 = zeros(1,length(F1)); % Array of distances from cell-body center.
	S1 = zeros(1,length(F1)); % Array of segments.
	for t=1:length(F1) % Go over all tips.
		D1(t) = ((Workspace1.Vertices(F1(t)).Coordinate(1) - Cxy(1))^2 + (Workspace1.Vertices(F1(t)).Coordinate(2) - Cxy(2))^2)^.5;
		S1(t) = find([Workspace1.Segments.Vertex1_Index] == Workspace1.Vertices(F1(t)).Vertex_Index | ...
					[Workspace1.Segments.Vertex2_Index] == Workspace1.Vertices(F1(t)).Vertex_Index);
		E1 = Workspace1.Segments(S1(t)).End2End_Angle; % [0,pi].
	end
	
	% Sort by distance from CB:
	[D1,I] = sort(D1); % First index contains smallest value.
	F1 = F1(I); % Sort F1 based on the distances in D1.
	S1 = S1(I); % ".
	E1 = E1(I); % ".
	
	% Choose the best two:
		% First, take only those that are approximately parrallel to the grid:
			
	
end