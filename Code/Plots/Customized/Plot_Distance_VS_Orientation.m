function Plot_Distance_VS_Orientation(Workspace)
	
	X = [];
	Y = [];
	for w=1:numel(Workspace)
		X = [X , Workspace(w).Workspace.All_Points.Midline_Distance];
		Y = [Y , Workspace(w).Workspace.All_Points.Midline_Orientation];
	end
	
	% f = find(abs(X) == 0);
	% X(f) = [];
	% Y(f) = [];
	
	% figure;
	
	subplot(2,2,[2,4]);
		histogram2(X,Y,-40:2.5:40,0:0.05:pi/2,'Normalization','probability','FaceColor','flat');
		% histogram2(X,Y,'Normalization','probability','FaceColor','flat');
	
	xlabel('Distance from Midline [um]');
	ylabel('Midline Orientation [radians]');
	set(gca,'FontSize',18);
	
    subplot(221);
		histogram(X);
		xlabel('Distance from Midline [um]');
		set(gca,'FontSize',18);
	
    subplot(223);
		histogram(Y);
		xlabel('Midline Orientation [radians]');
		set(gca,'FontSize',18);
end