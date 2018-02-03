function Vertices = Match_CB_Vertices(Vertices,CB_Vertices)
	
	for i=1:numel(CB_Vertices)
		
		Vxy = [Vertices.Coordinate];
		Vx = Vxy(1:2:end-1);
		Vy = Vxy(2:2:end);
		
		D = ((Vx-CB_Vertices(i).Coordinate(1)).^2 + (Vy-CB_Vertices(i).Coordinate(2)).^2).^.5; % Distances of vertices from the i-th CB branch outset.
		
		F = find(D == min(D)); % Find the closest vertex to the i-th CB branch outset.
		
		Vertices(F(1)).Order = - Vertices(F(1)).Order; % Mark it as a CB outset using the minus sign.
		
		if(abs(Vertices(F(1)).Order) > 1)
			disp('I found a CB outset with more than one rectangle');
		end
		if(length(F) > 1)
			disp('I found more than one closest segment to the i-th vertex. Taking the 1st.');
		end
	end
	
end