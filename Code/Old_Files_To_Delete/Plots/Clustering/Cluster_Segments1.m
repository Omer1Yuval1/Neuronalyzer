function Cluster_Segments1(GUI_Parameters)
	
	N = 8000;
	V = 5;
	varNames = {'Orientation' , 'Distance From CB' , 'Distance From Primary' , ...
				'Length' , 'Curviness'};
	Groups_Names = {'1','1.5','2','2.5','3','3.5','4','4.5','5'};
	S = zeros(N,V);
	Categories1 = zeros(N,1);
	r = 0;
	G = GUI_Parameters.General.Groups_OnOff(1);
	for j=1:length(GUI_Parameters.Workspace(G).Files) % For each memeber (animal) of the selected group.
		for s=1:numel(GUI_Parameters.Workspace(G).Files{j}.Segments)
			r = r +1;
			% S(r).Orientation = GUI_Parameters.Workspace(G).Files{j}.Segments(s).Orientation;
			S(r,1) = GUI_Parameters.Workspace(G).Files{j}.Segments(s).Orientation;
			% S(r).Primary_Arc_Distance_From_CB = mean(abs([GUI_Parameters.Workspace(G).Files{j}.Segments(s).Rectangles.Primary_Arc_Distance_From_CB]));
			S(r,2) = mean(([GUI_Parameters.Workspace(G).Files{j}.Segments(s).Rectangles.Primary_Arc_Distance_From_CB]));
			% S(r).Distance_From_Primary = mean(abs([GUI_Parameters.Workspace(G).Files{j}.Segments(s).Rectangles.Distance_From_Primary]));
			S(r,3) = mean(abs([GUI_Parameters.Workspace(G).Files{j}.Segments(s).Rectangles.Distance_From_Primary]));
			S(r,4) = GUI_Parameters.Workspace(G).Files{j}.Segments(s).Length;
			S(r,5) = GUI_Parameters.Workspace(G).Files{j}.Segments(s).Curviness;
			
			Categories1(r) = GUI_Parameters.Workspace(G).Files{j}.Segments(s).Order;
		end
	end
	
	S = S(1:r,:);
	Categories1 = Categories1(1:r,:);
	
	if(GUI_Parameters.Handles.Display_Clusters_CheckBox.Value)
		% eva = evalclusters(S,'kmeans','silhouette','KList',[1:10]);
		[Clusters1,C] = kmeans(S,9); % eva.OptimalK); % 4 groups.
	else
		Clusters1 = Categories1;
	end
	
	% andrewsplot(S,'group',Clusters1); % ,'quantile',.25,'standardize','on'
	
	parallelcoords(S,'group',Clusters1,'standardize','on');
	set(gca,'XTick',1:V,'XTickLabel',varNames);
	xlim([.8,V+.2]);
	
	colormap(parula);
	
	set(gca,'FontSize',18,'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
	L = legend(Groups_Names);
	L.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
	
end