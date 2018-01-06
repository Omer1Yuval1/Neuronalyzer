function color1 = order_colormap(order)
	
	switch(order)
		case {1,111}
			color1 = [.7 .7 .7]; % White.
		case 1.5
			color1 = [.4 .4 .4]; % Gray.
		case {2,112}
			color1 = [1 0 0]; % Red.
		case 2.5
			color1 = [.72,.47,.34]; % Brown.
			% color1 = [.7 .5 0]; % Brown.
		case {3,223}
			color1 = [0 .63 .9]; % Blue.
			% color1 = [0 1 1]; % Cyan (green-blue).
		case 3.5
			color1 = [.13,.7,.3]; % Green.
		case {4,233}
			color1 = [1 1 0]; % Yellow.
		case 4.5
			color1 = [1 .5 .15]; % Orange.
		case {5,334}
			color1 = [1 0 1]; % Pink.
		case {6,344}
			color1 = [0,1,0]; % Green.
		case {7,445}
			color1 = [1 0.6 0];
		case 8
			color1 = [0 0.5 0.5];
		case 9
			color1 = [.72,.33,.82];
		case 10
			color1 = [.82,.41,.11]; % Chocolate.
		case 11
			color1 = [0 1 0]; % Green.
		case 12
			color1 = [0 1 1]; % Cyan (green-blue).
		case 13
			color1 = [1 1 0]; % Yellow.
		case 14
			color1 = [1 0 0]; % Red.
		otherwise
			color1 = [1 0.5 0.5];
	end
end