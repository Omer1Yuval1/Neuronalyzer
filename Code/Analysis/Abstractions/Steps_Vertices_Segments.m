function Workspace1 = Steps_Vertices_Segments(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	Rect_Length_Width_Ratio = Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Length_Width_Ratio;
	% SmoothingParameter = Workspace1.Parameters.Branch_Parameters.Auto_Tracing_Parameters.Segment_Smoothing_Parameter;
	
	Workspace1.Vertices = struct('Vertex_Index',{},'Order',{},'Coordinates',{},'Rectangles_Indexes',{},'Rectangles_Angles',{},'Source_Rectangle',{},'Vertex_Order',{},'Interval',{});
	vi = 0;
	Workspace1.Segments = struct('Segment_Index',{},'Order',{},'Rectangles',{},'Vertex1',0,'Vertex2',0,'Length',{},'Straight_Length',{},'Curviness',{},'Line_Angle',{});
	si = 0;
	% TODO: Predetermine the size of Workspace1.Vertices & Workspace1.Segments.
	
	% TODO: try to merge the vertices and segments loops.
	
	Workspace1.Loops = struct('Rectangle_Index1',{},'Rectangle_Index2',{},'Segment_Index1',{},'Segment_Index2',{});
	F1 = find([Workspace1.Path.Looped_To_Step] > 0 & [Workspace1.Path.Is_Mapped] > 0); % List all loops.
	for i=1:length(F1) % For each loop point.
		Workspace1.Loops(i).Rectangle_Index1 = Workspace1.Path(F1(i)).Rectangle_Index; % 1st row: rectangles indices.
		F2 = find([Workspace1.Path.Step_Index] == Workspace1.Path(F1(i)).Looped_To_Step);
		Workspace1.Loops(i).Rectangle_Index2 = Workspace1.Path(F2(1)).Rectangle_Index; % 2nd row: matching rectangles indices.
		
		Workspace1.Loops(i).Coordinate = Workspace1.Path(F2(1)).Coordinates;
	end
	
	% Workspace1.Vertices:
	Ms = max([Workspace1.Path.Step_Index]);
	for i=1:Ms % For each step.		
		f = find([Workspace1.Path.Step_Index] == i & [Workspace1.Path.Is_Mapped] > 0);
		if(length(f) > 1 || (length(f) > 0 && [Workspace1.Path(f(1)).Connection] == 0)) % If a step includes more than 1 rect OR If it's a cell body rect - it's part of a junction.
			vi = vi + 1;
			Workspace1.Vertices(end+1).Vertex_Index = vi; % Create a new record.
			Workspace1.Vertices(end).Rectangles_Indexes = [Workspace1.Path(f).Rectangle_Index]; % Add all the rects of this step to this vertex.
			Workspace1.Vertices(end).Rectangles_Indexes(end+1) = Workspace1.Path(f(1)).Connection; % Cell body vertices get 0 here.
			Workspace1.Vertices(end).Source_Rectangle = Workspace1.Path(f(1)).Connection; % Cell body vertices get 0 here.
			for j=1:length(Workspace1.Vertices(end).Rectangles_Indexes) % For each rectangle (the last rect is the source rect).
				if(Workspace1.Vertices(end).Rectangles_Indexes(j) > 0) % If NOT a cell-body vertex.
					FA = find([Workspace1.Path.Rectangle_Index] == Workspace1.Vertices(end).Rectangles_Indexes(j));
					if(j < length(Workspace1.Vertices(end).Rectangles_Indexes)) % If one of the new rectangles.
						Workspace1.Vertices(end).Rectangles_Angles(end+1) = mod(Workspace1.Path(FA).Angle,360); % Degrees.
					else % The last rectangle - the root\source rectangle.
						Workspace1.Vertices(end).Rectangles_Angles(end+1) = mod(Workspace1.Path(FA).Angle+180,360);	% The vector should be pointing out of the vertex.				
					end
				else % TODO: check.
					Workspace1.Vertices(end).Rectangles_Angles(end+1) = mod(Workspace1.Vertices(end).Rectangles_Angles(1)+90,360); % Degrees. % TODO: use the derivative of cell body ellipse.
				end
			end
			if(Workspace1.Path(f(1)).Connection == 0)
				Workspace1.Vertices(end).Vertex_Order = -1; % -1 means that it's a cell body rectangle.
			else
				Workspace1.Vertices(end).Vertex_Order = length(f) + 1;
			end
			Workspace1.Vertices(end).Coordinates = [Workspace1.Path(f(1)).Coordinates(1),Workspace1.Path(f(1)).Coordinates(2)];
			for j=1:length(f) % For each possible route, check if it's a single step\rect route (a tip connected to a junction).
				f1 = find([Workspace1.Path.Connection] == Workspace1.Path(f(j)).Rectangle_Index & [Workspace1.Path.Is_Mapped] > 0);
				if(isempty(f1)) % If indeed nothing is connceted to it, add a tip record:
					vi = vi + 1;
					Workspace1.Vertices(end+1).Vertex_Index = -vi;
					Workspace1.Vertices(end).Rectangles_Indexes = Workspace1.Path(f(j)).Rectangle_Index; % Add all the rects of this step to this vertex.
					Workspace1.Vertices(end).Source_Rectangle = Workspace1.Path(f(j)).Rectangle_Index;
					Workspace1.Vertices(end).Vertex_Order = 1;
					f1 = find([Workspace1.Path.Rectangle_Index] == Workspace1.Path(f(j)).Rectangle_Index);
					Workspace1.Vertices(end).Coordinates = [Workspace1.Path(f1).Coordinates(1),Workspace1.Path(f1).Coordinates(2)];
				end
			end
		elseif(length(f) == 1) % If the step includes only 1 rect, check if it's a tip.
			f1 = find([Workspace1.Path(f(1):end).Connection] == Workspace1.Path(f(1)).Rectangle_Index & ...
				[Workspace1.Path(f(1):end).Is_Mapped] > 0); % Look if there's something connected to it. I use only part of 'Path'. This is possible since the values of f1 are not used.
			if(isempty(f1)) % if no rect is connected to the 1st rect in this step, then it's a tip.
				vi = vi + 1;
				Workspace1.Vertices(end+1).Vertex_Index = -vi;
				Workspace1.Vertices(end).Rectangles_Indexes = [Workspace1.Path(f).Rectangle_Index];
				Workspace1.Vertices(end).Source_Rectangle = Workspace1.Path(f(1)).Rectangle_Index;
				Workspace1.Vertices(end).Vertex_Order = 1;
				Workspace1.Vertices(end).Coordinates = [Workspace1.Path(f(1)).Coordinates(1),Workspace1.Path(f(1)).Coordinates(2)];
			end
		end
	end
	
	% Workspace1.Segments:
	for i=1:numel(Workspace1.Vertices) % Go over all vertices.
		if(Workspace1.Vertices(i).Vertex_Order == 1) % If it's a tip.
			continue; % Skip it.
		% elseif(Workspace1.Vertices(i).Vertex_Order == -1) % If it's a cell body rectangle.
		end
		for j=1:size(Workspace1.Vertices(i).Rectangles_Indexes,2)-1 % For each route coming out of this vertex (the last index is the source and thus not included).
			si = si + 1; % Segment Index.
			Width_Arr = [];
			Workspace1.Segments(si).Segment_Index = si; % Create a new record (segment).
			Workspace1.Segments(si).Vertex1 = Workspace1.Vertices(i).Vertex_Index; % First vertex.
			r1 = Workspace1.Vertices(i).Rectangles_Indexes(j); % The index of the current route (1st rect of this route).
			s1 = find([Workspace1.Path.Rectangle_Index] == r1); % Find the row # of this rect in 'Workspace1.Path'.
			Workspace1.Segments(si).Rectangles(end+1).Rectangle_Index = r1; % Add the second rect to the segment.
			Workspace1.Segments(si).Rectangles(end).X = Workspace1.Path(s1).Coordinates(1); % 1st rect of the segment.
			Workspace1.Segments(si).Rectangles(end).Y = Workspace1.Path(s1).Coordinates(2); % ".
			Workspace1.Segments(si).Rectangles(end).Angle = Workspace1.Path(s1).Angle; % ".
			Workspace1.Segments(si).Rectangles(end).Step_Length = Workspace1.Path(s1).Rect_Length; % ".
			Workspace1.Segments(si).Rectangles(end).Width = Workspace1.Path(s1).Width; % ".
			while(1)
				f1 = find([Workspace1.Vertices.Source_Rectangle] == r1); % Checking the connection is not enough because of the case of "tip-junctions". % f1 = find([Workspace1.Path.Connections] == r1 & [Workspace1.Path.Is_Mapped] > 0); % Find the rectangles connected to this rect.
				if(length(f1) > 0) % Check if 'r1' (last added step\rectangle) is the source rect of any vertex.
					Workspace1.Segments(si).Vertex2 = Workspace1.Vertices(f1).Vertex_Index; % Second vertex.
					Workspace1.Segments(si).Vertex1_Angle = Workspace1.Segments(si).Rectangles(1).Angle; % Angle of the 1st vertex.
					Workspace1.Segments(si).Vertex2_Angle = Workspace1.Segments(si).Rectangles(end).Angle; % Angle of the 1st vertex.
					break;
				else % If it's not a tip or the source rect of a junction, check what's connected to it.
					f1 = find([Workspace1.Path.Connection] == r1 & [Workspace1.Path.Is_Mapped] > 0); % Find the row number of the rectangle connected to it.
					r1 = Workspace1.Path(f1).Rectangle_Index;
					s1 = find([Workspace1.Path.Rectangle_Index] == r1);
					Workspace1.Segments(si).Rectangles(end+1).Rectangle_Index = r1;
					Workspace1.Segments(si).Rectangles(end).X = Workspace1.Path(s1).Coordinates(1); % First rect of the segment.
					Workspace1.Segments(si).Rectangles(end).Y = Workspace1.Path(s1).Coordinates(2); % ".
					Workspace1.Segments(si).Rectangles(end).Angle = Workspace1.Path(s1).Angle;
					Workspace1.Segments(si).Rectangles(end).Step_Length = Workspace1.Path(s1).Rect_Length;
					Workspace1.Segments(si).Rectangles(end).Width = Workspace1.Path(s1).Width;
				end
			end
		end
	end
	
	% Assigning additional properties to all segments:
	for i=1:numel(Workspace1.Segments)
		if(numel(Workspace1.Segments(i).Rectangles) == 1) % Only one rectangle. This means that two vertices have a mutual rectangle;
			Workspace1.Segments(i).Length = 0;
			Workspace1.Segments(i).Straight_Length = 0;
			Workspace1.Segments(i).Curviness = 0;
			Workspace1.Segments(i).Line_Angle = Workspace1.Segments(i).Rectangles(1).Angle;
			% Workspace1.Segments(i).Rectangles(1).Persistence_Length = 0;
		else
			% Workspace1.Segments(i).Length = sum([Workspace1.Segments(i).Rectangles(1:end-1).Step_Length]); % Sum of all step lengths, besides the last one.
			Workspace1.Segments(i).Length = sum([Workspace1.Segments(i).Rectangles(1:end).Step_Length]); % Sum of all step lengths, besides the last one.
			% Workspace1.Segments(i).Straight_Length = ( ((Workspace1.Segments(i).Rectangles(end).Y-Workspace1.Segments(i).Rectangles(1).Y)^2 + (Workspace1.Segments(i).Rectangles(end).X-Workspace1.Segments(i).Rectangles(1).X)^2)^0.5)*Scale_Factor; % The coodinates of the last point (rectangle origin (14)) is the point where the n-1 step ends.
			F1 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(i).Vertex1);
			F2 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(i).Vertex2);
			Workspace1.Segments(i).Straight_Length = ( ((Workspace1.Vertices(F1).Coordinates(2)-Workspace1.Vertices(F2).Coordinates(2))^2 + (Workspace1.Vertices(F1).Coordinates(1)-Workspace1.Vertices(F2).Coordinates(1))^2)^0.5)*Scale_Factor;
			Workspace1.Segments(i).Curviness = 1 - (Workspace1.Segments(i).Straight_Length/Workspace1.Segments(i).Length);
			% Workspace1.Segments(i).Rectangles = Persistence_Length(Workspace1.Segments(i).Rectangles);
			Workspace1.Segments(i).Line_Angle = mod(atan2d(Workspace1.Segments(i).Rectangles(end).Y-Workspace1.Segments(i).Rectangles(1).Y,Workspace1.Segments(i).Rectangles(end).X-Workspace1.Segments(i).Rectangles(1).X),360);
		end
		Workspace1.Segments(i).Width = mean([Workspace1.Segments(i).Rectangles(:).Width]);
		
		% [Workspace1.Segments(i).Rectangles,MeanR_LMS,MeanR2_LMS] = Curvature_Least_Mean_Squared(Workspace1.Segments(i).Rectangles,Scale_Factor,SmoothingParameter);
		% Workspace1.Segments(i).Curvature = MeanR_LMS;
		% Workspace1.Segments(i).Curvature2 = MeanR2_LMS;
		
		for l=1:numel(Workspace1.Loops)
			if(length(Workspace1.Loops(l).Segment_Index1) == 0)
				F1 = find([Workspace1.Segments(i).Rectangles.Rectangle_Index] == Workspace1.Loops(l).Rectangle_Index1);
				F2 = find([Workspace1.Segments(i).Rectangles.Rectangle_Index] == Workspace1.Loops(l).Rectangle_Index2);
				
				if(length(F1))
					Workspace1.Loops(l).Segment_Index1 = Workspace1.Segments(i).Segment_Index;
				elseif(length(F2))
					Workspace1.Loops(l).Segment_Index2 = Workspace1.Segments(i).Segment_Index;
				end
			end
		end
	end
	
	% TODO: prevent this cases during the tracing:
	Workspace1.Loops(find([Workspace1.Loops.Rectangle_Index1] == [Workspace1.Loops.Rectangle_Index2])) = [];
	
	[Workspace1.Segments.Order] = deal(0);
end