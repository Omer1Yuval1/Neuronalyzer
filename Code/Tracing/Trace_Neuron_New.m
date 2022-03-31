function Trace_Neuron_New(Im,Segments)
	
	% TODO:
		% In Segment_Skeleton.m, prepare skeleton coordinates in the same format as the final segments.
			% Their coordinates and width will only be tweaked by this algorithm.
	
	for s=1:numel(Segments)
		for r=1:numel(Segments(s).Rectangles)
			
			P = Segments(s).Rectangles(r).Coordinate;
			A = Segments(s).Rectangles(r).Angle;
			W = Segments(s).Rectangles(r).Width;
			% Length (L) should be set as a ratio of the width, but also constrained by the length of segment before and after that point.
			% upper and lower bounds for width should be ratios of the skeleton width.
			% Bound for the angle should be a fixed dA in radians.
			
			% TODO: take into account image boundaries:
			dL = 20;
			Im_Crop = Im(P(2)+[-dL,dL],P(1)+[-dL,dL]);
			
			x = fmincon(@(x) fit_rect(x,Im_Crop,P,L),[A,W/2,W/2],[],[],[],[],lb,ub);
			
		end
	end
end