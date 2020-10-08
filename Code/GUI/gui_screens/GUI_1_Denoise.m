function GUI_1_Denoise(P)
	
	% Set sliders and text boxes to choose parameters for CNN and binary image.
	
	
	Control_Panel_Grid = P.GUI_Handles.Control_Panel_Objects(1,1).Parent;
	Titles = {'CNN Threshold','Min Object Size','Marker Size'};
	
	for i=1:length(Titles)
		set(P.GUI_Handles.Control_Panel_Objects(i,5),'Text',Titles{i});
		
		
		r = P.GUI_Handles.Control_Panel_Objects(i,7).Layout.Row;
		c = P.GUI_Handles.Control_Panel_Objects(i,7).Layout.Column;
		delete(P.GUI_Handles.Control_Panel_Objects(i,7));
		P.GUI_Handles.Control_Panel_Objects(i,7) = uislider(Control_Panel_Grid,'UserData',[i,4]);
		P.GUI_Handles.Control_Panel_Objects(i,7).Layout.Row = r;
		P.GUI_Handles.Control_Panel_Objects(i,7).Layout.Column = c;
		
		r = P.GUI_Handles.Control_Panel_Objects(i,9).Layout.Row;
		c = P.GUI_Handles.Control_Panel_Objects(i,9).Layout.Column;
		delete(P.GUI_Handles.Control_Panel_Objects(i,9));
		P.GUI_Handles.Control_Panel_Objects(i,9) = uispinner(Control_Panel_Grid,'UserData',[i,5],'HorizontalAlignment','center');
		P.GUI_Handles.Control_Panel_Objects(i,9).Layout.Row = r;
		P.GUI_Handles.Control_Panel_Objects(i,9).Layout.Column = c;
end