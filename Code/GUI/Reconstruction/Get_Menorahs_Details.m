function Get_Menorahs_Details(GUI_Parameters)
	
	[x,y] = ginput(1);
	
	Text_Font_Size = 16;
	Text_Color = [0,0,0];
	
	MinD = max(size(GUI_Parameters.Workspace(1).Files{1}.Image0,1),size(GUI_Parameters.Workspace(1).Files{1}.Image0,2));
	C = 0;
	for i=1:numel(GUI_Parameters.Workspace(1).Files{1}.Segments)
		Xs = mean([GUI_Parameters.Workspace(1).Files{1}.Segments(i).Rectangles(1).X,GUI_Parameters.Workspace(1).Files{1}.Segments(i).Rectangles(end).X]);
		Ys = mean([GUI_Parameters.Workspace(1).Files{1}.Segments(i).Rectangles(1).Y,GUI_Parameters.Workspace(1).Files{1}.Segments(i).Rectangles(end).Y]);
		D = ((Xs - x)^2+(Ys - y)^2)^.5;
		if(D < MinD)
			MinD = D;
			C = i;
		end
	end
	
	M = GUI_Parameters.Workspace(1).Files{1}.Segments(C).Menorah;
	
	if(M > 0)
		Fm = find([GUI_Parameters.Workspace(1).Files{1}.Menorahs.Menorah_Index] == M);
		
		% TextBox = uicontrol(GUI_Parameters.Handles.Details_Tab,'style','text','Units','normalized','Position',[0,0,1,.85], ...
			% 'FontSize',18,'HorizontalAlignment','center');
		% set(TextBox,'BackgroundColor',get(GUI_Parameters.Handles.Details_Tab,'BackgroundColor'));
		Ax1 = axes(GUI_Parameters.Handles.Details_Tab,'Units','normalized','Position',[0,0,1,.95]);
		
		text(Ax1,0,0.85,['Total Length: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Total_Length),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
		
		% text(Ax1,0,0.75,['Disance from CB: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Primary_Arc_Distance_From_CB),'\mum'] ...
		% 	,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
		
		text(Ax1,0,0.75,['Anterior Overlap: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Anterior_Overlap),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
			
		text(Ax1,0,0.65,['Posterior Overlap: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Posterior_Overlap),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
			
		text(Ax1,0,0.55,['Anterior Length: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Anterior_Length),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
			
		text(Ax1,0,0.45,['Posterior Length: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Posterior_Length),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
			
		text(Ax1,0,0.35,['Anterior-Most Point: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Max_Anterior),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
			
		text(Ax1,0,0.25,['Posterior-Most Point: ',num2str(GUI_Parameters.Workspace(1).Files{1}.Menorahs(Fm).Max_Posterior),'\mum'] ...
			,'FontSize',Text_Font_Size,'Color',Text_Color,'HorizontalAlignment','left');
			
			
		axis off;
	end
	axes(GUI_Parameters.Handles.Axes);
end