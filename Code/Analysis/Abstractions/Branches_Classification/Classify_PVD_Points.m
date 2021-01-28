function Data = Classify_PVD_Points(Data,Clusters_Struct)
	
	% TODO: move to parameters file:
		X_Min_Max = [-2,2];
		Y_Min_Max = [-1,1];
		XFunc = @(x) rescale(x,X_Min_Max(1),X_Min_Max(2),'InputMin',-pi/2,'InputMax',pi/2);
		YFunc = @(y) rescale(y,Y_Min_Max(1),Y_Min_Max(2),'InputMin',0,'InputMax',pi/2);
		
		Classification_Method = 1; % 1 = Classify points based on the closest cluster center.
		Clusters_By_Distance = [2,4];
		% Min_Cluster_Distance = 0.5;
	
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	
	X = [Data.Points.Angular_Coordinate]; % Midline_Distance.
	Y = [Data.Points.Midline_Orientation_Corrected]; % Midline_Orientation.
	
	X = -XFunc(X); % Minus to make the ventral on the negative side (it is defined as positive in the database).
	Y = YFunc(Y);
	
	% R3 = [Data.Points.Half_Radius]; % Half-radius.
	% R4 = [Data.Points.Radius]; % Radius.
	% [X,Y] = Rescale_Midline_Distance_And_Orientation(X,Y,R3,R4);
	
	[Data.Points.Class] = deal(nan);
	switch(Classification_Method)
		case 1 % Classify points based on the closest cluster center.
			for p=1:numel(Data.Points) % Find the distance of each PVD point from all cluster centers.
				Dp = ( (X(p) - [Clusters_Struct.Mean_X]).^2 + (Y(p) - [Clusters_Struct.Mean_Y]).^2 ).^(0.5); % Find the distance of the p-point from all clusters centers.
				f = find(Dp == min(Dp));
				
				if(~isempty(f))
					Data.Points(p).Class = Clusters_Struct(f(1)).Class;
				end
			end
		case 2 % Classify points within clusters.
			for c=1:numel(Clusters_Struct) % For each cluster.
				Bx = Clusters_Struct(c).X_Boundary;
				By = Clusters_Struct(c).Y_Boundary;
				
				in = inpolygon(X,Y,Bx,By);
				
				[Data.Points(in).Class] = deal(Clusters_Struct(c).Class);
			end
		case 3 % A mixture of methods 1 and 2.
			
			% First classify all points that fall within the boundaries of clusters:
			for c=1:numel(Clusters_Struct) % For each cluster.
				Bx = Clusters_Struct(c).X_Boundary;
				By = Clusters_Struct(c).Y_Boundary;
				in = inpolygon(X,Y,Bx,By);
				[Data.Points(in).Class] = deal(Clusters_Struct(c).Class);
			end
			
			% Then classify on the remaining points by distance from clusters:
			Vnan = find(isnan([Data.Points.Class])); % Find all points classified as NaN.
			for p=Vnan % For each unclassified point.
				Dp = ( (X(p) - [Clusters_Struct.Mean_X]).^2 + (Y(p) - [Clusters_Struct.Mean_Y]).^2 ).^(0.5); % Find the distance of the p-point from all clusters centers.
				f = find(Dp == min(Dp),1);
				if(~isempty(f) && ismember(Clusters_Struct(f).Class,Clusters_By_Distance))
					Data.Points(p).Class = Clusters_Struct(f).Class;
				end
			end
	end
	
	Data.Segments = Classify_PVD_Segment(Data);
	
	% Add the segment class to the points struct:
	[Data.Points.Segment_Class] = deal(nan);
	for s=1:numel(Data.Segments)
		Fs = find([Data.Points.Segment_Index] == Data.Segments(s).Segment_Index);
		[Data.Points(Fs).Segment_Class] = deal(Data.Segments(s).Class);
	end
	
	
	% After classifying the segments, classify vertices accordingly:
	% V = reshape([Data.Segments.Vertices],2,[]); % [2 x Ns].
	Data.Vertices(end).Class = [];
	for v=1:numel(Data.Vertices)
		Vs = [Data.Vertices(v).Rectangles.Segment_Index]; % A vector of ordered segment indices corresponding to the vertex rectangles.
		Ns = length(Vs);
		l = nan(1,Ns);
		for r=1:Ns % For each vertex rectangle (and its corresponding segment index).
			f1 = find([Data.Segments.Segment_Index] == Vs(r)); % Find the segment.
			Data.Vertices(v).Rectangles(r).Segment_Class = Data.Segments(f1).Class; % Extract segment class.
			l(r) = Data.Segments(f1).Class;
		end
		Data.Vertices(v).Class = l; % sum(sort(l) .* (10.^(Ns-1:-1:0)));
	end
	
	if(0)
		C = lines(numel(Clusters_Struct));
		% figure;
		imshow(Data.Image0);
		hold on;
		scatter([Data.Points.X],[Data.Points.Y],10,C([Data.Points.Class],:),'filled');
	end
end