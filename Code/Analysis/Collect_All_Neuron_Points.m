function All_Points = Collect_All_Neuron_Points(W)
	
	All_Points = struct('X',{},'Y',{},'Length',{},'Angle',{},'Curvature',{},'Is_Vertex',{},'Dorsal_Ventral',{});
	All_Points(3*(10^4)).X = nan;
	ii = 0;
	for s=1:numel(W.Segments)
		
		if(~isempty(W.Segments(s).Rectangles))
			f_v1 = find([W.Vertices.Vertex_Index] == W.Segments(s).Vertices(1));
			f_v2 = find([W.Vertices.Vertex_Index] == W.Segments(s).Vertices(2));
			
			Sx = [ W.Vertices(f_v1).Coordinate(1) , [W.Segments(s).Rectangles.X] , W.Vertices(f_v2).Coordinate(1)];
			Sy = [ W.Vertices(f_v1).Coordinate(2) , [W.Segments(s).Rectangles.Y] , W.Vertices(f_v2).Coordinate(2)];
			
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
			end
		end
	end
	All_Points = All_Points(1:ii);
end