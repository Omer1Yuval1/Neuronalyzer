function Plot_Distance_VS_Curvature(Workspace)
	
	Curvature_Min_Max = [0,0.3];
	
	XB = -40:5:40; % -40:2:40 , -40:5:40
	YB = Curvature_Min_Max(1):0.02:Curvature_Min_Max(2); % 0.005 , 0.01
	
	X = [];
	Y = [];
	for w=1:numel(Workspace)
		X = [X , Workspace(w).Workspace.All_Points.Midline_Distance];
		Y = [Y , Workspace(w).Workspace.All_Points.Curvature];
	end
	
	f = find(Y < Curvature_Min_Max(1) | Y > Curvature_Min_Max(2));
	X(f) = [];
	Y(f) = [];
	
	[N,Xedges,Yedges,XBins,YBins] = histcounts2(X,Y,XB,YB,'Normalization','probability');
	xx = (Xedges(1:end-1) + Xedges(2:end)) ./ 2;
	yy = (Yedges(1:end-1) + Yedges(2:end)) ./ 2;
	
	% figure;
	
	subplot(2,2,[2,4]);
		% histogram2(X,Y,XB,YB,'Normalization','probability','FaceColor','flat');
		% binscatter(X,Y);
		% colormap(gca,'parula');
		
		b = bar3(N',1);
		for k = 1:length(b)
			zdata = b(k).ZData;
			b(k).CData = zdata;
			b(k).FaceColor = 'interp';
		end
		axis([0,length(XB),0,length(YB)]);
		set(gca,'XTick',1:2:length(XB),'XTickLabels',XB(1:2:end),'YTick',1:2:length(YB),'YTickLabels',YB(1:2:end));
	
		xlabel('Distance from Midline [um]');
		ylabel('Curvature [1/um]');
		title('Midline Distance VS Curvature');
		set(gca,'FontSize',18,'View',[23.5,36.7]);
	
	subplot(2,2,[1,3]);
		
		for b=1:max(XBins)
			s = sum(XBins == b); % Number of points in all bins for which XBins = b.
			N(b,:) = N(b,:) ./ s; % Divide the counts of all the correspoinding bins by s.
		end
		
		b = bar3(N',1);
		for k = 1:length(b)
			zdata = b(k).ZData;
			b(k).CData = zdata;
			b(k).FaceColor = 'interp';
		end
		% set(gca,'XTick',[],'XTickLabels',XB,'YTick',[],'YTickLabels',YB);
		axis([0,length(XB),0,length(YB)]);
		set(gca,'XTick',1:2:length(XB),'XTickLabels',XB(1:2:end),'YTick',1:2:length(YB),'YTickLabels',YB(1:2:end));
		
		xlabel('Distance from Midline [um]');
		ylabel('Curvature [1/um]');
		title('Midline Distance VS Curvature (per unit length*)');
		set(gca,'FontSize',18,'View',[23.5,36.7]);
	
	return;
	
    subplot(221);
		histogram(X);
		xlabel('Distance from Midline [um]');
		ylabel('Count');
		set(gca,'FontSize',18);
	
    subplot(223);
		histogram(Y);
		xlabel('Curvature [1/um]');
		ylabel('Count');
		set(gca,'FontSize',18);
end