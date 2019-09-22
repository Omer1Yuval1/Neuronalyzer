function [S,L,A3] = Vertices_Symmetry_Linearity(Junction_Angles)
	
	% This function computes the symmetry and linearity indices.
	% Symmetry is defined as the ratio between the two angles that are most similar to each other (smaller divided my the bigger).
	% Linearity is defined as the angle closest to pi, divided by pi (for normalization).
	% A3 is the angle that is not one of the angles used to compute the symmetry ratio.
	
	S = nan;
	L = nan;
	A3 = nan;
	
	if(length(Junction_Angles) == 3) % Do only for 3-way junctions.
		
		m = 2*pi;
		
		D12 = abs(Junction_Angles(1) - Junction_Angles(2));
		D13 = abs(Junction_Angles(1) - Junction_Angles(3));
		D23 = abs(Junction_Angles(2) - Junction_Angles(3));
		
		if(0)
			MinD = min([D12,D13,D23]);
			switch MinD % Find symmetry and linearity using the pair of angles that are closest to each other.
				case D12
					S = min(Junction_Angles(1),Junction_Angles(2)) / max(Junction_Angles(1),Junction_Angles(2)); % Symmetry.
					A3 = Junction_Angles(3); % The other angle (not used for symmetry).
					% disp(1);
				case D13
					S = min(Junction_Angles(1),Junction_Angles(3)) / max(Junction_Angles(1),Junction_Angles(3));
					A3 = Junction_Angles(2);
					% disp(2);
				case D23
					S = min(Junction_Angles(2),Junction_Angles(3)) / max(Junction_Angles(2),Junction_Angles(3));
					A3 = Junction_Angles(1);
					% disp(3);
			end
		else % Mean Symmetry.
			S(1) = min(Junction_Angles(1),Junction_Angles(2)) / max(Junction_Angles(1),Junction_Angles(2));
			S(2) = min(Junction_Angles(1),Junction_Angles(3)) / max(Junction_Angles(1),Junction_Angles(3));
			S(3) = min(Junction_Angles(2),Junction_Angles(3)) / max(Junction_Angles(2),Junction_Angles(3));
			S = mean(S);
		end
		
		% Find angle closest to pi:
		V = [Junction_Angles(1),Junction_Angles(2),Junction_Angles(3)];
		Vpi = abs(V - m/2);
		F = find(Vpi == min(Vpi));
		L = V(F(1)); % Linearity.
	end
end