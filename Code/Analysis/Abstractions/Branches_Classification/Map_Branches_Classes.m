function Clusters_Struct = Map_Branches_Classes(X,Y,Plot_01)
	
	% TODO:
		% Rescale X by dividing by the half-radius.
		% Add min\max to rescale.
	
	% clear all;
	close all;
	
	X = rescale(X,-1,1);
	Y = rescale(Y,0,1);
	
	cutoff = 0.00285; % 0.0028,0.0029;
	Cluster_Size_Threshold = 5; % 5
	cmap = [0,0,0 ; 0.1,0.1,0.1]; % ;1 1 1];
	
	Disatnce_Edges = -40:2.5:40;
	Disatnce_Edges = rescale(Disatnce_Edges,-1,1);
	
	Orientation_Edges = 0:0.05:pi/2;
	Orientation_Edges = rescale(Orientation_Edges,0,1);
	
	TickValues_X = -40:10:40;
	TickValues_X = rescale(TickValues_X,-1,1);
	TickValues_Y = [0,90]; % -60:30:120;
	TickValues_Y = rescale(TickValues_Y,0,1);
	
	ZZ = histcounts2(X,Y,Disatnce_Edges,Orientation_Edges,'Normalization','probability');
	Z = ZZ';
	
	zrows = ceil(size(Z,1)/2);
	
	xR = linspace(min(X),max(X),size(Z,2));
	yR = linspace(min(Y),max(Y),size(Z,1)); % *180/pi;
	[x,y] = meshgrid(xR,yR); %,size(Z,1));
	
	% This makes minus/plus distances symmetrical:
	makeSymmetic = true;
	if makeSymmetic
		Z2 = fliplr(Z(:,1:zrows))+Z(:,zrows:end-1);
		Z2 = [fliplr(Z2) Z2];
	else
		Z2 = Z;
	end
	
	% patch together to get full peaks
	Z3 = [ flipud(Z2); Z2 ; flipud(Z2)];
	
	x3 = [x; x; x];
	% y3 = [y; y; y];
	% y3 = [-flipud(y);y;-flipud(y)];
	y3 = [-flipud(y);y;-flipud(y) + 2*y(end)];
	% figure; surf(x3,y3,Z3);
	
	% cut away surperflupus regions:
	Z4 = Z3(zrows:end-zrows,:);
	y4 = y3(zrows:end-zrows,:);
	x4 = x3(zrows:end-zrows,:);
	
	if(Plot_01 == 2)
		% plot:
		figure; 
		surf(x4,y4,Z4);
		set(gca,'FontSize',24);
		axis square;
		xlim(Disatnce_Edges([1,end]));
		ylim([-0.3,1.3]);
		
		figure('color','w');
		contourf(x4,y4,Z4,15,'edgecolor','none'); % 16
		if makeSymmetic
			xlabel('Dist [um] (symmetrical!)');
		else
			xlabel('Dist [um]')
		end
		ylabel('Orientation [deg]');
		colormap(jet);
		
		h = gca;
		grid on    
		h.XAxis.TickValues = TickValues_X;
		h.YAxis.TickValues = TickValues_Y;
		h.YAxis.TickLabels = [0,90];
		% h.GridAlpha=0.3; 
		h.GridColor = 'w';
		xlim(Disatnce_Edges([1,end]));
		ylim([-0.3,1.3]);
		
		set(gca,'FontSize',24);
		axis square;
	end
	
	figure('color','w');
	[M,c] = contourf(x4,y4,Z4,cutoff*[1,1],'edgecolor','none'); % ,'edgecolor','none'; ,'-r';
    
	if(Plot_01)
		c.LineWidth = 3;
		if(makeSymmetic)
			xlabel('Normalized Midline Distance [um] (symmetrical)');
		else
			xlabel('Dist [um]');
		end
		ylabel('Orientation [deg]');
		colormap(cmap);
		
		h = gca;
		grid on    
		h.XAxis.TickValues = TickValues_X;
		h.YAxis.TickValues = TickValues_Y;
        h.YAxis.TickLabels = [0,90];
		% h.GridAlpha = 0.3; 
		h.GridColor = 'w';
		set(gca,'FontSize',24);
		axis square;
		xlim(Disatnce_Edges([1,end]));
		ylim([-0.5,1.5]);
	else
		close all;
	end
	
	Clusters_Struct = struct('Cluster_ID',{},'X_Boundary',{},'Y_Boundary',{},'Class',{});
	C = find(M(1,:) == cutoff);
	hold on;
	for i=1:length(C)-1
		
		x = M(1,C(i)+1:C(i+1)-1);
		y = M(2,C(i)+1:C(i+1)-1);
		
		if(length(x) > Cluster_Size_Threshold)
			Clusters_Struct(end+1).Cluster_ID = i;
			Clusters_Struct(end).X_Boundary = x;
			Clusters_Struct(end).Y_Boundary = y;
			Clusters_Struct(end).Mean_X = mean(x);
			Clusters_Struct(end).Mean_Y = mean(y);
			
			if(Plot_01)
				plot(x,y,'LineWidth',3);
			end
		end
	end
	
end