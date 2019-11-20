function [X,Y] = Rescale_Midline_Distance_And_Orientation(X0,Y0,R3,R4)
	
	% Rescale midline distance to PVD raddi:
	F3 = find(abs(X0) <= R3); % Find points that are between the midline and half-radius.
	F4 = find(abs(X0) > R3 & abs(X0) <= R4); % Find points that are between the half-radius and radius.
	
	X = abs(X0);
	X(F3) = rescale(X(F3),0,0.5,'InputMin',zeros(1,length(F3)),'InputMax',R3(F3)); % Rescale the midline distance from [0,R3(:)] to [0,0.5].
	X(F4) = rescale(X(F4),0.5,1,'InputMin',R3(F4),'InputMax',R4(F4)); % Rescale the midline distance from [R3(:),R4(:)] to [0.5,1].
	X = X .* sign(X0); % Add back the sign of the midline distance.
	
	Y = rescale(Y0,-1,1,'InputMin',0,'InputMax',pi/2);
	
	% Find points that are outside the neuron's boundaries, and set them to nan:
	F5 = find(abs(X0) > R4);
	X(F5) = nan;
	Y(F5) = nan;
	
end