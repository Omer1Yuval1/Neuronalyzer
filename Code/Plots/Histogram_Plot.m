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
	
	% assignin('base','Input_Struct',Input_Struct);
	Ncat = 0; % length(GUI_Parameters.General.Categories_Filter_Values);
	Groups_Num = numel(Input_Struct);
	
	if(Groups_Num > 0) % If at least one group is ON.
		
		Groups_Names = {Input_Struct.Group_Name}; % Cell array of group names.
		Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});		
		% assignin('base','Groups_Names',Groups_Names);
		if(Ncat == 0)
			
			Legend_Handles_Array = [];
			Bar_Mat = zeros(X-values_Num,Groups_Num);
			for i=1:Groups_Num % For each group (a unique combination of selected features).
				
				Bar_Mat(,i) = mean(Input_Struct(i).Values);
				% Prepare the bar plot matrix. Each row corresponds to a single x-value (range). Each col corresponds to a single group.
				
				% Mean1 = nanmean(Input_Struct(i).Values);
				C = Input_Struct(i).Color;
				
				% hold on;
				% scatter(i*ones(1,length(Input_Struct(i).Values)),Input_Struct(i).Values,Visuals.Scatter_Dot_Size1,'MarkerFaceColor',Input_Struct(i).Color,'MarkerEdgeColor',Input_Struct(i).Color,'jitter','on','jitterAmount',Visuals.Jitter1);
				% errorbar(i,Mean1,nanstd(Input_Struct(i).Values),'LineWidth',Visuals.ErrorBar_Width1,'Color',Visuals.ErrorBar_Color1);
				% Legend_Handles_Array(i) = plot(i+[-1,+1]*Visuals.Jitter1,[Mean1,Mean1],'Color',Input_Struct(i).Color,'LineWidth',Visuals.Mean_Line_Width);
				
				Groups_Struct(end+1).Group_ID = i;
				Groups_Struct(end).Values = Input_Struct(i).Values;
				Groups_Struct(end).Mean = Mean1;
				Groups_Struct(end).SE = nanstd(Input_Struct(i).Values);
				Groups_Struct(end).Category = 0;
			end
			b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat);
			
			if(GUI_Parameters.Handles.Significance_Bars_CheckBox.Value)
				Get_Statistically_Significance_Bars(Groups_Struct,Visuals.Active_Colormap(1,:));
			end
			
			set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',Visuals.Axes_Lables_Font_Size); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			ylabel(YLabel,'FontSize',Visuals.Axes_Titles_Font_Size);
			set(gca,'YColor',Visuals.Active_Colormap(1,:));
			title(Title1,'FontSize',Visuals.Main_Title_Font_Size,'Color',Visuals.Active_Colormap(1,:));
			xlim([0.5,Groups_Num+0.5]);
			grid on;
			
			% No need for a legend if the x-axis labels are the groups' names:
			% Lg = legend(Legend_Handles_Array,Groups_Names,'Location','best');
			% Lg.TextColor = Visuals.Active_Colormap(1,:);
			% Lg.EdgeColor = Visuals.Active_Colormap(1,:);
			% Lg.FontSize = Visuals.Legend_Font_Size2;
	end
end