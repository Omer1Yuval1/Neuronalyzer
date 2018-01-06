function Xp = Calc_Persistence_Length(Contour_Length,R2,Step_Size)
	
	Contour_Length_Bins = 0:Step_Size:max([Contour_Length]);
	R2_Bins = zeros(1,length(Contour_Length_Bins)-1);
	
	for L=2:length(Contour_Length_Bins)
		F = find(Contour_Length >= Contour_Length_Bins(L-1) & Contour_Length < Contour_Length_Bins(L));
		R2_Bins(L-1) = max(-1,mean([R2(F)]));
		% R2_Bins(L-1) = mean([R2(F)]);
	end
	
	X = Contour_Length_Bins(2:end);
	Y = R2_Bins;
	
	F = find(Y == -1);
	X(F) = [];
	Y(F) = [];
	
	if(length(X) > 0 && length(Y) > 0)
		Eq1 = '2*2*P*x*(1-(2*P/x)*(1-exp(-x/(2*P))))';
		Exp_Fit_Object = fit(X',Y',Eq1,'StartPoint',0);
		% Exp_Fit_Object = fit(X',Y',Eq1,'StartPoint',max(X));
	
		Xp = Exp_Fit_Object.P;
	
		if(Xp < 0)
			Xp = -1;
		end
	else
		Xp = -1;
	end
	
	
	% figure;
	% plot(X,Y,'.g','MarkerSize',16);
	% hold on;
	% plot(Exp_Fit_Object);
end