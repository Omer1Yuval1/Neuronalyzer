function S = Plot_Filtered_Features(W,m,M,Groups,IsTerminal)
    
	Min_Curvature = 0;
	Max_Curvature = .1;
	
	Max_PValue = 0.05;
	
	S = struct('Workspace_Index',{});
	ColorMap = lines(2);
	
	figure(1); clf(1);
	for w=1:numel(W) % For each workspace (= a single neuron).
		
		S(w).Workspace_Index = w;
		
		Fv = find([W(w).Workspace.Vertices.Distance_From_Medial_Axis] >= m & [W(w).Workspace.Vertices.Distance_From_Medial_Axis] <= M);
		if(IsTerminal)
			Fs = find([W(w).Workspace.Segments.Distance_From_Medial_Axis] >= m & [W(w).Workspace.Segments.Distance_From_Medial_Axis] <= M & [W(w).Workspace.Segments.Terminal] == 1);
		else
			Fs = find([W(w).Workspace.Segments.Distance_From_Medial_Axis] >= m & [W(w).Workspace.Segments.Distance_From_Medial_Axis] <= M);
		end
		
		S(w).Filtered_Vertex_Indices = Fv;
		S(w).Filtered_Segment_Indices = Fs;
		
		if(~isempty(W(w).Workspace.Medial_Axis))
			S(w).Filtered_Vertex_Num = length(Fv);
			S(w).Filtered_Segment_Num = length(Fs);
			
			S(w).Medial_Angle_Diffs = [W(w).Workspace.Vertices(Fv).Min_Medial_Angle_Corrected_Diff];
			S(w).Medial_Angle_Diffs = S(w).Medial_Angle_Diffs(S(w).Medial_Angle_Diffs >= 0);
			
			S(w).Total_Length = sum([W(w).Workspace.Segments(Fs).Length]);
			
			V1 = [W(w).Workspace.Segments(Fs).Curvature];
			S(w).Mean_Squared_Curvature = mean(V1(V1 >= Min_Curvature & V1 <= Max_Curvature));
			
			V2 = [W(w).Workspace.Segments(Fs).Max_Curvature];
			S(w).Mean_Max_Squared_Curvature = mean(V2(V2 >= Min_Curvature & V2 <= Max_Curvature));
			
			S(w).Mean_Squared_Curvature_Count = length(V1) ./ numel(W(w).Workspace.Segments);
			S(w).Max_Squared_Curvature_Count = length(V2) ./ numel(W(w).Workspace.Segments);
		else % TODO: isn't this going to happen automatically??
			S(w).Filtered_Vertex_Num = [];
			S(w).Filtered_Segment_Num = [];
			S(w).Medial_Angle_Diffs = [];
			S(w).Total_Length = [];
			S(w).Mean_Squared_Curvature = [];
			S(w).Mean_Max_Squared_Curvature = [];
			S(w).Mean_Squared_Curvature_Count = [];
			S(w).Max_Squared_Curvature_Count = [];
		end
    end
	
	V1 = cell(1,2);
	V2 = cell(1,2);
	figure(1); clf(1);
	figure(2); clf(2);
	% for g=[1,2] % N2, crowded (1) and isolated (2).
	for g=1:size(Groups,1)
		
		% Fg = find([W.Grouping] == g);
		Fg = find([W.Grouping] == Groups(g,1) & [W.Genotype] == Groups(g,2));
		
		figure(1);
			subplot(2,2,1); % Mean Squared Curvature.
				hold on;
				Dg = [S(Fg).Mean_Squared_Curvature]; % A vector of numbers of segments (per neuron).
				V1{g} = Dg;
				SE = nanstd(Dg) ./ sqrt(length(Dg));
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				errorbar(g,nanmean(Dg),SE,'Color','k','LineWidth',2);
				plot(g,nanmean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				set(gca,'FontSize',18,'XTickLabels',{'','N2-Crowded','','N2-Isolated',''});
				xlabel('Group');
				ylabel('Squared Curvature');
				title('Mean Squared Curvature');
				xlim([.5,2.5]);
				% ylim([0,0.02]);
				grid on;
			
			subplot(2,2,2); % Mean Max Squared Curvature.
				hold on;
				Dg = [S(Fg).Mean_Max_Squared_Curvature]; % A vector of numbers of segments (per neuron).
				V2{g} = Dg;
				SE = nanstd(Dg) ./ sqrt(length(Dg));
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				errorbar(g,nanmean(Dg),SE,'Color','k','LineWidth',2);
				plot(g,nanmean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				set(gca,'FontSize',18);
				xlabel('Group');
				ylabel('Squared Curvature');
				title('Mean Max Squared Curvature');
				xlim([.5,2.5]);
				% ylim([0,0.025]);
				grid on;
				% Ly = get(gca,'Ylim');
				% Ly(1) = 0;
				% set(gca,'Ylim',Ly);
			%
			subplot(2,2,3); % Count Mean.
				hold on;
				Dg = [S(Fg).Mean_Squared_Curvature_Count]; % A vector of numbers of segments (per neuron).
				V3{g} = Dg;
				SE = std(Dg) ./ sqrt(length(Dg));
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				errorbar(g,nanmean(Dg),SE,'Color','k','LineWidth',2);
				plot(g,nanmean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				set(gca,'FontSize',18,'XTickLabels',{'','N2-Crowded','','N2-Isolated',''});
				xlabel('Group');
				ylabel('Squared Curvature');
				title('Number of Curved Segments (mean)');
				xlim([.5,2.5]);
				% ylim([0,0.02]);
				grid on;
				
			subplot(2,2,4); % Count Max.
				hold on;
				Dg = [S(Fg).Max_Squared_Curvature_Count]; % A vector of numbers of segments (per neuron).
				V4{g} = Dg;
				SE = std(Dg) ./ sqrt(length(Dg));
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				errorbar(g,mean(Dg),SE,'Color','k','LineWidth',2);
				plot(g,mean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				set(gca,'FontSize',18);
				xlabel('Group');
				ylabel('Squared Curvature');
				title('Number of Curved Segments (max)');
				xlim([.5,2.5]);
				% ylim([0,0.025]);
				grid on;
				% Ly = get(gca,'Ylim');
				% Ly(1) = 0;
				% set(gca,'Ylim',Ly);
			%}
		figure(2);
			subplot(2,2,1); % Number of Vertices.
				hold on;
				Dg = [S(Fg).Filtered_Vertex_Num]; % A vector of numbers of segments (per neuron).
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				plot(g,mean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				xlabel('Group');
				ylabel('Mean Number of Vertices');
				title('Number of Vertices');
				xlim([.5,2.5]);
			
			subplot(2,2,2); % Number of Segments.
				hold on;
				Dg = [S(Fg).Filtered_Segment_Num]; % A vector of numbers of segments (per neuron).
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				plot(g,mean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				xlabel('Group');
				ylabel('Number of Segments');
				title('Number of Segments');
				xlim([.5,2.5]);
				
			subplot(2,2,3); % Total Length.
				hold on;
				Dg = [S(Fg).Total_Length]; % A vector of numbers of segments (per neuron).
				
				scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				plot(g,mean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				xlabel('Group');
				ylabel(['Length (',char(181),'m)']);
				title('Total Length of Segments');
				xlim([.5,2.5]);
				
			subplot(2,2,4); % Medial Angle Diffs.
				hold on;
				Dg = [S(Fg).Medial_Angle_Diffs]; % A vector of numbers of segments (per neuron).
				
				histogram(Dg.*180./pi,0:2:180);
				% scatter(g.*ones(1,length(Dg)),Dg,5,'k','filled','jitter','on','jitterAmount',.25);
				% plot(g,mean(Dg),'.','Color',ColorMap(g,:),'MarkerSize',30);
				
				xlabel('Group');
				ylabel(['Min Diff from Medial Angle (',char(176),')']);
				title('Medial Angle Diffs');
				xlim([0,180]);
			
	end
	[IsSig_1,PVal_1,Test_Name_1] = Test_Stat_Sig(V1{1},V1{2},Max_PValue);
	[IsSig_2,PVal_2,Test_Name_2] = Test_Stat_Sig(V2{1},V2{2},Max_PValue);
	disp([num2str(IsSig_1),' , ',num2str(PVal_1),' , ',Test_Name_1]);
	disp([num2str(IsSig_2),' , ',num2str(PVal_2),' , ',Test_Name_2]);
	
	
	function [IsSig,PVal,Test_Name] = Test_Stat_Sig(V1,V2,Max_PValue)
		[H_TTEST,PV_TTEST] = ttest2(V1,V2); % TTEST.
		[PV_MWU,H_MWU] = ranksum(V1,V2); % Mann-Whitney.
		
		if(ttest(V1) == 0 && ttest(V2) == 0) % If both distribute normally.
			if(H_TTEST && PV_TTEST <= Max_PValue) % If TTEST is successful and the P-Value is small enough (0.05).
				IsSig = 1;
				PVal = PV_TTEST;
				Test_Name = 'TTEST';
			end
		elseif(H_MWU && PV_MWU <= Max_PValue) % If Mann-Whitney is successful.
			IsSig = 1;
			PVal = PV_MWU;
			Test_Name = 'Mann-Whitney';
		else
			IsSig = 0;
			PVal = PV_MWU;
			Test_Name = 'Mann-Whitney';
		end
	end
	
end

%{
S(w).Segments_Num = length(Fs);
S(w).Segment_Arc_Lengths = W.Segments(Fs).Length;
S(w).Segment_End2End_Lengths = W.Segments(Fs).End2End_Length;
S(w).Segment_Curvatures = W.Segments(Fs).Curvature;
%}