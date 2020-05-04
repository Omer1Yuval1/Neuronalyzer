function D = Get_Linearity(XY)
	
	% XY = [Np x 2].
	
	v1 = XY(1,:); % Head point. [1 x 2].
	v2 = XY(end,:); % Tail point. [1 x 2].
	
	a = v1 - v2;
	b = XY(2:end-1,:) - v2;
	d = vecnorm(cross(repmat(a,size(b,1),1),b,2),2,2) / norm(a); % Distance from line. Row-wise cross and norm. d = norm(cross(a,b),2) / norm(a);
	d1 = sum( (XY(2:end-1,:) - XY(1,:)).^2 ,2).^(0.5); % Distance of each midline point from the head point.
	d2 = sum( (XY(2:end-1,:) - XY(end,:)).^2 ,2).^(0.5); % Distance of each midline point from the tail point.
	D = min([d,d1,d2],[],2); % Minimal distance of each midline point from the line *segment*.
end