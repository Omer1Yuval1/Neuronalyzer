function Vertices = Match_CB_Vertices(Vertices,CB_Vertices)
	
	for i=1:numel(CB_Vertices)
		
		Vxy = [Vertices.Coordinate];
		Vx = Vxy(1:2:end-1);
		Vy = Vxy(2:2:end);
		
		D = ((Vx-CB_Vertices(i).Coordinate(1)).^2 + (Vy-CB_Vertices(i).Coordinate(2)).^2).^.5; % Distances of vertices from the i-th CB branch outset.
		
		F = find(D == min(D)); % Find the closest vertex to the i-th CB branch outset.
		
		Vertices(F).Order = - Vertices(F).Order; % Mark it as a CB outset using the minus sign.
		
		if(abs(Vertices(F).Order) > 1)
			disp('I found a CB outset with more than one rectangle');
		end
	end
	
end