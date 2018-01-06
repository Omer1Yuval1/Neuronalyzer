function GUI_Parameters_General = Update_Categories_Filter_Values(GUI_Parameters_General,ColorMap)
	
	% This function generates a column vector of the values and labels of the current selected categories.
	C = get(GUI_Parameters_General.Categories_Filter_Handles,'Value');
	
	if(GUI_Parameters_General.View_Category_Type == 1)
		F = find(cell2mat(C(1:GUI_Parameters_General.Num_Of_Menorah_Orders)) == 1); % An array of positions\indices that indicates which checkboxes are ON.
	elseif(GUI_Parameters_General.View_Category_Type == 2)
		F = find(cell2mat(C(1:GUI_Parameters_General.Num_Of_Menorah_Angles_Orders)) == 1); % An array of positions\indices that indicates which checkboxes are ON.
	end
	A = get(GUI_Parameters_General.Categories_Filter_Handles(F),'UserData'); % An array of selected checkboxes values.
	
	GUI_Parameters_General.Menorah_Orders_Labels = {};
	if(iscell(A))
		GUI_Parameters_General.Categories_Filter_Values = cell2mat(A);
	else
		GUI_Parameters_General.Categories_Filter_Values = A; % Zero or one value.
	end
	
	% assignin('base','A',A);
	
	if(length(A) > 0)
		if(size(A,1) == 1)
			A = cellfun(@string,{A},'UniformOutput',false);
		else
			A = cellfun(@string,A,'UniformOutput',false);
		end
		A = cellfun(@char,A,'UniformOutput',false);
		GUI_Parameters_General.Menorah_Orders_Labels = cellstr(A);
		% GUI_Parameters_General.Menorah_Orders_Labels = cellstr(string(A));
		if(GUI_Parameters_General.View_Category_Type == 1 && strcmp(char(string(A(end))),num2str(GUI_Parameters_General.Max_Menorah_Order)))
			GUI_Parameters_General.Menorah_Orders_Labels(end) = {[char(GUI_Parameters_General.Menorah_Orders_Labels(end)),'+']};
		end
	end
	
	if(GUI_Parameters_General.View_Category_Type == 1) % Branches Orders Plot.
		% ColorMap = hsv(15);
		% ColorMap = GUI_Parameters.Visuals.Active_Colormap;
		set(GUI_Parameters_General.Categories_Filter_Handles,'BackgroundColor',[.7,.7,.7]);
		for i=1:GUI_Parameters_General.Num_Of_Menorah_Orders
			
			if(get(GUI_Parameters_General.Categories_Filter_Handles(i),'Value') == 1)
				set(GUI_Parameters_General.Categories_Filter_Handles(i),'BackgroundColor',ColorMap(i,:));
			end
		end
		% GUI_Parameters_General.Categories_Colormap = jet(GUI_Parameters_General.Num_Of_Menorah_Orders);
		% GUI_Parameters_General.Categories_Colormap = GUI_Parameters_General.Categories_Colormap(F,:);
		% colormap(GUI_Parameters_General.Categories_Colormap);
	end
	
	% assignin('base','F',F);
	% assignin('base','Categories_Colormap',GUI_Parameters_General.Categories_Colormap);
	% assignin('base','Categories_Filter_Values',GUI_Parameters_General.Categories_Filter_Values);
	
end