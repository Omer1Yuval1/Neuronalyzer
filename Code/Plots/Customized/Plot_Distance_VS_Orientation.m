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
	
	% subplot(2,2,[2,4]);
		histogram2(X,Y,-40:2.5:40,0:0.05:pi/2,'Normalization','probability','FaceColor','flat');
		% [N,Xedges,Yedges] = histcounts2(X,Y,-40:2.5:40,0:0.05:pi/2,'Normalization','probability');
		% X = (Xedges(1:end-1) + Xedges(2:end)) ./ 2;
		% Y = (Yedges(1:end-1) + Yedges(2:end)) ./ 2;
		% histogram2(X,Y,'Normalization','probability','FaceColor','flat');
	
	xlabel('Distance from Midline [um]');
	ylabel('Midline Orientation [radians]');
	set(gca,'FontSize',18);
	
	colormap colorcube; % jet, hsv.
	
	
	% assignin('base','X',X);
	% assignin('base','Y',Y);
	
	%{
	https://uk.mathworks.com/help/stats/cluster-analysis.html
	https://uk.mathworks.com/help/stats/clustering-using-gaussian-mixture-models.html
	https://uk.mathworks.com/help/stats/dbscan-clustering.html
	https://uk.mathworks.com/help/stats/dbscan.html
	%}
	
	
	%{
	E = evalclusters([X',Y'],'kmeans','silhouette','klist',[1:6]);
	Nc = 6; % E.OptimalK; % Nc = 6;
	
	opts = statset('Display','final');
	[idx,C] = kmeans([X',Y'],Nc,'Distance','cityblock','Replicates',5,'Options',opts); % ,'Distance','cityblock'
	
	figure;
		plot(X(idx==1),Y(idx==1),'r.','MarkerSize',12)
		hold on;
		plot(X(idx==2),Y(idx==2),'b.','MarkerSize',12)
		plot(C(:,1),C(:,2),'kx','MarkerSize',15,'LineWidth',3);
		legend('Cluster 1','Cluster 2','Centroids','Location','NW');
		title('Cluster Assignments and Centroids');
		hold off;
	%}
	
	figure;
		% Z = linkage([X',Y'],'ward');
		% c = cluster(Z,'Maxclust',6);
		
		Z = linkage([X',Y'],'average','chebychev'); % Cluster the data using a threshold of 1.5 for the 'distance' criterion.*
		c = cluster(Z,'cutoff',1.5,'Criterion','distance');
		
		scatter(X,Y,10,c,'filled');
		
	%{
    subplot(221);
		histogram(X);
		xlabel('Distance from Midline [um]');
		set(gca,'FontSize',18);
	
    subplot(223);
		histogram(Y);
		xlabel('Midline Orientation [radians]');
		set(gca,'FontSize',18);
	%}
end