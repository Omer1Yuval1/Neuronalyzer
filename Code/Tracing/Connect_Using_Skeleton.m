function Segment = Connect_Using_Skeleton(Segment,Im_Rows,Im_Cols,Scale_Factor)

	[Ys,Xs] = ind2sub([Im_Rows,Im_Cols],Segment.Skeleton_Linear_Coordinates);

	X1 = Segment.Rectangles1(end).X;
	Y1 = Segment.Rectangles1(end).Y;

	D1 = ( (Xs-X1).^2 + (Ys-Y1).^2 ) .^ 0.5; % The distances of all skeleton coordinates from the current step's origin.
	F1 = find(D1 == min(D1)); % Find the closest skeleton coordinate.

	X2 = Segment.Rectangles2(end).X;
	Y2 = Segment.Rectangles2(end).Y;
    
	D2 = ( (Xs-X2).^2 + (Ys-Y2).^2 ) .^ 0.5; % The distances of all skeleton coordinates from the current step's origin.
	F2 = find(D2 == min(D2)); % Find the closest skeleton coordinate.
	
	if(F2(1) > F1(1) + 1)
		for r=F1(1)+1:F2(1)-1
			Segment.Rectangles1(end+1).X = Xs(r);
			Segment.Rectangles1(end).Y = Ys(r);
			Segment.Rectangles1(end).Width = 1 .* Scale_Factor;
		end
	end
end