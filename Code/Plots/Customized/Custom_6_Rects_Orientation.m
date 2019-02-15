function Custom_6_Rects_Orientation(GUI_Parameters,Visuals,YLabel,Title1)
	
	Medial_Range = [0,40];
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	V1 = [];
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			
			F1 = find([W.Vertices.Min_Medial_Angle_Corrected_Diff] >= 0);
			F2 = find([W.Segments.Distance_From_Medial_Axis] >= Medial_Range(1) & [W.Segments.Distance_From_Medial_Axis] <= Medial_Range(2));
			F = intersect(F1,F2);
			% v = mod([W.Vertices(F).Min_Medial_Angle_Corrected_Diff],pi./2) .* 180./pi;
			v = [W.Vertices(F).Min_Medial_Angle_Corrected_Diff] .* 180./pi;
			V1 = [ V1 , v ];
		end
	end
	
	histogram(V1,0:5:180,'Normalization','probability');
	
	set(gca,'FontSize',16); % ,'FontSize',Visuals.Axes_Lables_Font_Size/(Groups_Num/2)); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientatio
	xlabel(YLabel,'FontSize',20);
	ylabel('Probability','FontSize',20);
	% xlabel('Group','FontSize',20);
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title([Title1,' (',num2str(Medial_Range(1)),'-',num2str(Medial_Range(2)),'\mum^2)'],'FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	% xlim([0.5,Groups_Num+0.5]);
	YLIMITS = get(gca,'ylim');
	ylim([0,YLIMITS(2)]);
	% xlim([0,Curvature_Range(2)]);
	grid on;
end