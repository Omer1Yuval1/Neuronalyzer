function R = Calc_Radius_Of_Curvature(X,Y)
	
	% This function calculates the radius of curvature of an X-Y vector of coordinates.
	
	mx = mean(X);
	my = mean(Y);
	x = X - mx; % Translation to 0. mean(x) = 0;
	y = Y - my; % Translation to 0. mean(y) = 0;
	
	dx2 = mean(x.^2); % mean([X - mx].^2).
	dy2 = mean(y.^2); % mean([Y - my].^2).
	t = [x,y]\((x.^2 - dx2 + y.^2 - dy2)/2);
	a0 = t(1);
	b0 = t(2);
	R = sqrt(dx2 + dy2 + a0^2 + b0^2);
	% a = a0 + mx; % Center.
	% b = b0 + my; % ".
	
end