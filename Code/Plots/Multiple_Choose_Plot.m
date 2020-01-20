function Multiple_Choose_Plot(GP)
	
	% This function...
	% 
	% 
	% 
	% The flag RowWise tells the Generate_Plot_Input() function to perform the field operation in a row-wise manner.
		% For example, this is necessary in cases in which a second field is used to filter out rows (e.g. vertex order).
	
	
	% Note: When using a field to filter-out rows, the # of values in different fields can be different.
		% This means that values in corresponding positions don't correspond. But that's ok because the filtering field is not analyzed.
		% Example: using the "order" field to include only 3rd order junctions, and the "Angle" field which can contain any number (>0) of values.	
	
	% Var_Operations is a function to operate on the values vector of each single workspace (= animal).
	
	% Note: RowWise must be set to 1 if: one of the field is a vector AND thes values won't be simply combined with all the rest (other rows).
	
	% assignin('base','GP2',GP);
	
	% Impotrant TODO:
		% The Angles field now contains the angle for tips (instead of -1).
		% Some of the plots here rely on that -1 to filter out tips.
		% Instead, I should change it to use the order field as a filter.
	%
	
	switch(GP.Handles.Workspace_Mode.Value)
		case 1 % Use all workspaces.
			Groups = cell(1,max([GP.Workspace.Genotype]));
			for g=1:max([GP.Workspace.Genotype])
				Workspace_Set{g} = find([GP.Workspace.Genotype] == g);
				Groups{g} = GP.Workspace(Workspace_Set{g}(1)).Workspace.User_Input.Features.Genotype;
			end
			% Workspace_Set = 1:numel(GP.Workspace);
		case 2 % Use current workspace.
			Workspace_Set = GP.Handles.Im_Menu.UserData;
	end
	
	if(1)
		figure(1);
		hold on;
	else
		figure('WindowState','maximized');
		GP.Handles.Axes = axes;
		hold on;
	end
	
	FontSize_1 = 36;
	
	% assignin('base','GP',GP);
	
	% set(GP.Handles.Normalization_List,'String',{'Not Normalized'},'Value',1);
	set(GP.Handles.Analysis.Dynamic_Slider_Min,'Enable','off');
	set(GP.Handles.Analysis.Dynamic_Slider_Max,'Enable','off');
	
	switch GP.General.Active_Plot
		case 'Number of Segments'
			% TODO: this could be replaced by a sums plot (similar to Means_Plot) but currently Generate_Plot_Input does not differentiate betweern workspaces.
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			m = GP.Handles.Analysis.Dynamic_Slider_Min.Value;
			M = GP.Handles.Analysis.Dynamic_Slider_Max.Value;
			Var_Operations{1} = @(x) Fan(x,m,M); % Summing up the logical 1s (but only taking positive sums).
			Filter_Operations = [];
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = [];
			%
			RowWise = 0;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%
			Y_Label = 'Count';
			Title = 'Number of Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		case 'Number of Terminal Segments'
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			m = GP.Handles.Analysis.Dynamic_Slider_Min.Value;
			M = GP.Handles.Analysis.Dynamic_Slider_Max.Value;
			Var_Operations{1} = @(x) sum(x >= m & x<= M); % Summing up the logical 1s.
			Var_Operations{2} = @(x) sum(x >= m & x<= M); % Summing up the logical 1s.
			Filter_Operations = [];
			Var_Fields = {'Distance_From_Medial_Axis','Terminal'};
			Filter_Fields = [];
			%
			RowWise = 0;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%
			Y_Label = 'Count';
			Title = 'Number of Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
		case 'Mean Segment Length'
			Var_Operations{1} = @(x) x(x>=0); % The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Length'};
			Filter_Fields = [];
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Length (\mum)';
			Title = 'Mean Length of Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
		case 'Total Length'
			Var_Operations{1} = @(x) sum(x(x>=0)); % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Length'};
			Filter_Fields = [];
			%
			set(GP.Handles.Normalization_List,'String',{'Not Normalized','Normalized to Primary Branch'});
			set(GP.Handles.Plot_Type_List,'String',{'Default','Box Plot'});
			%
			RowWise = 0;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Length (\mum)';
			Title = 'Total Length';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
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
			
		case 'Mean Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Curvature'};
			Filter_Fields = {};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Mean Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature of Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
		case 'Max Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Max_Curvature'};
			Filter_Fields = {};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			Y_Label = 'Max Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature of Segments';
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GP,GP.Visuals,Y_Label,Title);
			
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
			
		
		case {'Midline Distance of All Points','Midline Distance of 3-Way Junctions','Midline Distance of Tips','Midline Distance of All Points - MoI'}
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized','Normalized to Local Radii'});
			set(GP.Handles.Plot_Type_List,'String',{'Default','Dorsal-Ventral Merged','Color Gradient'});
			
			switch(GP.Handles.Normalization_List.Value)
				case 1 % Not Normalized.
					if(~GP.Handles.Analysis.Slider.UserData)
						set(GP.Handles.Analysis.Slider,'Min',1,'Max',6,'Value',2,'SliderStep',[0.2,1]);
					end
					Edges = -45:GP.Handles.Analysis.Slider.Value:45;
				case 2 % Normalized to both radii.
					if(~GP.Handles.Analysis.Slider.UserData)
						set(GP.Handles.Analysis.Slider,'Min',0.01,'Max',.11,'Value',0.05,'SliderStep',[0.1,0.2]);
					end
					Edges = -1:GP.Handles.Analysis.Slider.Value:1;
			end
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			set(GP.Handles.Analysis.Slider_Text,'String',num2str(GP.Handles.Analysis.Slider.Value));
			
			switch GP.General.Active_Plot
				case {'Midline Distance of Tips','Midline Distance of All Points - MoI'}
					Vertex_Order = 1;
					Vertex_Order_Func = @(X) find(X == Vertex_Order);
				case 'Midline Distance of All Points'
					% Vertex_Order = 2;
					Vertex_Order_Func = @(X) find(X); % Include vertices.
				case 'Midline Distance of 3-Way Junctions'
					Vertex_Order = 3;
					Vertex_Order_Func = @(X) find(X == Vertex_Order);
			end
			
			if(~strcmp(GP.General.Active_Plot(end-2:end),'MoI'))
				Workspace_Set = Workspace_Set(1);
			end
			
			for g=1:length(Workspace_Set)
				X{g} = nan(length(Workspace_Set{g}),length(xx));
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					Fx = Vertex_Order_Func([GP.Workspace(ww).Workspace.All_Points.Vertex_Order]);
					Xw = [GP.Workspace(ww).Workspace.All_Points(Fx).Midline_Distance];
					switch GP.Handles.Normalization_List.Value
						case 1
							X{g}(w,:) = histcounts(Xw,Edges,'Normalization','Probability');
						case 2
							R3 = [GP.Workspace(ww).Workspace.All_Points(Fx).Half_Radius]; % Half-radius (on the same side that the point is).
							R4 = [GP.Workspace(ww).Workspace.All_Points(Fx).Radius]; % Radius (on the same side that the point is).
							[Xw,Fin] = Scale_Midline_Distance_To_Local_Radii(Xw,R3,R4);
							X{g}(w,:) = histcounts(Xw(Fin),Edges,'Normalization','Probability');
							% TODO: For each point check if D/V and save both radii.
					end
				end
				switch(GP.Handles.Plot_Type_List.Value)
					case 2
						X{g} = abs(X{g});
						Edges = 0:GP.Handles.Analysis.Slider.Value:Edges(end);
				end
			end
			
			if(strcmp(GP.General.Active_Plot(end-2:end),'MoI'))
				for g=1:length(Workspace_Set)
					MoI = sum(X{g} .* (xx.^2),2); % disp(['Moment of Inertia = ',num2str(sum(N .* (xx.^2)))]);
					bar(g,mean(MoI));
					errorbar(g,mean(MoI),std(MoI),'Color','k','LineWidth',2,'LineStyle','none');
				end
				set(gca,'XTick',1:length(Workspace_Set),'XTickLabels',Groups);
				ylabel('Moment of Inertia');
				grid on;
			else
				H = bar(xx,mean(X{1},1),1,'FaceColor','flat');
				
				if(GP.Handles.Plot_Type_List.Value == 3)
					L_D = find(xx >= 0); % # of bars.
					L_V = find(xx < 0); % # of bars.
					CM = hsv(max(length(L_D),length(L_V)));
					H.CData(L_D,:) = CM(1:length(L_D),:);
					H.CData(L_V,:) = flipud(CM(1:length(L_V),:));
				end
				
				switch(GP.Handles.Normalization_List.Value)
					case 1
						xlabel(['Midline Distance [',char(181),'m]']);
					case {2,3}
						xlabel(['Midline Distance [normalized]']);
				end
				xlim([Edges(1),Edges(end)]);
				ylabel('Count');
				grid on;
			end
			
			set(gca,'FontSize',FontSize_1);
			% set(gca,'position',[0.1,0.1490,0.87,0.7760]);
		
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
			
		case 'Distribution of Max Squared Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Max_Curvature'};
			Filter_Fields = {};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			X_Label = 'Squared Curvature (1/(\mum)^2)';
			Y_Label = 'Count';
			Title = 'Max of Squared Curvature of Segments';
			%
			X_Min_Max = [0,0.1];
			BinSize = 0.005 .* GP.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GP,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);		
			
		case 'Distribution of Min Medial Angle Diff'
			Var_Operations{1} = @(x) x(x>=0) .*180 ./ pi;
			Filter_Operations = {};
			Var_Fields = {'Min_Medial_Angle_Corrected_Diff'};
			Filter_Fields = [];
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
			%
			X_Label = ['Angle (',char(176),')'];
			Y_Label = 'Count';
			Title = 'Minimal Difference between Medial Angle and Vertex Angles';
			%
			X_Min_Max = [0,180];
			BinSize = 20 .* GP.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
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
			
			Class_Indices = [1,2,3,3.5,4,5];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0,0.8,0.8 ; 0,0,1 ; 0.8,0.8,0 ; 0.5,0.5,0.5];
			colormap(Class_Colors);
			Max_PVD_Orders = length(Class_Colors);
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized','Normalized to Midline Length','Normalized to Total Length'});
			set(GP.Handles.Plot_Type_List,'String',{'Default','Dorsal-Ventral Merged','Orders Merged'}); % ,'All Merged'});
			
			% switch GP.Handles.Normalization_List.Value
			% end
			
			for g=1:length(Workspace_Set)
				M{g} = zeros(length(Class_Indices) , length(Workspace_Set{g}) , 2); % Class x workspace x dorsal-ventral.
				
				for w=1:length(Workspace_Set{g})
					ww = Workspace_Set{g}(w);
					
					switch GP.Handles.Normalization_List.Value
						case 1
							Normalization_Length = 1;
							YLIM = [-1000,1000];
						case 2 % Normalized to Midline Length.
							Normalization_Length = GP.Workspace(ww).Workspace.Neuron_Axes.Axis_0(end).Arc_Length;
							YLIM = [-1.25,1.25];
						case 3 % Normalized to Total Length.
							Normalization_Length = sum([GP.Workspace(ww).Workspace.All_Points.Length]);
							YLIM = [-1,1];
					end
					
					for s=1:numel(GP.Workspace(ww).Workspace.Segments)
						
						Fs = find([GP.Workspace(ww).Workspace.All_Points.Segment_Index] == GP.Workspace(ww).Workspace.Segments(s).Segment_Index);
						f_D = Fs(find([GP.Workspace(ww).Workspace.All_Points(Fs).Midline_Distance] >= 0)); % Find all dorsal points that belong to segment s.
						f_V = Fs(find([GP.Workspace(ww).Workspace.All_Points(Fs).Midline_Distance] < 0)); % Find all ventral points that belong to segment s.
						o = find(Class_Indices == GP.Workspace(ww).Workspace.Segments(s).Class); % Find the index of the segment's class.
						
						if(~isempty(o)) % If the class exists in the Class_Indices vector.
							
							M{g}(o,w,1) = M{g}(o,w,1) + (sum([GP.Workspace(ww).Workspace.All_Points(f_D).Length]) ./ Normalization_Length);
							M{g}(o,w,2) = M{g}(o,w,2) + (sum([GP.Workspace(ww).Workspace.All_Points(f_V).Length]) ./ Normalization_Length);
						end
					end
				end
            end
			
            CM = lines(length(Workspace_Set));
			switch(GP.Handles.Plot_Type_List.Value)
				case 1
					for g=1:length(Workspace_Set)
						B_D(:,g) = mean(M{g}(:,:,1),2);
						B_V(:,g) = -mean(M{g}(:,:,2),2);
					end
					H_D = bar(1:Max_PVD_Orders,B_D,0.8,'hist','FaceColor','flat');
					hold on;
					H_V = bar(1:Max_PVD_Orders,B_V,0.8,'hist','FaceColor','flat');
					
					for g=1:length(Workspace_Set)
						H_D(g).FaceColor = CM(g,:); % Class_Colors(o,:);
						H_V(g).FaceColor = CM(g,:); % Class_Colors(o,:);
						
						errorbar(mean(H_D(g).XData,1),B_D(:,g),std(M{g}(:,:,1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						errorbar(mean(H_V(g).XData,1),B_V(:,g),std(M{g}(:,:,1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					xlabel(['Menorah Order']);
					ylabel(['Neuronal Length  [',char(181),'m]']);
					ylim(YLIM);
					set(gca,'FontSize',FontSize_1);
					set(gca,'YTickLabels',abs(get(gca,'YTick')));
					legend(Groups);
					grid on;
					set(gca,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices);
				case 2 % Dorsal-ventral merged.
					for g=1:length(Workspace_Set)
						B_DV(:,g) = mean(sum(M{g},3),2);
					end
					H_DV = bar(1:Max_PVD_Orders,B_DV,0.8,'hist','FaceColor','flat');
					for g=1:length(Workspace_Set)
						H_DV(g).FaceColor = CM(g,:); % H_DV.CData(o,:) = Class_Colors(o,:);
						errorbar(mean(H_DV(g).XData,1),B_DV(:,g),std(sum(M{g},3),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					xlabel(['Menorah Order']);
					ylabel(['Neuronal Length  [',char(181),'m]']);
					ylim([0,2.*YLIM(2)]);
					set(gca,'FontSize',FontSize_1);
					legend(Groups);
					grid on;
					set(gca,'XTick',1:Max_PVD_Orders,'XTickLabels',Class_Indices);
				case 3 % Classes merged.
					for g=1:length(Workspace_Set)
						B_D(:,g) = mean(sum(M{g}(:,:,1),1),2);
						B_V(:,g) = -mean(sum(M{g}(:,:,2),1),2);
					end
					H_D = bar(1:length(Workspace_Set),B_D,0.8,'FaceColor','flat');
					hold on;
					H_V = bar(1:length(Workspace_Set),B_V,0.8,'FaceColor','flat');
					
					for g=1:length(Workspace_Set)
						H_D.CData(g,:) = CM(g,:); % Class_Colors(o,:);
						H_V.CData(g,:) = CM(g,:); % Class_Colors(o,:);
						
						errorbar(g,B_D(:,g),std(sum(M{g}(:,:,1),1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
						errorbar(g,B_V(:,g),std(sum(M{g}(:,:,2),1),0,2)','Color','k','LineWidth',2,'LineStyle','none');
					end
					
					ylabel(['Neuronal Length  [',char(181),'m]']);
					ylim(3*YLIM);
					set(gca,'FontSize',FontSize_1);
					set(gca,'YTickLabels',abs(get(gca,'YTick')),'XTick',1:length(Workspace_Set),'XTickLabels',Groups);
					grid on;
			end
			
		case 'Menorah Orders - Neuronal Length'
			% profile clear; profile on;
			
			Workspace_Set = Workspace_Set{1};
			
			Max_Midline_Length = 800;
			
			Class_Indices = [1,2,3,3.5,4,5];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0,0.8,0.8 ; 0,0,1 ; 0.8,0.8,0 ; 0.5,0.5,0.5];
			Max_PVD_Orders = length(Class_Colors);
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized','Normalized to Midline Length (X)','Normalized to Total Length (Y)','Normalized to Midline and Total Length'});
			set(GP.Handles.Plot_Type_List,'String',{'Default','Dorsal-Ventral Merged','Orders Merged','All Merged'});
			
			switch GP.Handles.Normalization_List.Value
				case 1
					if(~GP.Handles.Analysis.Slider.UserData)
						set(GP.Handles.Analysis.Slider,'Min',20,'Max',120,'Value',50,'SliderStep',[0.01,0.1]);
					end
					Edges = 0:GP.Handles.Analysis.Slider.Value:Max_Midline_Length;
				case {2,4} % Normalized to Midline Length.
					if(~GP.Handles.Analysis.Slider.UserData)
						set(GP.Handles.Analysis.Slider,'Min',0.02,'Max',.12,'Value',0.05,'SliderStep',[0.01,0.1]);
					end
					Edges = 0:GP.Handles.Analysis.Slider.Value:1;
			end
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
			set(GP.Handles.Analysis.Slider_Text,'String',num2str(GP.Handles.Analysis.Slider.Value));
			
			S_D = cell(1,Max_PVD_Orders);
			L_D = cell(1,Max_PVD_Orders);
			S_V = cell(1,Max_PVD_Orders);
			L_V = cell(1,Max_PVD_Orders);
			for w=Workspace_Set
				
				switch GP.Handles.Normalization_List.Value
					case 1
						Midline_Length = 1;
						Total_Length = 1;
					case 2 % Normalized to Midline Length.
						Midline_Length = GP.Workspace(w).Workspace.Neuron_Axes.Axis_0(end).Arc_Length;
						Total_Length = 1;
					case 3 % Normalized to Total Length.
						Midline_Length = 1;
						Total_Length = sum([GP.Workspace(w).Workspace.All_Points.Length]);
					case 4 % Normalized to both Midline and Total Length.
						Midline_Length = GP.Workspace(w).Workspace.Neuron_Axes.Axis_0(end).Arc_Length;
						Total_Length = sum([GP.Workspace(w).Workspace.All_Points.Length]);
				end
				
				% for o=1:Max_PVD_Orders
				for s=1:numel(GP.Workspace(w).Workspace.Segments)
					
					Fs = find([GP.Workspace(w).Workspace.All_Points.Segment_Index] == GP.Workspace(w).Workspace.Segments(s).Segment_Index);
					f_D = Fs(find([GP.Workspace(w).Workspace.All_Points(Fs).Midline_Distance] >= 0)); % Find all dorsal points that belong to segment s.
					f_V = Fs(find([GP.Workspace(w).Workspace.All_Points(Fs).Midline_Distance] < 0)); % Find all ventral points that belong to segment s.
					o = find(Class_Indices == GP.Workspace(w).Workspace.Segments(s).Class); % Find the index of the segment's class.
					
					% f_D = find([GP.Workspace(w).Workspace.All_Points.Midline_Distance] > 0 & [GP.Workspace(w).Workspace.All_Points.Class] == o);
					% f_V = find([GP.Workspace(w).Workspace.All_Points.Midline_Distance] < 0 & [GP.Workspace(w).Workspace.All_Points.Class] == o);
					
					if(~isempty(o)) % If the class exists in the Class_Indices vector.
					
						Nd = length(S_D{o});
						Nv = length(S_V{o});
						
						dd = Nd+1:Nd+length(f_D);
						vv = Nv+1:Nv+length(f_V);
						
						S_D{o}(dd) = [GP.Workspace(w).Workspace.All_Points(f_D).Length] ./ Total_Length; % A vector of rectangle lengths (dorsal side only) of class o.
						L_D{o}(dd) = [GP.Workspace(w).Workspace.All_Points(f_D).Axis_0_Position] ./ Midline_Length; % A vector of midline position (arc-length) from the head (dorsal).
						S_V{o}(vv) = [GP.Workspace(w).Workspace.All_Points(f_V).Length] ./ Total_Length; % A vector of rectangle lengths (ventral side only) of class o
						L_V{o}(vv) = [GP.Workspace(w).Workspace.All_Points(f_V).Axis_0_Position] ./ Midline_Length; % A vector of midline position (arc-length) from the head (ventral).
					end
				end
			end
			
			for o=1:Max_PVD_Orders
				[N_D(o,:),~,I_D] = histcounts(L_D{o},Edges,'Normalization','Probability'); % I_D are bin indices.
				[N_V(o,:),~,I_V] = histcounts(L_V{o},Edges,'Normalization','Probability');
				
				f_D = find(I_D == 0);
				f_V = find(I_V == 0);
				
				if(~isempty(f_D) || ~isempty(f_V))
					disp([num2str(length(f_D) + length(f_V)),' values (order ',num2str(o),') do not fall within any bin.']);
				end
				
				I_D(f_D) = length(Edges) - 1; % Associate uncategorized points with the last bin.
				I_V(f_V) = length(Edges) - 1; % ".
				
				% Multiply the counts by the total lengths within each [bin + class o], and divide by the number of workspaces to get the mean:
				N_D(o,:) = ( N_D(o,:) .* sum(S_D{o}(I_D)) ) ./ length(Workspace_Set);
				N_V(o,:) = ( N_V(o,:) .* sum(S_V{o}(I_V)) ) ./ length(Workspace_Set);
			end
			
			% assignin('base','N_D',N_D);
			% assignin('base','N_V',N_V);
			
			H_D = bar(xx,N_D',1,'stacked','FaceColor','flat'); % histogram(X_D,Edges);
			hold on;
			set(gca,'ColorOrderIndex',1);
			H_V = bar(xx,-N_V',1,'stacked','FaceColor','flat'); % histogram(X_V,Edges);
			
			%
			if(1 || GP.Handles.Plot_Type_List.Value == 2)
				L = size([H_D.CData],1); % # of bars.
				for o=1:Max_PVD_Orders
					H_D(o).CData = repmat(Class_Colors(o,:),L,1);
					H_V(o).CData = repmat(Class_Colors(o,:),L,1);
				end
				% CM = transpose(rescale(1:L));
				% CM = [1-CM, 0.*CM , CM];
				% H_D.CData = CM;
				% H_V.CData = CM;
			else
				legend({'Dorsal','Ventral'});
			end
			%}
			
			% xl = 0:pi/6:pi/2;
			set(gca,'FontSize',FontSize_1,'xlim',[Edges([1,end])]); % ,'XTick',xl,'XTickLabels',strsplit(num2str(xl.*180/pi)));
			
			YL_D = max(sum(reshape([H_D(:).YData],[],Max_PVD_Orders),2));
			YL_V = min(sum(reshape([H_V(:).YData],[],Max_PVD_Orders),2));
			ylim([(1.05.*YL_V),1.05.*YL_D]);
			
			switch GP.Handles.Normalization_List.Value
				case 1
					xlabel(['Midline Position [',char(181),'m]']);
					ylabel(['Neuronal Length  [',char(181),'m]']);
				case 2 % Normalized to Midline Length.
					xlabel(['Midline Position (normalized)']);
					ylabel(['Neuronal Length  [',char(181),'m]']);
				case 3
					xlabel(['Midline Position [',char(181),'m]']);
					ylabel('Neuronal Length (normalized)');
					% set(gca,'YLim',1.25.*get(gca,'YLim'));
				case 4
					xlabel(['Midline Position (normalized)']);
					ylabel('Neuronal Length (normalized)');
			end
			set(gca,'YTickLabels',abs(get(gca,'YTick'))); % set(gca,'YTickLabels',strrep(get(gca,'YTickLabels'),'-',''));
			legend({'1','2','3','3.5','4','5'},'Orientation','horizontal');
			
			% set(gca,'unit','normalize');
			% set(gca,'position',[0.08,0.15,0.90,0.8]); % set(gca,'position',[0.05,0.15,0.94,0.8]); % set(gca,'position',[0.09,0.15,0.88,0.8]);
			
			% profile off; profile viewer;
		case {'Menorah Orders - 3-Way Junctions','Menorah Orders - Tips'}
			
			Workspace_Set = Workspace_Set{1};
			
			switch GP.General.Active_Plot
				case 'Menorah Orders - 3-Way Junctions'
					Vertex_Order = 3;
					Junction_Classes = [112,233,234,334,344];
				case 'Menorah Orders - Tips'
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
			
			set(GP.Handles.Analysis.Slider_Text,'String',num2str(GP.Handles.Analysis.Slider.Value));
			
			L_D = cell(1,Max_PVD_Orders);
			L_V = cell(1,Max_PVD_Orders);
			for w=Workspace_Set
				
				switch GP.Handles.Normalization_List.Value
					case 1
						Midline_Length = 1;
					case 2 % Normalized to Midline Length.
						Midline_Length = GP.Workspace(w).Workspace.Neuron_Axes.Axis_0(end).Arc_Length;
				end
				
				for o=1:Max_PVD_Orders
					
					% Find all the vertices assigned with class Junction_Classes(o):
					f_D = find([GP.Workspace(w).Workspace.All_Vertices.Midline_Distance] > 0 & [GP.Workspace(w).Workspace.All_Vertices.Class] == Junction_Classes(o) & [GP.Workspace(w).Workspace.All_Vertices.Order] == Vertex_Order);
					f_V = find([GP.Workspace(w).Workspace.All_Vertices.Midline_Distance] < 0 & [GP.Workspace(w).Workspace.All_Vertices.Class] == Junction_Classes(o) & [GP.Workspace(w).Workspace.All_Vertices.Order] == Vertex_Order);
				
					Nd = length(L_D{o});
					Nv = length(L_V{o});
					
					dd = Nd+1:Nd+length(f_D);
					vv = Nv+1:Nv+length(f_V);
					
					% Add the midline positions corresponding to the current vertex subset:
					L_D{o}(dd) = [GP.Workspace(w).Workspace.All_Vertices(f_D).Axis_0_Position] ./ Midline_Length; % A vector of midline position (arc-length) from the head (dorsal).
					L_V{o}(vv) = [GP.Workspace(w).Workspace.All_Vertices(f_V).Axis_0_Position] ./ Midline_Length; % A vector of midline position (arc-length) from the head (ventral).
				end
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
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
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
				X = [X,[GP.Workspace(w).Workspace.All_Points.Curvature]];
				Y = [Y,[GP.Workspace(w).Workspace.All_Points.Midline_Orientation]];
				Z = [Z,[GP.Workspace(w).Workspace.All_Points.Midline_Distance]];
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
				X = [X,[GP.Workspace(w).Workspace.All_Points.Curvature]];
				Y = [Y,[GP.Workspace(w).Workspace.All_Points.Midline_Orientation]];
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
				X = [X,[GP.Workspace(w).Workspace.All_Points.Axis_0_Position]];
				Y = [Y,[GP.Workspace(w).Workspace.All_Points.Midline_Orientation]];
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
				
				f = find([GP.Workspace(w).Workspace.All_Points.Vertex_Order] ~= 2);
				X = [X,[GP.Workspace(w).Workspace.All_Points(f).Axis_0_Position]];
				Y = [Y,[GP.Workspace(w).Workspace.All_Points(f).Midline_Orientation]];
			end
			
			histogram2(X,Y,X_Edges,Y_Edges,'Normalization','Probability','FaceColor','flat');
			xlabel('Midline Arclength');
			ylabel(['Midline Orientation [',char(176),']']);
			yl = 0:pi/6:pi/2;
			set(gca,'FontSize',18,'ylim',[0,pi/2],'YTick',yl,'YTickLabels',strsplit(num2str(yl.*180/pi)));
			
		case 'Distribution of Midline Orientation'
			
			Workspace_Set = Workspace_Set{1};
			
			set(GP.Handles.Normalization_List,'String',{'Not Normalized'});
			set(GP.Handles.Plot_Type_List,'String',{'Default','Color Gradient'});
			
			if(~GP.Handles.Analysis.Slider.UserData)
				set(GP.Handles.Analysis.Slider,'Min',2,'Max',12,'Value',2,'SliderStep',[0.1,0.2]);
			end
			Edges = 0:GP.Handles.Analysis.Slider.Value*pi/180:pi/2;
			set(GP.Handles.Analysis.Slider_Text,'String',num2str(GP.Handles.Analysis.Slider.Value));
			
			X_D = [];
			X_V = [];
			for w=Workspace_Set
				
				% f_0 = find([GP.Workspace(w).Workspace.All_Points.Midline_Distance] == 0);
				f_D = find([GP.Workspace(w).Workspace.All_Points.Midline_Distance] > 0);
				f_V = find([GP.Workspace(w).Workspace.All_Points.Midline_Distance] < 0);
				
				X_D = [X_D,[GP.Workspace(w).Workspace.All_Points(f_D).Midline_Orientation]];
				X_V = [X_V,[GP.Workspace(w).Workspace.All_Points(f_V).Midline_Orientation]];
			end
			
			N_D = histcounts(X_D,Edges,'Normalization','Probability');
			N_V = histcounts(X_V,Edges,'Normalization','Probability');
			xx = (Edges(2:end) + Edges(1:end-1)) ./ 2;
			
			H_D = bar(xx,N_D,1,'FaceColor','flat'); % histogram(X_D,Edges);
			hold on;
			H_V = bar(xx,-N_V,1,'FaceColor','flat'); % histogram(X_V,Edges);
			
			if(GP.Handles.Plot_Type_List.Value == 2)
				L = size(H_D.CData,1); % # of bars.
				% H_D.CData = jet(L);
				% H_V.CData = jet(L);
				
				CM = transpose(rescale(1:L));
				CM = [1-CM, CM , 0.*CM+0.2];
				H_D.CData = CM;
				H_V.CData = CM;
			else
				legend({'Dorsal','Ventral'});
			end
			
			xlabel(['Midline Orientation [',char(176),']']);
			ylabel('Count');
			xl = 0:pi/6:pi/2;
			set(gca,'FontSize',FontSize_1,'xlim',[Edges([1,end])],'XTick',xl,'XTickLabels',strsplit(num2str(xl.*180/pi)));
			ylim([-max(N_V),max(N_D)]);
			
			% set(gca,'unit','normalize');
			% set(gca,'position',[0.09,0.15,0.89,0.84]);
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
			
		case 'Histogram of all Angles'
			
			Workspace_Set = Workspace_Set{1};
			
			V = zeros(1,10^4);
			ii = 0;
			for w=Workspace_Set
				for v=1:numel(GP.Workspace(w).Workspace.All_Vertices)
					if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.All_Vertices(v).Angles]) == 3)
						ii = ii + 3;
						V(ii-2:ii) = [GP.Workspace(w).Workspace.All_Vertices(v).Angles];
					end
				end
			end
			V = V(1:ii-1)*180/pi;
			
			histogram(V,'Normalization','Probability');
			xlabel(['Angle (',char(176),')']);
			ylabel('Probability');
			set(gca,'FontSize',22);
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
				Lmax = GP.Workspace(w).Workspace.Neuron_Axes.Axis_0(end).Arc_Length;
				
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
				for w=Workspace_Set
					Midline_Length = GP.Workspace(w).Workspace.Neuron_Axes.Axis_0(end).Arc_Length;
					for v=1:numel(GP.Workspace(w).Workspace.All_Vertices)
						% if(ismember(GP.Workspace(w).Workspace.All_Vertices(v).Class,Junction_Classes))
						if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.All_Vertices(v).Angles]) == 3)
							
							ii = ii + 1;
							
							Vi = [GP.Workspace(w).Workspace.All_Vertices(v).Angles];
							
							A1(ii) = min(Vi);
							A2(ii) = max(Vi);
							% D(ii) = GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance;
							D(ii) = GP.Workspace(w).Workspace.All_Vertices(v).Midline_Distance ./ (2.*(GP.Workspace(w).Workspace.All_Vertices(v).Half_Radius));
							L(ii) = GP.Workspace(w).Workspace.All_Vertices(v).Axis_0_Position ./ Midline_Length; %  ./ (2.*(GP.Workspace(w).Workspace.All_Vertices(v).Half_Radius));
							S(ii) = Vertices_Symmetry_Linearity(Vi);
							
							C(ii) = GP.Workspace(w).Workspace.All_Vertices(v).Class;
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
			
			Junction_Classes = [112,233,234,334,344]; % Junction_Classes = [112,233,334];
			Lc = length(Junction_Classes);
			
			% for c=1:Lc
			% 	Junction_Classes_Strings{c} = [num2str(c),'<->',num2str(c+1)];
			% end
			
			A1 = cell(1,length(Junction_Classes));
			A2 = cell(1,length(Junction_Classes));
			for w=Workspace_Set
				for v=1:numel(GP.Workspace(w).Workspace.Vertices)
					c = find(Junction_Classes == GP.Workspace(w).Workspace.Vertices(v).Class);
					R = GP.Workspace(w).Workspace.Vertices(v).Rectangles;
					if(numel(R) == 3 && ~isempty(c) && isfield(R,'Corrected_Angle') && all([R.Corrected_Angle]))
						
						Vr = [GP.Workspace(w).Workspace.Vertices(v).Rectangles.Segment_Class]; % Vector of rectangles classes.
						Va = [GP.Workspace(w).Workspace.Vertices(v).Rectangles.Corrected_Angle]; % Vector of rectangles angles.
						
						% d = min([GP.Workspace(w).Workspace.Vertices(v).Angles]); % A vector of the angles between the rectangles of the junction.
						d = [GP.Workspace(w).Workspace.Vertices(v).Corrected_Angles]; % A vector of the angles between the rectangles of the junction.
						[Sym,Lin,~] = Vertices_Symmetry_Linearity(d);
						
						if(0) % Just use the minimal angle.
							A1{c}(end+1) = min(d);
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
							A2{c}(end+1) = Sym;
							% A1{c}(end+1) = min(d); % Take the min angle of all the angles between order o and o+1.
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
			for c=1:Lc
				Vx = [Vx,A1{c}];
				Vg = [Vg,c*ones(1,length(A1{c}))];
				scatter(c*ones(1,length(A1{c})),A1{c}.*180./pi,4,'k','filled','Jitter','On','JitterAmount',0.3);
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
			xlabel('Junction Class');
			ylabel(['Mean Angle [',char(176),']']);
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
				F = find([GP.Workspace(w).Workspace.All_Points.Vertex_Order] == 1 & [GP.Workspace(w).Workspace.All_Points.Class] == 4 & [GP.Workspace(w).Workspace.All_Points.Midline_Distance] < Worm_Radium_Max); % Find all 4th order tips.
				
				X = [GP.Workspace(w).Workspace.All_Points(F).X];
				Y = [GP.Workspace(w).Workspace.All_Points(F).Y];
				
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
			
			Workspace_Set = Workspace_Set{1};
			
			Bin_Vector = 0:2:100;
			for o=1:4
				V_Length = [];
				for w=Workspace_Set
					F = find([GP.Workspace(w).Workspace.Segments.Class] == o & [GP.Workspace(w).Workspace.Segments.Length] > 0);
					V_Length = [V_Length,[GP.Workspace(w).Workspace.Segments(F).Length]];
				end
				subplot(2,2,o);
				histogram(V_Length,Bin_Vector,'Normalization','Probability');
				% scatter(o.*ones(1,length(V_Length)),V_Length,5,'k','filled');
				xlabel(['Segment Length [',char(181),'m]']);
				ylabel('Probability');
				legend(['Menorah Order = ',num2str(o)]);
				%%% title(GP.General.Active_Plot);
				set(gca,'FontSize',22);
				xlim([0,100]); % axis([0,100,0,0.3]);
				%%%hold on;
			end
			
		case 'Sum of 2 Smallest VS Product of 2 Smallest'
			%{
			Var_Operations{1} = @(x) (x(x == min(x) & x>0)) + x(x ~= min(x) & x~=max(x) & x>0);
			Var_Operations{2} = @(x) (x(x == min(x) & x>0)) .* x(x ~= min(x) & x~=max(x) & x>0);
			X_Label = 'Sum of 2 Smallest Angles';
			Y_Label = 'Product of 2 Smallest Angles';			
			Title = 'Sum of 2 Smallest VS Product of 2 Smallest';
			RowWise = 1;
			% Input_Struct = Generate_Plot_Input(GP,'Vertices',{'Angles','Angles'},Var_Operations,RowWise);
			% Two_Vars_Plot(Input_Struct,GP,GP.Visuals,X_Label,Y_Label,Title);
			%}
		case 'Smallest Angle VS Diff between 2 Smallest'
			%{
			Var_Operations{1} = @(x) x(x == min(x) & x>0);
			Var_Operations{2} = @(x) abs((x(x == min(x) & x>0)) - x(x ~= min(x) & x~=max(x) & x>0));
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Diff between 2 Smallest Angles';			
			Title = 'Smallest Angle VS Diff between 2 Smallest';
			%%%
			% Input_Struct = Generate_Plot_Input(GP,'Vertices',{'Angles','Angles'},Var_Operations,RowWise);
			% Two_Vars_Plot(Input_Struct,GP,GP.Visuals,X_Label,Y_Label,Title);
			%}
		case 'Smallest-Mid-largest'
			%{
			Var_Operations{1} = @(x) x(x == min(x) & x>0);
			Var_Operations{2} = @(x) x(x ~= min(x) & x~=max(x) & x>0);
			Var_Operations{3} = @(x) x(x == max(x) & x>0);
			X_Label = 'Minimal Angle';
			Y_Label = 'Mid-size Angle';
			Z_Label = 'Maximal Angle';
			Title = 'Smallest-Mid-largest';
			RowWise = 1;
			% Input_Struct = Generate_Plot_Input(GP,'Vertices',{'Angles','Angles','Angles'},Var_Operations,RowWise);
			% Three_Vars_Plot(Input_Struct,GP,GP.Visuals,X_Label,Y_Label,Z_Label,Title);
			%}
		case '2D Histogram Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) x(x == min(x)).*180./pi;
			Var_Operations{2} = @(x) x(x == max(x)).*180./pi;
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			Filter_Operations{2} = @(x) (x>=10 & x<=20);
			%
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Angles','Distance_From_Medial_Axis'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Largest Angle'; % 'Maximal Angle';	
			Title = 'Angles of 3-Way Junctions';
			%%%
			BinSize = 20 .* GP.Handles.Analysis.Slider.Value;
			% disp(GP.Handles.Analysis.Slider.Value);
			X_Min_Max = [30,120];
			Y_Min_Max = [110,290];
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			% Input_Struct = Generate_Plot_Input(GP,'Vertices',{'Angles','Angles','Distance_From_Medial_Axis'},Var_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
		%%%
		case '2D Histogram of Corrected Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) x(x == min(x)).*180./pi;
			Var_Operations{2} = @(x) x(x == max(x)).*180./pi;
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			% Filter_Operations{2} = @(x) (x>=25 & x<=35);
			%
			Var_Fields = {'Corrected_Angles','Corrected_Angles'};
			Filter_Fields = {'Corrected_Angles'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Largest Angle'; % 'Maximal Angle';	
			Title = 'Corrected Angles of 3-Way Junctions';
			%%%
			BinSize = 20 .* GP.Handles.Analysis.Slider.Value;
			% disp(GP.Handles.Analysis.Slider.Value);
			X_Min_Max = [30,120];
			Y_Min_Max = [110,290];
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
		
		case '2D Histogram of Invariant Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) (x(1).*x(2) + x(1).*x(3) + x(2).*x(3));
			Var_Operations{2} = @(x) (x(1).*x(2).*x(3));
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			% Filter_Operations{2} = @(x) (x>=25 & x<=35);
			%
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Angles'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Invariant 1';
			Y_Label = 'Invariant 2'; % 'Maximal Angle';	
			Title = 'Invariants of Angles of 3-Way Junctions';
			%%%
			BinSize = GP.Handles.Analysis.Slider.Value;
			% disp(GP.Handles.Analysis.Slider.Value);
			X_Min_Max = [10,15];
			Y_Min_Max = [5,10];
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			% Input_Struct = Generate_Plot_Input(GP,'Vertices',{'Corrected_Angles','Corrected_Angles','Distance_From_Medial_Axis'},Var_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case '2D Histogram of Invariant Corrected Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) (x(1).*x(2) + x(1).*x(3) + x(2).*x(3));
			Var_Operations{2} = @(x) (x(1).*x(2).*x(3));
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			% Filter_Operations{2} = @(x) (x>=25 & x<=35);
			%
			Var_Fields = {'Corrected_Angles','Corrected_Angles'};
			Filter_Fields = {'Corrected_Angles'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Invariant 1';
			Y_Label = 'Invariant 2'; % 'Maximal Angle';	
			Title = 'Invariants of Corrected Angles of 3-Way Junctions';
			%%%
			BinSize = GP.Handles.Analysis.Slider.Value;
			% disp(GP.Handles.Analysis.Slider.Value);
			X_Min_Max = [10,15];
			Y_Min_Max = [5,10];
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			% Input_Struct = Generate_Plot_Input(GP,'Vertices',{'Corrected_Angles','Corrected_Angles','Distance_From_Medial_Axis'},Var_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distribution of Vertices Angles Relative To The Medial Axis'
			Var_Operations{1} = @(x) mod(x.*180./pi,90);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles_Medial'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = '';
			Y_Label = 'Count';
			Title = 'Distribution of Vertices Angles Relative To The Medial Axis';
			X_Min_Max = [0,90];
			BinSize = 10 .* GP.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise); % assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distribution of Vertices Angles Relative To The Medial Axis - Corrected'
			Var_Operations = @(x) mod(x.*180./pi,90);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles_Corrected_Medial'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = '';
			Y_Label = 'Count';
			Title = 'Distribution of Vertices Angles Relative To The Medial Axis - Corrected';
			X_Min_Max = [0,90];
			BinSize = 10 .* GP.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GP,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise); % assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GP,GP.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
		case 'Histogram of Smallest, Mid & Largest Angles'
			
			Workspace_Set = Workspace_Set{1};
			
			V = nan(3,10^4);
			ii = 0;
			for w=Workspace_Set{1}
				for v=1:numel(GP.Workspace(w).Workspace.Vertices)
					if(GP.Workspace(w).Workspace.All_Vertices(v).Order == 3 && length([GP.Workspace(w).Workspace.Vertices(v).Corrected_Angles]) == 3) % Corrected_Angles
						if(1)
							% if(ismember([GP.Workspace(w).Workspace.All_Vertices(v).Class],[334]))
							ii = ii + 1;
							V(:,ii) = [GP.Workspace(w).Workspace.Vertices(v).Corrected_Angles];
						end
					end
				end
			end
			V = V(:,1:ii);
			
			BinSize = 5; % 1 + (30 .* GP.Handles.Analysis.Slider.Value);
			Title = 'Histogram of Smallest, Mid & Largest Angles';
			% assignin('base','A123',V);
			Plot_3Angles_Junction_Histogram(V,BinSize,Title);
            
		case 'Custom_1_Total_Length'
			Custom_1_Total_Length(GP,GP.Visuals,'Length [\mum]','Total Length');
		case 'Custom_2_Vertices_Num'
			Custom_2_Vertices_Num(GP,GP.Visuals,'Count','Number of Vertices per Unit Length');
		case 'Custom_1_3_3Way_Junctions_Num'
			Custom_1_3_3Way_Junctions_Num(GP,GP.Visuals,'Count','Number of 3-Way Junctions per Unit Length');
		case 'Custom_3_Tips_Num'
			Custom_3_Tips_Num(GP,GP.Visuals,'Count','Number of Tips per Unit Length');
		case 'Custom_4_Mean_Segment_Length'
			Custom_4_Mean_Segment_Length(GP,GP.Visuals,'Length [\mum]','Mean Segment Length');
		case 'Custom_5_Segment_Length_Dist'
			Custom_5_Segment_Length_Dist(GP,GP.Visuals,'Count','Segment Length Distribution');
		case 'Custom_2_1_Mean_Segment_Curvature_Hist'
			Custom_2_1_Mean_Segment_Curvature_Hist(GP,GP.Visuals,'Squared Curvature','Histogram of Mean Squared Curvature of Segments');			
		case 'Custom_2_2_Mean_Segment_Curvature'
			Custom_2_2_Mean_Segment_Curvature(GP,GP.Visuals);			
		case 'Custom_2_3_Max_Segment_Curvature_Hist'
			% Custom_2_3_Max_Segment_Curvature_Hist(GP,GP.Visuals,'Squared Curvature','Mean Squared Curvature of Segments');			
		case 'Custom_2_4_Max_Segment_Curvature'
			% Custom_2_4_Max_Segment_Curvature(GP,GP.Visuals,'Squared Curvature','Mean Squared Curvature of Segments');
		case 'Custom_2_5_Point_Curvature_Hist'
			Custom_2_5_Point_Curvature_Hist(GP,GP.Visuals);
		case 'Custom_3_1_Rects_Medial_Distance_Dist'
			Custom_3_1_Rects_Medial_Distance_Dist(GP,GP.Visuals,'Distance (\mum)','Distribution of Rectangle Distances from the Medial Axis');
		case 'Custom_3_2_Vertices_Rects_Medial_Distance_Dist'
			Custom_3_2_Vertices_Rects_Medial_Distance_Dist(GP,GP.Visuals,'Distance (\mum)','Distribution of Vertices Rectangle Distances from the Medial Axis');
		case 'Custom_4_1_Rects_Medial_Orientation_Hist'
			Custom_4_1_Rects_Medial_Orientation_Hist(GP,GP.Visuals,'Probability','Orientation of Rectangles relative to Medial Axis');			
		case 'Custom_4_2_Vertex_End2End_Angles_Correlation_Hist'
			Custom_4_2_Vertex_End2End_Angles_Correlation_Hist(GP,GP.Visuals,'Probability','End2End-Vertex Angle Diff');
		case {'Custom_4_3_Rects_Medial_Orientation_VS_Distance_2D_Hist','Orientation VS Distance from Primary Branch'}
			Custom_4_3_Rects_Medial_Orientation_VS_Distance_2D_Hist(GP,GP.Visuals,'Probability','Custom_4_3_Rects_Medial_Orientation_VS_Distance_2D_Hist');
		case 'Custom_4_3_1_Medial_Orientation_VS_Distance_2D_Hist_Groups'
			Custom_4_3_1_Medial_Orientation_VS_Distance_2D_Hist_Groups(GP,GP.Visuals,'Probability','Custom_4_3_1_Medial_Orientation_VS_Distance_2D_Hist_Groups');
		case 'Custom_4_4_Segment_Angles_Correlation_VS_Medial_Distance_Hist'
			Custom_4_4_Segment_Angles_Correlation_VS_Medial_Distance_Hist(GP,GP.Visuals);
		case 'Custom_4_5_Rects_Curvature_VS_Distance_2D_Hist'
			Custom_4_5_Rects_Curvature_VS_Distance_2D_Hist(GP,GP.Visuals);
		case 'Custom_4_6_Curvature_VS_Distance_2D_Hist_Groups'
			Custom_4_6_Curvature_VS_Distance_2D_Hist_Groups(GP,GP.Visuals);
		case 'Custom_6_Rects_Orientation'
			Custom_6_Rects_Orientation(GP,GP.Visuals,['Angle (',char(176),')'],'Orientation of Vertices Relative to the Medial Axis');
		
		case 'Midline Distance VS Midline Orientation'
			Plot_Distance_VS_Orientation(GP.Workspace);
		case 'Midline Distance VS Curvature'
			Plot_Distance_VS_Curvature(GP.Workspace);
	end
	
	% set(GP.Handles.Axes,'unit','normalize');
	% set(GP.Handles.Axes,'position',[0,0,1,1]);
	% axis tight;
	
	% assignin('base','Input_Struct',Input_Struct);
	set(GP.Handles.Analysis.Slider,'UserData',0); % Used as a flag to tell if this script was run as a result of the use of this slider.
	
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