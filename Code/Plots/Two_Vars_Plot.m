function Two_Vars_Plot(Input_Struct,GUI_Parameters,Visuals,XLabel,YLabel,Title1)
	
	% Description:
		% This function generated a scatter plot of two variables.
		% Parent functions: Multiple_Choose_Plot.
	% Input:
		% GUI_Parameters: general visual parameters and graphic handles.
		% TODO: Field_Name: the field name in the Statistics structure corresponding to a morphological feature.
		% TODO: YLabel and Title1: y-axis title and main title (respectively).
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
				
				MeanX = nanmean(Input_Struct(i).XValues);
				MeanY = nanmean(Input_Struct(i).YValues);
				C = Input_Struct(i).Color;
				hold on;
				scatter(Input_Struct(i).XValues,Input_Struct(i).YValues,Visuals.Scatter_Dot_Size1,'MarkerFaceColor',Input_Struct(i).Color,'MarkerEdgeColor',Input_Struct(i).Color);
				% errorbar(i,Mean1,nanstd(Input_Struct(i).Values),'LineWidth',Visuals.ErrorBar_Width1,'Color',Visuals.ErrorBar_Color1);
				Legend_Handles_Array(i) = plot(MeanX,MeanY,'.','Color',Input_Struct(i).Color,'MarkerSize',Visuals.Mean_Dot_Size);
				
				% Groups_Struct(end+1).Group_ID = i;
				% Groups_Struct(end).Values = Input_Struct(i).Values;
				% Groups_Struct(end).Mean = Mean1;
				% Groups_Struct(end).SE = nanstd(Input_Struct(i).Values);
				% Groups_Struct(end).Category = 0;
			end
			
			% if(GUI_Parameters.Handles.Significance_Bars_CheckBox.Value)
				% Get_Statistically_Significance_Bars(Groups_Struct,Visuals.Active_Colormap(1,:));
			% end
			
			% set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',Visuals.Axes_Lables_Font_Size/(Groups_Num/5)); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			% set(gca,'XTick',1:Groups_Num,'XTickLabel',{Input_Struct.Labels},'FontSize',Visuals.Axes_Lables_Font_Size); % ,'XTickLabelRotation',Visuals.Axss_Lables_Orientation
			set(gca,'FontSize',Visuals.Axes_Lables_Font_Size);
			xlabel(XLabel,'FontSize',Visuals.Axes_Titles_Font_Size);
			ylabel(YLabel,'FontSize',Visuals.Axes_Titles_Font_Size);
			set(gca,'YColor',Visuals.Active_Colormap(1,:));
			title(Title1,'FontSize',Visuals.Main_Title_Font_Size,'Color',Visuals.Active_Colormap(1,:));
			% xlim([0.5,Groups_Num+0.5]);
			grid on;
			
			Lg = legend(Legend_Handles_Array,Groups_Names,'Location','best','Interpreter','none');
			Lg.TextColor = Visuals.Active_Colormap(1,:);
			Lg.EdgeColor = Visuals.Active_Colormap(1,:);
			Lg.FontSize = Visuals.Legend_Font_Size2;
	end
end