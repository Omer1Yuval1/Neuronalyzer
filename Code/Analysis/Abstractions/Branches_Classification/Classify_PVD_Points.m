function W = Classify_PVD_Points(W,Clusters_Struct)
	
	Scale_Factor = W.User_Input.Scale_Factor;
	% All_Points = W.All_Points;
	% Class_Num = max([Clusters_Struct.Class]);
	X = W.All_Points.Midline_Distance ./ (2 .* W.All_Points(p).Half_Radius);
	Y = rescale(W.All_Points.Midline_Orientation .* 180/pi,'InputMin',0,'InputMax',90);
	
	for p=1:numel(W.All_Points) % Find the distance of each PVD point from all cluster centers.
		Dp = ( (X(p) - [Clusters_Struct.Mean_X]).^2 + (Y(p) - [Clusters_Struct.Mean_Y]).^2 ).^(0.5); % Find the distance of the p-point from all clusters centers.
		
		f = find(Dp == min(Dp));
		
		if(isempty(f))
			W.All_Points(p).Class = nan;
		else
			W.All_Points(p).Class = Clusters_Struct(f(1)).Class;
		end
	end
	
	for s=1:numel(W.Segments)
		f = find([W.All_Points.Segment_Index] == W.Segments(s).Segment_Index);
		W.Segments(s).Class = mode([W.All_Points(f).Class]);
	end
	
	if(0)
		C = lines(numel(Clusters_Struct));
		% figure;
		imshow(W.Image0);
		hold on;
		scatter([W.All_Points.X],[W.All_Points.Y],10,C([W.All_Points.Class],:),'filled');
	end
end