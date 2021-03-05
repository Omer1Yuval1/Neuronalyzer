function Set_Plots_Menu(P)
	
	% set(P.GUI_Handles.Plots_Menu_Handles(:));
	P.GUI_Handles.Plots_Menu_Handles = gobjects(1,60);
	
	H_Menu1_Length = uimenu(P.GUI_Handles.Menus(3),'Label','Length');
		P.GUI_Handles.Plots_Menu_Handles(1) = uimenu(H_Menu1_Length,'Label','Neuronal Length per Menorah Order','Checked','on');
		P.GUI_Handles.Plots_Menu_Handles(2) = uimenu(H_Menu1_Length,'Label','Mean Segment Length','Enable','off');
		P.GUI_Handles.Plots_Menu_Handles(3) = uimenu(H_Menu1_Length,'Label','Distribution of Segment Lengths Per Order','Enable','off');
		P.GUI_Handles.Plots_Menu_Handles(4) = uimenu(H_Menu1_Length,'Label','Segment Linearity','Enable','off');
		P.GUI_Handles.Plots_Menu_Handles(5) = uimenu(H_Menu1_Length,'Label','End2End Length Of Segments','Enable','off');
	
	H_Menu2_Counts = uimenu(P.GUI_Handles.Menus(3),'Label','Count / Density');
		P.GUI_Handles.Plots_Menu_Handles(6) = uimenu(H_Menu2_Counts,'Label','Junction Number/Density','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(7) = uimenu(H_Menu2_Counts,'Label','Tip Number/Density','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(8) = uimenu(H_Menu2_Counts,'Label','Number of Segments','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(9) = uimenu(H_Menu2_Counts,'Label','Number of Menorahs','Enable','on');
		
	H_Menu3_Curvature = uimenu(P.GUI_Handles.Menus(3),'Label','Curvature');
		P.GUI_Handles.Plots_Menu_Handles(10) = uimenu(H_Menu3_Curvature,'Label','Mean Curvature','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(11) = uimenu(H_Menu3_Curvature,'Label','Curvature Distribution','Enable','off');
		P.GUI_Handles.Plots_Menu_Handles(12) = uimenu(H_Menu3_Curvature,'Label','Max Segment Curvature per Menorah Order','Enable','off');
	
	H_Menu2_CB = uimenu(P.GUI_Handles.Menus(3),'Label','Cell Body','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(13) = uimenu(H_Menu2_CB,'Label','CB Intensity','Enable','off');
		P.GUI_Handles.Plots_Menu_Handles(14) = uimenu(H_Menu2_CB,'Label','CB Area','Enable','off');
	
	H_Menu3_Vertices = uimenu(P.GUI_Handles.Menus(3),'Label','Vertices Angles','Callback','');
				P.GUI_Handles.Plots_Menu_Handles(15) = uimenu(H_Menu3_Vertices,'Label','Histogram of all Angles');
				% P.GUI_Handles.Plots_Menu_Handles(16) = uimenu(H_Menu311,'Label','Angles of Menorah Orders');			
	
	H_Menu4_Orientation = uimenu(P.GUI_Handles.Menus(3),'Label','Midline Orientation','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(43) = uimenu(H_Menu4_Orientation,'Label','Distribution of Midline Orientation');
		P.GUI_Handles.Plots_Menu_Handles(44) = uimenu(H_Menu4_Orientation,'Label','Distribution of Midline Orientation Along the Midline');
		P.GUI_Handles.Plots_Menu_Handles(45) = uimenu(H_Menu4_Orientation,'Label','Distribution of Midline Orientation Along the Midline - Vertices Only');
			% H_Menu1321_Primary_Vertices_Mean_Distance = uimenu(H_Menu132_Distances,'Label','Primary_Vertices_Mean_Distance');
		% H_Menu133_Vertices_Density = uimenu(H_Menu13_Vertices,'Label','Density of Vertices');			
	
	H_Menu6_Distance = uimenu(P.GUI_Handles.Menus(3),'Label','Radial Distance','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(46) = uimenu(H_Menu6_Distance,'Label','Radial Distance of All Points');
		P.GUI_Handles.Plots_Menu_Handles(47) = uimenu(H_Menu6_Distance,'Label','Radial Distance of All Points - Second Moment');
		P.GUI_Handles.Plots_Menu_Handles(48) = uimenu(H_Menu6_Distance,'Label','Radial Distance of 3-Way Junctions');
		P.GUI_Handles.Plots_Menu_Handles(49) = uimenu(H_Menu6_Distance,'Label','Radial Distance of Tips');
		
	H_Menu8_Angular = uimenu(P.GUI_Handles.Menus(3),'Label','Angular Coordinate','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(50) = uimenu(H_Menu8_Angular,'Label','Angular Coordinate of All Points');
		P.GUI_Handles.Plots_Menu_Handles(51) = uimenu(H_Menu8_Angular,'Label','Angular Coordinate of Junctions');
		P.GUI_Handles.Plots_Menu_Handles(52) = uimenu(H_Menu8_Angular,'Label','Angular Coordinate of Tips');
		P.GUI_Handles.Plots_Menu_Handles(53) = uimenu(H_Menu8_Angular,'Label','Angular Coordinate of All Points - Second Moment');
	
	H_Menu7_Midline_Density = uimenu(P.GUI_Handles.Menus(3),'Label','Menorah Orders','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(54) = uimenu(H_Menu7_Midline_Density,'Label','Menorah Orders Classification','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(55) = uimenu(H_Menu7_Midline_Density,'Label','Midline Density - Neuronal Length');
		P.GUI_Handles.Plots_Menu_Handles(56) = uimenu(H_Menu7_Midline_Density,'Label','Density of Points per Menorah order','Enable','off');
	
	% H_Menu5_2D_Plots = uimenu(P.GUI_Handles.Menus(3),'Label','2D Plots','Callback','');
		% P.GUI_Handles.Plots_Menu_Handles(57) = uimenu(H_Menu5_2D_Plots,'Label','Midline Distance VS Midline Orientation');
		% P.GUI_Handles.Plots_Menu_Handles(58) = uimenu(H_Menu5_2D_Plots,'Label','Midline Distance VS Curvature');
		% P.GUI_Handles.Plots_Menu_Handles(59) = uimenu(H_Menu5_2D_Plots,'Label','Midline Orientation VS Curvature');
		% P.GUI_Handles.Plots_Menu_Handles(60) = uimenu(H_Menu5_2D_Plots,'Label','Midline Orientation VS Curvature VS Midlines Distance');
	
	for i=1:length(P.GUI_Handles.Plots_Menu_Handles)
		if(~isempty(properties(P.GUI_Handles.Plots_Menu_Handles(i))))
			set(P.GUI_Handles.Plots_Menu_Handles(i),'UserData',3);
		end
	end
end