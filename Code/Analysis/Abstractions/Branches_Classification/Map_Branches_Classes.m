function Clusters_Struct = Map_Branches_Classes(X,Y,Plot_01)
	
	% TODO:
		% Rescale X by dividing by the half-radius.
		% Add min\max to rescale.
	
	% clear all;
	% close all;
	
	PVD_Radius = 40;
	cutoff = 0.00280; % 0.00285. 0.0028. 0.0029;
	Cluster_Size_Threshold = 10; % 5
	
	cmap = [0,0,0 ; 0.1,0.1,0.1]; % ;1 1 1];
	Levels = [0.0028:0.001:0.05];
	
	X = rescale(X,0,1,'InputMin',-PVD_Radius,'InputMax',PVD_Radius); % +1 is dorsal. -1 is ventral.
	Y = rescale(Y,0,1);
	
	Disatnce_Edges = -40:2.5:40;
	Disatnce_Edges = rescale(Disatnce_Edges,0,1);
	
	Orientation_Edges = 0:0.05:pi/2;
	Orientation_Edges = rescale(Orientation_Edges,0,1);
	
	TickValues_X = -40:10:40;
	TickValues_X = rescale(TickValues_X,0,1);
	TickValues_Y = [0,90]; % -60:30:120;
	TickValues_Y = rescale(TickValues_Y,0,1);
	
	PVD_Orders = struct;
	PVD_Orders(1).Class = 1; PVD_Orders(1).X = 0.5; PVD_Orders(1).Y = 0;
	PVD_Orders(2).Class = 2; PVD_Orders(2).X = 0.4; PVD_Orders(2).Y = 1;
	PVD_Orders(3).Class = 2; PVD_Orders(3).X = 0.6; PVD_Orders(3).Y = 1;
	PVD_Orders(4).Class = 3; PVD_Orders(4).X = 0.2; PVD_Orders(4).Y = 0;
	PVD_Orders(5).Class = 3; PVD_Orders(5).X = 0.8; PVD_Orders(5).Y = 0;
	PVD_Orders(6).Class = 4; PVD_Orders(6).X = 0.15; PVD_Orders(6).Y = 1;
	PVD_Orders(7).Class = 4; PVD_Orders(7).X = 0.85; PVD_Orders(7).Y = 1;
	
	ZZ = histcounts2(X,Y,Disatnce_Edges,Orientation_Edges,'Normalization','probability');
	Z = ZZ';
	
	zrows = ceil(size(Z,1)/2);
	
	xR = linspace(min(X),max(X),size(Z,2));
	yR = linspace(min(Y),max(Y),size(Z,1)); % *180/pi;
	[x,y] = meshgrid(xR,yR); %,size(Z,1));
	
	% This makes minus/plus distances symmetrical:
	makeSymmetic = 1;
	if(makeSymmetic)
		Z2 = fliplr(Z(:,1:zrows))+Z(:,zrows:end-1);
		Z2 = [fliplr(Z2) Z2];
		Z3 = [ flipud(Z2); Z2 ; flipud(Z2)]; % patch together to get full peaks.
		
		x3 = [x; x; x];
		y3 = [-flipud(y);y;-flipud(y) + 2*y(end)];
		
		% cut away surperflupus regions:
		Z4 = Z3(zrows:end-zrows,:);
		y4 = y3(zrows:end-zrows,:);
		x4 = x3(zrows:end-zrows,:);
	else
		Z4 = Z;
		x4 = x;
		y4 = y;
	end
	% figure; surf(x3,y3,Z3);
	
	if(Plot_01 == 2)
		
		%
		% plot:
		H2 = figure(2);
		set(H2,'color','w');
		surf(x,y,Z,'EdgeColor','none','FaceColor','interp');
		axis square;
		% xlim(Disatnce_Edges([1,end]));
		% ylim([-0.3,1.3]);
		zlim([0,0.018]);
		
		view([-46,43.15]); % view([-137,40]); % view([-54.8,73.5]);
		
		xlabel(['Normalized Midline Distance']); % [',char(181),'m]'
		ylabel(['Midline Orientation [',char(176),']']);
		zlabel('Count');
		
		set(get(gca,'xlabel'),'rotation',35.5); % set(get(gca,'xlabel'),'rotation',-31);
		set(get(gca,'ylabel'),'rotation',-32.5); % set(get(gca,'ylabel'),'rotation',37);
		%
		cMap = hsv(256);
		dataMax = 0.018;
		dataMin = 0;
		centerPoint = 0.005;
		scalingIntensity = 4;
		
		x = 1:length(cMap); 
		x = x - (centerPoint-dataMin)*length(x)/(dataMax-dataMin);
		x = scalingIntensity * x/max(abs(x));
		
		x = sign(x).* exp(abs(x));
		x = x - min(x);
		x = x*511/max(x)+1; 
		newMap = interp1(x,cMap,1:512);
		colormap(newMap);
		% colormap hsv;
		h2 = colorbar('Ticks',0);
		h2.Position(3) = 0.025;
		h2.Position(4) = 0.37;
		
		set(gca,'FontSize',18,'XTick',[-1,1],'YTick',[0,1],'YTickLabels',[0,90]);
		%}
		
		H3 = figure(3);
		set(H3,'color','w');
		[M,c] = contourf(x4,y4,Z4,Levels,'edgecolor','none'); % 16
		if makeSymmetic
			xlabel(['Normalized Midline Distance']); % symmetrical. %  [',char(181),'m]'
		else
			xlabel(['Normalized Midline Distance']);
		end
		ylabel(['Midline Orientation [',char(176),']']);
		colormap(jet);
		
		CM = lines(7);
		CM = CM([2,7,5,3],:);
		CM = lines(4);
		
		h = gca;
		grid on;
		h.XAxis.TickValues = TickValues_X;
		h.YAxis.TickValues = TickValues_Y;
		h.YAxis.TickLabels = [0,90];
		% h.GridAlpha=0.3; 
		h.GridColor = 'w';
		xlim(Disatnce_Edges([1,end]));
		ylim([-0.4,1.3]);
		
		set(gca,'FontSize',24);
		axis square;
		
		hold on;
		C = find(M(1,:) == Levels(1));
		for i=1:length(C)-1
			
			x = M(1,C(i)+1:C(i+1)-1);
			y = M(2,C(i)+1:C(i+1)-1);
			
			Di = ( (mean(x) - [PVD_Orders.X]).^2 + (mean(y) - [PVD_Orders.Y]).^2 ).^(0.5);
			Fi = find(Di == min(Di),1);
			
			plot(x,y,'Color',CM(PVD_Orders(Fi).Class,:),'LineWidth',6);
		
		end
	end
	
	H4 = figure(4);
	set(H4,'color','w');
	[M,c] = contourf(x4,y4,Z4,cutoff*[1,1],'edgecolor','none'); % ,'edgecolor','none'; ,'-r';
    
	if(Plot_01)
		c.LineWidth = 3;
		if(makeSymmetic)
			xlabel(['Normalized Midline Distance']); % symmetrical. %  [',char(181),'m]'
		else
			xlabel(['Normalized Midline Distance']);
		end
		ylabel(['Midline Orientation [',char(176),']']);
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
		ylim([-0.4,1.3]);
	else
		close all;
	end
	
	Clusters_Struct = struct('Cluster_ID',{},'X_Boundary',{},'Y_Boundary',{},'Class',{});
	C = find(M(1,:) == cutoff);
	CM = lines(7);
	CM = CM([1,3,5,7],:);
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
			
			Di = ( (mean(x) - [PVD_Orders.X]).^2 + (mean(y) - [PVD_Orders.Y]).^2 ).^(0.5);
			Fi = find(Di == min(Di),1);
			Clusters_Struct(end).Class = PVD_Orders(Fi).Class;
			
			if(Plot_01)
				plot(x,y,'Color',CM(Clusters_Struct(end).Class,:),'LineWidth',5);
			end
		end
	end
	
end