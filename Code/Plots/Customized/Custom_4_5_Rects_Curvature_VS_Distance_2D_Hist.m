function Custom_4_5_Rects_Curvature_VS_Distance_2D_Hist(GUI_Parameters,Visuals,YLabel,Title1)
	
	Curvature_Min_Max = [0,0.4];
	Medial_Dist_Range = [0,45];
	Medial_Dist_Range_1 = [0,25];
	Medial_Dist_Range_2 = [25,45];
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	
	V0 = zeros(2,10^6); % [Curvature ; Medial Distance].
	V1 = zeros(2,10^6); % ".
	V2 = zeros(2,10^6); % ".
    I0 = [1,0];
    I1 = [1,0];
    I2 = [1,0];
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			
			if(~isempty(W.Medial_Axis))
				[~,Vc_Dist_0,~,Dist_Vector_0] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),0);
				[~,Vc_Dist_1,~,Dist_Vector_1] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range_1(1),Medial_Dist_Range_1(2),0);
				[~,Vc_Dist_2,~,Dist_Vector_2] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range_2(1),Medial_Dist_Range_2(2),0);
				
				Li = length(Vc_Dist_0);
				I0(2) = I0(1) + Li - 1;
				V0(:,I0(1):I0(2)) = [Vc_Dist_0' ; Dist_Vector_0'];
				I0(1) = I0(2) + 1;
				
				Li = length(Vc_Dist_1);
				I1(2) = I1(1) + Li - 1;
				V1(:,I1(1):I1(2)) = [Vc_Dist_1' ; Dist_Vector_1'];
				I1(1) = I1(2) + 1;
				
				Li = length(Vc_Dist_2);
				I2(2) = I2(1) + Li - 1;
				V2(:,I2(1):I2(2)) = [Vc_Dist_2' ; Dist_Vector_2'];
				I2(1) = I2(2) + 1;
			end			
		end
	end
	V0 = V0(:,1:I0(2));
	V1 = V1(:,1:I1(2));
	V2 = V2(:,1:I2(2));
	
	%{
	[N,Xedges,Yedges] = histcounts2(V1,V2,'Normalization','pdf');
	N1 = sum(N,1);
	N = N ./ N1;
	histogram2('XBinEdges',Xedges,'YBinEdges',Yedges,'BinCounts',N,'FaceColor','flat');
	%}
	
	histogram2(V0(1,:),V0(2,:),'FaceColor','flat');
	
	%{
	histogram2(V1(1,:),V1(2,:),'Normalization','pdf');
	hold on;
	histogram2(V2(1,:),V2(2,:),'Normalization','pdf');
	%}
	
	view([28.4,37.2]);
    % set(gca,'XTick',0:pi/6:pi./2,'XTickLabel',0:30:90,'FontSize',16); % 0:pi/3:2*pi
	xlabel('Curvature [1/\mum]','FontSize',20);
	ylabel('Distance [\mum]','FontSize',20);
	zlabel('Probability','FontSize',20);
	
	set(gca,'FontSize',16,'YColor',Visuals.Active_Colormap(1,:));
	title('Rects Curvature VS Medial Distance','FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	% xlim([0,pi./2]); % xlim([0,pi]);
	xlim([0,Curvature_Min_Max(2)]);
	% ylim([0,Medial_Dist_Range(2)]);
	grid on;
end