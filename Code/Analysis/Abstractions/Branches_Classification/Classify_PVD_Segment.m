function c = Classify_PVD_Segment(Sx,Sy,Sc,Is_Terminal)
	
	% Sx and Sy are vectors of segment coordinates.
	% Sc is a vector containing Menorah classes corresponding to segment coordinates.
	
	Threshold_3 = 0.2;
	Threshold_4 = 0.3;
	
	Lp = length(Sx);
	
	% Mc = mode(Sc); % The most frequent class.
	% Fm = find(Sc == Mc);
	
	L3 = length(find(Sc == 3)) ./ Lp;
	L4 = length(find(Sc == 4)) ./ Lp;
	
	if(L3 >= Threshold_3 && L4 >= Threshold_4)
		c = 3.5;
	else
		c = mode(Sc);
	end
	
	%{
	if(Is_Terminal && c < 3)
		c = 5;
	end
	%}
end