function Output = Calc_Junction_Angles(Angles)
	
	m = 2*pi;
	if(length(Angles) == 3) % Do only for 3-way junctions.
        
		V = [(1:3)',(mod(Angles,m))'];
		V = sortrows(V,2); % Sort by angle size.
		
		A21 = V(2,2) - V(1,2);
		A32 = V(3,2) - V(2,2);
		A31 = m - A21 - A32;
		
		Output = [A21,A32,A31];
	elseif(length(Angles) == 1) % Tips.
		Output = mod(Angles(1),m);
	else
		Output = -1;
	end
	
end