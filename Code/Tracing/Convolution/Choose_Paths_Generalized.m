function paths = Choose_Paths_Generalized(X,Y,Min_Peak_Prominence,Min_Peak_Distance,SP)
	
	% Curve Fitting:
	fitobject = fit(X,Y,'smoothingspline','SmoothingParam',SP);
	xvf = linspace(min(X),max(X),1000); % Angles.
	yvf = fitobject(xvf); % Scores.
	
	[yp,xp,pw,pp] = findpeaks(yvf,xvf,'SortStr','descend','MinPeakProminence',Min_Peak_Prominence,'MinPeakDistance',Min_Peak_Distance);
	
	paths = [];
	if(length(xp) > 0) % If the peaks array is not empty.
		paths(:,1) = xp; % Angle.
		paths(:,2) = yp; % Mean pixel value.
		paths(:,3) = pw; % Peak width.
		paths(:,4) = pp; % Peak Prominence.
		paths = sortrows(paths,-2); % Sort the paths so that the first path has the highest score.
	else
		paths = zeros(1,4);
	end
	
end