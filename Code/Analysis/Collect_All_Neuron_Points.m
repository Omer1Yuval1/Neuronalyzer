function Data = Collect_All_Neuron_Points(Data)
	
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	
	Data.Points = struct('X',{},'Y',{},'Length',{},'Angle',{},'Curvature',{},'Is_Vertex',{},'Dorsal_Ventral',{});
	Data.Points(3*(10^4)).X = nan; % Memory pre-allocation.
	
	% Vertices = struct('X',{},'Y',{},'Order',{},'Angles',{},'Midline_Distance',{},'Midline_Orientation',{},'Dorsal_Ventral',{});
	% Vertices(3*(10^3)).X = nan;
	
	ii = 0;
	for s=1:numel(Data.Segments)
		
		if(~isempty(Data.Segments(s).Rectangles) && all(Data.Segments(s).Vertices > 0))
			f_v1 = find([Data.Vertices.Vertex_Index] == Data.Segments(s).Vertices(1));
			f_v2 = find([Data.Vertices.Vertex_Index] == Data.Segments(s).Vertices(2));
			
			% Find the specific rectangle within each vertex that correspond to the current segment:
			% a_v1 = find([Data.Vertices(f_v1).Rectangles.Segment_Index] == Data.Segments(s).Segment_Index);
			% a_v2 = find([Data.Vertices(f_v2).Rectangles.Segment_Index] == Data.Segments(s).Segment_Index);
			
            % Add the end-points of the segments (junctions or tips):
            Sx = [ Data.Vertices(f_v1).X , [Data.Segments(s).Rectangles.X] , Data.Vertices(f_v2).X];
            Sy = [ Data.Vertices(f_v1).Y , [Data.Segments(s).Rectangles.Y] , Data.Vertices(f_v2).Y];
            
			Vertices_Orders = 2.*ones(1,length(Sx)-1); % All points that are not tips of junctions are vertices of order 2.
			Vertices_Orders(1) = Data.Vertices(f_v1).Order;
			Vertices_Orders(end) = Data.Vertices(f_v2).Order;
			
			Vertex_Indices = nan(1,length(Sx)-1);
			Vertex_Indices(1) = Data.Vertices(f_v1).Vertex_Index;
			Vertex_Indices(end) = Data.Vertices(f_v2).Vertex_Index;
			
			% Angles = nan(1,length(Sx)); % Rectangle angles.
			% ds = nan(1,length(Sx)); % Rectangle lengths.
			% Angles(1) = Data.Vertices(f_v1).Rectangles(a_v1).Angle;
			% Angles(end) = Data.Vertices(f_v1).Rectangles(a_v2).Angle;
			
			dsx = Sx(2:end)-Sx(1:end-1);
			dsy = Sy(2:end)-Sy(1:end-1);
			Angles = atan2(dsy , dsx);
			ds = (dsx.^2 + dsy.^2).^(.5);
			
			[~,~,~,~,Cxy] = Get_Segment_Curvature(Sx,Sy,Data.Parameters.Analysis.Curvature.Min_Points_Num_Smoothing);
			
			for p=1:length(Sx)-1
				ii = ii + 1;
				Data.Points(ii).X = Sx(p);
				Data.Points(ii).Y = Sy(p);
				Data.Points(ii).Angle = mod(Angles(p),2*pi); % [0,2*pi].
				Data.Points(ii).Length = ds(p) .* Scale_Factor; % Pixels to Micrometers.
				Data.Points(ii).Curvature = Cxy(p) ./ Scale_Factor; % 1/Pixels to 1/Micrometers.
				Data.Points(ii).Vertex_Order = Vertices_Orders(p);
				Data.Points(ii).Segment_Index = Data.Segments(s).Segment_Index;
				Data.Points(ii).Vertex_Index = Vertex_Indices(p);
			end
		end
	end
	Data.Points = Data.Points(1:ii);
end