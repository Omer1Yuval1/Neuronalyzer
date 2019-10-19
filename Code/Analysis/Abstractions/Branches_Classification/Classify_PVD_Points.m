function W = Classify_PVD_Points(W,Clusters_Struct)
	
	Scale_Factor = W.User_Input.Scale_Factor;
	% All_Points = W.All_Points;
	% Class_Num = max([Clusters_Struct.Class]);
	X = [W.All_Points.Midline_Distance] ./ (2 .* [W.All_Points.Half_Radius]); % The result is between [0,1].
	Y = rescale([W.All_Points.Midline_Orientation] .* 180/pi,0,1,'InputMin',0,'InputMax',90);
	
	fx = find(abs(X) > 1);
	X(fx) = nan;
	Y(fx) = nan;
	
	X = rescale(X,0,1);
	
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
        if(~isempty(f))
            W.Segments(s).Class = mode([W.All_Points(f).Class]);
        else
            W.Segments(s).Class = nan;
        end
	end
	
	% V = reshape([W.Segments.Vertices],2,[]); % [2 x Ns].
	W.All_Vertices(end).Class = [];
	W.Vertices(end).Class = [];
    for v=1:numel(W.Vertices)
		Vs = [W.Vertices(v).Rectangles.Segment_Index]; % A vector of ordered segment indices corresponding to the vertex rectangles.
		Ns = length(Vs);
		l = nan(1,Ns);
		for r=1:Ns % For each vertex rectangle (and its corresponding segment index).
			f1 = find([W.Segments.Segment_Index] == Vs(r));
			W.Vertices(v).Rectangles(r).Segment_Class = W.Segments(f1).Class;
			l(r) = W.Segments(f1).Class;
		end
		W.All_Vertices(v).Class = sum(sort(l) .* (10.^(Ns-1:-1:0)));
		W.Vertices(v).Class = sum(sort(l) .* (10.^(Ns-1:-1:0)));
	end
	
	if(0)
		C = lines(numel(Clusters_Struct));
		% figure;
		imshow(W.Image0);
		hold on;
		scatter([W.All_Points.X],[W.All_Points.Y],10,C([W.All_Points.Class],:),'filled');
	end
end