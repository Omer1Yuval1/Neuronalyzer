function Plot_Distribution_Multiple(GUI_Parameters,Gradient_Func,XAxis_Min_Max,BinSize_Min_Max,Bin_Res,XLabel,YLabel,Title1,XAxis_Direction,Sum1_Mean2,Categories1)
	
	% Description:
		% A general function for generating a histogram\bar plot using the bar function.
		% The function allows interactive filtering of categories and groups (via the GUI).		
		% It also allows manipulation of the resolution (bin size).
		% Calling functions: Multiple_Choose_Plot.
	% Input:
		% GUI_Parameters: general visual parameters and graphic handles.
		% Gradient_Func: the name of the MATLAB function used to generate the data to be plotted.
		% XAxis_Min_Max: x-axis limits.
		% BinSize_Min_Max: bin size limits.
		% Bin_Res: bin range resolution.
		% XLabel, YLabel, Title1: x-axis title, y-axis title and main title (respectively).
		% XAxis_Direction: x-axis direction (left-to-right (+1) or right-to-left(-1)).
		% Sum1_Mean2: a flag used to indicate if the data of each category should be summed-up (1) or averaged (2).
		% Categories1: % a flag used to indicate if the data should be categorized (1) or not (0).
	% Output:
		% No output.
	
	Groups_Names = {GUI_Parameters.Workspace.Group_Name};
	
	BinSize = round(BinSize_Min_Max(2)*GUI_Parameters.Handles.Slider.Value,Bin_Res);
	BinSize = max(10^(-Bin_Res),BinSize);
	set(GUI_Parameters.Handles.Slider,'Value',BinSize/BinSize_Min_Max(2)); % Update the rounded value on the slide-bar (always between [0,1]).
	
	if(XAxis_Min_Max(1) < 0) % If x-values contain negatives.
		XAxis_Min_Max(1) = XAxis_Min_Max(1) - (BinSize-mod(XAxis_Min_Max(1),BinSize));
		XAxis_Min_Max(2) = XAxis_Min_Max(2) + (BinSize-mod(XAxis_Min_Max(2),BinSize));
		Edges_Vector = [fliplr(-BinSize/2:-BinSize:XAxis_Min_Max(1)),BinSize/2:BinSize:XAxis_Min_Max(2)];
		% assignin('base','XAxis_Min_Max',XAxis_Min_Max);
	else
		% XAxis_Min_Max(1) = XAxis_Min_Max(1) - (BinSize-mod(XAxis_Min_Max(1),BinSize));
		XAxis_Min_Max(2) = XAxis_Min_Max(2) + (BinSize-mod(XAxis_Min_Max(2),BinSize));
		Edges_Vector = [XAxis_Min_Max(1):BinSize:XAxis_Min_Max(2)];
	end
	XTick_Vector = (Edges_Vector(1:end-1) + Edges_Vector(2:end)) / 2;
	
	if(Categories1 == 0)
		Vc = 0;
	elseif(Categories1 == 1) % Branches Categories.
		if(length(GUI_Parameters.General.Categories_Filter_Values) == 0)
			Vc = 1.5:.5:5;
		else
			Vc = GUI_Parameters.General.Categories_Filter_Values';
		end
	% elseif(Categories1 == 2) % Angles Categories.
	end
	
	Groups1 = cell(1,length(GUI_Parameters.General.Groups_OnOff));
	for i=1:length(GUI_Parameters.General.Groups_OnOff) % For each group.
		Group_i = cell(length(Edges_Vector)-1,length(Vc),2); % [Bin,Category,Dorsal-Ventral]. Each cell contains a vector with the values for all animals in a specific bin and category.
		G = GUI_Parameters.General.Groups_OnOff(i);
		for j=1:length(GUI_Parameters.Workspace(G).Files) % For each memeber (animal) of group G.
			Gradient1 = Gradient_Func(GUI_Parameters.Workspace(G).Files{j});
			% assignin('base','Gradient1',Gradient1);
			Weighted_Counts_Dorsal_Total = []; % TODO: pre-determine size.
			Weighted_Counts_Ventral_Total = []; % ".
			
			for o=Vc % For each Category.
				F_Dorsal = find([Gradient1.Order] == o & [Gradient1.Dorsal_Ventral] >= 0);
				F_Ventral = find([Gradient1.Order] == o & [Gradient1.Dorsal_Ventral] <= 0);
				
				Weighted_Counts_Dorsal_Order = Weighted_Histogram([Gradient1(F_Dorsal).Property],[Gradient1(F_Dorsal).Weight],Edges_Vector,Sum1_Mean2);
				Weighted_Counts_Ventral_Order = Weighted_Histogram([Gradient1(F_Ventral).Property],[Gradient1(F_Ventral).Weight],Edges_Vector,Sum1_Mean2);
				
				Weighted_Counts_Dorsal_Total(:,end+1) = Weighted_Counts_Dorsal_Order; % Each col contains a different Category.
				Weighted_Counts_Ventral_Total(:,end+1) = Weighted_Counts_Ventral_Order; % Each col contains a different Category.
			end
			
			if(Nc) % Normalization. TODO: think: the primary branch is taken into account in the normalization even if dorsal-ventral are separated.
				T = Weighted_Counts_Dorsal_Total + Weighted_Counts_Ventral_Total;
				if(Categories1 > 0) % TODO: what if the 1st category is filtered out???
					T(:,1) = T(:,1) / 2; % Divide count by 2 to account only once for the first category.
				end
				T = sum(sum(T)); % Total count.
				
				Weighted_Counts_Dorsal_Total = Weighted_Counts_Dorsal_Total / T; % Normalization of the j-animal to [0,1].
				Weighted_Counts_Ventral_Total = Weighted_Counts_Ventral_Total / T; % Normalization of the j-animal to [0,1].
			end
			
			if(GUI_Parameters.Handles.Merge_Dorsal_Ventral_CheckBox.Value) % Merge.
				T = Weighted_Counts_Dorsal_Total + Weighted_Counts_Ventral_Total;
				if(Categories1 > 0)
					T(:,1) = T(:,1) / 2; % Divide the count by 2 to account only once for the first category.
				end
				for v=1:numel(T) % For each category (columns) and bin (rows) of animal j (in group G).
					Group_i{v}(end+1,1) = T(v); % Add info about the j-animal to the total matrix. Only for the dorsal (used in the 'merge' case for all the data).
				end
			else % Do not merge dorsal-ventral.
				[Sr,Sc] = size(Weighted_Counts_Dorsal_Total); % Also the size of 'Weighted_Counts_Ventral_Total'.
				for r=1:Sr % For each bin (of animal j).
					for c=1:Sc % For each category (of animal j).
						Group_i{r,c,1}(end+1,1) = Weighted_Counts_Dorsal_Total(r,c); % Add info about the j-animal to the total matrix.
						Group_i{r,c,2}(end+1,1) = Weighted_Counts_Ventral_Total(r,c); % Add info about the j-animal to the total matrix.
					end
				end
			end
		end
		Groups1{i} = Group_i;
	end
	
	% assignin('base','Groups1',Groups1);
	
	if(GUI_Parameters.Handles.Merge_Dorsal_Ventral_CheckBox.Value) % Merge.
		% Showing all the data as one category:
		if(length(GUI_Parameters.General.Groups_OnOff) > 1 || ... % All categories are averaged.
			(length(GUI_Parameters.General.Groups_OnOff) == 1 && Categories1 == 0)) % Only one category (regradless of the filtering).
				Bar_Mat = zeros(length(Edges_Vector)-1,length(GUI_Parameters.General.Groups_OnOff));
				Bar_STD = zeros(length(Edges_Vector)-1,length(GUI_Parameters.General.Groups_OnOff));
				for i=1:length(GUI_Parameters.General.Groups_OnOff) % For each group.
					for bin_i=1:size(Groups1{1,1},1) % For each bin.
						A = cell2mat(Groups1{i}(bin_i,:,1)); % Each col is a category. Each row is a different animal (in group i).
						Bar_Mat(bin_i,i) = nanmean(nansum(A,2)); % Sum of all categories for each animal, then mean of animals.
						Bar_STD(bin_i,i) = nanstd(nansum(A,2)); % Sum of all categories for each animal, then std of animals.
					end
				end
				% assignin('base','Bar_Mat',Bar_Mat);
				b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat);
				colormap(GUI_Parameters.Visuals.Active_Colormap(GUI_Parameters.General.Groups_OnOff,:));
				
				if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
					pause(0.1); % Bug fix - since 2014b, a delay is needed in order to let the engine create the plot (before using the handle).
					hold on;
					for s=1:length([b1.XOffset]) % For each set of bars (group or category).
						for p=1:length([b1(s).XData]) % For each x-value.
							Xv = b1(s).XData(p) + b1(s).XOffset;
							plot([Xv,Xv],[b1(s).YData(p)-Bar_STD(p,s),b1(s).YData(p)+Bar_STD(p,s)],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',3); % GUI_Parameters.Visuals.ErrorBar_Color1
						end
						b1(s).FaceColor = 'none';
						b1(s).EdgeColor = GUI_Parameters.Visuals.Active_Colormap(GUI_Parameters.General.Groups_OnOff(s),:);
						b1(s).LineWidth = 3;
					end
				end
				if(GUI_Parameters.Handles.Display_Significance_Bars_CheckBox.Value)
					pause(0.1); % Bug fix - since 2014b, a delay is needed in order to let the engine create the plot (before using the handle).
					Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
					hold on;
					for s=1:length([b1.XOffset]) % For each set of bars (for each group of animals = for each cell in Group1).
						for p=1:length([b1(s).XData]) % For each x-value (each bin = each row in each group cell).
							A = sum(cell2mat(Groups1{s}(p,:,1)),2); % Take the cell of animal s, and bin p. Convert to a matrix and sum up each animal for all categories. The result: a vector of animals mean values.
							
							Groups_Struct(end+1).Group_ID = b1(s).XData(p) + b1(s).XOffset;
							Groups_Struct(end).Values = A; % TODO: fix for dorsal-ventral.
							Groups_Struct(end).Mean = nanmean(A);
							Groups_Struct(end).SE = nanstd(A);
							Groups_Struct(end).Category = b1(s).XData(p);
						end
					end
					Get_Statistically_Significance_Bars(Groups_Struct,GUI_Parameters.Visuals.Active_Colormap(1,:));
				end
				
				xlim([XAxis_Min_Max(1),XAxis_Min_Max(2)]); % xlim([XAxis_Min_Max(1)-(BinSize/2),XAxis_Min_Max(2)+(BinSize/2)]);
				set(gca,'YLim',[0, get(gca, 'YLim')*[0;1]]);
				Lg = legend(Groups_Names{GUI_Parameters.General.Groups_OnOff},'Location','best');
				Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
				
				% xlim([-350,550]);
				% XBins = {'[-350,-250]' ; '[-250,-150]' ; '[-150,-50]' ; '[-50,50]' ; '[50,150]' ; '[150,250]' ; '[250,350]' ; '[350,450]' ; '[450,550]'}; % 100.
				% XBins = {'[-45,-15]' ; '[-15,15]' ; '[15,45]' ; '[45,75]' ; '[75,105]'}; % Orientation of Segments. 30.
				% XBins = {'[-0.6,-0.2]' ; '[-0.2,0.2]' ; '[0.2,0.6]' ; '[0.6,1]'}; % Menorahs Symmetry. 0.4.
				% XBins = {'[-5,5]' ; '[5,15]' ; '[15,25]'}; % Menorahs Overlap. 10.
				% 
				% set(gca,'XTickLabel',XBins);
				
				set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size, ...
				'XTick',XTick_Vector,'xdir',XAxis_Direction, ...
				'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
				ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				% xlabel(XLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				xlabel([XLabel,' ','; Bin Size =',' ',num2str(BinSize)],'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				title(Title1,'FontSize',GUI_Parameters.Visuals.Main_Title_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
				
			% else % 2+ groups, one category.
			
			% else % > 1
			
			% end
		elseif(length(GUI_Parameters.General.Groups_OnOff) == 1) % AND Categories1 > 0.
			Bar_Mat = cellfun(@nanmean,Groups1{1}(:,:,1)); % Mean of all animals for each category, and then, mean of all categories.
			Bar_STD = cellfun(@nanstd,Groups1{1}(:,:,1)); % Mean of all animals for each category, and then, mean of all categories.
			if(length(GUI_Parameters.General.Categories_Filter_Values) == 0)
				b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat,'stacked');
				colormap(GUI_Parameters.Visuals.Active_Menorah_Colormap(2*Vc-1,:));
				A = get(GUI_Parameters.General.Categories_Filter_Handles,'UserData');
				A = cellfun(@string,A(2*Vc-1),'UniformOutput',false);
				A = cellstr(cellfun(@char,A,'UniformOutput',false));
				Lg = legend(A,'Location','best');
			else % At least one category is selected.
				b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat);
				colormap(GUI_Parameters.Visuals.Active_Menorah_Colormap(2*GUI_Parameters.General.Categories_Filter_Values-1,:));
				Lg = legend(GUI_Parameters.General.Menorah_Orders_Labels,'Location','best');
			end			
			
			xlim([XAxis_Min_Max(1),XAxis_Min_Max(2)]);
			set(gca,'YLim',[0, get(gca, 'YLim')*[0;1]]);
			
			Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
			Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
			Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
			
			% xlim([-350,550]);
			% ylim([0,900]);
			% XBins = {'[-350,-250]' ; '[-250,-150]' ; '[-150,-50]' ; '[-50,50]' ; '[50,150]' ; '[150,250]' ; '[250,350]' ; '[350,450]' ; '[450,550]'};
			% XBins = {'[-45,-15]' ; '[-15,15]' ; '[15,45]' ; '[45,75]' ; '[75,105]'};
			% set(gca,'XTickLabel',XBins);
			
			set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size, ...
			'XTick',XTick_Vector,'xdir',XAxis_Direction, ...
			'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
			ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			% xlabel([XLabel,' ','; Bin Size =',' ',num2str(BinSize)],'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			xlabel(XLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			title(Title1,'FontSize',GUI_Parameters.Visuals.Main_Title_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
		end
	else % Do not merge.
		if(length(GUI_Parameters.General.Groups_OnOff) > 1 || ... % All categories are averaged.
			(length(GUI_Parameters.General.Groups_OnOff) == 1 && Categories1 == 0)) % Only one category.
			
			h1 = subplot(2,1,1);
				% p1 = get(h1, 'pos');
				% p1(4) = p1(4) * 1.3;
				% p1(2) = p1(2) * 0.7;
				% set(h1,'pos',p1);
				
				Bar_Mat = zeros(length(Edges_Vector)-1,length(GUI_Parameters.General.Groups_OnOff));
				Bar_STD = zeros(length(Edges_Vector)-1,length(GUI_Parameters.General.Groups_OnOff));
				for i=1:length(GUI_Parameters.General.Groups_OnOff) % For each group.
					for bin_i=1:size(Groups1{1,1},1) % For each bin.
						A = cell2mat(Groups1{i}(bin_i,:,1)); % Each col is a category. Each row is a different animal (in group i).
						Bar_Mat(bin_i,i) = nanmean(nansum(A,2)); % Sum of all categories for each animal, then mean of animals.
						Bar_STD(bin_i,i) = nanstd(nansum(A,2)); % Sum of all categories for each animal, then std of animals.
					end
				end
				b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat);
				colormap(GUI_Parameters.Visuals.Active_Colormap(GUI_Parameters.General.Groups_OnOff,:));
				
				if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
					pause(0.1); % Bug fix - since 2014b, a delay is needed in order to let the engine create the plot (before using the handle).
					hold on;
					for s=1:length([b1.XOffset]) % For each set of bars (group or category).
						for p=1:length([b1(s).XData]) % For each x-value.
							Xv = b1(s).XData(p) + b1(s).XOffset;
							plot([Xv,Xv],[b1(s).YData(p)-Bar_STD(p,s),b1(s).YData(p)+Bar_STD(p,s)],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',3); % GUI_Parameters.Visuals.ErrorBar_Color1
						end
						b1(s).FaceColor = 'none';
						b1(s).EdgeColor = GUI_Parameters.Visuals.Active_Colormap(GUI_Parameters.General.Groups_OnOff(s),:);
						b1(s).LineWidth = 3;
					end
				end
				if(GUI_Parameters.Handles.Display_Significance_Bars_CheckBox.Value)
					pause(0.1); % Bug fix - since 2014b, a delay is needed in order to let the engine create the plot (before using the handle).
					Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
					hold on;
					for s=1:length([b1.XOffset]) % For each set of bars (for each group of animals = for each cell in Group1).
						for p=1:length([b1(s).XData]) % For each x-value (each bin = each row in each group cell).
							A = sum(cell2mat(Groups1{s}(p,:,1)),2); % Take the cell of animal s, and bin p. Convert to a matrix and sum up each animal for all categories. The result: a vector of animals mean values.
							
							Groups_Struct(end+1).Group_ID = b1(s).XData(p) + b1(s).XOffset;
							Groups_Struct(end).Values = A; % TODO: fix for dorsal-ventral.
							Groups_Struct(end).Mean = nanmean(A);
							Groups_Struct(end).SE = nanstd(A);
							Groups_Struct(end).Category = b1(s).XData(p);
						end
					end
					Get_Statistically_Significance_Bars(Groups_Struct,GUI_Parameters.Visuals.Active_Colormap(1,:));
				end
				
				xlim([XAxis_Min_Max(1),XAxis_Min_Max(2)]);
				set(gca,'YLim',[0, get(gca, 'YLim')*[0;1]]);
				
				% Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
				
				% XBins = {'[-0.6,-0.2]' ; '[-0.2,0.2]' ; '[0.2,0.6]' ; '[0.6,1]'}; % Menorahs Symmetry. 0.4.
				% set(gca,'XTickLabel',XBins);
				set(gca,'XTick',XTick_Vector);
				
				set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size, ...
				'xdir',XAxis_Direction, ...
				'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
				% ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				% xlabel([XLabel,' ','; Bin Size =',' ',num2str(BinSize)],'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				T1 = title(Title1,'FontSize',GUI_Parameters.Visuals.Main_Title_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));
				
			h2 = subplot(2,1,2);
				% p2 = get(h2, 'pos');
				% p2(4) = p2(4) * 1.3;
				% set(h2,'pos',p2);
				
				% display(p1);
				% display(p2);
				
				Bar_Mat = zeros(length(Edges_Vector)-1,length(GUI_Parameters.General.Groups_OnOff));
				Bar_STD = zeros(length(Edges_Vector)-1,length(GUI_Parameters.General.Groups_OnOff));
				for i=1:length(GUI_Parameters.General.Groups_OnOff) % For each group.
					for bin_i=1:size(Groups1{1,1},1) % For each bin.
						A = cell2mat(Groups1{i}(bin_i,:,2)); % Each col is a category. Each row is a different animal (in group i).
						Bar_Mat(bin_i,i) = nanmean(nansum(A,2)); % Sum of all categories for each animal, then mean of animals.
						Bar_STD(bin_i,i) = nanstd(nansum(A,2)); % Sum of all categories for each animal, then std of animals.
					end
				end
				b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat);
				colormap(GUI_Parameters.Visuals.Active_Colormap(GUI_Parameters.General.Groups_OnOff,:));
				
				xlim([XAxis_Min_Max(1),XAxis_Min_Max(2)]);
				set(gca,'YLim',[0, get(gca, 'YLim')*[0;1]],'ydir','reverse');
				
				if(GUI_Parameters.Handles.Standard_Deviation_CheckBox.Value)
					pause(0.1); % Bug fix - since 2014b, a delay is needed in order to let the engine create the plot (before using the handle).
					hold on;
					for s=1:length([b1.XOffset]) % For each set of bars (group or category).
						for p=1:length([b1(s).XData]) % For each x-value.
							Xv = b1(s).XData(p) + b1(s).XOffset;
							plot([Xv,Xv],[b1(s).YData(p)-Bar_STD(p,s),b1(s).YData(p)+Bar_STD(p,s)],'Color',GUI_Parameters.Visuals.Active_Colormap(1,:),'LineWidth',3); % GUI_Parameters.Visuals.ErrorBar_Color1
						end
						b1(s).FaceColor = 'none';
						b1(s).EdgeColor = GUI_Parameters.Visuals.Active_Colormap(GUI_Parameters.General.Groups_OnOff(s),:);
						b1(s).LineWidth = 3;
					end
				end
				if(GUI_Parameters.Handles.Display_Significance_Bars_CheckBox.Value)
					pause(0.1); % Bug fix - since 2014b, a delay is needed in order to let the engine create the plot (before using the handle).
					Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
					hold on;
					for s=1:length([b1.XOffset]) % For each set of bars (for each group of animals = for each cell in Group1).
						for p=1:length([b1(s).XData]) % For each x-value (each bin = each row in each group cell).
							A = sum(cell2mat(Groups1{s}(p,:,2)),2); % Take the cell of animal s, and bin p. Convert to a matrix and sum up each animal for all categories. The result: a vector of animals mean values.
							
							Groups_Struct(end+1).Group_ID = b1(s).XData(p) + b1(s).XOffset;
							Groups_Struct(end).Values = A; % TODO: fix for dorsal-ventral.
							Groups_Struct(end).Mean = nanmean(A);
							Groups_Struct(end).SE = nanstd(A);
							Groups_Struct(end).Category = b1(s).XData(p);
						end
					end
					Get_Statistically_Significance_Bars(Groups_Struct,GUI_Parameters.Visuals.Active_Colormap(1,:));
				end
				
				set(gca,'XTick',[]);
				
				% Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
				
				% XBins = {'[-45,-15]' ; '[-15,15]' ; '[15,45]' ; '[45,75]' ; '[75,105]'};
				% set(gca,'XTickLabel',XBins);
				
				set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size, ...
				'xdir',XAxis_Direction, ...
				'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
				ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				xlabel([XLabel,' ','; Bin Size =',' ',num2str(BinSize)],'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				% xlabel(XLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			
			% t1 = get(T1,'pos');
			p1 = get(h1,'pos');
			p2 = get(h2,'pos');
			D12 = (p1(2) - (p2(2) + p2(4))) / 2; % The distance between the subplots.
			p1(4) = p1(4) + D12/2;
			p1(2) = p1(2) - D12/2;
			p2(4) = p2(4) + D12/2 - 0.03;
			set(h1,'pos',p1);
			set(h2,'pos',p2);
			% set(T1,'pos',[t1(1),,0]);
			Y1 = get(h1,'ylim');
			Y2 = get(h2,'ylim');
			set(h1,'ylim',[0,max(Y1(2),Y2(2))]);
			set(h2,'ylim',[0,max(Y1(2),Y2(2))]);
			
		elseif(length(GUI_Parameters.General.Groups_OnOff) == 1) % AND Categories1 > 0.
			h1 = subplot(2,1,1);
				Bar_Mat_Dorsal = cellfun(@nanmean,Groups1{1}(:,:,1)); % Mean of all animals for each category, and then, mean of all categories.
				% Bar_STD = cellfun(@nanstd,Groups1{1}(:,:,1)); % Mean of all animals for each category, and then, mean of all categories.
				if(length(GUI_Parameters.General.Categories_Filter_Values) == 0)
					b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat_Dorsal,'stacked');
					colormap(GUI_Parameters.Visuals.Active_Menorah_Colormap(2*Vc-1,:));
					A = get(GUI_Parameters.General.Categories_Filter_Handles,'UserData');
					A = cellfun(@string,A(2*Vc-1),'UniformOutput',false);
					A = cellstr(cellfun(@char,A,'UniformOutput',false));
					Lg = legend(A,'Location','best');
				else % At least one category is selected.
					b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat_Dorsal);
					colormap(GUI_Parameters.Visuals.Active_Menorah_Colormap(2*GUI_Parameters.General.Categories_Filter_Values-1,:));
					Lg = legend(GUI_Parameters.General.Menorah_Orders_Labels,'Location','best');
				end
				
				xlim([XAxis_Min_Max(1),XAxis_Min_Max(2)]);
				set(gca,'YLim',[0, get(gca, 'YLim')*[0;1]]);
				
				Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
				
				% XBins = {'[-90,-75]' ; '[-75,-45]' ; '[-45,-15]' ; '[-15,15]' ; '[15,45]' ; '[45,75]' ; '[75,90]'};
				% XBins = {'[-45,-15]' ; '[-15,15]' ; '[15,45]' ; '[45,75]' ; '[75,105]'};
				% set(gca,'XTickLabel',XBins);
				% ylim([0,0.2]);
				
				set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size/1.5, ...
				'XTick',XTick_Vector,'xdir',XAxis_Direction, ...
				'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
				% ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				% xlabel([XLabel,' ','; Bin Size =',' ',num2str(BinSize)],'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				title(Title1,'FontSize',GUI_Parameters.Visuals.Main_Title_Font_Size,'Color',GUI_Parameters.Visuals.Active_Colormap(1,:));

			h2 = subplot(2,1,2);
				Bar_Mat_Ventral = cellfun(@nanmean,Groups1{1}(:,:,2)); % Mean of all animals for each category, and then, mean of all categories.
				% Bar_STD = cellfun(@nanstd,Groups1{1}(:,:,1)); % Mean of all animals for each category, and then, mean of all categories.
				if(length(GUI_Parameters.General.Categories_Filter_Values) == 0)
					b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat_Ventral,'stacked');
					colormap(GUI_Parameters.Visuals.Active_Menorah_Colormap(2*Vc-1,:));
					A = get(GUI_Parameters.General.Categories_Filter_Handles,'UserData');
					A = cellfun(@string,A(2*Vc-1),'UniformOutput',false);
					A = cellstr(cellfun(@char,A,'UniformOutput',false));
					% Lg = legend(A,'Location','best');
				else % At least one category is selected.
					b1 = bar(Edges_Vector(1:end-1)+BinSize/2,Bar_Mat_Ventral);
					colormap(GUI_Parameters.Visuals.Active_Menorah_Colormap(2*GUI_Parameters.General.Categories_Filter_Values-1,:));
					% Lg = legend(GUI_Parameters.General.Menorah_Orders_Labels,'Location','best');
				end
				
				xlim([XAxis_Min_Max(1),XAxis_Min_Max(2)]);
				set(gca,'YLim',[0, get(gca, 'YLim')*[0;1]],'ydir','reverse');
				
				% Lg.TextColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.EdgeColor = GUI_Parameters.Visuals.Active_Colormap(1,:);
				% Lg.FontSize = GUI_Parameters.Visuals.Legend_Font_Size1;
				
				% XBins = {'[-45,-15]' ; '[-15,15]' ; '[15,45]' ; '[45,75]' ; '[75,105]'};
				% set(gca,'XTickLabel',[]); % ,XBins
				% ylim([0,0.2]);
				
				set(gca,'FontSize',GUI_Parameters.Visuals.Axes_Lables_Font_Size/1.5, ...
				'XTick',XTick_Vector,'xdir',XAxis_Direction, ...
				'XColor',GUI_Parameters.Visuals.Active_Colormap(1,:),'YColor',GUI_Parameters.Visuals.Active_Colormap(1,:));
				ylabel(YLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				% xlabel([XLabel,' ','; Bin Size =',' ',num2str(BinSize)],'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
				xlabel(XLabel,'FontSize',GUI_Parameters.Visuals.Axes_Titles_Font_Size);
			
			p1 = get(h1,'pos');
			p2 = get(h2,'pos');
			D12 = (p1(2) - (p2(2) + p2(4))) / 2; % The distance between the subplots.
			p1(4) = p1(4) + D12/2;
			p1(2) = p1(2) - D12/2;
			p2(4) = p2(4) + D12/2 - 0.03;
			set(h1,'pos',p1);
			set(h2,'pos',p2);
			Y1 = get(h1,'ylim');
			Y2 = get(h2,'ylim');
			set(h1,'ylim',[0,max(Y1(2),Y2(2))]);
			set(h2,'ylim',[0,max(Y1(2),Y2(2))]);
		end
	end
	
end