function Custom_2_5_Point_Curvature_Hist(GUI_Parameters,Visuals)
	
	% Curvature_Min_Max = [10^(-2),0.2];
	% Curvature_Min_Max = [0,0.2];
	Curvature_Min_Max = [0,0.4];
	% Max_Curvature_Min_Max = [0,1];
	Medial_Dist_Range = [25,60];
	
	WT_Crowded = [];
	WT_Crowded_Max = [];
	WT_Isolated = [];
	WT_Isolated_Max = [];
	
	for w=1:numel(GUI_Parameters.Workspace) % For each neuron (= animal).
		
		if(~isempty(GUI_Parameters.Workspace(w).Workspace.Medial_Axis) && GUI_Parameters.Workspace(w).Genotype == 1)
			W = GUI_Parameters.Workspace(w).Workspace;
			
			[Vc,Vc_Dist,Vc_Max] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),0);
			
			if(GUI_Parameters.Workspace(w).Genotype == 1) % If WT.
				if(GUI_Parameters.Workspace(w).Grouping == 1) % If Crowded.
					WT_Crowded = [WT_Crowded , Vc_Dist'];
					WT_Crowded_Max = [WT_Crowded_Max , Vc_Max];
				elseif(GUI_Parameters.Workspace(w).Grouping == 2) % If Isolated.
					WT_Isolated = [WT_Isolated , Vc_Dist'];
					WT_Isolated_Max = [WT_Isolated_Max , Vc_Max];
				end
			end
		end
	end
	
	BinSize1 = 0.02; % BinSize1 = 0.0075;
	
	subplot(2,2,1);
	histogram(WT_Crowded,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf'); % probability
	xlabel(['Curvature [1/\mum]      ' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2))]);
	ylabel('Probability');
	xlim(Curvature_Min_Max);
	set(gca,'FontSize',18);
	title(['Curvature of Points (WT-Crowded) (',num2str(Medial_Dist_Range(1)) ,'-', num2str(Medial_Dist_Range(2)),'\mum)']);
	
	%
	[yy,edges] = histcounts(WT_Crowded,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xx = (edges(1:end-1) + edges(2:end)) ./ 2;
	% hold on;
	% findpeaks(yy,xx);
	
	f1 = fit(xx',yy','exp1');
	hold on;
	plot([0,xx],f1([0,xx]),'r','LineWidth',2);
	Eq = ['$',num2str(f1.a),'\times e^{',num2str(f1.b),'x}$'];
	legend({'Data',Eq},'Interpreter','latex');
	%}
	
	%{
	pd1 = fitdist(transpose(WT_Crowded),'HalfNormal');
	xx = 0:0.01:0.2;
	yy = pdf(pd1,xx);	
	hold on;
	plot(xx,yy,'r','LineWidth',2);
	disp(['mu = ',num2str(pd1.mu),' ; sigma = ',num2str(pd1.sigma)]);
	%}
	
	axis([0,0.4,0,14]);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	subplot(2,2,2);
	histogram(WT_Isolated,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xlabel(['Curvature [1/\mum]      ' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2))]);
	ylabel('Probability');
	xlim(Curvature_Min_Max);
	set(gca,'FontSize',18);
	title(['Curvature of Points (WT-Isolated) (',num2str(Medial_Dist_Range(1)) ,'-', num2str(Medial_Dist_Range(2)),'\mum)']);
	%
    [yy,edges] = histcounts(WT_Isolated,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xx = (edges(1:end-1) + edges(2:end)) ./ 2;
	% hold on;
	% findpeaks(yy,xx);
	
	f2 = fit(xx',yy','exp1');
	hold on;
	plot([0,xx],f2([0,xx]),'r','LineWidth',2);
    % legend([num2str(f2.a),'*exp(',num2str(f2.b),'*x)']);
    % legend({'e^{\frac{y^2}{4}}'},'Interpreter','latex');
	Eq = ['$',num2str(f2.a),'\times e^{',num2str(f2.b),'x}$'];
	legend({'Data',Eq},'Interpreter','latex');
	% formula(f2)
	%}
	
    %{
	pd2 = fitdist(transpose(WT_Isolated),'HalfNormal');
	xx = Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2); % 0:0.01:0.2;
	yy = pdf(pd2,xx);
	hold on;
	plot(xx,yy,'r','LineWidth',2);
	disp(['mu = ',num2str(pd2.mu),' ; sigma = ',num2str(pd2.sigma)]);
	%}
	
	axis([0,0.4,0,14]);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	BinSize1 = 0.025; % 0.01.
	
	subplot(2,2,3);
	histogram(WT_Crowded_Max,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xlabel(['Curvature [1/\mum]      ' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2))]);
	ylabel('Probability');
	xlim(Curvature_Min_Max);
	set(gca,'FontSize',18);
	title('Max Curvature of Segments (WT-Crowded)');
	
    [yy,edges] = histcounts(WT_Crowded_Max,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xx = (edges(1:end-1) + edges(2:end)) ./ 2;
	hold on;
	findpeaks(yy,xx);
	
	%{
	pd3 = fitdist(transpose(WT_Crowded_Max),'Kernel','Kernel','epanechnikov');
	xx = Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2); % 0:0.01:0.2;
	yy = pdf(pd3,xx);
	hold on;
	plot(xx,yy,'r','LineWidth',2);
	%}
	
	axis([0,0.4,0,7]);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	subplot(2,2,4);
	histogram(WT_Isolated_Max,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xlabel(['Curvature [1/\mum]     ' , num2str(Curvature_Min_Max(1)) ,'-', num2str(Curvature_Min_Max(2))]);
	ylabel('Probability');
	xlim(Curvature_Min_Max);
	set(gca,'FontSize',18);
	title('Max Curvature of Segments (WT-Isolated)');
	
	[yy,edges] = histcounts(WT_Isolated_Max,Curvature_Min_Max(1):BinSize1:Curvature_Min_Max(2),'Normalization','pdf');
	xx = (edges(1:end-1) + edges(2:end)) ./ 2;
	hold on;
	findpeaks(yy,xx);
	
	axis([0,0.4,0,7]);
end