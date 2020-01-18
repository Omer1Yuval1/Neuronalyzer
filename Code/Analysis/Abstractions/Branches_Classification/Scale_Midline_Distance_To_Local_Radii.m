function [D,Fin] = Scale_Midline_Distance_To_Local_Radii(D0,R3,R4)

	% This function rescales the midline distances to local PVD raddi.
	% The radii are given as either the dorsal or ventral radii, depending on the side of the corresponding coordinate.
	
	F3 = find(abs(D0) <= R3); % Find points that are between the midline and half-radius.
	F4 = find(abs(D0) > R3 & abs(D0) <= R4); % Find points that are between the half-radius and radius.

	D = abs(D0);
	D(F3) = rescale(D(F3),0,0.5,'InputMin',zeros(1,length(F3)),'InputMax',R3(F3)); % Rescale the midline distance from [0,R3(:)] to [0,0.5].
	D(F4) = rescale(D(F4),0.5,1,'InputMin',R3(F4),'InputMax',R4(F4)); % Rescale the midline distance from [R3(:),R4(:)] to [0.5,1].
	
	Fin = find(D <= R4); % Find points that are inside the neuron's boundaries.
	
	D = D .* sign(D0); % Add back the sign of the midline distance.
	
end