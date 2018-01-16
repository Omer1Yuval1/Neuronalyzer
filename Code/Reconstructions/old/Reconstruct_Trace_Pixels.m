function Reconstruct_Trace_Pixels(Workspace1)
	
	[Rows1,Cols1] = size(Workspace1.Image0);
	Im_Trace = zeros(Rows1,Cols1);
	
	F = find([Workspace1.Path.Is_Mapped] > -1);
	V = [Workspace1.Path(F).Coordinates];
	X = (V(1:2:end));
	Y = (V(2:2:end));
	
	X = max(1,round(X));
	Y = max(1,round(Y));
	
	Linear_Indices = Rows1*(X-1)+Y; % Conversion to linear indices.
	Im_Trace(Linear_Indices) = 1;
	
	imshow(Im_Trace);
	
	set(gca,'YDir','normal');
	
end