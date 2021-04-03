function Display_Plot(P,Data,Label)
	
	% This function is used to display different plots for quantitative analysis of the data.
	
	Grouping_List = {'Strain_Name','Age'};
	
	% FontSize_1 = 18;
	BarWidth = 0.8;
	
	set(P.GUI_Handles.Control_Panel_Objects(3,1),'Text','Show Data Points');
	set(P.GUI_Handles.Control_Panel_Objects(2,5),'Enable','off');
	set(P.GUI_Handles.Control_Panel_Objects(3,[4,5]),'Enable','off');
	set(P.GUI_Handles.Control_Panel_Objects(4,5),'Enable','off');
	
	% Reset the normalization and plot type menus:
	if(~isequal(Label,P.GUI_Handles.Buttons(3,1).UserData)) % If the previous plot was different.
		set(P.GUI_Handles.Control_Panel_Objects(2,4),'Value',1);
		set(P.GUI_Handles.Control_Panel_Objects(4,4),'Value',1);
	end
	
	
	Groups = cell(1,0);
	Workspace_Set = cell(1,0); % One cell for each group. The cells contain row numbers of the members (Data(p)).
	
	% Choose field to group by:
	Feature_Values = "";
	Group_By = [];
	for f=1:length(Grouping_List)
		
		for p=1:numel(Data)
			Feature_Values(p) = [Data(p).Info.Experiment(1).(Grouping_List{f})];
		end
		
		if(length(unique(Feature_Values)) > 1) % If there are multiple values for feature f, use it for grouping.
			Group_By = Grouping_List{f};
			break;
		end
	end
	
	if(isempty(Group_By))
		Group_By = 'Strain_Name';
	end
	
	% List all groups (all existing values of "Group_By"):
	if(~P.GUI_Handles.Control_Panel_Objects(1,1).Value) % Use all projects.
		for p=1:numel(Data)
			s = Data(p).Info.Experiment(1).(Group_By);
			
			Fs = find(ismember(Groups,s),1);
			
			if(isempty(Fs)) % If it's the first instance of "Group_By".
				Groups{end+1} = s; % If this value is not listed yet as a group, add it.
				Workspace_Set{length(Groups)} = p; % Associate the project index with this group.
			else % If it's not the first instance of "Group_By".
				Workspace_Set{Fs}(end+1) = p; % Associate the project index with this group.
			end
		end
	else % Use selected project only.
		Workspace_Set{1} = P.GUI_Handles.Current_Project;
	end
	
	if(P.GUI_Handles.Control_Panel_Objects(4,1).Value) % Undock.
		figure(1);
		Ax1 = gca;
	else
		% figure(P.GUI_Handles.Main_Figure);
		delete(allchild(P.GUI_Handles.Main_Panel_1));
		Ax1 = axes(P.GUI_Handles.Main_Panel_1);
		set(P.GUI_Handles.Main_Panel_1,'BackgroundColor',[1,1,1]);
		% hold on;
	end
	
	% Workspace_Set = Workspace_Set(1);
	
	set(P.GUI_Handles.Control_Panel_Objects(1,3),'Text','Bin size:');
	set(0,'defaulttextInterpreter','tex'); % none.
	% assignin('base','GP',GP);
	
	switch(Label)
		case 'Number of Segments'
			
			set(P.GUI_Handles.Control_Panel_Objects(3,4),'Items',{'Not Normalized'},'ItemsData',1);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Terminal Segments'},'ItemsData',2);
			
			Name = '$\mathrm{Segments Number}$';
			Menorah_Classes = 1:4;
			Field_1_Name = 'Length_Corrected';
			Max_Segment_Length = 2; % um.
			Ng = length(Workspace_Set);
			CM = lines(Ng);
			
			%{
			if(~GP.Handles.Analysis.Slider.UserData)
				set(GP.Handles.Analysis.Slider,'Min',1,'Max',Max_Slider_Length,'Value',5,'SliderStep',[0.05,0.2]);
				set(GP.Handles.Analysis.Slider_Text,'String',num2str(GP.Handles.Analysis.Slider.Value));
			end
			%}
			
			for g=1:length(Workspace_Set)
				X{g} = nan(length(Menorah_Classes),length(Workspace_Set{g}));
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					switch(GP.Handles.Plot_Type_List.Value)
						case 1
							It = unique([GP.Workspace(ww).Workspace.Segments.Segment_Index]); % Indices of all segments.
						case 2 % Terminal segments only.
							F1 = find([GP.Workspace(ww).Workspace.Segments.Terminal] == 1);
							It = [GP.Workspace(ww).Workspace.Segments(F1).Segment_Index]; % Indices of terminal segments.
					end
					
					for o=1:length(Menorah_Classes)
						Fo = find([GP.Workspace(ww).Workspace.Points.Segment_Class] == Menorah_Classes(o) & ismember([GP.Workspace(ww).Workspace.Points.Segment_Index],It)); % All points of order o.
						
						Is = [GP.Workspace(ww).Workspace.Points(Fo).Segment_Index]; % Segment indices.
						Lw = [GP.Workspace(ww).Workspace.Points(Fo).(Field_1_Name)]; % Point Lenghs.
						Sw = accumarray(Is',Lw'); % Segment lengths.
						
						X{g}(o,w) = length(find(Sw > 0 & Sw <= Max_Segment_Length)); % Number of segments.
					end
				end
			end
			
			for g=1:length(Workspace_Set)
				B(:,g) = mean(X{g},2);
			end
			
			H1 = bar(B,'hist','FaceColor','flat');
			
			for g=1:length(Workspace_Set)
				H1(g).FaceColor = CM(g,:);
				errorbar(mean(H1(g).XData,1),B(:,g),std(X{g},0,2),'Color','k','LineWidth',2,'LineStyle','none');
			end
			
			xlabel('$\mathrm{Class}$','Interpreter','Latex');
			ylabel(Name,'Interpreter','Latex'); % ylabel('$$\frac{\# \; of \; 3-Way \; Junctions}{Total \; Length \; (\mu m)}$$','Interpreter','Latex');
			set(gca,'FontSize',FontSize_1,'TickLabelInterpreter','Latex','XTick',1:length(Menorah_Classes)+1,'xlim',[0.5,length(Menorah_Classes)+0.5]);
			legend(Groups,'Interpreter','Latex');
			grid on;
			
			if(g > 1)
				disp(['Number of segments - stats:']);
				for o=1:length(Menorah_Classes)
					[PVal,Test_Name] = Stat_Test(X{1}(o,:),X{2}(o,:));
					
					disp(['Menorah Order = ',num2str(Menorah_Classes(o)),': ','; P-Value = ',num2str(PVal),' (',Test_Name,')']);
				end
			end			
		case 'Mean Segment Length'
			set(P.GUI_Handles.Control_Panel_Objects(3,4),'Items',{'Not Normalized'},'ItemsData',1);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Terminal Segments'},'ItemsData',1:2);
			
			Menorah_Classes = 1:4;
			Field_1_Name = 'Length_Corrected';
			% Edges = 0:2:150;
			
			for g=1:length(Workspace_Set)
				X{g} = cell(length(Menorah_Classes),length(Workspace_Set{g}));
				X_Mean{g} = nan(length(Menorah_Classes),length(Workspace_Set{g}));
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					if(P.GUI_Handles.Control_Panel_Objects(4,4).Value == 2) % Type.
						F1 = find([Data(ww).Segments.Terminal] == 1);
						It = [Data(ww).Segments(F1).Segment_Index]; % Indices of terminal segments.
					end
					
					for o=1:length(Menorah_Classes)
						switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
						case 1
							Fo = find([Data(ww).Points.Segment_Class] == Menorah_Classes(o)); % All points of order o.
						case 2
							Fo = find([Data(ww).Points.Segment_Class] == Menorah_Classes(o) & ismember([Data(ww).Points.Segment_Index],It)); % All points of order o.
						end
						
						Is = [Data(ww).Points(Fo).Segment_Index]; % Segment indices.
						Lw = [Data(ww).Points(Fo).(Field_1_Name)]; % Point Lenghs.
						Sw = accumarray(Is',Lw');
						Sw = Sw(Sw > 0); %  & Sw < 10.
						
						X{g}{o,w} = Sw;
						X_Mean{g}(o,w) = nanmean(Sw); % Mean segment length per animal per order.
					end
				end
			end
			
			CM = lines(length(Workspace_Set));
			
			for g=1:length(Workspace_Set)
				
				%{
				for o=1:length(Menorah_Classes)
					A = cat(1,X{g}{o,:});
					B(o,g) = nanmean(A,1); % Combine all segment length from all workspaces, and then average.
					S(o,g) = nanstd(A,0,1);
				end
				%}
				B(:,g) = nanmean(X_Mean{g},2);
				S(:,g) = nanstd(X_Mean{g},0,2);
			end
			H = bar(Ax1,1:length(Menorah_Classes),B,'hist','FaceColor','flat');
			hold(Ax1,'on');
			for g=1:length(Workspace_Set)
				H(g).FaceColor = CM(g,:); % Class_Colors(o,:);
				errorbar(Ax1,mean(H(g).XData,1),B(:,g),S(:,g),'Color','k','LineWidth',2,'LineStyle','none');
			end
			
			disp(['Mean segment length per Menorah Order - Stats:']);
			for o=1:length(Menorah_Classes)
				% [PVal,Test_Name] = Stat_Test(cat(1,X{1}{o,:}),cat(1,X{2}{o,:}));
				[PVal,Test_Name] = Stat_Test(X_Mean{1}(o,:),X_Mean{2}(o,:));
				disp(['Menorah Order = ',num2str(Menorah_Classes(o)),': ','; P-Value = ',num2str(PVal),' (',Test_Name,')']);
			end
			
			set(Ax1,'XTick',Menorah_Classes,'FontSize',FontSize_1,'TickLabelInterpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
			xlabel(Ax1,'$\mathrm{Class}$','Interpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
			ylabel(Ax1,'$\mathrm{Segment \; Length}$','Interpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
			
			legend(Ax1,Groups,'Interpreter','Latex');
			grid(Ax1,'on');
		case 'Segment Linearity'
			set(GP.Handles.Normalization_List,'String',{'Not Normalized'});
			set(GP.Handles.Plot_Type_List,'String',{'Default'});
			
			% Length_Min_Max = [0,0.5];
			Field_1_Name = 'Length_Corrected';
			Edges = 0:0.25:20;
			
			for g=1:length(Workspace_Set)
				X{g} = [];
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					Ns = max([GP.Workspace(ww).Workspace.Points.Segment_Index]);
					Vw = nan(1,Ns);
					for s=1:Ns
						Fs = find([GP.Workspace(ww).Workspace.Points.Segment_Index] == s);
						Ls = nansum([GP.Workspace(ww).Workspace.Points(Fs).(Field_1_Name)]);
						% Ls = nansum();
						Vw(s) = mean([ std([GP.Workspace(ww).Workspace.Points(Fs).X]) , std([GP.Workspace(ww).Workspace.Points(Fs).Y]) ]);
					end
					X{g} = [X{g},Vw];
				end
				histogram(X{g},Edges,'normalization','probability'); % ,Edges
				hold on;
			end
			xlim(Edges([1,end]));
			% ylim([0,0.07]);
			
			xlabel('$$STD$$','Interpreter','Latex');
			ylabel('Probability','Interpreter','Latex');
			set(gca,'FontSize',FontSize_1,'TickLabelInterpreter','Latex');
			legend(Groups,'Interpreter','Latex');
			grid on;
		case 'End2End Length Of Segments'
			Var_Operations{1} = @(x) x(x>=0); % The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'End2End_Length'};
			Filter_Fields = [];
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Length (\mum)';
			Title = 'End2End Length of Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		case 'Mean Curvature'
			Class_Indices = 1:length(P.GUI_Handles.Class_Colors);
			Curvature_Min_Max = [0,0.3];
			% Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0]; % 3=0,0.8,0.8 ; 3.5=0,0,1 ; 5=0.5,0.5,0.5
			% colormap(Class_Colors);
			Max_PVD_Orders = length(Class_Indices);
			
			set(P.GUI_Handles.Control_Panel_Objects(3,4),'Items',{'Not Normalized'},'ItemsData',1);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Dorsal-Ventral Merged','Orders Merged','Pie Chart'},'ItemsData',1:4); % ,'All Merged'});
			
			if(P.GUI_Handles.Control_Panel_Objects(2,1).Value) % Apply projection correction.
				Field_1_Name = 'Curvature';
				Field_2_Name = 'Length_Corrected';
			else
				Field_1_Name = 'Curvature';
				Field_2_Name = 'Length';
			end
			
			Ng = length(Workspace_Set);
			for g=1:Ng
				M{g} = zeros(length(Class_Indices) , length(Workspace_Set{g}) , 2); % Class x workspace x dorsal-ventral.
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					for o=1:length(Class_Indices)
						f_D = find([Data(ww).Points.Midline_Distance] >= 0 & [Data(ww).Points.Segment_Class] == Class_Indices(o)); % Dorsal AND Menorah order o.
						f_V = find([Data(ww).Points.Midline_Distance] <= 0 & [Data(ww).Points.Segment_Class] == Class_Indices(o)); % Ventral AND Menorah order o.
						
						% Weighted average of point curvature (weighted by rectangle length):
						C_D = [Data(ww).Points(f_D).(Field_1_Name)];
						C_V = [Data(ww).Points(f_V).(Field_1_Name)];
						
						C_D(C_D < Curvature_Min_Max(1) | C_D > Curvature_Min_Max(2)) = nan;
						C_V(C_V < Curvature_Min_Max(1) | C_V > Curvature_Min_Max(2)) = nan;
						
						M{g}(o,w,1) = nansum(C_D .* [Data(ww).Points(f_D).(Field_2_Name)]) ./ nansum([Data(ww).Points(f_D).(Field_2_Name)]);
						M{g}(o,w,2) = nansum(C_V .* [Data(ww).Points(f_V).(Field_2_Name)]) ./ nansum([Data(ww).Points(f_V).(Field_2_Name)]);
					end
				end
			end
			
			CM = lines(Ng);
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
				case 1 % All classes, dorsal and ventral separated.
					for g=1:Ng
						B_D(:,g) = mean(M{g}(:,:,1),2); % Average across animals (columns). Rows correspond to Menorah orders.
						B_V(:,g) = -mean(M{g}(:,:,2),2); % ".
					end
					H_D = bar(Ax1,1:Max_PVD_Orders,B_D,0.8,'hist','FaceColor','flat');
					hold(Ax1,'on');
					H_V = bar(Ax1,1:Max_PVD_Orders,B_V,0.8,'hist','FaceColor','flat');
					
					for g=1:length(Workspace_Set)
						H_D(g).FaceColor = CM(g,:); % Class_Colors(o,:);
						H_V(g).FaceColor = CM(g,:); % Class_Colors(o,:);
						
						errorbar(Ax1,mean(H_D(g).XData,1),B_D(:,g),std(M{g}(:,:,1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						errorbar(Ax1,mean(H_V(g).XData,1),B_V(:,g),std(M{g}(:,:,2),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					% ylim(Ax1,YLIM);
					set(Ax1,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices,'TickLabelInterpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
					xlabel(Ax1,['$\mathrm{Class}$'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					ylabel(Ax1,'$\mathrm{Mean \; Curvature \; [\mu m ^{-1}]}$','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					
					legend(Ax1,Groups,'Interpreter','Latex');
					grid(Ax1,'on');
					
					if(g > 1)
						disp(['Mean curvature per Menorah Order - Result:']);
						for o=1:Max_PVD_Orders
							[PVal_D,Test_Name_D] = Stat_Test(M{1}(o,:,1),M{2}(o,:,1)); % Dorsal length of order Class_Indices(o).
							[PVal_V,Test_Name_V] = Stat_Test(M{1}(o,:,2),M{2}(o,:,2)); % Ventral length of order Class_Indices(o).
							
							disp(['Menorah Order = ',num2str(Class_Indices(o)),' (D): ','; P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
							disp(['Menorah Order = ',num2str(Class_Indices(o)),' (V): ','; P-Value = ',num2str(PVal_V),' (',Test_Name_V,')']);
						end
					end
					set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')));
				case 2 % Dorsal-ventral merged.
					for g=1:Ng
						B_DV(:,g) = mean(nanmean(M{g},3),2); % Average dorsal-ventral, and then average across animals.
					end
					H_DV = bar(Ax1,1:Max_PVD_Orders,B_DV,0.8,'hist','FaceColor','flat');
					hold(Ax1,'on');
					for g=1:Ng
						H_DV(g).FaceColor = CM(g,:); % H_DV.CData(o,:) = Class_Colors(o,:);
						
						Xm = mean(H_DV(g).XData,1);
						
						errorbar(Ax1,Xm,B_DV(:,g),std(nanmean(M{g},3),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						
						if(P.GUI_Handles.Control_Panel_Objects(3,1).Value) % Plot data points.
							DV_Mean = nanmean(M{g},3);
							for o=1:length(Class_Indices)
								scatter(Ax1,Xm(o).*ones(1,size(DV_Mean,2)),DV_Mean(o,:),10,[0.2,0.2,0.2],'filled','jitter','on','jitterAmount',0.2);
							end
						end
					end
					
					if(g == 1)
						disp(['Mean curvature per Menorah Order - Result:']);
						for o1=1:Max_PVD_Orders-1
							for o2=o1+1:Max_PVD_Orders
								[PVal_D,Test_Name_D] = Stat_Test(M{1}(o1,:,1),M{1}(o2,:,1)); % Dorsal of orders o1 & o2.
								[PVal_V,Test_Name_V] = Stat_Test(M{1}(o1,:,2),M{1}(o2,:,2)); % Ventral ...".
								[PVal_DV,Test_Name_DV] = Stat_Test(nanmean(M{1}(o1,:,:),3),nanmean(M{1}(o2,:,:),3)); % Ventral ...".
								
								disp(['Menorah Order = ',num2str(Class_Indices([o1 o2])),' (D): ','P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
								disp(['Menorah Order = ',num2str(Class_Indices([o1 o2])),' (V): ','P-Value = ',num2str(PVal_V),' (',Test_Name_V,')']);
								disp(['Menorah Order = ',num2str(Class_Indices([o1 o2])),' (D+V): ','P-Value = ',num2str(PVal_DV),' (',Test_Name_DV,')']);
							end
						end
					else
						disp(['Mean curvature per Menorah Order - Result:']);
						for o=1:Max_PVD_Orders
							[PVal_DV,Test_Name_DV] = Stat_Test(nanmean(M{1}(o,:,:),3),nanmean(M{2}(o,:,:),3)); % Dorsal length of order Class_Indices(o).
							disp(['Menorah Order = ',num2str(Class_Indices(o)),': ','; P-Value = ',num2str(PVal_DV),' (',Test_Name_DV,')']);
						end
					end
					
					set(Ax1,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
					% set(Ax1,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices,'TickLabelInterpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
					
					xlabel(Ax1,'Class','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize); % ,'interpreter','Latex'
					ylabel(Ax1,['Mean Curvature [',char(181),'m^{-1}]'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					
					legend(Ax1,Groups);
					grid(Ax1,'on');
					
				case 3 % Total length (all classes merged).
					%{
					for g=1:Ng
						B_D(:,g) = mean(sum(sum(M{g}(:,:,1),1),3),2);
						% B_V(:,g) = -mean(sum(M{g}(:,:,2),1),2);
					end
					H_D = bar(1:Ng,B_D,0.8,'FaceColor','flat');
					hold on;
					% H_V = bar(1:length(Workspace_Set),B_V,0.8,'FaceColor','flat');
					
					for g=1:length(Workspace_Set)
						H_D.CData(g,:) = CM(g,:); % Class_Colors(o,:);
						% H_V.CData(g,:) = CM(g,:); % Class_Colors(o,:);
						
						errorbar(g,B_D(:,g),std(sum(sum(M{g}(:,:,1),1),3),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						% errorbar(g,B_V(:,g),std(sum(M{g}(:,:,2),1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					disp(['Total Neuronal Length - Result:']);
					Total_Length_1 = sum(sum(M{1}(:,:,:),1),3);
					Total_Length_2 = sum(sum(M{2}(:,:,:),1),3);
					[PVal_D,Test_Name_D] = Stat_Test(Total_Length_1,Total_Length_2); % Summing up the classes and then dorsal-ventral.
					disp(['P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
					
					disp(['Total Length Ratio = ',num2str(mean(Total_Length_2) ./ mean(Total_Length_1))]);
					
					switch GP.Handles.Normalization_List.Value
						case 1
							ylabel('$$Neuronal \; Length \; [{\mu}m]$$','Interpreter','Latex');
						case 2
							ylabel('$$\frac{Neuronal \; Length}{Total \; Length}$$','Interpreter','Latex');
					end
					
					ylim([0,3.*YLIM(2)]); % ylim(3*YLIM);
					set(gca,'FontSize',FontSize_1);
					set(gca,'XTick',1:length(Workspace_Set),'XTickLabels',Groups,'TickLabelInterpreter','Latex'); % ,'YTickLabels',abs(get(gca,'YTick'))
					grid on;
					%}
				case 4 % Pie chart.
					%{
					for g=1:length(Workspace_Set)
						subplot(1,Ng,g);
						H = pie( mean(sum(M{g},3),2) ); % Sum dorsal ventral, and average across animals.
						axis equal;
						set(gca,'XTick',[],'YTick',[],'TickLabelInterpreter','Latex','FontSize',FontSize_1);
						set(findobj(H,'type','text'),'fontsize',FontSize_1);
					end
					%}
			end
			% set(gca,'unit','normalize','position',[0.098,0.15,0.89,0.82]);
			
		case 'Curvature Distribution'
			
			set(P.GUI_Handles.Control_Panel_Objects(3,4),'Items',{'Not Normalized'},'ItemsData',1);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default'},'ItemsData',1);
			
			Curvature_Min_Max = [0,0.5]; % [0,0.5], [0,500]
			dx = 0.005; % 0.005, 2.
			Field_1_Name = 'Curvature';
			Field_2_Name = 'Midline_Orientation_Corrected'; % Length_Corrected
			
			for g=1:length(Workspace_Set)
				X{g} = [];
				Y{g} = [];
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					if(0)
						Fw = find([Data(ww).Points.Segment_Class] == 3);
						Cw = [Data(ww).Points(Fw).(Field_1_Name)];
						Lw = [Data(ww).Points(Fw).(Field_2_Name)];
					else
						Cw = [Data(ww).Points.(Field_1_Name)];
						Lw = [Data(ww).Points.(Field_2_Name)];
						% Cw = rescale(Cw,Curvature_Min_Max(1),Curvature_Min_Max(2),'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2));
						% Cw(Cw < Curvature_Min_Max(1) | Cw > Curvature_Min_Max(2)) = nan;
					end
					
					X{g} = [X{g},Cw];
					Y{g} = [Y{g},Lw];
				end
				
				histogram(Ax1,X{g},Curvature_Min_Max(1):dx:Curvature_Min_Max(2),'normalization','probability');
				%%% histogram(1./X{g},Curvature_Min_Max(1):dx:Curvature_Min_Max(2),'normalization','probability');
				
				%{
				subplot(1,2,g); histogram2(X{g},Y{g}*180/pi,Curvature_Min_Max(1):dx:Curvature_Min_Max(2),0:2:90,'FaceColor','flat','normalization','probability'); % scatter(X{1},Y{1},1,'b','filled');
				set(gca,'YTick',0:30:90,'XTick',0:0.5:0.5);
				zlim([0,0.01]);
				set(gca,'FontSize',18,'TickLabelInterpreter','Latex');
				%}
				
				xlim(Ax1,Curvature_Min_Max);
				% ylim([0,0.07]);
				
				set(Ax1,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
				xlabel(Ax1,['Mean Curvature [\mum^{-1}]'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				ylabel(Ax1,'Probability','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				
				% legend(Groups,'Interpreter','Latex');
				% grid on;
			end
			
			% set(gca,'unit','normalize','position',[0.098,0.2,0.87,0.76]);
		case 'Mean Curvature Of Terminal Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations{1} = @(x) (x==1);
			Var_Fields = {'Curvature'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Squared Curvature (1/(\mum)^2)';
			Title = 'Mean Curvature Of Terminal Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		case 'Max Curvature Of Terminal Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.05); % The curvature of a segment has to be positive.
			Filter_Operations{1} = @(x) (x==1);
			Var_Fields = {'Max_Curvature'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Squared Curvature (1/(\mum)^2)';
			Title = 'Max Curvature Of Terminal Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		
		case {'Radial Distance of All Points','Radial Distance of 3-Way Junctions','Radial Distance of Tips','Radial Distance of All Points - Second Moment','Angular Coordinate of All Points','Angular Coordinate of All Points - Second Moment',...
			'Angular Coordinate of Junctions','Angular Coordinate of Tips'}
			
			set(P.GUI_Handles.Control_Panel_Objects(2,4),'Items',{'Not Normalized','Total Length','Midline Length'},'ItemsData',1:3);
			
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Dorsal-Ventral Merged','Color Gradient'},'ItemsData',1:3);
			
			if(P.GUI_Handles.Control_Panel_Objects(2,1).Value) % Apply projection correction.
				% Field_1_Name = 'Midline_Orientation_Corrected';
				Field_2_Name = 'Length_Corrected';
			else
				% Field_1_Name = 'Midline_Orientation';
				Field_2_Name = 'Length';
			end
			
			switch(Label)
				case {'Radial Distance of All Points','Radial Distance of All Points - Second Moment'}
					if(~isequal(Label,P.GUI_Handles.Buttons(3,1).UserData)) % If the previous plot was different.
						set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[0.01,0.11],'Step',0.01,'Value',0.02,'Tooltip','');
					end
					Bin_Min = -1;
					Bin_Max = 1;
				case {'Angular Coordinate of All Points','Angular Coordinate of All Points - Second Moment','Angular Coordinate of Tips','Angular Coordinate of Junctions'}
					if(~isequal(Label,P.GUI_Handles.Buttons(3,1).UserData)) % If the previous plot was different.
						set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[1,30],'Step',1,'Value',2,'Tooltip','');
					end
					Bin_Min = -pi/2; % Radians.
					Bin_Max = pi/2; % Radians.
			end
			
			BinSize = P.GUI_Handles.Control_Panel_Objects(1,4).Value .* pi ./ 180; % Degrees to radians.
			Edges = Bin_Min:BinSize:Bin_Max;
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
			switch(Label)
				case {'Radial Distance of All Points','Radial Distance of All Points - Second Moment'}
					Field_1_Name = 'Radial_Distance_Corrected';
					Vertex_Order_Func = @(X) find(X);
					Weigh_by_Length = 1;
					Y_Label = 'Neuronal Length';
				case {'Angular Coordinate of All Points','Angular Coordinate of All Points - Second Moment'}
					Field_1_Name = 'Angular_Coordinate';
					Vertex_Order_Func = @(X) find(X);
					Weigh_by_Length = 1;
					Y_Label = 'Neuronal Length}';
				case 'Radial Distance of Tips'
					Field_1_Name = 'Radial_Distance_Corrected';
					Vertex_Order = 1;
					Vertex_Order_Func = @(X) find(X == Vertex_Order);
					Weigh_by_Length = 0;
					Y_Label = 'Number of Tips';
				case 'Angular Coordinate of Tips'
					Field_1_Name = 'Angular_Coordinate';
					Vertex_Order = 1;
					Vertex_Order_Func = @(X) find(X == Vertex_Order);
					Weigh_by_Length = 0;
					Y_Label = 'Number of Tips';
				case 'Radial Distance of 3-Way Junctions'
					Field_1_Name = 'Radial_Distance_Corrected';
					Vertex_Order = 3;
					Vertex_Order_Func = @(X) find(X == Vertex_Order);
					Weigh_by_Length = 0;
					Y_Label = 'Number of Junctions';
				case 'Angular Coordinate of Junctions'
					Field_1_Name = 'Angular_Coordinate';
					Vertex_Order = 3;
					Vertex_Order_Func = @(X) find(X == Vertex_Order);
					Weigh_by_Length = 0;
					Y_Label = 'Number of Junctions';
			end
			
			Ng = length(Workspace_Set);
			
			for g=1:Ng
				X{g} = [];
				L{g} = [];
				Y{g} = nan(length(Workspace_Set{g}),length(xx));
				for w=1:length(Workspace_Set{g})
					pp = Workspace_Set{g}(w);
					
					Fx = Vertex_Order_Func([Data(pp).Points.Vertex_Order]);
					Xw = -[Data(pp).Points(Fx).(Field_1_Name)]; % Multiplying by (-1) to make ventral positive.
					
					if(Weigh_by_Length)
						Lw = [Data(pp).Points(Fx).(Field_2_Name)]; % Corresponding rectangle lengths. % Use this for weight = 1: ones(1,length(Xw)); % 
					else % Just count.
						Lw = ones(1,length(Fx)) ./ [Data(pp).Points(Fx).Vertex_Order]; % The weight of each vertex rectangle is 1 divided by the number of rectangles (the vertex order).
					end
					
					switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
						case 1
							Norm_Value = 1;
						case 2 % Total length.
							Norm_Value = nansum([Data(pp).Points.(Field_2_Name)]);
						case 3 % Midline length.
							Norm_Value = Data(pp).Axes.Axis_0(end).Arc_Length;
					end % TODO: For each point check if D/V and save both radii.
					
					Lw = Lw ./ Norm_Value; % Normalization to total length. This affects to weigh both the bins in Y{g}(w,:) and ksdensity.
					
					% Bin the data:
					[Y{g}(w,:),~,Iw] = histcounts(Xw,Edges); % Iw is a vector of bin indices (in Y{g}(w,:)) corresponding to Xw values. % ,'Normalization','pdf'
					
					fw = find(Iw > 0 & Lw > 0);
					Lw = Lw(fw);
					Iw = Iw(fw);
					
					Y_L = accumarray([Iw,1:length(Edges)-1]',[Lw,zeros(1,length(Edges)-1)])'; % Y_L is a vector of summed length (values of Lw) into bins corresponding to Y{g}(w,:). It is used to weigh the bins by their total neuron length.
					Y{g}(w,:) = Y_L; % Now the height of the bins is neuronal length.
					
					% Finally, apply pdf:
					% Y{g}(w,:) = Y{g}(w,:);
				end
			end
			
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value)
				case 2 % Merge dorsal ventral.
					for g=1:Ng
						Y{g} = abs(Y{g});
						Edges = 0:BinSize:Edges(end);
					end
			end
			
			if(contains(Label,'Moment')) % Moment of inertia.
				MoI = cell(1,Ng);
				for g=1:Ng
					MoI{g} = sum(Y{g} .* (xx.^2),2); % disp(['Moment of Inertia = ',num2str(sum(N .* (xx.^2)))]);
					bar(Ax1,g,mean(MoI{g}));
					errorbar(Ax1,g,mean(MoI{g}),std(MoI{g}),'Color','k','LineWidth',2,'LineStyle','none');
				end
				set(gca,'XTick',1:Ng,'XTickLabels',Groups);
				ylabel('Moment of Inertia','Interpreter','Latex');
				grid(Ax1,'on');
				
				[PVal,Test_Name] = Stat_Test(MoI{1},MoI{2});
				disp(['Moment of Inertia Test Result:']);
				disp([Test_Name,': P-Value = ',num2str(PVal)]);
				
				set(gca,'FontSize',FontSize_1/2);
			else % Histogram of midline distances.
				
				switch(Ng)
					case 1 % If there is only one group, show as a histogram.
						H{1} = bar(Ax1,xx,nanmean(Y{1},1),1,'FaceColor','flat'); % ,'EdgeColor','none');
						
						if(P.GUI_Handles.Control_Panel_Objects(4,4).Value == 3) % Color gradient.
							L_D = find(xx >= 0); % # of bars.
							L_V = find(xx < 0); % # of bars.
							CM = hsv(max(length(L_D),length(L_V)));
							H{1}.CData(L_D,:) = CM(1:length(L_D),:);
							H{1}.CData(L_V,:) = flipud(CM(1:length(L_V),:));
						end
					otherwise % If there are multiple groups, show as an area plot.
						CM = lines(Ng);
						for g=1:Ng
							bar(Ax1,xx,mean(Y{g},1),1,'FaceColor','flat'); % ,'EdgeColor','none');
							hold(Ax1,'on');
							switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
								% case {3,5} % PDF.
									% TODO: this uses all values together, while other places average across animals.
									% [fk{g},xk{g}] = ksdensity(X{g},linspace(Edges(1),Edges(end),1000),'Weights',L{g},'Bandwidth',0.05); % ,'NumPoints',10. [Edges(1),xx,Edges(end)]
								otherwise
									Fit_Object = fit(xx',nanmean(Y{g},1)','smoothingspline','smoothingparam',0.99999);
									xk{g} = linspace(Edges(1),Edges(end),1000);
									fk{g} = Fit_Object(xk{g});
							end
							% H{g} = area(xk{g},fk{g},'FaceColor',CM(g,:),'FaceAlpha',0.5); % 1./(Ng-g+1)./1.5
							% hold(Ax1,'on');
						end
						for g=1:Ng
							plot(Ax1,xk{g},fk{g},'LineWidth',2,'Color',CM(g,:));
						end
						% legend(Groups,'Interpreter','Latex');
				end
				
				set(Ax1,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
				
				if(P.GUI_Handles.Control_Panel_Objects(1,5).Value > 1)
					y_scale = num2str(P.GUI_Handles.Control_Panel_Objects(1,5).Value);
				else
					y_scale = '';
				end
				
				switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
					case 1
						xlabel(Ax1,[char(981),' (azimuthal position) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						if(Weigh_by_Length)
							ylabel(Ax1,['Neuronal Length [',y_scale,char(181),'m]'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						else
							ylabel(Ax1,Y_Label,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						end
					case 2 % Total length.
						xlabel(Ax1,'$\mathrm{\phi} \; [^{\circ}]$','Interpreter','Latex');
						ylabel(Ax1,['$\frac{',Y_Label,'}{\mathrm{Total \; Length}}$'],'Interpreter','Latex');
					case 3 % Midline length.
						xlabel(Ax1,'$\mathrm{\phi} \; [^{\circ}]$','Interpreter','Latex');
						ylabel(Ax1,['$\frac{',Y_Label,'}{\mathrm{Midline \; Length}}$'],'Interpreter','Latex');
					case 5
						xlabel(Ax1,'$\phi \; [^{\circ}]$','Interpreter','Latex');
						ylabel(Ax1,['$\frac{',Y_Label,'}$'],'Interpreter','Latex');
						% set(Ax1,'position',[0.13,0.1490,0.85,0.7760]); % set(gca,'position',[0.1,0.1490,0.87,0.7760]);
				end
				set(Ax1,'XTick',-pi/2:pi/4:pi/2,'YTick',0:100:max(get(Ax1,'YTick')));
				drawnow;
				set(Ax1,'XTickLabels',get(Ax1,'xtick') .* 180 ./ pi,'YTickLabels',get(Ax1,'YTick') ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
				xlim(Ax1,[Edges(1),Edges(end)]);
				Py = get(Ax1,'ylim');
				ylim(Ax1,[0,Py(2)]);
				grid(Ax1,'on');
			end
		
		case 'Menorah Orders Classification'
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Contour Levels','Surface'},'ItemsData',1:3);
			Clusters_Struct = Map_Branches_Classes(P,Ax1);
		case 'Distribution of Mean Squared Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Curvature'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			X_Label = 'Squared Curvature (1/(\mum)^2)';
			Y_Label = 'Count';
			Title = 'Mean of Squared Curvature of Segments';
			%
			X_Min_Max = [0,0.1];
			BinSize = 0.005 .* GP.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Max Segment Curvature per Menorah Order'
			Class_Indices = 1:4;
			Curvature_Min_Max = [0,0.3];
			Max_PVD_Orders = length(Class_Indices);
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized'});
			set(GP.Handles.Plot_Type_List,'String',{'Default'});
			
			if(GP.Handles.Projection_Correction_Checkbox.Value) % Apply projection correction.
				Field_1_Name = 'Curvature';
				Field_2_Name = 'Length_Corrected';
			else
				Field_1_Name = 'Curvature';
				Field_2_Name = 'Length';
			end
			
			Ng = length(Workspace_Set);
			for g=1:Ng
				M{g} = zeros(length(Class_Indices) , length(Workspace_Set{g})); % Class x workspace x dorsal-ventral.
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					Cw = cell(1,Max_PVD_Orders);
					for s=1:numel(GP.Workspace(ww).Workspace.Segments)
						if(~isempty(GP.Workspace(ww).Workspace.Segments(s).Rectangles))
							C = [GP.Workspace(ww).Workspace.Segments(s).Rectangles.Curvature];
							C(C < Curvature_Min_Max(1) | C > Curvature_Min_Max(2)) = nan;
							C = max(C);
							o = find(Class_Indices == GP.Workspace(ww).Workspace.Segments(s).Class);
							if(~isnan(o))
								Cw{o} = [Cw{o},C];
							end
						end
					end
					for o=1:Max_PVD_Orders
						M{g}(o,w) = nanmean(Cw{o});
					end
				end
			end
			
			CM = lines(Ng);
			for g=1:Ng
				B(:,g) = nanmean(M{g},2); % Average across animals.
			end
			H = bar(1:Max_PVD_Orders,B,0.8,'hist','FaceColor','flat');
			for g=1:length(Workspace_Set)
				H(g).FaceColor = CM(g,:);
				errorbar(mean(H(g).XData,1),B(:,g),nanstd(M{g},0,2)','Color','k','LineWidth',2,'LineStyle','none');
			end
			
			if(g == 1)
				disp(['Max segment curvature per Menorah Order - Result:']);
				for o1=1:Max_PVD_Orders-1
					for o2=o1+1:Max_PVD_Orders
						[PVal_DV,Test_Name_DV] = Stat_Test(M{1}(o1,:),M{1}(o2,:)); % Ventral ...".
						disp(['Menorah Order = ',num2str(Class_Indices([o1 o2])),' (D+V): ','P-Value = ',num2str(PVal_DV),' (',Test_Name_DV,')']);
					end
				end
			else
				disp(['Mean curvature per Menorah Order - Result:']);
				for o=1:Max_PVD_Orders
					[PVal_DV,Test_Name_DV] = Stat_Test(M{1}(o,:),M{2}(o,:)); % Dorsal length of order Class_Indices(o).
					disp(['Menorah Order = ',num2str(Class_Indices(o)),': ','; P-Value = ',num2str(PVal_DV),' (',Test_Name_DV,')']);
				end
			end
			
			xlabel(['Menorah Order'],'interpreter','Latex');
			ylabel('$$Mean \; Curvature \; (\frac{1}{{\mu}m})$$','Interpreter','Latex');
			% ylim([0,2.*YLIM(2)]);
			set(gca,'FontSize',FontSize_1);
			legend(Groups,'Interpreter','Latex');
			grid on;
			set(gca,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices,'TickLabelInterpreter','Latex');
		case 'Signed Midline Orientation of Junction Rectangles'
			
			% First show the distribution of class-2 and class-4 midline orientation, with respect to AP (A is positive).
				% I'm expecting the two classes to both give symmetrical distribution around 90.
			
			% Then show the distribution of class-1 and class-3 midline orientation, with respect to R (away from midline is positive).
				% I'm expecting the two classes to give mirror image distributions, both with a peak at 0 (parallel to midline).
			
		case 'Distribution of the Difference between Vertex and End2End Angles'
			Var_Operations{1} = @(x) x(x>0).*180./pi; % Angle difference in degrees (this values is supposed to always be positive: max(a1,a2)-min(a1,a2) ; a1,a2=[0,2.*pi]).
			Filter_Operations{1} = @(x) (x >= 0); % Both terminals and non-terminals.
			Var_Fields = {'End2End_Vertex_Angle_Diffs'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			X_Label = ['Angle (',char(176),')'];
			Y_Label = 'Count';
			Title = 'Difference between Vertex and End2End Angles';
			%
			X_Min_Max = [0,180];
			BinSize = 5 .* GP.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
		
		case 'Neuronal Length per Menorah Order'
			
			Class_Indices = 1:length(P.GUI_Handles.Class_Colors);
			colormap(Ax1,P.GUI_Handles.Class_Colors);
			Max_PVD_Orders = length(P.GUI_Handles.Class_Colors);
			
			% P.GUI_Handles.Control_Panel_Objects(4,1).Value
			set(P.GUI_Handles.Control_Panel_Objects(2,4),'Items',{'Not Normalized','Normalized to Midline Length','Normalized to Total Length'},'ItemsData',1:3);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Dorsal-Ventral Merged','Total Length (Orders Merged)','Pie Chart'},'ItemsData',1:4); % ,'All Merged'});
			
			if(P.GUI_Handles.Control_Panel_Objects(2,1).Value) % Apply projection correction.
				Field_1_Name = 'Length_Corrected';
			else
				Field_1_Name = 'Length';
			end
			
			switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
				case 1
					
					if(P.GUI_Handles.Control_Panel_Objects(1,5).Value > 1)
						xy_scale = num2str(P.GUI_Handles.Control_Panel_Objects(1,5).Value);
					else
						xy_scale = '';
					end
					
					Y_Name = ['Neuronal Length [',xy_scale,char(181),'m]'];
				case 2
					Y_Name = 'Neuronal Length / Midline Length'; % '${\frac{Neuronal \; Length}{Midline \; Length}}$';
					% Y_Name = '$\frac{Neuronal Length}{Midline Length}$';
				case 3
					Y_Name = '^{Neuronal Length}/_{Total Length}'; % '$\mathrm{\frac{Neuronal \; Length}{Total \; Length}}$';
			end
			
			Ng = length(Workspace_Set);
			for g=1:Ng
				M{g} = zeros(length(Class_Indices) , length(Workspace_Set{g}) , 2); % Class x workspace x dorsal-ventral.
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value)
						case 1
							Normalization_Length = 1;
							YLIM = [-1500,1500];
						case 2 % Normalized to Midline Length.
							Normalization_Length = Data(ww).Axes.Axis_0(end).Arc_Length;
							YLIM = [-2,2];
						case 3 % Normalized to Total Length.
							Normalization_Length = sum([Data(ww).Points.(Field_1_Name)]);
							YLIM = [-1,1];
					end
					
					for o=1:length(Class_Indices)
						f_D = find([Data(ww).Points.Midline_Distance] >= 0 & [Data(ww).Points.Segment_Class] == Class_Indices(o)); % Dorsal AND Menorah order o.
						f_V = find([Data(ww).Points.Midline_Distance] < 0 & [Data(ww).Points.Segment_Class] == Class_Indices(o)); % Ventral AND Menorah order o.
						
						M{g}(o,w,1) = nansum([Data(ww).Points(f_D).(Field_1_Name)]) ./ Normalization_Length; % Dorsal.
						M{g}(o,w,2) = nansum([Data(ww).Points(f_V).(Field_1_Name)]) ./ Normalization_Length; % Ventral.
					end
				end
			end
			
			CM = lines(Ng);
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
				case 1 % All classes, dorsal and ventral separated.
					for g=1:Ng
						B_D(:,g) = mean(M{g}(:,:,1),2); % Average across animals (columns). Rows correspond to Menorah orders.
						B_V(:,g) = -mean(M{g}(:,:,2),2); % ".
					end
					H_D = bar(Ax1,1:Max_PVD_Orders,B_D,BarWidth,'hist','FaceColor','flat');
					hold(Ax1,'on');
					H_V = bar(Ax1,1:Max_PVD_Orders,B_V,BarWidth,'hist','FaceColor','flat');
					
					for g=1:length(Workspace_Set)
						H_D(g).FaceColor = CM(g,:); % Class_Colors(o,:);
						H_V(g).FaceColor = CM(g,:); % Class_Colors(o,:);
						
						errorbar(Ax1,mean(H_D(g).XData,1),B_D(:,g),std(M{g}(:,:,1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						errorbar(Ax1,mean(H_V(g).XData,1),B_V(:,g),std(M{g}(:,:,2),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					% ylim(Ax1,YLIM);
					legend(Ax1,Groups);
					grid(Ax1,'on');
					
					set(Ax1,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
					xlabel(Ax1,'Class','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					ylabel(Ax1,Y_Name,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					
					if(Ng > 1)
						disp(['Neuronal Length per Menorah Order - Result:']);
						for o=1:Max_PVD_Orders
							[PVal_D,Test_Name_D] = Stat_Test(M{1}(o,:,1),M{2}(o,:,1)); % Dorsal length of order Class_Indices(o).
							[PVal_V,Test_Name_V] = Stat_Test(M{1}(o,:,2),M{2}(o,:,2)); % Ventral length of order Class_Indices(o).
							
							disp(['Menorah Order = ',num2str(Class_Indices(o)),' (D): ','P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
							disp(['Menorah Order = ',num2str(Class_Indices(o)),' (V): ','P-Value = ',num2str(PVal_V),' (',Test_Name_V,')']);
						end
					end
				case 2 % Dorsal-ventral merged.
					for g=1:Ng
						B_DV(:,g) = mean(sum(M{g},3),2);
					end
					H_DV = bar(Ax1,1:Max_PVD_Orders,B_DV,BarWidth,'hist','FaceColor','flat');
					hold(Ax1,'on');
					for g=1:length(Workspace_Set)
						H_DV(g).FaceColor = CM(g,:); % H_DV.CData(o,:) = Class_Colors(o,:);
						errorbar(Ax1,mean(H_DV(g).XData,1),B_DV(:,g),std(sum(M{g},3),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					ylim(Ax1,[0,Ax1.YLim(2)]); % ylim(Ax1,[0,2.*YLIM(2)]);
					
					legend(Ax1,Groups);
					grid(Ax1,'on');
					
					set(Ax1,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize); % ,'TickLabelInterpreter','Latex'
					xlabel(Ax1,'Class','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					ylabel(Ax1,Y_Name,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					
					set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')) ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
					
					if(Ng > 1)
						disp(['Stats (D-V merged):']);
						disp(['WT:']);
						for o=2:Max_PVD_Orders % Compare all orders to order 1 in wt.
							[PVal_D,Test_Name_D] = Stat_Test(nansum(M{1}(1,:,:),3),nansum(M{1}(o,:,:),3)); % Sum up across D-V.
							disp(['P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
						end
						disp(['WT-Mutant:']);
						for o=1:Max_PVD_Orders % Compare each order between wt and mutant.
							[PVal_D,Test_Name_D] = Stat_Test(nansum(M{1}(o,:,:),3),nansum(M{2}(o,:,:),3)); % Sum up across D-V.
							disp(['P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
						end
					end
				case 3 % Total length (all classes merged).
					for g=1:Ng
						B_DV(:,g) = mean(sum(sum(M{g},1),3),2); % Sum orders, then sum DV, then average projects.
						% B_D(:,g) = -mean(sum(M{g}(:,:,1),1),2);
						% B_V(:,g) = -mean(sum(M{g}(:,:,2),1),2);
					end
					H_D = bar(Ax1,1:Ng,B_DV,BarWidth,'FaceColor','flat');
					hold(Ax1,'on');
					% H_V = bar(Ax1,1:length(Workspace_Set),B_V,0.8,'FaceColor','flat');
					
					for g=1:length(Workspace_Set)
						H_D.CData(g,:) = CM(g,:); % Class_Colors(o,:);
						% H_V.CData(g,:) = CM(g,:); % Class_Colors(o,:);
						
						errorbar(Ax1,g,B_DV(:,g),std(sum(sum(M{g},1),3),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						% errorbar(g,B_V(:,g),std(sum(M{g}(:,:,2),1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					if(Ng > 1)
						disp(['Total Neuronal Length - Result:']);
						Total_Length_1 = nansum(sum(M{1},1),3); % Sum up across menorah orders and D-V.
						Total_Length_2 = nansum(sum(M{2},1),3); % ".
						[PVal_D,Test_Name_D] = Stat_Test(Total_Length_1,Total_Length_2); % Summing up the classes and then dorsal-ventral.
						disp(['P-Value = ',num2str(PVal_D),' (',Test_Name_D,')']);
						
						disp(['Total Length Ratio = ',num2str(mean(Total_Length_2) ./ mean(Total_Length_1))]);
						disp(['Total Length STDs (1) = ',num2str(mean(Total_Length_1)),'um +\- ',num2str(std(sum(sum(M{1}(:,:,1),1),3),0,2))]);
						disp(['Total Length STDs (1) = ',num2str(mean(Total_Length_2)),'um +\- ',num2str(std(sum(sum(M{2}(:,:,1),1),3),0,2))]);
					end
					
					xlim(Ax1,[0.5,Ng+0.5]);
					% ylim(Ax1,[0,Ax1.YLim(2)]); % ylim(3*YLIM);
					set(Ax1,'XTick',1:length(Workspace_Set),'XTickLabels',Groups,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
					ylabel(Ax1,Y_Name,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')) ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
					
					grid(Ax1,'on');
				case 4 % Pie chart.
					% set(0,'defaulttextInterpreter','Latex');
					% H = nan(Ng,2*length(Class_Indices));
					for g=1:Ng
						if(P.GUI_Handles.Control_Panel_Objects(4,1).Value)
							Ax1 = subplot(1,Ng,g,'Parent',gcf);
						else
							Ax1 = subplot(1,Ng,g,'Parent',P.GUI_Handles.Main_Panel_1);
						end
						
						V = mean(sum(M{g},3),2);
						
						H = pie(Ax1,V,'%.2f%%'); % Sum up dorsal ventral, and average across animals.
						
						colormap(Ax1,P.GUI_Handles.Class_Colors);
						
						axis(Ax1,'equal');
						
						set(Ax1,'XTick',[],'YTick',[],'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize); % set(Ax1,'XTick',[],'YTick',[],'TickLabelInterpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
						
						set(findobj(H,'type','text'),'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
						for i=1:length(H)
							if(strcmp(H(i).Type,'text'))
								H(i).String = [H(i).String(1:end-1),'%'];
							end
						end
                        
					end
					% assignin('base','H',H);
			end
			% set(Ax1,'TickLabelInterpreter','Latex');
			drawnow;
			% set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')));
			% set(gca,'unit','normalize','position',[0.098,0.15,0.89,0.82]);
		
		case 'Midline Density - Neuronal Length'
			% profile clear; profile on;
			
			% Workspace_Set = Workspace_Set{1};
			Ng = length(Workspace_Set);
			
			Max_Midline_Length = 900;
			
			Class_Indices = 1:length(P.GUI_Handles.Class_Colors);
			Max_PVD_Orders = length(Class_Indices);
			
			set(P.GUI_Handles.Control_Panel_Objects(2,4),'Items',{'Not Normalized','Normalized to Midline Length (X)','Normalized to Total Length (Y)','Normalized to Midline and Total Length'},'ItemsData',1:4);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Dorsal-Ventral Merged','Orders Merged','All Merged'},'ItemsData',1:4);
			
			if(P.GUI_Handles.Control_Panel_Objects(2,1).Value) % Apply projection correction.
				Field_1_Name = 'Length_Corrected';
			else
				Field_1_Name = 'Length';
			end
			
			switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value)
				case {1,3}
					if(~isequal(Label,P.GUI_Handles.Buttons(3,1).UserData)) % If the previous plot was different.
						set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[10,110],'Value',50);
						set(P.GUI_Handles.Control_Panel_Objects(1,5),'Value',1,'Limits',[1,100]);
						% set(GP.Handles.Analysis.Slider,'Min',10,'Max',110,'Value',50,'SliderStep',[0.01,0.1]);
					end
					Edges = 0:P.GUI_Handles.Control_Panel_Objects(1,4).Value:Max_Midline_Length;
				case {2,4} % Normalized to Midline Length.
					if(~isequal(Label,P.GUI_Handles.Buttons(3,1).UserData)) % If the previous plot was different.
						set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[0.02,12],'Value',0.05);
						% set(GP.Handles.Analysis.Slider,'Min',0.02,'Max',.12,'Value',0.05,'SliderStep',[0.01,0.1]);
					end
					Edges = 0:P.GUI_Handles.Control_Panel_Objects(1,4).Value:1;
			end
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
			% set(P.GUI_Handles.Control_Panel_Objects(1,5),'Value',P.GUI_Handles.Control_Panel_Objects(1,4).Value);
			
			for g=1:Ng
				N_D{g} = nan(Max_PVD_Orders,length(xx),length(Workspace_Set{g}));
				N_V{g} = nan(Max_PVD_Orders,length(xx),length(Workspace_Set{g}));
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value)
						case 1
							Midline_Length = 1;
							Total_Length = 1;
						case 2 % Normalized to Midline Length.
							Midline_Length = Data(ww).Axes.Axis_0(end).Arc_Length;
							Total_Length = 1;
						case 3 % Normalized to Total Length.
							Midline_Length = 1;
							Total_Length = sum([Data(ww).Points.(Field_1_Name)]);
						case 4 % Normalized to both Midline and Total Length.
							Midline_Length = Data(ww).Axes.Axis_0(end).Arc_Length;
							Total_Length = sum([Data(ww).Points.(Field_1_Name)]);
					end
					
					for o=1:Max_PVD_Orders
						
						% Fs = find([Data(ww).Points.Segment_Index] == Data(ww).Segments(Fo(s)).Segment_Index);
						f_D = find([Data(ww).Points.Midline_Distance] <= 0 & [Data(ww).Points.Segment_Class] == Class_Indices(o)); % Find all dorsal points that belong to segment s.
						f_V = find([Data(ww).Points.Midline_Distance] >= 0 & [Data(ww).Points.Segment_Class] == Class_Indices(o)); % Find all ventral points that belong to segment s.
						
						P_D = [Data(ww).Points(f_D).Axis_0_Position]; % A vector of midline position (arc-length) from the head (dorsal).
						L_D = [Data(ww).Points(f_D).(Field_1_Name)]; % A vector of rectangle lengths (dorsal side only) of class o.
						P_V = [Data(ww).Points(f_V).Axis_0_Position]; % A vector of midline position (arc-length) from the head (ventral).
						L_V = [Data(ww).Points(f_V).(Field_1_Name)]; % A vector of rectangle lengths (ventral side only) of class o.
						
						% Bin points by midline position, and then multiply by neuronal length:
						[N_D{g}(o,:,w),~,Iw_D] = histcounts(P_D ./ Midline_Length,Edges); % Iw is a vector of bin indices (in Y{g}(w,:)) corresponding to Xw values. % ,'Normalization','pdf'
						[N_V{g}(o,:,w),~,Iw_V] = histcounts(P_V ./ Midline_Length,Edges); % ".
						
						f_D = find(Iw_D > 0 & L_D > 0);
						f_V = find(Iw_V > 0 & L_V > 0);
						
						N_D{g}(o,:,w) = accumarray([Iw_D(f_D),1:length(Edges)-1]',[L_D(f_D) ./ Total_Length,zeros(1,length(Edges)-1)])'; % Bin heights converted to neuronal length. Y_L is a vector of summed length (values of Lw) into bins corresponding to Y{g}(w,:). It is used to weigh the bins by their total neuron length.
						N_V{g}(o,:,w) = accumarray([Iw_V(f_V),1:length(Edges)-1]',[L_V(f_V) ./ Total_Length,zeros(1,length(Edges)-1)])'; % ".
					end
				end
			end
			
			for g=1:Ng
				N_D{g} = mean(N_D{g},3); % Average all bins (preserving sub-classes) across animals.
				N_V{g} = mean(N_V{g},3); % ".
			end
			
			if(Ng == 1)
				H_D = bar(Ax1,xx,N_D{1}',1,'stacked','FaceColor','flat'); % ,'EdgeAlpha',0.
				hold(Ax1,'on');
				set(Ax1,'ColorOrderIndex',1);
				H_V = bar(Ax1,xx,-N_V{1}',1,'stacked','FaceColor','flat'); % histogram(X_V,Edges);
				
				if(1 || P.GUI_Handles.Control_Panel_Objects(4,4).Value == 2)
					L = size([H_D.CData],1); % # of bars.
					for o=1:Max_PVD_Orders
						H_D(o).CData = repmat(P.GUI_Handles.Class_Colors(o,:),L,1);
						H_V(o).CData = repmat(P.GUI_Handles.Class_Colors(o,:),L,1);
					end
				else
					legend(Ax1,{'Dorsal','Ventral'});
				end
				
				YL_D = max(sum(reshape([H_D(:).YData],[],Max_PVD_Orders),2));
				YL_V = min(sum(reshape([H_V(:).YData],[],Max_PVD_Orders),2));
				ylim(Ax1,round(max([-(1.25.*YL_V),1.25.*YL_D]),-2) .* [-1,1]);
				legend(Ax1,{'1','2','3','4'},'Orientation','horizontal');
			else
				CM = lines(Ng);
				for g=1:Ng
					Fit_Object_D = fit(xx',sum(N_D{g},1)','smoothingspline','smoothingparam',0.99999); % Sum over classes.
					Fit_Object_V = fit(xx',sum(N_V{g},1)','smoothingspline','smoothingparam',0.99999); % Sum over classes.
					
					xk{g} = linspace(Edges(1),Edges(end),1000);
					
					fk_D{g} = Fit_Object_D(xk{g});
					fk_V{g} = Fit_Object_V(xk{g});
					
					H_D(g) = area(Ax1,xk{g},fk_D{g},'FaceColor',CM(g,:),'FaceAlpha',0.5); % 1./(Ng-g+1)./1.5
					hold(Ax1,'on');
					H_V(g) = area(Ax1,xk{g},-fk_V{g},'FaceColor',CM(g,:),'FaceAlpha',0.5); % 1./(Ng-g+1)./1.5
					
				end
				
				for g=1:Ng
					plot(Ax1,xk{g},fk_D{g},'LineWidth',2,'Color',CM(g,:));
					plot(Ax1,xk{g},-fk_V{g},'LineWidth',2,'Color',CM(g,:));
				end
				legend(H_D,Groups,'Interpreter','Latex');
			end
			
			% xl = 0:pi/6:pi/2;
			set(Ax1,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize,'xlim',[Edges([1,end])]); % ,'TickLabelInterpreter','Latex','XTick',xl,'XTickLabels',strsplit(num2str(xl.*180/pi)));
			
			switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value)
				case 1
					if(P.GUI_Handles.Control_Panel_Objects(1,5).Value > 1)
						xy_scale = num2str(P.GUI_Handles.Control_Panel_Objects(1,5).Value);
					else
						xy_scale = '';
					end
					XLabel = ['Midline Position [',xy_scale,char(181),'m]'];
					YLabel = ['Neuronal Length [',xy_scale,char(181),'m]'];
				case 2 % Normalized to Midline Length.
					XLabel = 'Midline Position (normalized)';
					YLabel = '$\mathrm{Neuronal \; Length \; [{\mu}m]}$';
				case 3
					XLabel = ['Midline Position [',char(181),'m]'];
					YLabel = '$\mathrm{\frac{Neuronal \; Length}{Total \; Length}}$';
					% set(gca,'YLim',1.25.*get(gca,'YLim'));
				case 4
					XLabel = 'Midline Position (normalized)';
					YLabel = '$\frac{ \mathrm{Neuronal Length} }{ \mathrm{Total Length} }$';
			end
			xlabel(Ax1,XLabel,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize); % ,'Interpreter','Latex'
			ylabel(Ax1,YLabel,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize); % ,'Interpreter','Latex'
			
			% set(Ax1,'unit','normalize','position',[0.1,0.15,0.87,0.8]);
			set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')));
			
			set(Ax1,'XTickLabels',get(Ax1,'XTick') ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')) ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			
			% profile off; profile viewer;
		case {'Midline Density - 3-Way Junctions','Midline Density - Tips'}
			
			Workspace_Set = Workspace_Set{1};
			
			switch GP.General.Active_Plot
				case 'Midline Density - 3-Way Junctions'
					Vertex_Order = 3;
					Junction_Classes = [112,233,234,334,344];
				case 'Midline Density - Tips'
					Vertex_Order = 1;
					Junction_Classes = 1:4;
			end
			
			Max_Midline_Length = 800;
			Max_PVD_Orders = length(Junction_Classes);
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized','Normalized to Midline Length'});
			set(GP.Handles.Plot_Type_List,'String',{'Default','Dorsal-Ventral Merged','Orders Merged','All Merged'});
			
			switch GP.Handles.Normalization_List.Value
				case 1
					if(~GP.Handles.Analysis.Slider.UserData)
						set(GP.Handles.Analysis.Slider,'Min',10,'Max',110,'Value',50,'SliderStep',[0.01,0.1]);
					end
					Edges = 0:GP.Handles.Analysis.Slider.Value:Max_Midline_Length;
				case 2 % Normalized to Midline Length.
					if(~GP.Handles.Analysis.Slider.UserData)
						set(GP.Handles.Analysis.Slider,'Min',0.02,'Max',.12,'Value',0.05,'SliderStep',[0.01,0.1]);
					end
					Edges = 0:GP.Handles.Analysis.Slider.Value:1;
			end
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
			set(GP.Handles.Analysis.Slider_Text,'String',num2str(GP.Handles.Analysis.Slider.Value));
			
			L_D = [];
			L_V = [];
			for w=Workspace_Set
				
				switch GP.Handles.Normalization_List.Value
					case 1
						Midline_Length = 1;
					case 2 % Normalized to Midline Length.
						Midline_Length = GP.Workspace(w).Workspace.Axes.Axis_0(end).Arc_Length;
				end
				
				% for o=1:Max_PVD_Orders
					
					% Find all the vertices assigned with class Junction_Classes(o):
					f_D = find([GP.Workspace(w).Workspace.Points.Midline_Distance] > 0 & [GP.Workspace(w).Workspace.All_Vertices.Order] == Vertex_Order);
					f_V = find([GP.Workspace(w).Workspace.Points.Midline_Distance] < 0 & [GP.Workspace(w).Workspace.All_Vertices.Order] == Vertex_Order);
					
					Nd = length(L_D{o});
					Nv = length(L_V{o});
					
					dd = Nd+1:Nd+length(f_D);
					vv = Nv+1:Nv+length(f_V);
					
					% Add the midline positions corresponding to the current vertex subset:
					L_D{o}(dd) = [GP.Workspace(w).Workspace.All_Vertices(f_D).Axis_0_Position] ./ Midline_Length; % A vector of midline position (arc-length) from the head (dorsal).
					L_V{o}(vv) = [GP.Workspace(w).Workspace.All_Vertices(f_V).Axis_0_Position] ./ Midline_Length; % A vector of midline position (arc-length) from the head (ventral).
				% end
			end
			
			for o=1:Max_PVD_Orders
				[N_D(o,:),~,I_D] = histcounts(L_D{o},Edges,'Normalization','Probability'); % I_D are bin indices.
				[N_V(o,:),~,I_V] = histcounts(L_V{o},Edges,'Normalization','Probability');
				
				f_D = find(I_D == 0);
				f_V = find(I_V == 0);
				
				if(~isempty(f_D) || ~isempty(f_V))
					disp([num2str(length(f_D) + length(f_V)),' values (order ',num2str(o),') do not fall within any bin.']);
				end
				
				% I_D(f_D) = length(Edges) - 1; % Associate uncategorized points with the last bin.
				% I_V(f_V) = length(Edges) - 1; % ".
			end
			
			H_D = bar(xx,N_D',1,'stacked','FaceColor','flat'); % histogram(X_D,Edges);
			hold on;
			set(gca,'ColorOrderIndex',1);
			H_V = bar(xx,-N_V',1,'stacked','FaceColor','flat'); % histogram(X_V,Edges);
			
			legend(string(Junction_Classes),'FontSize',14);
			
			set(gca,'FontSize',26,'xlim',[Edges([1,end])]); % ,'XTick',xl,'XTickLabels',strsplit(num2str(xl.*180/pi)));
			
			YL_D = max(sum(reshape([H_D(:).YData],[],Max_PVD_Orders),2));
			YL_V = min(sum(reshape([H_V(:).YData],[],Max_PVD_Orders),2));
			ylim([(1.1.*YL_V),1.1.*YL_D]);
			
			switch GP.Handles.Normalization_List.Value
				case 1
					xlabel(['Midline Position [',char(181),'m]']);
					ylabel('Count');
				case 2 % Normalized to Midline Length.
					xlabel(['Midline Position (normalized)']);
					ylabel('Probability');
			end
			
			set(gca,'YTickLabels',strrep(get(gca,'YTickLabels'),'-',''));
			
		case 'Density of Points per Menorah order'
			% For each point (rectangle), find all points from the same class and not from the same segment.
			% Then order them by midline distance (normalized to local radius), and find the closest one (in terms of midline distance), one from each side (along the midline).
			% Do separatly for dorsal and ventral.
			
			Menorah_Classes = [2,4];
			Radial_Tolerance = 0.025;
			Ng = length(Workspace_Set);
			
			X = cell(Ng,length(Menorah_Classes)); % nan(2,0);
			
			for g=1:Ng
				ii = 0;
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					for o=1:length(Menorah_Classes)
						f1 = find([GP.Workspace(ww).Workspace.Points.Segment_Class] == Menorah_Classes(o)); % All points of *segment* class o.
						for p=1:length(f1)
							Segment_Index = GP.Workspace(ww).Workspace.Points(f1(p)).Segment_Index;
							Midline_Position = GP.Workspace(ww).Workspace.Points(f1(p)).Axis_0_Position;
							Radial_Distance = GP.Workspace(ww).Workspace.Points(f1(p)).Radial_Distance_Corrected;
							
							% From all points of order o (f1), find the ones within some radial distance tolerance, and that do not belong to the same segment as point p:
							f2 = find([GP.Workspace(ww).Workspace.Points(f1).Segment_Index] ~= Segment_Index & ...
										[GP.Workspace(ww).Workspace.Points(f1).Radial_Distance_Corrected] >= Radial_Distance - Radial_Tolerance & ...
										[GP.Workspace(ww).Workspace.Points(f1).Radial_Distance_Corrected] <= Radial_Distance + Radial_Tolerance);
							
							x = sort([GP.Workspace(ww).Workspace.Points(f1(f2)).Axis_0_Position] - Midline_Position); % The midline position of all points found in f2, minus the tested point, sorted in increasing order.
							f3 = find(x < 0);
							f4 = find(x > 0);
							
							if( (~isempty(f3) && x(f3(end)) == 0) || (~isempty(f4) && x(f4(1)) == 0) )
								disp(1);
							end
							
							if(~isempty(f3))
								ii = ii + 1;
								X{g,o}(:,ii) = [Midline_Position ; abs(x(f3(end)))]; % Closest midline position from below (last negative number).
							end
							
							if(~isempty(f4))
								ii = ii + 1;
								X{g,o}(:,ii) = [Midline_Position ; abs(x(f4(1)))]; % Closest midline position from above (first positive number).
							end
						end
					end
				end
			end
			
			for g=1:Ng
				for o=1:length(Menorah_Classes)
					subplot(Ng,2,o+(2*(g-1)));
					
					if(o == 1)
						histogram(X{g,o}(2,:),0:5:150,'Normalization','Probability');
						axis([0,150,0,0.06]);
					elseif(o == 2)
						histogram(X{g,o}(2,:),0:1:100,'Normalization','Probability');
						axis([0,100,0,0.07]);
					end
					
					xlabel('$$Distance \; (\mu m)$$','Interpreter','Latex');
					ylabel('Probability');
					set(gca,'FontSize',22,'TickLabelInterpreter','Latex');
				end
			end
			
			assignin('base','X',X);
			
		case {'Junction Number/Density','Tip Number/Density'}
			
			set(P.GUI_Handles.Control_Panel_Objects(2,4),'Items',{'Not Normalized','Midline Length','Total Length'},'ItemsData',1:3);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Orders Merged','Orders 1-3'},'ItemsData',1:3); % ,'Dorsal-Ventral Merged',
			
			if(P.GUI_Handles.Control_Panel_Objects(2,1).Value) % Apply projection correction.
				Field_1 = 'Length_Corrected';
			else
				Field_1 = 'Length';
			end
			
			switch(Label)
				case 'Junction Number/Density'
					Vertex_Order = 3;
					Name = 'Junction'; % 3-way junctions only ?
				case 'Tip Number/Density'
					Vertex_Order = 1;
					Name = 'Tip';
				case 'Points Density'
					% Vertex_Order = [1,2,3];
			end
			
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
				case 1 % Per menorah order.
					Classes = 1:4;
					Nc = length(Classes);
				case 2 % Orders merged.
					Classes = nan;
					Nc = 1;
				case 3
					Classes = 1:3;
					Nc = 1;
			end
			
			if(P.GUI_Handles.Control_Panel_Objects(1,5).Value > 1)
				y_scale = num2str(P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			else
				y_scale = '';
			end
			
			switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
				case 1
					Y_Name = ['# of ',Name,'s'];
				case 2
					Y_Name = ['# of ',Name,'s / Midline Length [',y_scale,char(181),'m]']; % ['$\mathrm{\frac{\# \; of \; ',Name,'}{Midline \; Length \; (\mu m)}}$'];
				case 3
					Y_Name = [Name,' Density [',y_scale,char(181),'m^{-1}]'];
			end
			
			Ng = length(Workspace_Set);
			CM = lines(Ng);
			
			for g=1:Ng
				N{g} = nan(Nc,length(Workspace_Set{g}));
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
						case 1 % Per class.
							for o=1:length(Classes)
								
								switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
									case 1
										Normalization_Factor = 1;
									case 2 % Midline.
										Normalization_Factor = Data(ww).Axes.Axis_0(end).Arc_Length;
									case 3 % Total length of order Classes(o).
										f0 = find([Data(ww).Points.Segment_Class] == Classes(o)); % Find all points of class Classes(o).
										Normalization_Factor = nansum([Data(ww).Points(f0).(Field_1)]); % Total length of order o in workspace ww.
								end
								
								f3 = find([Data(ww).Points.Segment_Class] == Classes(o) & [Data(ww).Points.Vertex_Order] == Vertex_Order); % Find all rectangles that belong to a 3-way junction of class o.
								I3 = unique([Data(ww).Points(f3).Vertex_Index]); % Number of vertices (uniqe vertex indices). Junctions or tips (Vertex_Order).
								
								N{g}(o,w) = length(I3) ./ Normalization_Factor; % Number of 3-way junctions (or tips) that have at least one rectangle of order o.
								
							end
						case 2 % No classification
							switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
								case 1
									Normalization_Factor = 1;
								case 2 % Midline.
									Normalization_Factor = Data(ww).Axes.Axis_0(end).Arc_Length;
								case 3 % Total length of entire neuron.
									Normalization_Factor = nansum([Data(ww).Points.(Field_1)]); % Total neuron length.
							end
							
							f3 = find([Data(ww).Points.Vertex_Order] == Vertex_Order);
							I3 = unique([Data(ww).Points(f3).Vertex_Index]); % Number of vertices (uniqe vertex indices). Junctions or tips (Vertex_Order).
							
							N{g}(w) = length(I3) ./ Normalization_Factor; % Number of 3-way junctions (or tips).
						case 3 % Classes 1-3.
							switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
								case 1
									Normalization_Factor = 1;
								case 2 % Midline.
									Normalization_Factor = Data(ww).Axes.Axis_0(end).Arc_Length;
								case 3 % Total length of entire neuron.
									f0 = find(ismember([Data(ww).Points.Segment_Class],Classes)); % Find all points of Classes (1-3).
									Normalization_Factor = nansum([Data(ww).Points(f0).(Field_1)]); % Total length of Classes (1-3).
							end
							
							f3 = find([Data(ww).Points.Vertex_Order] == Vertex_Order & ismember([Data(ww).Points.Segment_Class],Classes));
							I3 = unique([Data(ww).Points(f3).Vertex_Index]); % Number of vertices (uniqe vertex indices). Junctions or tips (Vertex_Order).
							
							N{g}(w) = length(I3) ./ Normalization_Factor; % Number of 3-way junctions (or tips).
					end
				end
			end
			
			for g=1:Ng
				N_Mean(:,g) = nanmean(N{g},2); % Average across animals.
				N_std(:,g) = nanstd(N{g},0,2); % ".
			end
			
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
				case 1 % Per order.
					H = bar(Ax1,1:length(Classes),N_Mean,BarWidth,'hist','FaceColor','flat'); % ".
				case {2,3} % Orders merged. X-axis used for groups.
					H = bar(Ax1,1:Ng,N_Mean,'FaceColor','flat'); % ".
			end
			hold(Ax1,'on');
			for g=1:Ng
				switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
					case 1 % Per order.
						H(g).FaceColor = CM(g,:);
						errorbar(Ax1,mean(H(g).XData,1),N_Mean(:,g),N_std(:,g),'Color','k','LineWidth',2,'LineStyle','none');
					case {2,3} % Orders merged. X-axis used for groups.
						H.CData(g,:) = CM(g,:);
						errorbar(Ax1,H.XData(g),N_Mean(:,g),N_std(:,g),'Color','k','LineWidth',2,'LineStyle','none');
				end
			end
			
			disp(['Stats (',Name,')']);
			disp(['Across Classes:']);
			for g=1:Ng % First compare classes within each group.
				disp([Groups{g},':']);
				for o=2:Nc
					switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
						case 1 % Per order.
							[PVal_Junctions,Test_Name_Junctions] = Stat_Test(N{g}(o-1,:),N{g}(o,:));
							disp(['P-Value (',num2str(Classes(o)),') = ',num2str(PVal_Junctions),' (',Test_Name_Junctions,')']);
					end
				end
			end
			
			if(Ng > 1)
				disp(['Across Groups:']);
				for g=2:Ng % Then compare across groups.
					for o=1:Nc
						[PVal_Junctions,Test_Name_Junctions] = Stat_Test(N{g-1}(o,:),N{g}(o,:));
						disp(['P-Value (',num2str(Classes(o)),') = ',num2str(PVal_Junctions),' (',Test_Name_Junctions,')']);
					end
				end
			end
			
			set(Ax1,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
			
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value) % Type.
				case 1 % Per order.
					XLabel = 'Class';
					legend(Ax1,Groups); % Axis_Ticks_FontSize
					set(Ax1,'XTick',1:length(Classes),'xlim',[0.5,length(Classes)+0.5]);
					xlabel(Ax1,XLabel,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				case {2,3} % Orders merged. X-axis used for groups.
					set(Ax1,'XTick',1:Ng,'XTickLabels',Groups,'xlim',[0.5,Ng+0.5]);
			end
			ylabel(Ax1,Y_Name,'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
			
			if(P.GUI_Handles.Control_Panel_Objects(2,4).Value > 1) % If the count is divided by length (midline/total).
				set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')) .* P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			end
			
			% grid(Ax1,'on');
			
		case 'CB Intensity'
			Var_Operations = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Mean_Intensity'};
			Filter_Fields = [];
			%
			Y_Label = 'Pixel Intensity';
			Title = 'Intensity of the Cell Body';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GP,'CB',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
		case 'CB Area'
			Var_Operations = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Area'};
			Filter_Fields = [];
			%
			Y_Label = 'Area (\mum^2)';
			Title = 'Area of the Cell Body';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GP,'CB',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		case 'Distances Of Vertices From The CB'
			Var_Operations{1} = @(x) x;
			Filter_Operations{1} = [];
			Var_Fields = {'Distance_From_CB'};
			Filter_Fields = [];
			%
			Y_Label = 'Length (\mum)';
			Title = 'Distances Of Vertices From The CB';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%
		case 'Distances Of Vertices From The Medial Axis - Means'
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = [];
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = [];
			%
			Y_Label = 'Distance (\mum)';
			Title = 'Mean Distance Of Vertices From The Medial Axis';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		case 'Midline Orientation VS Curvature VS Midlines Distance'
			
			Workspace_Set = Workspace_Set{1};
			
			X = []; % Curvature.
			Y = []; % Midline Orientation.
			Z = []; % Midline Distance.
			for w=Workspace_Set
				X = [X,[GP.Workspace(w).Workspace.Points.Curvature]];
				Y = [Y,[GP.Workspace(w).Workspace.Points.Midline_Orientation]];
				Z = [Z,[GP.Workspace(w).Workspace.Points.Midline_Distance]];
			end
			
			if(1)
				C = rescale(Z');
				H = scatter3(X,Y,Z,20,[1-C,0.*C,C],'filled');
				H.MarkerFaceAlpha = 0.5;
				xlabel('Curvature [1/\mum]');
				ylabel(['Midline Orientation [',char(176),']']);
				zlabel('Midline Distance [\mum]');
				yl = 0:pi/6:pi/2;
				set(gca,'FontSize',18,'xlim',[0,0.4],'ylim',[0,pi/2],'YTick',yl,'YTickLabels',strsplit(num2str(yl.*180/pi)));
				view([38.9,10.8]);
			elseif(0) % Curvature VS Orientation + Distance Colormap.
				C = rescale(Z');
				scatter(X,Y,10,[1-C,0.*C,C],'filled');
				xlabel('Curvature [1/\mum]');
				ylabel(['Midline Orientation [',char(176),']']);
				yl = 0:pi/6:pi/2;
				set(gca,'FontSize',18,'xlim',[0,0.4],'ylim',[0,pi/2],'YTick',yl,'YTickLabels',strsplit(num2str(yl.*180/pi)));
			else % Curvature VS Distance + Orientation Colormap.
				C = rescale(Y');
				scatter(X,Z,10,[1-C,0.*C,C],'filled');
				ylim([-45,45]);
				xlabel('Curvature [1/\mum]');
				ylabel(['Midline Distance [',char(176),']']);
				set(gca,'FontSize',18,'xlim',[0,0.4],'ylim',[-45,45]);
			end
			
		case 'Midline Orientation VS Curvature'
			
			Workspace_Set = Workspace_Set{1};
			
			X_Edges = 0:0.025:0.4;
			Y_Edges = 0:5*pi/180:pi/2;
			
			X = []; % Curvature.
			Y = []; % Midline Orientation.
			for w=Workspace_Set
				X = [X,[GP.Workspace(w).Workspace.Points.Curvature]];
				Y = [Y,[GP.Workspace(w).Workspace.Points.Midline_Orientation]];
			end
			
			histogram2(X,Y,X_Edges,Y_Edges,'Normalization','Probability','FaceColor','flat');
			xlabel('Curvature [1/\mum]');
			ylabel(['Midline Orientation [',char(176),']']);
			yl = 0:pi/6:pi/2;
			set(gca,'FontSize',18,'xlim',[0,0.4],'ylim',[0,pi/2],'YTick',yl,'YTickLabels',strsplit(num2str(yl.*180/pi)));
			
		case 'Distribution of Midline Orientation Along the Midline'
			
			Workspace_Set = Workspace_Set{1};
			
			X_Edges = 0:25:800;
			Y_Edges = 0:5*pi/180:pi/2;
			
			X = []; % Midline Arclength.
			Y = []; % Midline Orientation.
			for w=Workspace_Set
				X = [X,[GP.Workspace(w).Workspace.Points.Axis_0_Position]];
				Y = [Y,[GP.Workspace(w).Workspace.Points.Midline_Orientation]];
			end
			
			histogram2(X,Y,X_Edges,Y_Edges,'Normalization','Probability','FaceColor','flat');
			xlabel('Midline Arclength');
			ylabel(['Midline Orientation [',char(176),']']);
			yl = 0:pi/6:pi/2;
			set(gca,'FontSize',18,'ylim',[0,pi/2],'YTick',yl,'YTickLabels',strsplit(num2str(yl.*180/pi)));
			
		case 'Distribution of Midline Orientation Along the Midline - Vertices Only'
			
			Workspace_Set = Workspace_Set{1};
			
			X_Edges = 0:25:800;
			Y_Edges = 0:5*pi/180:pi/2;
			
			X = []; % Midline Arclength.
			Y = []; % Midline Orientation.
			for w=Workspace_Set
				
				f = find([GP.Workspace(w).Workspace.Points.Vertex_Order] ~= 2);
				X = [X,[GP.Workspace(w).Workspace.Points(f).Axis_0_Position]];
				Y = [Y,[GP.Workspace(w).Workspace.Points(f).Midline_Orientation]];
			end
			
			histogram2(X,Y,X_Edges,Y_Edges,'Normalization','Probability','FaceColor','flat');
			xlabel('Midline Arclength');
			ylabel(['Midline Orientation [',char(176),']']);
			yl = 0:pi/6:pi/2;
			set(gca,'FontSize',18,'ylim',[0,pi/2],'YTick',yl,'YTickLabels',strsplit(num2str(yl.*180/pi)));
			
		case 'Distribution of Midline Orientation'
			
			Ng = length(Workspace_Set);
			
			set(P.GUI_Handles.Control_Panel_Objects(2,4),'Items',{'Not Normalized','Total Length'},'ItemsData',1:2);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Color Gradient','Vertices Only'},'ItemsData',1:3);
			
			if(P.GUI_Handles.Control_Panel_Objects(2,1).Value) % Apply projection correction.
				Field_1_Name = 'Midline_Orientation_Corrected';
				Field_2_Name = 'Length_Corrected';
			else
				Field_1_Name = 'Midline_Orientation';
				Field_2_Name = 'Length';
			end
			
			if(~isequal(Label,P.GUI_Handles.Buttons(3,1).UserData)) % If the previous plot was different.
				set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[1,30],'Step',1,'Value',2,'Tooltip','');
			end
			BinSize = P.GUI_Handles.Control_Panel_Objects(1,4).Value .* pi ./ 180; % Degrees to radians.
			Edges = 0:BinSize:pi/2;
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
			for g=1:Ng
				
				Y_D{g} = nan(length(Workspace_Set{g}),length(xx));
				Y_V{g} = nan(length(Workspace_Set{g}),length(xx));
				
				for w=1:length(Workspace_Set{g})
					pp = Workspace_Set{g}(w);
					
					switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
						case 1
							Total_Length = 1;
						case 2
							Total_Length = nansum([Data(pp).Points.(Field_2_Name)]);
					end
					
					if(P.GUI_Handles.Control_Panel_Objects(4,4).Value <= 2) % Type.
						f_D = find([Data(pp).Points.Midline_Distance] <= 0);
						f_V = find([Data(pp).Points.Midline_Distance] >= 0);
					elseif(P.GUI_Handles.Control_Panel_Objects(4,4).Value == 3) % Only use rectangles of vertices.
						f_D = find([Data(pp).Points.Midline_Distance] <= 0 & [Data(pp).Points.Vertex_Order] == 3);
						f_V = find([Data(pp).Points.Midline_Distance] >= 0 & [Data(pp).Points.Vertex_Order] == 3);
					end
					
					Xw_D = [Data(pp).Points(f_D).(Field_1_Name)];
					Xw_V = [Data(pp).Points(f_V).(Field_1_Name)];
					
					% Length:
					if(P.GUI_Handles.Control_Panel_Objects(4,4).Value <= 2) % Type.
						Lw_D = [Data(pp).Points(f_D).(Field_2_Name)] ./ Total_Length;
						Lw_V = [Data(pp).Points(f_V).(Field_2_Name)] ./ Total_Length;
					else % Only use rectangles of vertices. Weigh vertices as length 1 (we only want the number of vertices without length weighing).
						Lw_D = ones(1,length(f_D)) ./ Total_Length;
						Lw_V = ones(1,length(f_V)) ./ Total_Length;
					end
					
					[Y_D{g}(w,:),~,Iw_D] = histcounts(Xw_D,Edges);
					[Y_V{g}(w,:),~,Iw_V] = histcounts(Xw_V,Edges);
					
					Lw_D = Lw_D(Iw_D > 0);
					Iw_D = Iw_D(Iw_D > 0);
					Lw_V = Lw_V(Iw_V > 0);
					Iw_V = Iw_V(Iw_V > 0);
					
					Y_L_D = accumarray([Iw_D,1:length(Edges)-1]',[Lw_D,zeros(1,length(Edges)-1)])'; % Y_L is a vector of summed length (values of Lw) into bins corresponding to Y{g}(w,:). It is used to weigh the bins by their total neuron length.
					Y_L_V = accumarray([Iw_V,1:length(Edges)-1]',[Lw_V,zeros(1,length(Edges)-1)])'; % Y_L is a vector of summed length (values of Lw) into bins corresponding to Y{g}(w,:). It is used to weigh the bins by their total neuron length.
					
					Y_D{g}(w,:) = Y_L_D; % Now the height of the bins is neuronal length.
					Y_V{g}(w,:) = Y_L_V; % ".
				end
			end
			
			if(Ng == 1)
				Merge_DV = 1;
				switch Merge_DV
					case 0
						H_D = bar(Ax1,xx,mean(Y_D{1},1),1,'FaceColor','flat');
						hold(Ax1,'on');
						H_V = bar(Ax1,xx,-mean(Y_V{1},1),1,'FaceColor','flat');
					case 1
						H_D = bar(Ax1,xx,mean(Y_D{1},1)+mean(Y_V{1},1),1,'FaceColor','flat');
				end
				
				if(P.GUI_Handles.Control_Panel_Objects(4,4).Value == 2 || P.GUI_Handles.Control_Panel_Objects(4,4).Value == 3) % Color gradient.
					L = size(H_D.CData,1); % # of bars.
					CM = transpose(rescale(1:L));
					CM = [1-CM, CM , 0.*CM+0.2];
					H_D.CData = CM;
					if(~Merge_DV)
						H_V.CData = CM;
					end
				end
			else
				CM = lines(Ng);
				for g=1:Ng
					Fit_Object_D = fit(xx',mean(Y_D{g},1)','smoothingspline','smoothingparam',0.99999);
					Fit_Object_V = fit(xx',mean(Y_V{g},1)','smoothingspline','smoothingparam',0.99999);
					
					xk_D{g} = linspace(Edges(1),Edges(end),1000);
					fk_D{g} = Fit_Object_D(xk_D{g});
					
					xk_V{g} = linspace(Edges(1),Edges(end),1000);
					fk_V{g} = Fit_Object_V(xk_V{g});
					
					H_D{g} = area(Ax1,xk_D{g},fk_D{g},'FaceColor',CM(g,:),'FaceAlpha',0.5); % 1./(Ng-g+1)./1.5
					hold(Ax1,'on');
					H_V{g} = area(Ax1,xk_V{g},-fk_V{g},'FaceColor',CM(g,:),'FaceAlpha',0.5); % 1./(Ng-g+1)./1.5
				end
				
				for g=1:Ng
					plot(Ax1,xk_D{g},fk_D{g},'LineWidth',2,'Color',CM(g,:));
					plot(Ax1,xk_V{g},-fk_V{g},'LineWidth',2,'Color',CM(g,:));
				end
				legend(Ax1,Groups);
			end
			
			set(Ax1,'FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
			
			if(P.GUI_Handles.Control_Panel_Objects(1,5).Value > 1)
				y_scale = num2str(P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			else
				y_scale = '';
			end
			
			xlabel(Ax1,[char(952),' (orientation) [',char(176),']'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
			
			if(P.GUI_Handles.Control_Panel_Objects(4,4).Value <= 2)
				switch(P.GUI_Handles.Control_Panel_Objects(2,4).Value) % Normalization.
					case 1
						ylabel(Ax1,['Neuronal Length [',y_scale,char(181),'m]'],'FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
					case 2
						ylabel(Ax1,'Neuronal Length / Total Length','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				end
				
				set(Ax1,'XTick',0:pi/4:pi/2,'YTick',0:100:max(get(Ax1,'YTick')));
			else
				ylabel(Ax1,'Number of Junctional Elements','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
				
				set(Ax1,'XTick',0:pi/4:pi/2);
			end
			
			xlim(Ax1,[Edges([1,end])]);
			drawnow;
			% set(Ax1,'FontSize',FontSize_1,'XTick',xl,'XTickLabels',strsplit(num2str(xl.*180/pi)),'YTickLabels',get(Ax1,'YTick') ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			set(Ax1,'XTickLabels',get(Ax1,'xtick') .* 180 ./ pi,'YTickLabels',get(Ax1,'YTick') ./ P.GUI_Handles.Control_Panel_Objects(1,5).Value);
			
			% set(Ax1,'YTickLabels',abs(get(Ax1,'YTick')));
			
		case 'Distances Of Vertices From The Medial Axis - Histogram'
			
			Workspace_Set = Workspace_Set{1};
			
			Edges = -45:2:45;
			
			X1 = [];
			X3 = [];
			for w=Workspace_Set
				f1 = find([GP.Workspace(w).Workspace.All_Vertices.Order] == 1);
				f3 = find([GP.Workspace(w).Workspace.All_Vertices.Order] == 3);
				
				X1 = [X1,[GP.Workspace(w).Workspace.All_Vertices(f1).Midline_Distance]];
				X3 = [X3,[GP.Workspace(w).Workspace.All_Vertices(f3).Midline_Distance]];
			end
			
			histogram(X1,Edges);
			hold on;
			histogram(X3,Edges);
			xlabel('Distance [\mum]');
			ylabel('Count');
			set(gca,'FontSize',18);
			legend({'Tips','3-Way Junctions'});
			
		case 'Distances Of 3-Way Junctions From The Medial Axis - Histogram'
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = @(x) (x == 3); % Choose third order vertices only (= 3-way junctions).
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of 3-Way Junctions From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GP.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distances Of Tips From The Medial Axis - Histogram'
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = @(x) (x == 1); % Choose first order vertices only (= tips).
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of Tips From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GP.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Smallest Angle VS Distance From Medial Axis'
			% TODO: what if there are two minimums???????????
			Var_Operations{1} = @(x) x(x == min(x)); % Smallest Angle.
			Var_Operations{2} = @(x) x; % Distance from Medial Axis.
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions (and specifically not tips)..
			Filter_Operations{2} = @(x) (x >= 0); % Only 3-way junctions (and specifically not tips)..
			Var_Fields = {'Angles','Distance_From_Medial_Axis'};
			Filter_Fields = {'Order','Distance_From_Medial_Axis'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Distance (\mum)';
			Title = 'Smallest Angle VS Distance From Medial Axis';
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,[],Var_Operations,Filter_Operations,RowWise);
			assignin('base','Input_Struct',Input_Struct);
			Two_Vars_Plot(Input_Struct,GP,GP.Visuals,X_Label,Y_Label,Title);
			
		case 'All Angles VS Midline Distance'
			
			Workspace_Set = Workspace_Set{1};
			for g=1 % :Ng
				A = [];
				L = [];
				ii = 0;
				for w=Workspace_Set
					for v=1:numel(GP.Workspace(w).Workspace.All_Vertices) % for v=1:numel(GP.Workspace(w).Workspace.Points) % 
						if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.All_Vertices(v).Angles]) == 3)
							[l,in] = Scale_Midline_Distance_To_Local_Radii(GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance,GP.Workspace(w).Workspace.All_Vertices(v).Half_Radius,GP.Workspace(w).Workspace.All_Vertices(v).Radius);
							%%%[l,in] = Scale_Midline_Distance_To_Local_Radii(GP.Workspace(w).Workspace.Points(v).Midline_Distance,GP.Workspace(w).Workspace.Points(v).Half_Radius,GP.Workspace(w).Workspace.Points(v).Radius);
							if(~isempty(in))
								ii = ii + 3;
								A(ii-2:ii) = [GP.Workspace(w).Workspace.All_Vertices(v).Angles];
								L(ii-2:ii) = l;
								
								% ii = ii + 1; A(ii) = [GP.Workspace(w).Workspace.Points(v).Curvature]; L(ii) = l;
							end
						end
					end
				end
			end
			
			Edges_X = 0:0.3:2*pi; % Edges_X = 0:0.01:1;
			Edges_Y = -1:0.1:1;
			
			xx = (Edges_X(2:end) + Edges_X(1:end-1)) ./ 2;
			yy = (Edges_Y(2:end) + Edges_Y(1:end-1)) ./ 2;
			
			% histogram2(A,L,Edges_X,Edges_Y,'FaceColor','flat');
			% scatter(A,L,5,'k','filled');
			
			[N,Xedges,Yedges] = histcounts2(A,L,Edges_X,Edges_Y);
			[X,Y] = meshgrid(xx,yy);
			
			N = interp2(X,Y,N',X,Y,'spline');
			surf(X,Y,N,'FaceColor','interp','EdgeColor','none');
			
		case 'Histogram of the Largest Angle'
			
			Workspace_Set = Workspace_Set{1};
			
			V = zeros(1,10^4);
			% D = zeros(1,10^4);
			ii = 0;
			for w=Workspace_Set
				for v=1:numel(GP.Workspace(w).Workspace.All_Vertices)
					if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.All_Vertices(v).Angles]) == 3)
						ii = ii + 1;
						V(ii) = max([GP.Workspace(w).Workspace.All_Vertices(v).Angles]);
						% D(ii) = abs(GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance ./ (2.*(GP.Workspace(w).Workspace.All_Vertices(v).Half_Radius)));
					end
				end
			end
			V = V(1:ii)*180/pi;
			% D = D(1:ii);
			
			% scatter(V,D);
			histogram(V,120:3:320,'Normalization','Probability');
			xlabel(['Angle (',char(176),')']);
			ylabel('Probability');
			set(gca,'FontSize',22);
			% xlim([0,2]);
		case 'Histogram of Symmetry Indices'
			
			Workspace_Set = Workspace_Set{1};
			
			S = zeros(1,10^4); % Symmetry Index.
			A = zeros(1,10^4); % Largest Angle.
			ii = 0;
			for w=Workspace_Set
				for v=1:numel(GP.Workspace(w).Workspace.All_Vertices)
					if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.All_Vertices(v).Angles]) == 3)
						V = GP.Workspace(w).Workspace.All_Vertices(v).Angles;
						[Sym,Lin,~] = Vertices_Symmetry_Linearity(V);
						ii = ii + 1;
						if(1)
							S(ii) = Sym;
							% A(ii) = max([GP.Workspace(w).Workspace.All_Vertices(v).Angles]);
							%% A(ii) = Lin; % max([GP.Workspace(w).Workspace.All_Vertices(v).Angles]);
						else
							if(GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance >= 0)
								S(ii) = 1-Sym+1;
							else
								S(ii) = -(1-Sym)+1;
							end
						end
					end
				end
			end
			S = S(1:ii);
			
			% A = A(1:ii)*180/pi;
			% scatter(A,S,'filled'); xlabel(['Linearity (',char(176),')']); ylabel('Symmetry'); xlim([120,200]);
			
			histogram(S,0:0.03:1,'Normalization','Probability'); xlim([0,1]); xlabel('Symmetry Index'); ylabel('Probability');
			% histogram(S,0:0.05:2,'Normalization','Probability'); xlim([0,2]); xlabel('Symmetry Index'); ylabel('Probability');
			set(gca,'FontSize',22);
			
		case 'Angles VS Midline Distance'
			
			Workspace_Set = Workspace_Set{1};
			
			Amin = zeros(1,10^4);
			Amid = zeros(1,10^4);
			Amax = zeros(1,10^4);
			D = zeros(1,10^4);
			L = zeros(1,10^4);
			r = 0;
			for w=Workspace_Set
				F3 = find([GP.Workspace(w).Workspace.All_Vertices.Order] == 3);
				Lmax = GP.Workspace(w).Workspace.Axes.Axis_0(end).Arc_Length;
				
				for v=1:numel(GP.Workspace(w).Workspace.All_Vertices)
					if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length(GP.Workspace(w).Workspace.All_Vertices(v).Angles) == 3)
						r = r + 1;
						a = sort(GP.Workspace(w).Workspace.All_Vertices(v).Angles);
						Amin(r) = a(1);
						Amid(r) = a(2);
						Amax(r) = a(3);
						D(r) = GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance ./ (2.*(GP.Workspace(w).Workspace.All_Vertices(v).Half_Radius));
						L(r) = GP.Workspace(w).Workspace.All_Vertices(v).Axis_0_Position ./ Lmax;
					end
				end
			end
			Amin = Amin(1:r);
			Amid = Amid(1:r);
			Amax = Amax(1:r);
			D = D(1:r);
			L = L(1:r)';
			CM = [L,0.*L,1-L];
			
			figure;
			
			subplot(121);
				polarscatter(Amin,abs(D),10,'filled');
				hold on;
				polarscatter(Amid,abs(D),10,'filled');
				polarscatter(Amax,abs(D),10,'filled');
				set(gca,'FontSize',22);
				rticklabels([]);
			
			subplot(122);
				polarscatter(Amin,abs(D),20,CM,'filled');
				% hold on;
				% polarscatter(Amax.*(180/pi),abs(D),'filled');
				set(gca,'FontSize',22);
		case 'Minimal and Maximal Angles of 3-Way junctions'
			Var_Operations{1} = @(x) x(x == min(x) & min(x) > 0 & max(x) > 0).*180./pi;
			Var_Operations{2} = @(x) x(x == max(x) & min(x) > 0 & max(x) > 0).*180./pi; % x(x ~= min(x) & x~=max(x) & x>0);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = ['Minimal Angle (',char(176),')']';
			Y_Label = ['Maximal Angle (',char(176),')'];
			Title = 'Minimal and Maximal Angles of 3-Way junctions';
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,[],Var_Operations,Filter_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GP,GP.Visuals,X_Label,Y_Label,Title);
			axis([0,2.2,2,4].*180./pi);
		case 'The Two Minimal Angles of each 3-Way junction'
			Var_Operations{1} = @(x) x(x == min(x));
			Var_Operations{2} = @(x) x(x ~= min(x) & x~=max(x));
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Minimal Angle';
			Y_Label = 'Mid-size Angle';			
			Title = 'The Two Minimal Angles of each 3-Way junction';
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GP,GP.Visuals,X_Label,Y_Label,Title);
		case 'Menorah Orders of 3-Way Junctions'
				
			Workspace_Set = Workspace_Set{1};
				
				% TODO:
					% Look at the histogram of angles between specific pairs of orders (either only the smallest or all within one junction).
					% Make a 2D plot with some order on the angles.
				
				Junction_Classes = [112,233,234,334,344];
				Edges = 0:0.05:1;
				
				A1 = nan(1,10^4); % Smallest Angle.
				A2 = nan(1,10^4); % Largest Angle.
				D = nan(1,10^4); % Midline Distance.
				L = nan(1,10^4); % Midline Arc-length.
				S = nan(1,10^4); % Symmetry Index.
				C = nan(1,10^4); % Vertex class (Menorah orders).
				ii = 0;
				l = 3;
				for w=1:length(Workspace_Set)
					
					ww = Workspace_Set(w);
					
					Midline_Length = GP.Workspace(ww).Workspace.Axes.Axis_0(end).Arc_Length;
					for v=1:numel(GP.Workspace(ww).Workspace.All_Vertices)
						% if(ismember(GP.Workspace(ww).Workspace.All_Vertices(v).Class,Junction_Classes))
						if(GP.Workspace(ww).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(ww).Workspace.All_Vertices(v).Angles]) == 3)
							
							ii = ii + 1;
							
							Vi = [GP.Workspace(ww).Workspace.All_Vertices(v).Angles];
							
							A1(ii) = min(Vi);
							A2(ii) = max(Vi);
							% D(ii) = GP.Workspace(ww).Workspace.All_Vertices(v).Midline_Distance;
							D(ii) = GP.Workspace(ww).Workspace.All_Vertices(v).Midline_Distance ./ (2.*(GP.Workspace(ww).Workspace.All_Vertices(v).Half_Radius));
							L(ii) = GP.Workspace(ww).Workspace.All_Vertices(v).Axis_0_Position ./ Midline_Length; %  ./ (2.*(GP.Workspace(ww).Workspace.All_Vertices(v).Half_Radius));
							S(ii) = Vertices_Symmetry_Linearity(Vi);
							
							C(ii) = GP.Workspace(ww).Workspace.All_Vertices(v).Class;
						end
					end
				end
				A1 = A1(1:ii)*180/pi;
				A2 = A2(1:ii)*180/pi;
				D = D(1:ii);
				S = S(1:ii);
				L = L(1:ii);
				C = C(1:ii);
				
				F1 = find(~isnan(C)); disp(length(F1));
				D = D(F1);
				S = S(F1);
				L = L(F1);
				C = C(F1);
				
				% Vc = unique(C);
				Nc = length(Junction_Classes);
				CM = lines(Nc); % Number of classes.
				Mc = zeros(Nc,length(Edges)-1);
				for c=1:Nc % For each class.
					Fc = find(C == Junction_Classes(c));
					C(Fc) = c; % Replace the classes in C with integers in the range [1,max(class_num)].
					if(0)
						scatter(C(Fc),D(Fc),20,CM(C(Fc),:),'filled');
						ylabel('Menorah Order');
					else
						scatter(S(Fc),D(Fc),20,CM(C(Fc),:),'filled');
						% scatter(L(Fc),D(Fc),20,CM(C(Fc),:),'filled');
						% scatter3(A1(Fc),A2(Fc),D(Fc),20,CM(C(Fc),:),'filled'); % 3D plot.
						xlabel('Symmetry Index');
					end
				end
				
				ylabel(['Midline Distance [normalized]']); % [',char(181),'m]
				set(gca,'FontSize',22);
				
				legend(string(Junction_Classes),'FontSize',14);
		case 'Angles of Menorah Orders'
			
			Workspace_Set = Workspace_Set{1};
			
			Junction_Classes = [1,1,2 ; 2,3,3 ; 2,3,4 ; 3,3,4 ; 3,4,4]; % Junction_Classes = [112,233,334];
			Lc = length(Junction_Classes);
			
			% for c=1:Lc
			% 	Junction_Classes_Strings{c} = [num2str(c),'<->',num2str(c+1)];
			% end
			
			A1 = cell(1,size(Junction_Classes,1));
			A2 = cell(1,size(Junction_Classes,1));
			A3 = cell(1,size(Junction_Classes,1));
			for w=Workspace_Set
				for v=1:numel(GP.Workspace(w).Workspace.Vertices)
					
					R = GP.Workspace(w).Workspace.Vertices(v).Rectangles;
					if(numel(R) == 3 && isfield(R,'Corrected_Angle') && all([R.Corrected_Angle]))
						[~,c] = ismember(GP.Workspace(w).Workspace.Vertices(v).Class,Junction_Classes,'rows');
                        c = 1;
						if(1)
							Vr = [GP.Workspace(w).Workspace.Vertices(v).Rectangles.Segment_Class]; % Vector of rectangles classes.
							Va = [GP.Workspace(w).Workspace.Vertices(v).Rectangles.Corrected_Angle]; % Vector of rectangles angles.
							
							% d = min([GP.Workspace(w).Workspace.Vertices(v).Angles]); % A vector of the angles between the rectangles of the junction.
							d = [GP.Workspace(w).Workspace.Vertices(v).Corrected_Angles]; % A vector of the angles between the rectangles of the junction.
							% [Sym,Lin,~] = Vertices_Symmetry_Linearity(d);
							
							if(0) % Just use the minimal angle.
								A1{c}(end+1) = min(d);
								A2{c}(end+1) = max(d);
								A3{c}(end+1) = GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance;
							else
								% o1 = min(Vr);
								m = find(Vr == min(Vr)); % Row numbers of the minimal class.
								M = find(Vr == max(Vr)); % Row numbers of the maximal class.
								
								Vc = combvec(m,M); % All possible combinations of row numbers of the min and max orders.
								d = nan(1,size(Vc,2));
								for r=1:size(Vc,2) % For each combination (1st row is the lower class, 2nd row is the higher class).
									da = max([Va(Vc(2,r)),Va(Vc(1,r))]) - min([Va(Vc(2,r)),Va(Vc(1,r))]); % Angle diff between a pair of rectangles (min and max class).
									d(r) = min([da,2*pi-da]); % Taking the smaller angle.
								end
								A1{c}(end+1) = mean(d); % Take the mean angle of all the angles between order o and o+1.
								% A2{c}(end+1) = Sym;
								% A1{c}(end+1) = min(d); % Take the min angle of all the angles between order o and o+1.
							end
						end
					end
				end
			end
			
			Edges_Ang = 0:5:180;
			Edges_Sym = 0:0.025:1;
			yy_ang = 0.22;
			yy_sym = 0.125;
			
			Np = 3; % Max number of peaks.
			MinPeakProm = 0.02;
			Vx = [];
			Vg = [];
			CM = jet(size(Junction_Classes,1));
			for c=1:Lc % For each class.
				Vx = [Vx,A1{c}];
				Vg = [Vg,c*ones(1,length(A1{c}))];
				scatter(c*ones(1,length(A1{c})),A1{c}.*180./pi,4,'k','filled','Jitter','On','JitterAmount',0.3);
				% scatter(A1{c},A2{c},20,CM(c,:),'filled');
				% scatter3(A1{c},A2{c},A3{c},20,CM(c,:),'filled');
				% hold on;
				%{
				subplot(2,Lc,c);
					histogram(A1{c}.*180./pi,Edges_Ang,'Normalization','probability'); % histogram(A1{c}.*180./pi,0:3:180); % scatter(c.*ones(1,length(A1{c})),A1{c},20,'k','filled');
					hold on;
					% plot(mean(A1{c}.*180./pi)+[1,1],[0,0.16],'--k','LineWidth',2);
					
					N = histcounts(A1{c}.*180./pi,Edges_Ang,'Normalization','probability');
					xx = (Edges_Ang(2:end) + Edges_Ang(1:end-1)) ./ 2;
					findpeaks(N,xx,'SortStr','descend','NPeaks',Np,'MinPeakProminence',MinPeakProm,'WidthReference','halfheight'); % ,'Annotate','extents'
					
					xlim([Edges_Ang(1),Edges_Ang(end)]);
					ylim([0,yy_ang]);
					% title([num2str(c),'<->',num2str(c+1)]);
					legend([num2str(c),'<->',num2str(c+1)],'Location','northwest'); % legend({'1<->2','2<->3','3<->4'}); % legend(string(Junction_Classes));
					xlabel(['Angle (',char(176),')']);
					ylabel('Probability');
					set(gca,'FontSize',26);
					axis square;
				
				subplot(2,Lc,c+Lc);
					histogram(A2{c},Edges_Sym,'Normalization','probability');
					hold on;
					
					N = histcounts(A2{c},Edges_Sym,'Normalization','probability');
					xx = (Edges_Sym(2:end) + Edges_Sym(1:end-1)) ./ 2;
					findpeaks(N,xx,'SortStr','descend','NPeaks',Np,'MinPeakProminence',MinPeakProm,'WidthReference','halfheight'); % ,'Annotate','extents'
					
					xlim([Edges_Sym(1),Edges_Sym(end)]);
					ylim([0,yy_sym]);
					legend([num2str(c),'<->',num2str(c+1)],'Location','northwest');
					xlabel(['Symmetry']);
					ylabel('Probability');
					set(gca,'FontSize',26);
					axis square;
				%}
			end
			
			H = boxplot(Vx.*180./pi,Vg,'Labels',Junction_Classes); % Junction_Classes. {'1<->2','2<->3','3<->4'}
			set(H,{'linew'},{4});
			xlabel('$Junction \; Class$','Interpreter','Latex');
			ylabel('$Mean \; Angle \; (^ \circ)$','Interpreter','Latex');
			set(gca,'FontSize',36);
			
		case 'Linearity-Symmetry of 3-Way junctions'
			
			Workspace_Set = Workspace_Set{1};
			
			S = zeros(1,10^4);
			L = zeros(1,10^4);
			D = zeros(1,10^4);
			ii = 0;
			for w=Workspace_Set
				for v=1:numel(GP.Workspace(w).Workspace.All_Vertices)
					if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.All_Vertices(v).Angles]) == 3)
						V = GP.Workspace(w).Workspace.All_Vertices(v).Angles;
						[Sym,Lin,~] = Vertices_Symmetry_Linearity(V);
						ii = ii + 1;
						S(ii) = Sym;
						L(ii) = Lin;
						D(ii) = abs(GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance ./ (2.*(GP.Workspace(w).Workspace.All_Vertices(v).Half_Radius)));
					end
				end
			end
			S = S(1:ii);
			L = L(1:ii);
			D = rescale(D(1:ii))';
			disp(ii);
			
			scatter(S,L,10,[1-D,0.*D,D],'filled');
			
		case 'Inter-Tip Distance'
			
			Workspace_Set = Workspace_Set{1};
			
			Worm_Radium_Max = 50; % um;
			Bin_Vector = 0:1:Worm_Radium_Max;
			
			V_Dist = [];
			for w=Workspace_Set
				F = find([GP.Workspace(w).Workspace.Points.Vertex_Order] == 1 & [GP.Workspace(w).Workspace.Points.Class] == 4 & [GP.Workspace(w).Workspace.Points.Midline_Distance] < Worm_Radium_Max); % Find all 4th order tips.
				
				X = [GP.Workspace(w).Workspace.Points(F).X];
				Y = [GP.Workspace(w).Workspace.Points(F).Y];
				
				% For each 4th-order tip, find the distance to the closest tip (excluding itself):
				V_Dist_w = nan(1,length(X));
				for p=1:length(X)
					Dp = ( (X(p) - X).^2 + (Y(p) - Y).^2 ).^0.5;
					Dp(Dp == 0) = nan; % Setting distance zero to nan to exclude the distance of the vertex from itself.
					% Fmin = Find(Dp == min(Dp),1);
					
					V_Dist_w(p) = min(Dp) .* GP.Workspace(w).Workspace.User_Input.Scale_Factor;
				end
				V_Dist = [V_Dist,V_Dist_w];
			end
			
			histogram(V_Dist,Bin_Vector,'Normalization','Probability');
			xlabel(['Distance [',char(181),'m]']);
			ylabel('Probability');
			% legend(['Menorah Order = ',num2str(o)]);
			% title(GP.General.Active_Plot);
			set(gca,'FontSize',22);
			xlim([0,Worm_Radium_Max]);
		case 'Distribution of Segment Lengths Per Order'
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized','Total Length','Probability'});
			set(GP.Handles.Plot_Type_List,'String',{'Distribution','Mean'});
			
			Ng = length(Workspace_Set);
			CM = lines(Ng);
			Menorah_Classes = 1:4;
			
			Length_Field = 'Length_Corrected';
			
			Bin_Vector = 0:1:50;
			SP = 0.8; % Smoothing parameter.
			
			xx = (Bin_Vector(1:end-1) + Bin_Vector(2:end)) ./  2;
			
			H = [];
			N = cell(1,Ng);
			V = cell(1,Ng);
			% N_Total = cell(1,Ng);
			for g=1:Ng
				N{g} = nan(length(Workspace_Set{g}),length(xx),length(Menorah_Classes));
				V{g} = nan(length(Workspace_Set{g}),length(Menorah_Classes));
				% N_Total{g} = nan(length(Workspace_Set{g}),length(xx));
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					Total_Length = ones(1,length(Menorah_Classes));
					% V_Total = [];
					
					for o=1:length(Menorah_Classes)
						F1 = find([GP.Workspace(ww).Workspace.Segments.Class] == Menorah_Classes(o));
						
						switch(GP.Handles.Normalization_List.Value)
							case 1 % No normalization.
								% Total_Length(o) = 1;
								Normalization = 'count';
							case 2 % Each order is divided by the total length of that order.
								f1 = find([GP.Workspace(ww).Workspace.Points.Segment_Class] == Menorah_Classes(o));
								Total_Length(o) = nansum([GP.Workspace(ww).Workspace.Points(f1).(Length_Field)]); % Total length of order Menorah_Classes(o).
								Normalization = 'count';
							case 3 % Each order is normalized to 1.
								Normalization = 'Probability';
						end
						
						v = nan(1,length(F1));
						for s=1:length(F1) % For each segment of order o in animal w.
							% if(GP.Workspace(ww).Workspace.Segments(F1(s)).Terminal == 1) % Uncomment to exclude tips (== 0). Change to 1 to show only tips.
								F2 = find([GP.Workspace(ww).Workspace.Points.Segment_Index] == GP.Workspace(ww).Workspace.Segments(F1(s)).Segment_Index);
								v(s) = nansum([GP.Workspace(ww).Workspace.Points(F2).(Length_Field)]);
							% end
                        end
						v = v(~isnan(v));
						
						N{g}(w,:,o) = histcounts(v,Bin_Vector,'Normalization',Normalization) ./ Total_Length(o); % N{g}(w,:,o) = histcounts(V ./ Total_Length(o),Bin_Vector ./ Total_Length(o));
						V{g}(w,o) = nansum(v) ./ Total_Length(o);
						X{g}{w,o} = v;
						% disp(sum(N{g}(w,:,o)));
						% V_Total = [V_Total,v];
					end
					% N_Total{g}(w,:) = histcounts(V_Total ./ sum(Total_Length),Bin_Vector ./ sum(Total_Length));
					% N_Total{g}(w,:) = histcounts(V_Total,Bin_Vector) ./ sum(Total_Length);
				end
			end
			% disp('************');
			
			switch(GP.Handles.Plot_Type_List.Value)
			case 1 % Histogram.
				for o=1:length(Menorah_Classes)
					subplot(2,2,o);
					
					for g=1:Ng
						% bar(xx,mean(N{g}(:,:,o),1)','BarWidth',1,'FaceAlpha',0.5); % Average bins across animals.
                        histogram(cat(2,X{g}{:,o}),Bin_Vector,'Normalization','Probability'); % this uses all the values as one group.
						hold on;
						% disp(sum(sum(N{g}(:,:,o))));
					end
					
					xlabel('$$Segment \; Length \; (\mu m)$$','Interpreter','Latex');
					switch(GP.Handles.Normalization_List.Value)
						case 1
							ylabel('$$Count$$','Interpreter','Latex');
						case 2
							ylabel('$$\frac{Count}{Total \; Length}$$','Interpreter','Latex');
						case 3
							ylabel('$$Probability$$','Interpreter','Latex');
					end
					
					title(['Menorah Order = ',num2str(o)],'Interpreter','Latex');
					legend(Groups,'Interpreter','Latex');
					
					set(gca,'FontSize',22,'TickLabelInterpreter','Latex');
					xlim([0,Bin_Vector(end)]);
						
					% disp([Groups{g},'(',num2str(o),'): ',num2str(nanmean(V_Length)),' ',char(177),' ',num2str(nanstd(V_Length))]);
				end
			case 2
				for g=1:Ng
					M(:,g) = nanmean(V{g},1); % Average across animals, for each order separately.
					S(:,g) = nanstd(V{g},0,1);
				end
				
				H = bar(1:length(Menorah_Classes),M,'hist','FaceColor','flat');
				
				hold on;
				for g=1:Ng
					H(g).FaceColor = CM(g,:);
					errorbar(mean(H(g).XData,1),M(:,g),S(:,g),'Color','k','LineWidth',2,'LineStyle','none');
				end
				xlabel('$$Class$$','Interpreter','Latex');
				switch(GP.Handles.Normalization_List.Value)
					case 1
						ylabel('$$Length$$','Interpreter','Latex');
					case 2
						ylabel('$$\frac{Length}{Total \; Length}$$','Interpreter','Latex');
					case 3
						ylabel('$$Probability$$','Interpreter','Latex');
				end
				
				legend(Groups,'Interpreter','Latex');
				set(gca,'FontSize',22,'TickLabelInterpreter','Latex');
				
				if(Ng > 1)
					disp(['Total Length of Termimal Segments - Stats:']); % First bin.
					for o=1:length(Menorah_Classes)
						[PVal,Test_Name] = Stat_Test(V{1}(:,o),V{2}(:,o));
						disp(['Menorah Order = ',num2str(Menorah_Classes(o)),': P-Value = ',num2str(PVal),' (',Test_Name,')']);
					end
				end
			end
			
			%{
			figure; % Compare first bin.
			CM = lines(Ng);
			M = [];
			for g=1:Ng
				M(:,g) = squeeze(nanmean(N{g}(:,1,:),1)); % Mean across animals.
				S(:,g) = squeeze(nanstd(N{g}(:,1,:),0,1)); % std across animals.
			end
			H = bar(1:length(Menorah_Classes),M,'hist','FaceColor','flat','BarWidth',1,'FaceAlpha',0.5); % Average bins across animals.
			
			hold on;
			for g=1:Ng
				H(g).FaceColor = CM(g,:);
				errorbar(mean(H(g).XData,1),M(:,g),S(:,g),'Color','k','LineWidth',2,'LineStyle','none');
			end
			xlabel('$$Menorah Order$$','Interpreter','Latex');
			
			switch(GP.Handles.Normalization_List.Value)
				case 1
					ylabel('$$Count$$','Interpreter','Latex');
				case 2
					ylabel('$$\frac{Count}{Total \; Length}$$','Interpreter','Latex');
			end
			set(gca,'FontSize',22,'TickLabelInterpreter','Latex');
			legend(Groups,'Interpreter','Latex');
			
			set(gca,'Position',[0.05,0.1,0.92,0.86]);
			
			if(Ng > 1)
				disp(['Number of Short segments - Stats:']); % First bin.
				for o=1:length(Menorah_Classes)
					[PVal,Test_Name] = Stat_Test(squeeze(N{1}(:,1,o)),squeeze(N{2}(:,1,o)));
					disp(['Menorah Order = ',num2str(Menorah_Classes(o)),': P-Value = ',num2str(PVal),' (',Test_Name,')']);
				end
			end
			
			% Total length of first bin
			figure;
			CM = lines(Ng);
			M = [];
			S = [];
			for g=1:Ng
				M(:,g) = squeeze(nanmean(N_Total{g}(:,1),1)); % Average across animals.
				S(:,g) = squeeze(nanstd(N_Total{g}(:,1),0,1)); % std across animals.
			end
			H = bar(M,'hist','FaceColor','flat','BarWidth',1,'FaceAlpha',0.5); % Average bins across animals.
			
			hold on;
			for g=1:Ng
				% H(g).FaceColor = CM(g,:);
				errorbar(g,M(:,g),S(:,g),'Color','k','LineWidth',2,'LineStyle','none');
			end
			% xlabel('$$Menorah Order$$','Interpreter','Latex');
			
			switch(GP.Handles.Normalization_List.Value)
				case 1
					ylabel('$$Count$$','Interpreter','Latex');
				case 2
					ylabel('$$\frac{Count}{Total \; Length}$$','Interpreter','Latex');
			end
			set(gca,'FontSize',22,'TickLabelInterpreter','Latex');
			legend(Groups,'Interpreter','Latex');
			
			set(gca,'Position',[0.05,0.1,0.92,0.86]);
			
			if(Ng > 1)
				disp(['Number of Short segments - Stats:']); % First bin.
				[PVal,Test_Name] = Stat_Test(N_Total{1}(:,1),N_Total{2}(:,1));
				disp(['P-Value = ',num2str(PVal),' (',Test_Name,')']);
			end
			
			%}
			
			
		case {'Histogram of all Angles'}
			
			BinSize = 3;
			Edges = 0:BinSize:300;
			
			set(P.GUI_Handles.Control_Panel_Objects(2,4),'Items',{'Not Normalized'},'ItemsData',1);
			set(P.GUI_Handles.Control_Panel_Objects(4,4),'Items',{'Default','Sort by size'},'ItemsData',1:2);
			
			V = cell(1,length(Workspace_Set));
			for g=1:length(Workspace_Set)
				V{g} = zeros(3,0);
				ii = 0;
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					for v=1:numel(Data(ww).Vertices) % For each vertex.
						if(Data(ww).Vertices(v).Order == 3 && length([Data(ww).Vertices(v).Corrected_Angles]) == 3) % Corrected_Angles
							% if(1)
							% if(isequal([Data(ww).Vertices(v).Class],[3,3,4]))
								ii = ii + 1;
								V{g}(:,ii) = sort([Data(ww).Vertices(v).Corrected_Angles]);
							% end
						end
					end
				end
				V{g} = V{g}(:,1:ii);
			end
			
			% assignin('base','A123',V);
			
			switch(P.GUI_Handles.Control_Panel_Objects(4,4).Value)
				case 1
					for g=1:length(Workspace_Set)
						Ax(g) = subplot(1,length(Workspace_Set),g,'Parent',P.GUI_Handles.Main_Panel_1);
						histogram(Ax(g),V{g}(:).*180./pi,Edges);
						
						xlim(Ax(g),[0,360]);
						set(Ax(g),'XTick',0:30:360,'TickLabelInterpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
						xlabel(Ax(g),'$\mathrm{Angle \; [^{\circ}]}$','Interpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						ylabel(Ax(g),'$\mathrm{Count}$','Interpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						grid(Ax(g),'on');
						box(Ax(g),'on');
					end
				case 2
					for g=1:length(Workspace_Set)
						Ax(g) = subplot(1,length(Workspace_Set),g,'Parent',P.GUI_Handles.Main_Panel_1);
						histogram(Ax(g),V{g}(1,:).*180./pi,Edges);
						hold(Ax(g),'on');
						histogram(Ax(g),V{g}(2,:).*180./pi,Edges);
						histogram(Ax(g),V{g}(3,:).*180./pi,Edges);
						
						xlim(Ax(g),[0,360]);
						set(Ax(g),'XTick',0:30:360,'TickLabelInterpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Ticks_FontSize);
						xlabel(Ax(g),'$\mathrm{Angle \; [^{\circ}]}$','Interpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						ylabel(Ax(g),'$\mathrm{Count}$','Interpreter','Latex','FontSize',P.GUI_Handles.Plots.Axis_Title_FontSize);
						grid(Ax(g),'on');
						box(Ax(g),'on');
						% Plot_3Angles_Junction_Histogram(V{g},BinSize,Title);
					end
			end
	end
	% box(Ax1,'on');
	% set(GP.Handles.Axes,'unit','normalize');
	% set(GP.Handles.Axes,'position',[0,0,1,1]);
	% axis tight;
	
	% assignin('base','Input_Struct',Input_Struct);
	% set(GP.Handles.Analysis.Slider,'UserData',0); % Used as a flag to tell if this script was run as a result of the use of this slider.
	
	function Set_Dynamic_Sliders_Values(Handles,Min_Value,Max_Value)
		set(Handles.Dynamic_Slider_Min,'Enable','on');
		set(Handles.Dynamic_Slider_Max,'Enable','on');
		if(Handles.Dynamic_Slider_Min.Min ~= Min_Value || Handles.Dynamic_Slider_Min.Max ~= Max_Value || ...
			Handles.Dynamic_Slider_Max.Min ~= Min_Value || Handles.Dynamic_Slider_Max.Max ~= Max_Value) % Update the slider only if the max or min have changed. Otherwise, keep the last chosen values.
			Handles.Dynamic_Slider_Min.Min = Min_Value; % Scale dynamic sliders.
			Handles.Dynamic_Slider_Min.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Max.Min = Min_Value;% ".
			Handles.Dynamic_Slider_Max.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Min.Value = Min_Value;
			Handles.Dynamic_Slider_Max.Value = Max_Value;
			Handles.Dynamic_Slider_Text_Min.String = [num2str(Handles.Dynamic_Slider_Min.Value),char(181),'m']; % Update sliders text.
			Handles.Dynamic_Slider_Text_Max.String = [num2str(Handles.Dynamic_Slider_Max.Value),char(181),'m']; % ".
		end
	end
	
	function out = Fan(x,m,M)
		ss = sum(x >= m & x<= M);
		if(ss == 0)
			out = [];
		else
			out = ss;
		end
	end
end