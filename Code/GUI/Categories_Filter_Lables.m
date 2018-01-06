function Categories_Filter_Lables(GUI_Parameters)
	
	if(GUI_Parameters.General.View_Category_Type == 2) % Vertices plot.
		Vertices_Angles_Strings = {'[1,1,1.5]' ; '[1,1,2]' ; '[1.5,1.5,2]' ; '[2,2,2.5]' ; '[2,2,3]' ; '[2,3,3]' ; '[2,3,3.5]' ; ...
								   '[2,3,4]' ; '[2,3.5,4]' ; '[2,4,4]' ; '[3,3,4]' ; '[3,3.5,4]' ; '[3.5,3.5,5]' ; '[4,4,5]' ; '[4,5,5]'};
		GUI_Parameters.General.Vertices_Angles_Values = [1,1,1.5 ; 1,1,2 ; 1.5,1.5,2 ; 2,2,2.5 ; 2,2,3 ; 2,3,3 ; 2,3,3.5 ; ...
						 2,3,4 ; 2,3.5,4 ; 2,4,4 ; 3,3,4 ; 3,3.5,4 ; 3.5,3.5,5 ; 4,4,5 ; 4,5,5];
		GUI_Parameters.General.Vertices_Angles_Filter_Values = ones(1,numel(Vertices_Angles_Strings));
		
		for i=1:GUI_Parameters.General.Num_Of_Caterogories_Filter_Buttons
			if(i > numel(Vertices_Angles_Strings))
				set(GUI_Parameters.General.Categories_Filter_Handles(i),'String','');
				set(GUI_Parameters.General.Categories_Filter_Handles(i),'UserData',[0,0,0]);
			else
				set(GUI_Parameters.General.Categories_Filter_Handles(i),'String',Vertices_Angles_Strings(i));
				set(GUI_Parameters.General.Categories_Filter_Handles(i),'UserData',GUI_Parameters.General.Vertices_Angles_Values(i,:));
			end
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'BackgroundColor',[.7,.7,.7]);
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'ForegroundColor','k');
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'Tag',num2str(i));
		end
		set(GUI_Parameters.General.Categories_Filter_Handles,'Enable','on');
		set(GUI_Parameters.General.Categories_Filter_Handles,'Value',1);
	elseif(GUI_Parameters.General.View_Category_Type == 1) % Regular Plot.
		ColorMap = GUI_Parameters.Visuals.Active_Colormap;
		% assignin('base','GUI_Parameters',GUI_Parameters);
		% set(GUI_Parameters.General.Categories_Filter_Handles,'BackgroundColor',[.7,.7,.7]);
		% set(GUI_Parameters.General.Categories_Filter_Handles,'String','']);
		for i=1:GUI_Parameters.General.Num_Of_Menorah_Orders
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'String',num2str((i+1)/2));
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'UserData',(i+1)/2);
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'BackgroundColor',ColorMap(i,:));
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'ForegroundColor','k');
			set(GUI_Parameters.General.Categories_Filter_Handles(i),'Enable','on');
		end
		% set(GUI_Parameters.General.Categories_Filter_Handles,'Enable','on');
		set(GUI_Parameters.General.Categories_Filter_Handles,'Value',1);
	else
		set(GUI_Parameters.General.Categories_Filter_Handles,'Enable','off');
	end
	
end