function Custom_4_4_Segment_Angles_Correlation_VS_Medial_Distance_Hist(GUI_Parameters,Visuals)
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	V1 = zeros(1,10^5);
	V2 = zeros(1,10^5);
	ii = 0;
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			
			for s=1:numel(W.Segments)
				
				if( all(W.Segments(s).End2End_Vertex_Angle_Diffs >= 0) && W.Segments(s).Distance_From_Medial_Axis >= 0)
					for v=1:length(W.Segments(s).End2End_Vertex_Angle_Diffs)
						ii = ii + 1;
						V1(ii) = mod(W.Segments(s).End2End_Vertex_Angle_Diffs(v).*180./pi,180);
						V2(ii) = W.Segments(s).Vertices_Medial_Distance(v);
						% V2(ii) = W.Segments(s).Distance_From_Medial_Axis;
					end
				end
			end
			
		end
	end
	V1 = V1(1:ii);
	V2 = V2(1:ii);
	
	histogram2(V1,V2,'BinWidth',[5,2],'FaceColor','flat','DisplayStyle','bar3','Normalization','probability');
	
	set(gca,'XTick',0:30:180,'FontSize',16);
	xlabel('Angle [degrees]','FontSize',20);
	ylabel('Distance [\mum]','FontSize',20);
	zlabel('Probability','FontSize',20);
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title('Vertex-End2End Angles Correlation VS Medial Distance','FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	xlim([0,180]);
	ylim([0,45]);
	grid on;
end