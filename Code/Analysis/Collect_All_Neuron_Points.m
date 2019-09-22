function [All_Points,All_Vertices] = Collect_All_Neuron_Points(W)
	
	All_Points = struct('X',{},'Y',{},'Length',{},'Angle',{},'Curvature',{},'Is_Vertex',{},'Dorsal_Ventral',{});
	All_Points(3*(10^4)).X = nan;
	
	All_Vertices = struct('X',{},'Y',{},'Order',{},'Angles',{},'Midline_Distance',{},'Midline_Orientation',{},'Dorsal_Ventral',{});
	All_Vertices(3*(10^3)).X = nan;
	
	ii = 0;
	for s=1:numel(W.Segments)
		
		if(~isempty(W.Segments(s).Rectangles))
			f_v1 = find([W.Vertices.Vertex_Index] == W.Segments(s).Vertices(1));
			f_v2 = find([W.Vertices.Vertex_Index] == W.Segments(s).Vertices(2));
			
			Sx = [ W.Vertices(f_v1).Coordinate(1) , [W.Segments(s).Rectangles.X] , W.Vertices(f_v2).Coordinate(1)];
			Sy = [ W.Vertices(f_v1).Coordinate(2) , [W.Segments(s).Rectangles.Y] , W.Vertices(f_v2).Coordinate(2)];
			
			Vertices_Orders = 2.*ones(1,length(Sx)); % All points that are not tips of junctions are vertices of order 2.
			Vertices_Orders(1) = W.Vertices(f_v1).Order;
			Vertices_Orders(end) = W.Vertices(f_v2).Order;
			
			dsx = Sx(2:end)-Sx(1:end-1);
			dsy = Sy(2:end)-Sy(1:end-1);
			Angles = atan2(dsy , dsx);
			ds = (dsx.^2 + dsy.^2).^(.5);
			
			[~,~,~,~,Cxy] = Get_Segment_Curvature(Sx,Sy);
			
			for p=1:length(Sx)-1
				ii = ii + 1;
				All_Points(ii).X = Sx(p);
				All_Points(ii).Y = Sy(p);
				All_Points(ii).Angle = mod(Angles(p),2*pi); % [0,2*pi].
				All_Points(ii).Length = ds(p) .* W.User_Input.Scale_Factor; % Pixels to Micrometers.
				All_Points(ii).Curvature = Cxy(p) ./ W.User_Input.Scale_Factor; % 1/Pixels to 1/Micrometers.
				All_Points(ii).Vertex_Order = Vertices_Orders(p);
				All_Points(ii).Segment_Index = W.Segments(s).Segment_Index;
			end
		end
	end
	All_Points = All_Points(1:ii);
	
	ii = 0;
	for v=1:numel(W.Vertices)
		
		ii = ii + 1;
		All_Vertices(ii).Vertex_Index = W.Vertices(v).Vertex_Index;
		All_Vertices(ii).X = W.Vertices(v).Coordinate(1);
		All_Vertices(ii).Y = W.Vertices(v).Coordinate(2);
		All_Vertices(ii).Order = W.Vertices(v).Order;
		All_Vertices(ii).Angles = W.Vertices(v).Angles;
		
		% TODO:
			% find the segments for each vertex, extract their Menorah order.
			% Assign an order to the junction - a 3-digit number.
	end
	All_Vertices = All_Vertices(1:ii);
end