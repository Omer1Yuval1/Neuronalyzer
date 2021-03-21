function Clusters_Struct = Map_Branches_Classes(P,Ax)
	
	% TODO:
		% Rescale X by dividing by the half-radius.
		% Add min\max to rescale.
	
	% clear all;
	% close all;
	
	Mode = 2;
	FontSize_1 = 18; % 36.
	
	Class_Colors = P.GUI_Handles.Class_Colors;
	Plot_Type = P.GUI_Handles.Control_Panel_Objects(4,4).Value;
	
    switch Mode
		case 1
			Field_1 = 'Radial_Distance_Corrected'; % 'Angular_Coordinate'.
			Field_2 = 'Midline_Orientation_Corrected';
			Field_3 = 'Length_Corrected';
			
			cutoff = 0.000275; % [0.00029,0.00035,0.000287].
			X_Min_Max = [-1,1];
			
			% cutoff = 0.00053; % [0.00029,0.00035,0.000287].
			% X_Min_Max = [-1,1]./2;
			
			Levels = cutoff:0.00001:0.05; % [0.0001:0.01 , 0.0028:0.001:0.05];
			Cluster_Size_Threshold = 10; % [5,10,*50*].
			
			XFunc = @(x) rescale(x,X_Min_Max(1),X_Min_Max(2),'InputMin',-1,'InputMax',1);
			YFunc = @(y) rescale(y,-1,1,'InputMin',0,'InputMax',pi/2);
		case 2
			Field_1 = 'Angular_Coordinate';
			Field_2 = 'Midline_Orientation_Corrected';
			Field_3 = 'Length_Corrected';
			
			switch(4)
				case 1
					cutoff = 0.0004; % [0.00029,0.00035,0.000287]. % cutoff = 0.000000071; % For total length normalization.
					X_Min_Max = [-1,1];
					dx = 0.05; % 0.025;
					dy = 0.05; % 0.025;
				case 2
					cutoff = 0.00025; % 0.000195.
					X_Min_Max = [-2,2];
					dx = 0.06;
					dy = 0.06;
				case 3
					cutoff = 0.000047; % [0.00029,0.00035,0.000287]. % cutoff = 0.000000071; % For total length normalization.
					X_Min_Max = [-2,2];
					dx = 0.025; % 0.025;
					dy = 0.025; % 0.025;
				case 4
					cutoff = 0.000045; % [0.00029,0.00035,0.000287]. % cutoff = 0.000000071; % For total length normalization.
					X_Min_Max = [-2,2];
					dx = 0.025;
					dy = 0.025;
			end
			
			Cluster_Size_Threshold = 50; % [5,10,*50*].
			dc = 0.00001;
			Levels = cutoff:dc:0.05; % [0.0001:0.01 , 0.0028:0.001:0.05];
			% Cluster_Size_Threshold = 10; % [5,10,*50*].
			
			XFunc = @(x) rescale(x,X_Min_Max(1),X_Min_Max(2),'InputMin',-pi/2,'InputMax',pi/2);
			YFunc = @(y) rescale(y,-1,1,'InputMin',0,'InputMax',pi/2);
		case 3
			Field_1 = 'Midline_Distance';
			Field_2 = 'Midline_Orientation';
			Field_3 = 'Length';
			cutoff = 0.00024; % 0.00024, 0.000238, 0.00095, 0.0018, 0.00280, 0.00285. 0.0028. 0.0029;
			
			Levels = cutoff:0.0001:0.05; % [0.0001:0.01 , 0.0028:0.001:0.05];
			Cluster_Size_Threshold = 10; % [5,10,*50*].
    end
    
	Disatnce_Edges = X_Min_Max(1):dx:X_Min_Max(2);
	Orientation_Edges = -1:dy:1;
		
	cmap = [0,0,0 ; 0.1,0.1,0.1]; % ;1 1 1];
	YLIM = [-2.3,2.05];
	
	Clusters_Struct = struct('Cluster_ID',{},'X_Boundary',{},'Y_Boundary',{},'Class',{});
	
	X = [];
	Y = [];
	L0 = [];
	
	% Extract midline distance and orientation of all workspaces:
	for p=1:numel(P.Data) % For each project.
		
		% R3 = [Data(p).Points.Half_Radius];
		% R4 = [Data(p).Points.Radius];
		Dw = [P.Data(p).Points.(Field_1)];
		Ow = [P.Data(p).Points.(Field_2)];
		Lw = [P.Data(p).Points.(Field_3)];
		
		% Total_Length = nansum([Data(p).Points.(Field_3)]);
		% Lw = Lw ./ Total_Length;
		
		switch Mode
			case 3 % Both radii.
				[Dw,in] = Scale_Midline_Distance_To_Local_Radii(Dw,R3,R4);
			case 4 % Half_Radius. cutoff = 0.00028;
				Dw = Dw ./ (2.*R3);
				in = (~isnan(Dw) & ~isnan(Lw) & abs(Dw) <= 1);
		end
		
		X = [X,Dw]; % Midline distance.
		Y = [Y,Ow]; % Midline orientation.
		L0 = [L0,Lw]; % Rectangle length.
	end
	
	% in = (~isnan(Dw) & ~isnan(Lw) & abs(Dw) <= 1);
	
	X = -XFunc(X); % Minus to make the ventral on the negative side (it is defined as positive in the database).
	Y = YFunc(Y);
	% Y = rescale(Y,-1,1,'InputMin',0,'InputMax',pi/2);
	
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
	
	[~,~,~,binX,binY] = histcounts2(X,Y,Disatnce_Edges,Orientation_Edges,'Normalization','probability');
	
	% Scale bin heights using neuronal length:
	Ixy = combvec(1:length(Disatnce_Edges)-1,1:length(Orientation_Edges)-1);
	
	binXY = transpose([ [binX ; binY] , Ixy ]);
	L0 = [L0,zeros(1,size(Ixy,2))];
	
	f = find(binX > 0 & binY > 0);
	binXY = binXY(f,:);
	L0 = L0(f);
	
	ZZ = accumarray(binXY,L0) ./ length(binX);
	
	Z = transpose(ZZ);
	
	zrows = ceil(size(Z,1)/4);
	
	xR = linspace(min(X),max(X),size(Z,2));
	yR = linspace(min(Y),max(Y),size(Z,1));
	[x,y] = meshgrid(xR,yR);
	
	% This makes minus/plus distances symmetrical:
	makeSymmetic = 1;
	if(makeSymmetic)
		x3 = [x ; x ; x];
		y3 = [-flipud(y)-2 ; y ; -flipud(y)+2]; % y3 = [-flipud(y) ; y ; -flipud(y) + 2*y(end)];
		Z3 = [flipud(Z); Z ; flipud(Z)]; % patch together to get full peaks.
        % N = interp2(x3,y3,Z3,x3,y3,'spline'); figure; surf(x3,y3,N,'FaceColor','interp','EdgeColor','none');
        
		% cut away surperflupus regions:
		Z4 = Z3(zrows:end-zrows,:);
		y4 = y3(zrows:end-zrows,:);
		x4 = x3(zrows:end-zrows,:);
	else
		Z4 = Z;
		x4 = x;
		y4 = y;
	end
    
	% xyz_fit = fit([x4(:),y4(:)],Z4(:),'lowess','span',0.001);
	% Z4(1:length(Z4(:))) = xyz_fit([x4(:),y4(:)]);
	
	if(nargin > 1)
		switch(Plot_Type)
			case 1
				[M,c] = contourf(Ax,x4,y4,Z4,cutoff*[1,1],'edgecolor','none');
				
				cc = Ax.Children(end).ContourMatrix;
				m = 1;
				s = [];
				n = 1;
				
				while(m < size(cc,2))
					s(n).level = cc(1,m); 
					s(n).count = cc(2,m); 
					s(n).column = m;
					idx = (m+1):(m+cc(2,m));
					s(n).xdata = cc(1,idx)'; 
					s(n).ydata = cc(2,idx)'; 
					n = n+1;
					m = m+cc(2,m)+1;
				end
				cla(Ax);
				
				[sort_count,sort_ind] = sort([s.count],'descend');
				
				for i=1:6
					
					xx = s(sort_ind(i)).xdata;
					yy = s(sort_ind(i)).ydata;
					
					if(length(xx) > Cluster_Size_Threshold)
						Clusters_Struct(end+1).Cluster_ID = i;
						Clusters_Struct(end).X_Boundary = xx;
						Clusters_Struct(end).Y_Boundary = yy;
						Clusters_Struct(end).Mean_X = mean(xx);
						Clusters_Struct(end).Mean_Y = mean(yy);
						
						Di = ( (mean(xx) - [PVD_Orders.X]).^2 + (mean(yy) - [PVD_Orders.Y]).^2 ).^(0.5);
						Fi = find(Di == min(Di),1);
						Clusters_Struct(end).Class = PVD_Orders(Fi).Class;
						
						if(nargin > 1)
							hold(Ax,'on');
							
							xxyy = cell2mat(smoothn(num2cell([xx(:),yy(:)],1),200));
							xx = xxyy(:,1);
							yy = xxyy(:,2);
							
							fill(Ax,[xx;xx(1)],[yy;yy(1)],[0.1,0.1,0.1]);
							
							plot(Ax,[xx;xx(1)],[yy;yy(1)],'LineWidth',4,'Color',Class_Colors(Clusters_Struct(end).Class,:));
						end
					else
						% c.ContourMatrix(:,C(i)+1:C(i+1)-1) = nan;
					end
				end
				assignin('base','Clusters_Struct',Clusters_Struct);
				
				set(Ax,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
				
				xlabel(Ax,[char(981),' (azimuthal position) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				ylabel(Ax,[char(952),' (midline orientation) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				
				axis(Ax,'tight');
				axis(Ax,'square');
				
				Ax.XAxis.TickValues = X_Min_Max(1):X_Min_Max(2)./3:X_Min_Max(2); % -1:0.5:1; % [-1,0,1];
				Ax.XAxis.TickLabels = -90:30:90; % {'$$-90$$','$$-60$$','$$-30$$','$$0$$','$$30$$','$$60$$','$$90$$'}; % {'$$-90$$','$$-45$$',0,'$$45$$','$$90$$'}; % {'$$-\phi$$','$$-\frac{\phi}{2}$$',0,'$$\frac{\phi}{2}$$','$$\phi$$'}
				Ax.YAxis.TickValues = [-1,0,1];
				Ax.YAxis.TickLabels = [0,45,90];
				xlim(Ax,X_Min_Max([1,end])*1.1);
				ylim(Ax,YLIM);
				
			case 2
				[M,c] = contourf(Ax,x4,y4,Z4,cutoff*[1,1],'edgecolor','none'); % ,'edgecolor','none'; ,'-r';
				c.LineWidth = 3;
				
				set(Ax,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
				
				xlabel(Ax,[char(981),' (azimuthal position) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				ylabel(Ax,[char(952),' (midline orientation) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				
				colormap(Ax,cmap);
				
				% set(gcf,'Position',[10,50,1160,900]); % [10,50,900,600]
				axis(Ax,'tight');
				% set(Ax,'Position',[0.13,0.15,0.85,0.84]); % set(Ax,'Position',[0.10,0.18,0.87,0.80]);
				axis(Ax,'square');
				
				grid(Ax,'on');
				Ax.XAxis.TickValues = X_Min_Max(1):X_Min_Max(2)./3:X_Min_Max(2); % -1:0.5:1; % [-1,0,1];
				Ax.XAxis.TickLabels = -90:30:90; % {'$$-90$$','$$-60$$','$$-30$$','$$0$$','$$30$$','$$60$$','$$90$$'}; % {'$$-90$$','$$-45$$',0,'$$45$$','$$90$$'}; % {'$$-\phi$$','$$-\frac{\phi}{2}$$',0,'$$\frac{\phi}{2}$$','$$\phi$$'}
				Ax.YAxis.TickValues = [-1,0,1];
				Ax.YAxis.TickLabels = [0,45,90];
				Ax.GridColor = 'w';
				xlim(Ax,X_Min_Max([1,end])*1.1);
				ylim(Ax,YLIM);
				
			case 3
				Levels = 0:dc:Levels(end);
				[M,c] = contourf(Ax,x4,y4,Z4,Levels,'edgecolor','none'); % 16
				
				%{
				if(makeSymmetic)
					xlabel(Ax,['Normalized Midline Distance']); % symmetrical. %  [',char(181),'m]'
				else
					xlabel(Ax,['Normalized Midline Distance']);
				end
				%}
				
				set(Ax,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
				
				xlabel(Ax,[char(981),' (Azimuthal Position) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				ylabel(Ax,[char(952),' (Midline Orientation) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				% xlabel(Ax,'$\mathrm{\phi \; (Azimuthal \; Position)} \; [^{\circ}]$','Interpreter','latex');
				% ylabel(Ax,'$\mathrm{\theta \; (Midline \; Orientation)} \; [^{\circ}]$','Interpreter','latex'); % ylabel(Ax,['Midline Orientation [',char(176),']']);
				
				colormap(Ax,jet);
				set(Ax,'Color','w');
				
				% CM = lines(7);
				% CM = CM([2,7,5,3],:);
				% CM = lines(4);
				
				% set(gcf,'Position',[10,50,900,600]);
				axis(Ax,'tight');
				axis(Ax,'square');
				% set(Ax,'Position',[0.10,0.18,0.87,0.80]);
				% axis(Ax,'square');
				% set(Ax,'unit','normalize');
				% set(Ax,'position',[0.10,0.16,0.9,0.83]);
				
				grid(Ax,'on');
				
				Ax.XAxis.TickValues = X_Min_Max(1):X_Min_Max(2)./3:X_Min_Max(2); % -1:0.5:1; % [-1,0,1];
				Ax.XAxis.TickLabels = -90:30:90; % {'$$-90$$','$$-60$$','$$-30$$','$$0$$','$$30$$','$$60$$','$$90$$'}; % {'$$-90$$','$$-45$$',0,'$$45$$','$$90$$'}; % {'$$-\phi$$','$$-\frac{\phi}{2}$$',0,'$$\frac{\phi}{2}$$','$$\phi$$'}
				Ax.YAxis.TickValues = [-1,0,1];
				Ax.YAxis.TickLabels = [0,45,90];
				%%% Ax.GridAlpha=0.3; 
				
				Ax.GridColor = 'w';
				xlim(Ax,Disatnce_Edges([1,end]));
				ylim(Ax,YLIM); % ylim(Ax,Orientation_Edges([1,end])); % ylim([-0.4,1.3]);
				
				%{
				hold(Ax,'on');
				C = find(M(1,:) == Levels(1));
				C(end+1) = C(end)+5;
				for i=1:length(C)-1
					
					x = M(1,C(i)+1:C(i+1)-1);
					y = M(2,C(i)+1:C(i+1)-1);
					
					if(length(x) > Cluster_Size_Threshold)
						Di = ( (mean(x) - [PVD_Orders.X]).^2 + (mean(y) - [PVD_Orders.Y]).^2 ).^(0.5);
						Fi = find(Di == min(Di),1);
						
						plot(Ax,x,y,'Color',Class_Colors(PVD_Orders(Fi).Class,:),'LineWidth',6);
					end
				end
				%}
			
			case 4 % 3D surface plot.
				
				% surf(Ax,x,y,Z,'EdgeColor','none','FaceColor','interp');
				surf(Ax,x4,y4,Z4,'EdgeColor','none','FaceColor','interp');
				axis(Ax,'square');
				
				mask = imregionalmax(imbinarize(rescale(Z4),0.035));
				hold(Ax,'on');
				plot3(Ax,x4(mask),y4(mask),Z4(mask),'r+')
				
				% xlim(Disatnce_Edges([1,end]));
				% ylim([-0.3,1.3]);
				xlim(Ax,Disatnce_Edges([1,end]));
				ylim(Ax,YLIM);
				zlim(Ax,[0,0.018]);
				
				view(Ax,[-46,43.15]); % view([-137,40]); % view([-54.8,73.5]);
				
				xlabel(Ax,['Normalized Midline Distance']); % [',char(181),'m]'
				ylabel(Ax,['Midline Orientation [',char(176),']']);
				zlabel(Ax,'Count');
				
				% set(get(Ax,'xlabel'),'rotation',35.5); % set(get(gca,'xlabel'),'rotation',-31);
				% set(get(Ax,'ylabel'),'rotation',-32.5); % set(get(gca,'ylabel'),'rotation',37);
				
				%{
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
				colormap(Ax,newMap);
				% colormap hsv;
				h2 = colorbar(Ax,'Ticks',0);
				h2.Position(3) = 0.025;
				h2.Position(4) = 0.37;
				%}
				
				set(Ax,'FontSize',FontSize_1,'XTick',[-1,1],'YTick',[-1,1],'YTickLabels',[0,90]);
			case 5
				histogram2(Ax,Z);
		end
	end
	
	if(nargin > 1 && Plot_Type == 2)
		C = find(M(1,:) == cutoff);
		C(end+1) = length(M)+1;
		
		% CM = lines(7);
		% CM = CM([1,3,5,7],:);
		
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
				
				if(nargin > 1)
					hold(Ax,'on');
					
					u = smoothn(num2cell([x',y'],1),100);
					xy = horzcat(u{:});
					x = xy(:,1)'; % Smoothed x-coordinates.
					y = xy(:,2)'; % Smoothed y-coordinates.
					
					plot(Ax,[x,x(1)],[y,y(1)],'Color',Class_Colors(Clusters_Struct(end).Class,:),'LineWidth',5);
				end
			else
				% c.ContourMatrix(:,C(i)+1:C(i+1)-1) = nan;
			end
		end
		assignin('base','Clusters_Struct',Clusters_Struct);
		
		BW = c.ZData;
		BW(BW > c.LevelList) = 1;
		BW = imbinarize(BW);
		CC = bwconncomp(BW);
		
		%{
		for i=1:length(CC.PixelIdxList) % For each connected component.
			if(length(CC.PixelIdxList{i}) <= Cluster_Size_Threshold)
				% c.ZData(CC.PixelIdxList{i}) = 0;
				BW(CC.PixelIdxList{i}) = 0;
			end
		end
		%}
		
		% BW = bwareaopen(BW,25);
		% BW = imclearborder(BW);
		% BW = bwareafilt(BW,1);
		
		% BW = imfill(BW,'holes');
		% BW = imerode(BW,strel('disk',1));
		% BW = imdilate(BW,ones(1));
		
		%{
		windowSize = 2; % Whatever odd integer you want that's more than 1.
		kernel = ones(2) / windowSize^2;
		BW = conv2(BW,kernel,'same');
		BW = BW > 0.5;
		%}
		
		%{
		BW = imdilate(BW,ones(1));
		BW = imfill(BW,'holes');
		%}
		
		% BW = imfill(BW,'holes');
		% BW = bwareafilt(BW,[25,inf]);
		
		% c.ZData(BW == 0) = 0;
		% c.ZData(BW == 1) = max(c.ZData(:));
		
		% figure; imshow(BW); set(gca,'YDir','normal');
	end
end