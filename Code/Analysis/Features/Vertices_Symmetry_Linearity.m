% function [S,L] = Vertices_Symmetry(a1,a2,a3)
function Output = Vertices_Symmetry_Linearity(Junction_Angles)	
	
	% This function computes the symmetry and linearity indices.
	% Symmetry is defined as the ratio between the two angles that are most similar to each other (smaller divided my the bigger).
	% Linearity is defined as the angle closest to pi, divided by pi (for normalization).
	% A3 is the angle that is not one the angles used to compute the symmetry ratio.
	
	if(length(Junction_Angles) == 3) % Do only for 3-way junctions.
		
		m = 2*pi;
		
		D12 = abs(Junction_Angles(1) - Junction_Angles(2));
		D13 = abs(Junction_Angles(1) - Junction_Angles(3));
		D23 = abs(Junction_Angles(2) - Junction_Angles(3));
		
		MinD = min([D12,D13,D23]);
		switch MinD
			case D12
				S = min(Junction_Angles(1),Junction_Angles(2)) / max(Junction_Angles(1),Junction_Angles(2));
				A3 = Junction_Angles(3);
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
		
		% Find angle closest to pi:
		V = [Junction_Angles(1),Junction_Angles(2),Junction_Angles(3)];
		Vpi = abs(V - m/2);
		F = find(Vpi == min(Vpi));
		L = V(F(1));
		
		Output = [S,A3,L]; % [Symmetry index , the other angle , Linearity angle].
	else
		Output = 0;
	end
end