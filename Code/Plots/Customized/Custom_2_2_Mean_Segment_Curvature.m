function Custom_2_2_Mean_Segment_Curvature(GUI_Parameters,Visuals)
	
	% Curvature_Min_Max = [10^(-2),0.2];
	Curvature_Min_Max = [0,0.4]; % Curvature_Min_Max = [0,0.2];
	Medial_Dist_Range = [25,60];
	
	BinSize1 = 0.02;
	
	Crowding = [1,2];
	Genotype = 1:8;
	Group_Num = length(Crowding)*length(Genotype);
	
	Points = cell(1,Group_Num);
	Points_Per_Animal = cell(1,Group_Num);
	Exp_Fit = cell(2,Group_Num);
	%{
	WT_Crowded = [];
	WT_Crowded_Per_Animal = [];
	WT_Crowded_Max = [];
	WT_Isolated = [];
	WT_Isolated_Max = [];
	WT_Isolated_Per_Animal = [];
	%}
	
	for w=1:numel(GUI_Parameters.Workspace) % For each neuron (= animal).
		
		if(~isempty(GUI_Parameters.Workspace(w).Workspace.Medial_Axis))
			W = GUI_Parameters.Workspace(w).Workspace;
			
			c = GUI_Parameters.Workspace(w).Grouping;
			g = GUI_Parameters.Workspace(w).Genotype;
			
			ii = c*g;
			
			[Vc,Vc_Dist,Vc_Max] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),0);
			
			Points{ii} = [Points{ii},Vc_Dist'];
			Points_Per_Animal{ii}(end+1) = mean(Vc_Dist);
			
			% Exponential Fit:
			[yy,edges] = histcounts(Vc_Dist,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
			xx = (edges(1:end-1) + edges(2:end)) ./ 2;
			f = fit(xx',yy','exp1');
			
			Exp_Fit{1,ii}(end+1) = f.a;
			Exp_Fit{2,ii}(end+1) = f.b;
		end
		
	end
	
	for i=1:length(Points)
		subplot(2,1,1);
			hold on;
			plot(mean(Exp_Fit{1,i}),mean(Exp_Fit{2,i}),'.','MarkerSize',30);
			
			% Mean of all points (combined across all images in the same group):
			% errorbar(i,mean(Points{i}),std(Points{i}),'LineWidth',2,'Color','k');
			% plot(i,mean(Points{i}),'.','MarkerSize',30);
			
		subplot(2,1,2);
			hold on;
			Err = std(Points_Per_Animal{i}) ./ length(Points_Per_Animal{i});
			errorbar(i,mean(Points_Per_Animal{i}),Err,'LineWidth',2,'Color','k');
			plot(i,mean(Points_Per_Animal{i}),'.','MarkerSize',30);
	end
	
	subplot(2,1,1);
		ylabel('b'); % ylabel(['Curvature [1/\mum] (' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2)),')']);
		xlabel('a'); % xlabel('Group');
		set(gca,'FontSize',16); % set(gca,'FontSize',16,'XTick',1:length(Points_Per_Animal));
		title('Exponential Fit Coefficients'); % title(['Mean Curvature of Points (',num2str(Medial_Dist_Range(1)) ,'-', num2str(Medial_Dist_Range(2)),'\mum)']);
		% xlim([.5,length(Points)+0.5]);
		grid on;
		
	subplot(2,1,2);
		ylabel(['Curvature [1/\mum] (' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2)),')']);
		xlabel('Group');
		set(gca,'FontSize',16,'XTick',1:length(Points_Per_Animal));
		title(['Mean Curvature of Points - Per Animal (',num2str(Medial_Dist_Range(1)) ,'-', num2str(Medial_Dist_Range(2)),'\mum)']);
		xlim([.5,length(Points_Per_Animal)+0.5]);
		grid on;
end