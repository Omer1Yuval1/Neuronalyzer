function [Segments,Traced_Segments] = Trace_Short_Segments(Data)
	
	Min_Segment_Length = Data.Parameters.Tracing.Min_Segment_Length;
	[Im_Rows,Im_Cols] = size(Data.Info.Files.Raw_Image{1}); % TODO: this is already computed in the parent function.
	
    Segments = Data.Segments;
	Traced_Segments = zeros(1,numel(Segments)+1);
	
    t = 0;
	for s=1:numel(Segments)
		[Y,X] = ind2sub([Im_Rows,Im_Cols],Segments(s).Skeleton_Linear_Coordinates);
		L = sum( sum( [(X(2:end) - X(1:end-1)).^2 ; (Y(2:end) - Y(1:end-1)).^2] ).^0.5 );
		% Segments(s).Length = L;
		if(L <= Min_Segment_Length) % Arc-length thresholding.
			t = t + 1;
			Traced_Segments(t) = s; % Save the segment row number to avoid the regular tracing.
			Segments(s).Rectangles = struct('X',{},'Y',{},'Width',{});
			Segments(s).Rectangles(length(X)).X = -1;
			
			for r=1:length(Y) % For each pixel add a corresponding rectangle.
				Segments(s).Rectangles(r).X = X(r);
				Segments(s).Rectangles(r).Y = Y(r);
				Segments(s).Rectangles(r).Width = 1*Data.Info.Experiment(1).Scale_Factor;
			end
		end
	end
	Traced_Segments(t+1:end) = [];
end