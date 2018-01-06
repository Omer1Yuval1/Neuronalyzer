function Im_Trace = Reconstruct_TraceBW_NN_Old(Workspace1,Show)
	
	[Rows1,Cols1] = size(Workspace1.Image0);
	Im_Trace = zeros(Rows1,Cols1);
	
	Rects = find([Workspace1.Path.Is_Mapped] > -1);
	for i=Rects % For each Rectangle in Path.
		if(Workspace1.Path(i).Is_Mapped >= 0)
			[XV,YV] = Get_Rect_Vector(Workspace1.Path(i).Coordinates,Workspace1.Path(i).Angle,Workspace1.Path(i).Width, ...
						Workspace1.Path(i).Width*Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Length_Width_Ratio,14);
			Coordinates1 = InRect_Coordinates(Workspace1.Image0,[XV',YV']);
			Im_Trace(Coordinates1) = 1;
		end
	end
	
	V = [Workspace1.Path(Rects).Coordinates];
	X = (V(1:2:end));
	Y = (V(2:2:end));
	
	X = max(1,round(X));
	Y = max(1,round(Y));
	
	Linear_Indices = Rows1*(X-1)+Y; % Conversion to linear indices.
	Im_Trace(Linear_Indices) = 1;
	
	if(Show)
		imshow(Im_Trace);	
		set(gca,'YDir','normal');
	end
	
	% display(sum(Im_Trace(:)));
	
end