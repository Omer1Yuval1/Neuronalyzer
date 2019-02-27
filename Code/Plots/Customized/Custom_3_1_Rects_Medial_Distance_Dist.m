function Custom_3_1_Rects_Medial_Distance_Dist(GUI_Parameters,Visuals,YLabel,Title1)
	
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
	
	V = [];
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			Scale_Factor = W.User_Input.Scale_Factor;
			
			if(~isempty(W.Medial_Axis))
				for s=1:numel(W.Segments) % For each segment.
					
					for r=1:numel(W.Segments(s).Rectangles)
						
						Cxy = [W.Segments(s).Rectangles(r).X , W.Segments(s).Rectangles(r).Y];
						D = Find_Medial_Distance(Cxy,W.Medial_Axis,Scale_Factor);
						
						V = [ V , D ];
					end
				end
			end
		end
	end
	
	histogram(V,0:1:180,'Normalization','probability');
	
	set(gca,'FontSize',16);
	xlabel(YLabel,'FontSize',20);
	ylabel('Probability','FontSize',20);
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title(Title1,'FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	xlim([0,60]);
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