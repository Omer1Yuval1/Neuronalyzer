function Two_Angles_Closest_To_Source_Rect(GUI_Parameters)
	
	% assignin('base','GUI_Parameters',GUI_Parameters);
	Max_Category_Num = 15;
	
	Groups_Names = {GUI_Parameters.Workspace.Group_Name};
	Ng = length(GUI_Parameters.General.Groups_OnOff); % Number of (activated) groups.
	
	% ColorMap = hsv(15); % hsv; % colorcube;
	ColorMap = GUI_Parameters.Visuals.Active_Colormap;
	
	Means_struct = struct('X',{},'Y',{});
	Means_struct(max(1,size(GUI_Parameters.General.Categories_Filter_Values,1))).Y = [];
	
	Legend_Array = zeros(Ng,size(GUI_Parameters.General.Categories_Filter_Values,1));
	
	for g=1:Ng % For each group.
		
		Means_struct = struct('X',{},'Y',{});
		Means_struct(max(1,size(GUI_Parameters.General.Categories_Filter_Values,1))).Y = [];
		
		subplot(1,Ng,g,'Color',1-GUI_Parameters.Visuals.Active_Colormap(1,:));
		
		hold on;
		for m=1:length(GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files); % For each memeber of group g.
			for v=1:numel(GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files{m}.Vertices) % For each vertex.
				Current_Category = GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files{m}.Vertices(v).Order;
				if(length(Current_Category) == 3)
					V = GUI_Parameters.Workspace(GUI_Parameters.General.Groups_OnOff(g)).Files{m}.Vertices(v).Rects_Angles_Diffs;
					
					Vi = [abs(180-V(2)),abs(180-V(3))];
					
					F1 = find(Vi == min(Vi));
					F2 = find(Vi == max(Vi));
					
					Xi = V(1+F1(1)); % Linearity: The angle closest to 180.
					Yi = V(1+F2(1))/V(1+F1(1)); % Symmetry: the other angle divided by Xi.
					
					if(length(GUI_Parameters.General.Categories_Filter_Values) > 0) % If at least one category is selected.
						C1 = ismember(GUI_Parameters.General.Categories_Filter_Values,Current_Category,'rows');						
						if(sum(C1)) % If the category of the v-vertex is one the chosen categories.
							Hm = findobj(GUI_Parameters.General.Categories_Filter_Handles,'UserData',Current_Category);
							n = str2num(Hm.Tag);
							plot(Xi,Yi,'.','MarkerSize',10,'Color',ColorMap(n,:));
							F1 = find(C1 == 1); % Find the category number (in the filtered list).
							
							Means_struct(F1).X(end+1) = Xi;
							Means_struct(F1).Y(end+1) = Yi;
						end
					else % If no categories are selected.
						% plot(Xi,Yi,'.','MarkerSize',10,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
						Means_struct(1).X(end+1) = Xi;
						Means_struct(1).Y(end+1) = Yi;
					end
				end
			end
		end
		
		if(length(GUI_Parameters.General.Categories_Filter_Values) == 0) % If no categories are selected.
			plot(Means_struct.X,Means_struct.Y,'.','MarkerSize',10,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		end
		
		set(GUI_Parameters.General.Categories_Filter_Handles,'BackgroundColor',[.7,.7,.7]);
		
		hold on;
		if(length(GUI_Parameters.General.Categories_Filter_Values) == 0)
			
			if(GUI_Parameters.Handles.Clusters_Data_List.Value > 1)
				
				Algorithm_Name = GUI_Parameters.Handles.Clusters_Data_List.String{GUI_Parameters.Handles.Clusters_Data_List.Value};
				
				V = [Means_struct.X',Means_struct.Y'];
				[Clusters_Indices,Clusters_Centroids] = Cluster_Data(V,Algorithm_Name,[1:Max_Category_Num]);
				
				hold on;
				P1 = plot(V(Clusters_Indices==1,1),V(Clusters_Indices==1,2),'.','MarkerSize',10,'Color',GUI_Parameters.Visuals.Active_Colormap(2,:));
				hold on;
				P2 = plot(V(Clusters_Indices==2,1),V(Clusters_Indices==2,2),'.','MarkerSize',10,'Color',GUI_Parameters.Visuals.Active_Colormap(3,:));
				
				% P3 = plot(Clusters_Centroids(:,1),Clusters_Centroids(:,2),'x','MarkerSize',15,'LineWidth',3,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
				
				% Lg = legend([P1,P2,P3],'Cluster 1','Cluster 2','Centroids','Location','best');
				Lg = legend([P1,P2],'Cluster 1','Cluster 2','Location','best');
				Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
			else
				MeanY = mean([Means_struct(1).Y]);
				MeanX = mean([Means_struct(1).X]);
				
				if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
					Y_STD = nanstd([Means_struct(1).Y]);
					X_STD = nanstd([Means_struct(1).X]);
					plot([MeanX,MeanX],[MeanY-Y_STD,MeanY+Y_STD],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % Y-Error-Bar.
					plot([MeanX-X_STD,MeanX+X_STD],[MeanY,MeanY],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % X-Error-Bar.
				end
				
				plot(MeanX,MeanY,'.','MarkerSize',35,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
			end
			
		else
			if(GUI_Parameters.Handles.Clusters_Data_List.Value > 1)
				
				Algorithm_Name = GUI_Parameters.Handles.Clusters_Data_List.String{GUI_Parameters.Handles.Clusters_Data_List.Value};
				
				V = [];
				for d=1:numel(Means_struct)
					V = [V ; [Means_struct(d).X',Means_struct(d).Y']];
				end
				[Clusters_Indices,Clusters_Centroids] = Cluster_Data(V,Algorithm_Name,[1:Max_Category_Num]);
				% eva = evalclusters(V,'kmeans','silhouette','KList',[1:Max_Category_Num]);
				% [Clusters_Indices,Clusters_Centroids] = kmeans(V,eva.OptimalK);
				P = [];
				for d=1:length(unique(Clusters_Indices))
					P(d) = plot(V(Clusters_Indices==d,1),V(Clusters_Indices==d,2),'.','MarkerSize',10,'Color',GUI_Parameters.Visuals.Active_Colormap(d+1,:));
					% P0 = plot(Clusters_Centroids(d,1),Clusters_Centroids(d,2),'x','MarkerSize',15,'LineWidth',3,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
					hold on;					
				end
				% Lg = legend([P,P0],'Cluster 1','Cluster 2','Centroids','Location','best');
				% Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
			else
				Legend_Array = [];
				for m=1:numel(Means_struct) % For each category, calculate the means of X and Y.
					Hm = findobj(GUI_Parameters.General.Categories_Filter_Handles,'UserData',GUI_Parameters.General.Categories_Filter_Values(m,:));
					n = str2num(Hm.Tag);
					MeanY = mean([Means_struct(m).Y]);
					MeanX = mean([Means_struct(m).X]);
					
					if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
						Y_STD = nanstd([Means_struct(m).Y]);
						X_STD = nanstd([Means_struct(m).X]);
						plot([MeanX,MeanX],[MeanY-Y_STD,MeanY+Y_STD],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % Y-Error-Bar.
						plot([MeanX-X_STD,MeanX+X_STD],[MeanY,MeanY],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1); % X-Error-Bar.
					end
					
					Legend_Array(g,m) = plot(MeanX,MeanY,'.','MarkerSize',35,'Color',ColorMap(n,:));
					set(Hm,'BackgroundColor',ColorMap(n,:));
				end
				
				Hmatch = findobj(GUI_Parameters.General.Categories_Filter_Handles,'Value',1);
				Lg = legend(Legend_Array(g,:),[Hmatch.String],'Location','best');
				Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
			end
		end
		
		% plot([0 180],[0 180],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		% plot([0 180],[180 0],'r');
		% plot([0 120 180],[180 120 0],'Color',[0.16 0.4 1],'LineWidth',3); % Mathamatical bound (2y<=360-a).
		% plot([0 30],[30 0],'Color',[0.16 0.4 1],'LineWidth',3); % Algorithmic bound.
		set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size,'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
		
		title(Groups_Names(GUI_Parameters.General.Groups_OnOff(g)),'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		
		% X_Label = texlabel('Linearity (a_1 = Angle Closest to 180^o)');
		% xlabel(X_Label,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		xlabel('Linearity ($$ a_1 $$ = closest to $$ 180^o $$)','Interpreter','latex','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		ylabel('Symmetry ($$\frac{a_{2}}{a_{1}}$$)','Interpreter','latex','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		
		% xlabel('Min Angle','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		% ylabel('Max Angle','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		
		axis square;
		grid on;
		grid minor;
		% % % axis([100 360 0.3 1]);
		% axis([-0.01 1 0.3 1]);
		axis([60 220 0 1]);
		set(gca,'XTick',60:40:220,'YTick',0:.1:1);
	end
	
	% assignin('base','Means_struct',Means_struct);
	
	% hold on;
	% ST = suptitle('Two Smallest Angles of 3-way Junctions');
	% ST.Color = GUI_Parameters.Visuals.Active_Colormap(1,:);
	% ST.FontSize = 40;
	% ST.EdgeColor = 'w';
	% ST.Position = [.5,.5,0]
	
end