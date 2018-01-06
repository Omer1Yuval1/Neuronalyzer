function Cluster_Animals1(GUI_Parameters)
	
	N = 100;
	V = 4; % Number of dimensions.
	% S = struct('Orientation',{},'Primary_Arc_Distance_From_CB',{},'Distance_From_Primary',{});
	% S(5000).Orientation = -1;
	varNames = {'Curvature of 4 Branches' , 'Curvature of 3.5 Branches' , '# of 4+ Branches' , 'Self-Avoidance'};
	Groups_Names = {'WT_C_r_o_w_d_e_d','WT_I_s_o_l_a_t_e_d','mec-10_C_r_o_w_d_e_d','mec-10_I_s_o_l_a_t_e_d'};
	S = zeros(N,V);
	Categories1 = zeros(N,1);
	r = 0;
	for i=GUI_Parameters.General.Groups_OnOff % For each group.
		for j=1:length(GUI_Parameters.Workspace(i).Files) % For each memeber (animal) of the i-group.
			r = r +1;
			
			F = find([GUI_Parameters.Workspace(i).Files{j}.Branches.Order] == 4);
			S(r,1) = mean([GUI_Parameters.Workspace(i).Files{j}.Branches(F).Curvature]);
			
			F = find([GUI_Parameters.Workspace(i).Files{j}.Branches.Order] == 3.5);
			S(r,2) = mean([GUI_Parameters.Workspace(i).Files{j}.Branches(F).Curvature]);
			
			F = find([GUI_Parameters.Workspace(i).Files{j}.Branches.Order] >= 4);
			S(r,3) = length(F); % number of 4+ branches.
			% S(r,4) = length(F);
			
			S(r,4) = nanmean([GUI_Parameters.Workspace(i).Files{j}.Menorahs.Anterior_Overlap]);
			
			Categories1(r) = i;
		end
	end
	
	S = S(1:r,:);
	Categories1 = Categories1(1:r);
	
	% display(eva.OptimalK);
	display(r);
	
	if(GUI_Parameters.Handles.Display_Clusters_CheckBox.Value)
		% eva = evalclusters(S,'kmeans','silhouette','KList',[1:10]);
		[Clusters1,C] = kmeans(S,length(GUI_Parameters.General.Groups_OnOff)); % eva.OptimalK); % 4 groups.
	else
		Clusters1 = Categories1;
	end
	
	% andrewsplot(S,'group',Clusters1); % ,'quantile',.25,'standardize','on'
	
	parallelcoords(S,'group',Clusters1,'standardize','on');
	set(gca,'XTick',1:V,'XTickLabel',varNames);
	xlim([.8,V+.2]);
	
	set(gca,'FontSize',18, ...
		'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
	L = legend(Groups_Names(1:length(GUI_Parameters.General.Groups_OnOff)));
	L.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
	
end