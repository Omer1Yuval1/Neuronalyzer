function Cluster_Animals_Segments(GUI_Parameters)
	
	N = 2000;
	varNames = {'Orientation','Distance from Primary','Distance from CB','Length','Curviness'};
	V = length(varNames);
	Groups_Names = {'WT_C_r_o_w_d_e_d','WT_I_s_o_l_a_t_e_d','mec-10_C_r_o_w_d_e_d','mec-10_I_s_o_l_a_t_e_d'};
	C = {};
	S = zeros(N,V);
	Categories1 = zeros(N,1);
	r = 0;
	for i=GUI_Parameters.General.Groups_OnOff % For each group.
		C{i} = zeros(N,V+2);
		S1 = zeros(N,V+2);
		r1 = 0;
		for j=1:length(GUI_Parameters.Workspace(i).Files) % For each memeber (animal) of the i-group.
			for s=1:numel(GUI_Parameters.Workspace(i).Files{j}.Segments)
				r = r +1;
				
				S(r,1) = GUI_Parameters.Workspace(i).Files{j}.Segments(s).Orientation; % 
				S(r,2) = mean(([GUI_Parameters.Workspace(i).Files{j}.Segments(s).Rectangles.Primary_Arc_Distance_From_CB]));
				S(r,3) = mean(abs([GUI_Parameters.Workspace(i).Files{j}.Segments(s).Rectangles.Distance_From_Primary]));
				S(r,4) = GUI_Parameters.Workspace(i).Files{j}.Segments(s).Length;
				S(r,5) = GUI_Parameters.Workspace(i).Files{j}.Segments(s).Curviness;
				Categories1(r) = i;
				
				r1 = r1 +1;
				S1(r1,1) = GUI_Parameters.Workspace(i).Files{j}.Segments(s).Orientation; % 
				S1(r1,2) = mean(([GUI_Parameters.Workspace(i).Files{j}.Segments(s).Rectangles.Primary_Arc_Distance_From_CB]));
				S1(r1,3) = mean(abs([GUI_Parameters.Workspace(i).Files{j}.Segments(s).Rectangles.Distance_From_Primary]));
				S1(r1,4) = GUI_Parameters.Workspace(i).Files{j}.Segments(s).Length;
				S1(r1,5) = GUI_Parameters.Workspace(i).Files{j}.Segments(s).Curviness;
				S1(r1,6) = i;
				S1(r1,7) = j;				
			end
		end
		C{i} = S1;
		C{i} = C{i}(1:r1,:);
	end
	
	S = S(1:r,:);
	Categories1 = Categories1(1:r);
	
	% assignin('base','C',C);
	% display(r);
	return;
	if(GUI_Parameters.Handles.Display_Clusters_CheckBox.Value)
		% eva = evalclusters(S,'kmeans','silhouette','KList',[1:10]);
		% display(eva.OptimalK);
		% [Clusters1,C] = kmeans(S,3); % eva.OptimalK);
		
		eva = evalclusters(S,'gmdistribution','silhouette','KList',[1:10]);
		% display(eva.OptimalK);
		obj = fitgmdist(S,3);
		% h = ezcontour(@(x,y)pdf(obj,[x y]),[-8 6],[-8 6]);
		Clusters1 = cluster(obj,S);
	else
		Clusters1 = Categories1;
	end
	
	% andrewsplot(S,'group',Clusters1); % ,'quantile',.25,'standardize','on'
	
	parallelcoords(S,'group',Clusters1,'standardize','on');
	set(gca,'XTick',1:V,'XTickLabel',varNames);
	xlim([.8,V+.2]);
	
	set(gca,'FontSize',18, ...
		'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
	% L = legend(Groups_Names);
	% L.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
	
end