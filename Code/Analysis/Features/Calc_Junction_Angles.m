function Output = Calc_Junction_Angles(Rectangles)

	if(numel(Rectangles) == 3) % Do only for 3-way junctions.		
		m = 2*pi;
		
		a1 = Rectangles(1).Angle;
		a2 = Rectangles(2).Angle;
		a3 = Rectangles(3).Angle;
		
		V = [[1:3]',(mod([Rectangles.Angle],m))'];
		V = sortrows(V,2); % Sort by angle size.
		
		A21 = V(2,2) - V(1,2);
		A32 = V(3,2) - V(2,2);
		A31 = m - A21 - A32;
		
		Output = [A21,A32,A31];
	else
		Output = -1;
	end