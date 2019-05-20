function Custom_2_2_Mean_Segment_Curvature(GUI_Parameters,Visuals)
	
	% Curvature_Min_Max = [10^(-2),0.2];
	Curvature_Min_Max = [0,0.4]; % Curvature_Min_Max = [0,0.2];
	Medial_Dist_Range_1 = [0,20];
	Medial_Dist_Range_2 = [25,45]; % [25,60]
	
	BinSize1 = 0.02;
	
	% X_Fit = linspace()
	
	Crowding = [1,2];
	Genotype = 1:8;
	Group_Num = length(Crowding)*length(Genotype);
	Stats_Pairs = [1,2 ; 3,4 ; 3,1 ; 4,2 ; 5,6 ; 5,1 ; 6,2 ; 7,8 ; 7,1 ; 8,2 ; 9,10 ; 9,1 ; 10,2 ; 11,12 ; 11,1 ; 12,2 ; 13,14 ; 13,1 ; 14,2 ; 15,16 ; 15,1 ; 16,2];
	
	Group_Names = cell(1,length(Genotype));
	for g=1:length(Genotype)
		gg = g*2 - 1;
        Group_Names{gg} = [GUI_Parameters.Features(5).Values(g).Name,'-Crowded'];
		Group_Names{gg+1} = [GUI_Parameters.Features(5).Values(g).Name,'-Isolated'];
	end
	assignin('base','Group_Names',Group_Names);
	
	Points_Per_Group_1 = cell(1,Group_Num);
	Points_Per_Animal_1 = cell(1,Group_Num);
	Points_Per_Group_2 = cell(1,Group_Num);
	Points_Per_Animal_2 = cell(1,Group_Num);
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
			
			[~,Vc_Dist_1,Vc_Max_1] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range_1(1),Medial_Dist_Range_1(2),0);
			Points_Per_Group_1{ii} = [Points_Per_Group_1{ii},Vc_Dist_1']; % All images within the same group are treated as one dataset.
			Points_Per_Animal_1{ii}(end+1) = mean(Vc_Dist_1);
			% Points_Per_Group_1{ii} = [Points_Per_Group_1{ii},Vc_Max_1']; % All images within the same group are treated as one dataset.
			% Points_Per_Animal_1{ii}(end+1) = mean(Vc_Max_1);
			
			[~,Vc_Dist_2,Vc_Max_2] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range_2(1),Medial_Dist_Range_2(2),0);
			Points_Per_Group_2{ii} = [Points_Per_Group_2{ii},Vc_Dist_2']; % All images within the same group are treated as one dataset.
			Points_Per_Animal_2{ii}(end+1) = mean(Vc_Dist_2);
			% Points_Per_Group_2{ii} = [Points_Per_Group_2{ii},Vc_Max_2']; % All images within the same group are treated as one dataset.
			% Points_Per_Animal_2{ii}(end+1) = mean(Vc_Max_2);
		end
		
	end
	
	% Points_Per_Animal_1 = Points_Per_Group_1;
	% Points_Per_Animal_2 = Points_Per_Group_2;
	
	for i=1:length(Points_Per_Group_2) % For each group of animals (strain + condition).
		
		%{
		% Exponential Fit:
		[yy,edges] = histcounts(Points_Per_Group_2{i},Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
		xx = (edges(1:end-1) + edges(2:end)) ./ 2;
		
		F1 = find(isnan(xx) | isnan(yy));
		xx(F1) = []; yy(F1) = [];
        
		if(length(xx) > 1)
			
			f = fit(xx',yy','exp1');
			
			A = f.a;
			B = abs(f.b);
			Err = confint(f);
            A_Err = Err(:,1);
			B_Err = flipud(abs(Err(:,2)));
			
			subplot(2,2,1);
				hold on;
				plot(xx,f(xx),'LineWidth',3);
				
			subplot(2,2,2);
				hold on;
				errorbar(A,B,B-B_Err(1),B_Err(2)-B,A-A_Err(1),A_Err(2)-A,'LineWidth',2,'Color','k');
				plot(A,B,'.','MarkerSize',30);
		end
		%}
		
		subplot(2,2,[1,2]);
			hold on;
			Err = std(Points_Per_Animal_1{i}); % ./ length(Points_Per_Animal_1{i});
			errorbar(i,mean(Points_Per_Animal_1{i}),Err,'LineWidth',2,'Color','k');
			plot(i,mean(Points_Per_Animal_1{i}),'.','MarkerSize',30);
			
		subplot(2,2,[3,4]);
			hold on;
			Err = std(Points_Per_Animal_2{i}); % ./ length(Points_Per_Animal_2{i});
			errorbar(i,mean(Points_Per_Animal_2{i}),Err,'LineWidth',2,'Color','k');
			plot(i,mean(Points_Per_Animal_2{i}),'.','MarkerSize',30);
	end
	
	%{
	subplot(2,2,1);
		xlabel(['Curvature [1/\mum]      ' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2))]);
		ylabel('Count');		set(gca,'FontSize',16); % set(gca,'FontSize',16,'XTick',1:length(Points_Per_Animal_2));
		title(['Curvature Distribution - Exponent Fit (',num2str(Medial_Dist_Range_2(1)) ,'-', num2str(Medial_Dist_Range_2(2)),'\mum)']);
		grid on;
		
	subplot(2,2,2);
		ylabel('b'); % ylabel(['Curvature [1/\mum] (' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2)),')']);
		xlabel('a'); % xlabel('Group');
		set(gca,'FontSize',16); % set(gca,'FontSize',16,'XTick',1:length(Points_Per_Animal_2));
		title(['Curvature Distribution - Exponent Fit (',num2str(Medial_Dist_Range_2(1)) ,'-', num2str(Medial_Dist_Range_2(2)),'\mum)']); % title(['Mean Curvature of Points_Per_Group_2 (',num2str(Medial_Dist_Range_2(1)) ,'-', num2str(Medial_Dist_Range_2(2)),'\mum)']);
		% xlim([.5,length(Points_Per_Group_2)+0.5]);
		grid on;
	%}
	
	% Y_1 = cellfun(@mean,Points_Per_Animal_1);
	% Y_2 = cellfun(@mean,Points_Per_Animal_2);
	assignin('base','Y_1',Points_Per_Animal_1);
	assignin('base','Y_2',Points_Per_Animal_2);
	
	subplot(2,2,[1,2]);
		ylabel(['Curvature [1/\mum] (' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2)),')']);
		xlabel('Group');
		set(gca,'FontSize',16,'XTick',1:length(Points_Per_Animal_1));
		title(['Mean Curvature (',num2str(Medial_Dist_Range_1(1)) ,'-', num2str(Medial_Dist_Range_1(2)),'\mum)'],'Interpreter','none');
		xlim([.5,length(Points_Per_Animal_1)+0.5]);
		grid on;
		set(gca,'XTickLabels',Group_Names,'TickLabelInterpreter','none','FontSize',10);
		xtickangle(25);
		ylim([0.04,0.115]);
		Get_Stats_Bars_XY(Points_Per_Animal_1,Stats_Pairs);
		
	
	subplot(2,2,[3,4]);
		ylabel(['Curvature [1/\mum] (' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2)),')']);
		xlabel('Group');
		set(gca,'FontSize',16,'XTick',1:length(Points_Per_Animal_2));
		title(['Mean Curvature (',num2str(Medial_Dist_Range_2(1)) ,'-', num2str(Medial_Dist_Range_2(2)),'\mum)'],'Interpreter','none');
		xlim([.5,length(Points_Per_Animal_2)+0.5]);
		grid on;
		set(gca,'XTickLabels',Group_Names,'TickLabelInterpreter','none','FontSize',10);
		xtickangle(25);
		ylim([0.04,0.115]);
		Get_Stats_Bars_XY(Points_Per_Animal_2,Stats_Pairs);
        
end