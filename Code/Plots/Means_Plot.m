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
			
			Legend_Handles_Array = [];
			for i=1:Groups_Num % For each group (a unique combination of selected features).
				
				Mean1 = nanmean(Input_Struct(i).XValues);
				STD_SE = nanstd(Input_Struct(i).XValues); %  ./ sqrt(length(Input_Struct(i).XValues));
				C = Input_Struct(i).Color;
				hold on;
				scatter(i*ones(1,length(Input_Struct(i).XValues)),Input_Struct(i).XValues,Visuals.Scatter_Dot_Size1,'MarkerFaceColor',Input_Struct(i).Color,'MarkerEdgeColor',Input_Struct(i).Color,'jitter','on','jitterAmount',Visuals.Jitter1);
				errorbar(i,Mean1,STD_SE,'LineWidth',Visuals.ErrorBar_Width1,'Color',Visuals.ErrorBar_Color1);
				Legend_Handles_Array(i) = plot(i+[-1,+1]*Visuals.Jitter1,[Mean1,Mean1],'Color',Input_Struct(1).Color,'LineWidth',Visuals.Mean_Line_Width);
				
				Groups_Struct(end+1).Group_ID = i;
				Groups_Struct(end).Values = Input_Struct(i).XValues;
				Groups_Struct(end).Mean = Mean1;
				Groups_Struct(end).SE = STD_SE;
				Groups_Struct(end).Category = 0;
			end
			
			if(GUI_Parameters.Handles.Significance_Bars_CheckBox.Value)
				Get_Statistically_Significance_Bars(Groups_Struct,Visuals.Active_Colormap(1,:));
			end
			
			set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',Visuals.Axes_Lables_Font_Size/(Groups_Num)); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			% set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',Visuals.Axes_Lables_Font_Size); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			ylabel(YLabel,'FontSize',Visuals.Axes_Titles_Font_Size);
			set(gca,'YColor',Visuals.Active_Colormap(1,:));
			title(Title1,'FontSize',Visuals.Main_Title_Font_Size,'Color',Visuals.Active_Colormap(1,:));
			xlim([0.5,Groups_Num+0.5]);
			
			% XTickLabel.FontSize = 54;
			% hhh = get(gca,'XTickLabel');
			% assignin('base','hhh',hhh);
			% set(hhh,'FontSize',Visuals.Axes_Lables_Font_Size/(Groups_Num/5));
			
			grid on;
			
			% No need for a legend if the x-axis labels are the groups' names:
			% Lg = legend(Legend_Handles_Array,Groups_Names,'Location','best');
			% Lg.TextColor = Visuals.Active_Colormap(1,:);
			% Lg.EdgeColor = Visuals.Active_Colormap(1,:);
			% Lg.FontSize = Visuals.Legend_Font_Size2;
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