function Custom_3_2_Vertices_Rects_Medial_Distance_Dist(GUI_Parameters,Visuals,YLabel,Title1)
	
	Medial_Range = [0,40];
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	V1_All = [];
	V2_Tips = [];
	V3_3Way = [];
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			F = find( [W.Vertices.Distance_From_Medial_Axis] >= Medial_Range(1) & [W.Vertices.Distance_From_Medial_Axis] <= Medial_Range(2));
			F2_Tips = intersect(F , find([W.Vertices.Order] == 1));
			F3_3Way = intersect(F , find([W.Vertices.Order] == 3));
			
			V1_All = [ V1_All , W.Vertices(F).Distance_From_Medial_Axis];
			
			V2_Tips = [ V2_Tips , [W.Vertices(F2_Tips).Distance_From_Medial_Axis] ];
			V3_3Way = [ V3_3Way , [W.Vertices(F3_3Way).Distance_From_Medial_Axis] ];
		end
	end
	
	histogram(V1_All,0:1:180,'Normalization','probability');
	hold on;
	histogram(V2_Tips,0:1:180,'Normalization','probability');
	histogram(V3_3Way,0:1:180,'Normalization','probability');
	
	set(gca,'FontSize',16);
	xlabel(YLabel,'FontSize',20);
	ylabel('Probability','FontSize',20);
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title(Title1,'FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	xlim([0,Medial_Range(2)]);
	YLIMITS = get(gca,'ylim');
	ylim([0,YLIMITS(2)]);
	grid on;
	
	function D = Find_Medial_Distance(Cxy,XY_Med,Scale_Factor)
		Dm = Distance_Func(XY_Med(:,1),XY_Med(:,2),Cxy(1),Cxy(2));
		f1 = find(Dm == min(Dm));
		Medial_Distance = Dm(f1(1)); % Minimal distance of the vertex center of the medial axis (= distance along the Y' axis).
		D = Medial_Distance.*Scale_Factor;
	end
end