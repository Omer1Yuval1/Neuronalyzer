function Clusters_Struct = Map_Branches_Classes(W,Plot_01)
	
	% TODO:
		% Rescale X by dividing by the half-radius.
		% Add min\max to rescale.
	
	% clear all;
	% close all;
	
	Disatnce_Edges = -1:0.05:1; % 0.01,0.05.
	Orientation_Edges = -1:0.05:1;
	
	cutoff = 0.00095; % 0.0018, 0.00280, 0.00285. 0.0028. 0.0029;
	Levels = [cutoff:0.0001:0.01]; % [0.0028:0.001:0.05];
	Cluster_Size_Threshold = 8.5; % [5,10].
	
	cmap = [0,0,0 ; 0.1,0.1,0.1]; % ;1 1 1];
	Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0,0.8,0.8 ; 0.8,0.8,0 ; 0.5,0.5,0.5]; % [1,2,3,4,5].
	
	FontSize_1 = 36;
	
	Clusters_Struct = struct('Cluster_ID',{},'X_Boundary',{},'Y_Boundary',{},'Class',{});
	
	X0 = [];
	Y0 = [];
	R3 = [];
	R4 = [];
	
	% Extract midline distance and orientation of all workspaces:
	for w=1:numel(W) % For each workspace.
		% X0 = [X0,[W(w).Workspace.All_Points.X]];
		% Y0 = [Y0,[W(w).Workspace.All_Points.Y]];
		X0 = [X0,[W(w).Workspace.All_Points.Midline_Distance]]; % Midline distance.
		Y0 = [Y0,[W(w).Workspace.All_Points.Midline_Orientation]]; % Midline orientation.
		R3 = [R3,[W(w).Workspace.All_Points.Half_Radius]]; % Half-radius (on the same side that the point is).
		R4 = [R4,[W(w).Workspace.All_Points.Radius]]; % Radius (on the same side that the point is).
	end
	
	% Rescale midline distance to PVD raddi:
	F3 = find(abs(X0) <= R3); % Find points that are between the midline and half-radius.
	F4 = find(abs(X0) > R3 & abs(X0) <= R4); % Find points that are between the half-radius and radius.
	
	X = abs(X0);
	X(F3) = rescale(X(F3),0,0.5,'InputMin',zeros(1,length(F3)),'InputMax',R3(F3)); % Rescale the midline distance from [0,R3(:)] to [0,0.5].
	X(F4) = rescale(X(F4),0.5,1,'InputMin',R3(F4),'InputMax',R4(F4)); % Rescale the midline distance from [R3(:),R4(:)] to [0.5,1].
	X = X .* sign(X0); % Add back the sign of the midline distance.
	
	Y = rescale(Y0,-1,1,'InputMin',0,'InputMax',pi/2);
	
	F5 = find(abs(X0) > R4); % Find points that are outside the neuron's boundaries.
	X(F5) = [];
	Y(F5) = [];
	
	% For testing:
	%{
	figure;
		subplot(1,2,1);
			histogram(X,Disatnce_Edges,'Normalization','probability');
			xlabel('Midline Distance');
			ylabel('Probability');
			set(gca,'FontSize',FontSize_1);
			xlim([-1,1]);
			
		subplot(1,2,2);
			histogram(Y,Orientation_Edges,'Normalization','probability');
			xlabel('Midline Orientation');
			ylabel('Probability');
			set(gca,'FontSize',FontSize_1);
			xlim([-1,1]);
		
		return;
	%}
	
	PVD_Orders = struct;
	PVD_Orders(1).Class = 1; PVD_Orders(1).X = 0; PVD_Orders(1).Y = -1;
	PVD_Orders(2).Class = 2; PVD_Orders(2).X = 0.07; PVD_Orders(2).Y = 1;
	PVD_Orders(3).Class = 2; PVD_Orders(3).X = -0.07; PVD_Orders(3).Y = 1;
	PVD_Orders(4).Class = 3; PVD_Orders(4).X = 0.5; PVD_Orders(4).Y = -1;
	PVD_Orders(5).Class = 3; PVD_Orders(5).X = -0.5; PVD_Orders(5).Y = -1;
	PVD_Orders(6).Class = 4; PVD_Orders(6).X = -0.5; PVD_Orders(6).Y = 1;
	PVD_Orders(7).Class = 4; PVD_Orders(7).X = 0.5; PVD_Orders(7).Y = 1;
	
	ZZ = histcounts2(X,Y,Disatnce_Edges,Orientation_Edges,'Normalization','probability');
	Z = transpose(ZZ);
	
	zrows = ceil(size(Z,1)/2);
	
	xR = linspace(min(X),max(X),size(Z,2));
	yR = linspace(min(Y),max(Y),size(Z,1));
	[x,y] = meshgrid(xR,yR);
	
	% This makes minus/plus distances symmetrical:
	makeSymmetic = 1;
	if(makeSymmetic)
		Z2 = fliplr(Z(:,1:zrows)) + Z(:,zrows:end-1);
		Z2 = Z; % [fliplr(Z2) , Z2];
		Z3 = [flipud(Z2); Z2 ; flipud(Z2)]; % patch together to get full peaks.
		
		x3 = [x ; x ; x];
		y3 = [-flipud(y)-2 ; y ; -flipud(y)+2]; % y3 = [-flipud(y) ; y ; -flipud(y) + 2*y(end)];
		
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
		% 3D surface plot
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
		
		set(gca,'FontSize',FontSize_1,'XTick',[-1,1],'YTick',[-1,1],'YTickLabels',[0,90]);
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
		set(gca,'Color','k');
		
		% CM = lines(7);
		% CM = CM([2,7,5,3],:);
		% CM = lines(4);
		
		h = gca;
		grid on;
		
		h.XAxis.TickValues = [-1,0,1];
		h.YAxis.TickValues = [-1,0,1];
		h.YAxis.TickLabels = [0,45,90];
		%%% h.GridAlpha=0.3; 
		
		h.GridColor = 'w';
		xlim(Disatnce_Edges([1,end]));
		ylim([-1.9,1.7]); % ylim(Orientation_Edges([1,end])); % ylim([-0.4,1.3]);
		
		set(gca,'FontSize',FontSize_1);
		axis square;
		
		set(gca,'unit','normalize');
		set(gca,'position',[0.10,0.16,0.9,0.83]);
		
		%
		hold on;
		C = find(M(1,:) == Levels(1));
		C(end+1) = C(end)+5;
		for i=1:length(C)-1
			
			x = M(1,C(i)+1:C(i+1)-1);
			y = M(2,C(i)+1:C(i+1)-1);
			
			if(length(x) > Cluster_Size_Threshold)
				Di = ( (mean(x) - [PVD_Orders.X]).^2 + (mean(y) - [PVD_Orders.Y]).^2 ).^(0.5);
				Fi = find(Di == min(Di),1);
				
				plot(x,y,'Color',Class_Colors(PVD_Orders(Fi).Class,:),'LineWidth',6);
			end
		end
		%}
	end
	
	% return;
	
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
		h.XAxis.TickValues = [-1,0,1];
		h.YAxis.TickValues = [-1,0,1];
		h.YAxis.TickLabels = [0,45,90];
		% h.GridAlpha = 0.3; 
		h.GridColor = 'w';
		set(gca,'FontSize',FontSize_1);
		axis square;
		xlim(Disatnce_Edges([1,end]));
		ylim([-1.9,1.7]); % ylim(Orientation_Edges([1,end])); % ylim([-0.4,1.3]);
		
		set(gca,'unit','normalize');
		set(gca,'position',[0.10,0.16,0.9,0.83]);
	else
		close all;
	end
	
	C = find(M(1,:) == cutoff);
	C(end+1) = length(M)+1;
	
	% CM = lines(7);
	% CM = CM([1,3,5,7],:);
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
				plot(x,y,'Color',Class_Colors(Clusters_Struct(end).Class,:),'LineWidth',5);
			end
		end
	end
	
end