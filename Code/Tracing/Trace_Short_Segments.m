function [Workspace,Traced_Segments] = Trace_Short_Segments(Workspace)
	
	Min_Segment_Length = Workspace.Parameters.Tracing.Min_Segment_Length;
	[Im_Rows,Im_Cols] = size(Workspace.Image0); % TODO: this is already computed in the parent function.
	
	Traced_Segments = zeros(1,numel(Workspace.Segments)+1);
	t = 0;
	for s=1:numel(Workspace.Segments)
		[Y,X] = ind2sub([Im_Rows,Im_Cols],Workspace.Segments(s).Skeleton_Linear_Coordinates);
		L = sum( sum( [(X(2:end) - X(1:end-1)).^2 ; (Y(2:end) - Y(1:end-1)).^2] ).^0.5 );
		% Workspace.Segments(s).Length = L;
		if(L <= Min_Segment_Length) % Arc-length thresholding.
			t = t + 1;
			Traced_Segments(t) = s; % Save the segment row number to avoid the regular tracing.
			Workspace.Segments(s).Rectangles = struct('X',{},'Y',{},'Width',{});
			Workspace.Segments(s).Rectangles(length(X)).X = -1;
			
			for r=1:length(Y) % For each pixel add a corresponding rectangle.
				Workspace.Segments(s).Rectangles(r).X = X(r);
				Workspace.Segments(s).Rectangles(r).Y = Y(r);
				Workspace.Segments(s).Rectangles(r).Width = 1*Workspace.User_Input.Scale_Factor;
			end
		end
	end
	Traced_Segments(t+1:end) = [];
end