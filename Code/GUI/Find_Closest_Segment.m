function S = Find_Closest_Segment(Workspace1)
	
	set(gcf,'Pointer','crosshair');
	
	D = 1000;
	F0 = [];
	S = 0;
	
	[x,y] = ginput(1);
	% Find a close coordinate to [x,y].
	for s=1:numel(Workspace1.Segments)
		for r=1:numel(Workspace1.Segments(s).Rectangles)
			Xr = Workspace1.Segments(s).Rectangles(r).X;
			Yr = Workspace1.Segments(s).Rectangles(r).Y;
			D1 = ( (x-Xr)^2 + (y-Yr)^2 )^0.5;
			if(D1 < D)
				D = D1;
				S = s;
			end
		end
	end
	
	set(gcf,'Pointer','arrow');
	
end