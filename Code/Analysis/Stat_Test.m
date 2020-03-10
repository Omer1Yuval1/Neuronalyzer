function [PVal,Test_Name] = Stat_Test(X,Y)
	
	[~,PV_TTEST] = ttest2(X,Y); % TTEST.
	
	if(~ttest(X) && ~ttest(Y) && ~kstest(X) && ~kstest(Y)) % If both datasets come from a standard normal distribution (kstest), AND if they have means equal to zero (ttest, assuming normal distribution).
		PVal = PV_TTEST;
		Test_Name = 'T-Test';
	else
		[PV_MWU,~] = ranksum(X,Y); % Mann-Whitney.
		PVal = PV_MWU;
		Test_Name = 'U-Test';
	end

end