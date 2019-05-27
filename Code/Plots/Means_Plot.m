function Multiple_Means_Func(Input_Struct,GUI_Parameters,Visuals,YLabel,Title1)
	
	% Description:
		% This function generated a means plot with large dots representing the mean values, small dots representing the raw data
		% and error-bars representing standard devation or standard error.
		% Parent functions: Multiple_Choose_Plot.
	% Input:
		% GUI_Parameters: general visual parameters and graphic handles.
		% Field_Name: the field name in the Statistics structure corresponding to a morphological feature.
		% YLabel and Title1: y-axis title and main title (respectively).
	% Output:
		% No output.
	
	assignin('base','Input_Struct',Input_Struct);
	
	Ncat = 0; % length(GUI_Parameters.General.Categories_Filter_Values);
	Groups_Num = numel(Input_Struct);
	
	if(Groups_Num > 0) % If at least one group is ON.
		
		Groups_Names = {Input_Struct.Group_Name}; % Cell array of group names.
		Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});		
		% assignin('base','Groups_Names',Groups_Names);
		if(Ncat == 0)
			
			if(GUI_Parameters.Handles.Plot_Type_List.Value == 2)
				Box_Plot_Vals = [];
				Box_Plot_Indices = [];
			end
			
			for i=1:Groups_Num % For each group (a unique combination of selected features).
								
				if(GUI_Parameters.Handles.Significance_Bars_List.Value > 1)
					Vals{i} = Input_Struct(i).XValues; % Used for statistical tests.
				end
				
				switch(GUI_Parameters.Handles.Plot_Type_List.Value)
					case 1
						Mean1 = nanmean(Input_Struct(i).XValues);
						if(GUI_Parameters.Handles.Error_Bars_List.Value > 1)
							switch(GUI_Parameters.Handles.Error_Bars_List.Value)
								case 2 % Standard Deviation.
									Err_i = nanstd(Input_Struct(i).XValues);
								case 3 % Standard Error of the Mean.
									Err_i = nanstd(Input_Struct(i).XValues) ./ sqrt(length(Input_Struct(i).XValues));
							end
							errorbar(i,Mean1,Err_i,'LineWidth',Visuals.ErrorBar_Width1,'Color',Visuals.ErrorBar_Color1);
						end
						
						hold on;
						plot(i+[-1,+1]*Visuals.Jitter1,[Mean1,Mean1],'Color',Input_Struct(1).Color,'LineWidth',Visuals.Mean_Line_Width);
						scatter(i*ones(1,length(Input_Struct(i).XValues)),Input_Struct(i).XValues,6.*Visuals.Scatter_Dot_Size1,'MarkerFaceColor',Input_Struct(i).Color,'MarkerEdgeColor',Input_Struct(i).Color,'jitter','on','jitterAmount',Visuals.Jitter1);
					case 2
						Box_Plot_Vals = [Box_Plot_Vals, Input_Struct(i).XValues];
						Box_Plot_Indices = [Box_Plot_Indices , i.*ones(1,length(Input_Struct(i).XValues))];
				end
			end
			
			switch(GUI_Parameters.Handles.Plot_Type_List.Value)
				case 2
					hold on;
					boxplot(Box_Plot_Vals,Box_Plot_Indices);
			end
			
			set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',18); % ,'FontSize',Visuals.Axes_Lables_Font_Size/(Groups_Num/2)); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			% set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',Visuals.Axes_Lables_Font_Size); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			ylabel(YLabel); % ,'FontSize',Visuals.Axes_Titles_Font_Size);
			set(gca,'YColor',Visuals.Active_Colormap(1,:));
			title(Title1,'FontSize',Visuals.Main_Title_Font_Size,'Color',Visuals.Active_Colormap(1,:));
			xlim([0.5,Groups_Num+0.5]);
			YLIMITS = get(gca,'ylim');
			ylim([0,YLIMITS(2)]);
			grid on;
			
			switch(GUI_Parameters.Handles.Significance_Bars_List.Value)
				case 2 % T-Test & U-Test.
					Get_Stats_Bars_XY(Vals);
			end
			
			
		else % If at least one category is selected.
			Legend_Handles_Array = [];
			for o=1:Ncat % For each category.
				O = Order_Index_Conversion(GUI_Parameters.General.Categories_Filter_Values(o),1);
				for i=1:Groups_Num % For each (selected) group.
					Gi = GUI_Parameters.General.Groups_OnOff(i);
					A1 = GUI_Parameters.Workspace(Gi).Statistics.(Field_Name).Values(:,O);
					if(GUI_Parameters.Handles.Normalization_List.Value > 1 && ...
						isfield(GUI_Parameters.Workspace(Gi).Statistics.(Field_Name).Normalization,'Values'))
						A1 = A1 ./ GUI_Parameters.Workspace(Gi).Statistics.(Field_Name).Normalization(Nc).Values';
					end
					
					C = GUI_Parameters.Visuals.Active_Colormap(Gi,:);
					Xp = Get_Group_X_Position(length(GUI_Parameters.General.Groups_OnOff),i,GUI_Parameters.Visuals.Jitter1);
					Mean1 = nanmean(A1);
					hold on;
					% scatter(o+Xp*ones(1,length(A1)),A1,'MarkerFaceColor',C,'MarkerEdgeColor',C,'jitter','on','jitterAmount',GUI_Parameters.Visuals.Jitter2,'MarkerFaceAlpha',GUI_Parameters.Visuals.Alpha1,'MarkerEdgeAlpha',GUI_Parameters.Visuals.Alpha1);
					errorbar(o+Xp,Mean1,nanstd(A1),'LineWidth',GUI_Parameters.Visuals.ErrorBar_Width1,'Color',GUI_Parameters.Visuals.ErrorBar_Color1);
					Legend_Handles_Array(i) = plot((o+Xp)+[-1,1]*GUI_Parameters.Visuals.Jitter2,[Mean1,Mean1],'Color',C,'LineWidth',GUI_Parameters.Visuals.Mean_Line_width);
					
					Groups_Struct(end+1).Group_ID = o+Xp;
					Groups_Struct(end).Values = A1;
					Groups_Struct(end).Mean = Mean1;
					Groups_Struct(end).SE = nanstd(A1);
					Groups_Struct(end).Category = GUI_Parameters.General.Categories_Filter_Values(o);
				end
			end
			
			if(GUI_Parameters.Handles.Significance_Bars_CheckBox.Value)
				Get_Statistically_Significance_Bars(Groups_Struct,GUI_Parameters.Visuals.Active_Colormap(1,:));
			end
			
			set(gca,'XTick',1:Ncat,'XTickLabel',GUI_Parameters.General.Menorah_Orders_Labels,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size);
			xlabel('Menorah Order','FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			set(gca,'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
			title(Title1,'FontSize',GUI_Parameters.Visuals.Main_Title_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
			xlim([.5 Ncat+.5]);
			grid on;
			
			Lg = legend(Legend_Handles_Array,Groups_Names{GUI_Parameters.General.Groups_OnOff},'Location','best');
			Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
			Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
			Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
		end
	end
end