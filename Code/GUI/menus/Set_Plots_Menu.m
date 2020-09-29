function Set_Plots_Menu(P)
	
	% set(P.GUI_Handles.Plots_Menu_Handles(:));
	P.GUI_Handles.Plots_Menu_Handles = gobjects(1,60);
	
	H_Menu1_Length = uimenu(P.GUI_Handles.Menus(3),'Label','Length');
		P.GUI_Handles.Plots_Menu_Handles(1) = uimenu(H_Menu1_Length,'Label','Neuronal Length per Menorah Order');
		P.GUI_Handles.Plots_Menu_Handles(2) = uimenu(H_Menu1_Length,'Label','Mean Segment Length','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(3) = uimenu(H_Menu1_Length,'Label','Distribution of Segment Lengths Per Order','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(4) = uimenu(H_Menu1_Length,'Label','Segment Linearity','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(5) = uimenu(H_Menu1_Length,'Label','End2End Length Of Segments','Enable','off');
	
	H_Menu2_Counts = uimenu(P.GUI_Handles.Menus(3),'Label','Count / Density');
		P.GUI_Handles.Plots_Menu_Handles(6) = uimenu(H_Menu2_Counts,'Label','Junction Number/Density','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(7) = uimenu(H_Menu2_Counts,'Label','Tip Number/Density','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(8) = uimenu(H_Menu2_Counts,'Label','Number of Segments','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(9) = uimenu(H_Menu2_Counts,'Label','Number of Menorahs','Enable','on');
		
	H_Menu3_Curvature = uimenu(P.GUI_Handles.Menus(3),'Label','Curvature');
		P.GUI_Handles.Plots_Menu_Handles(10) = uimenu(H_Menu3_Curvature,'Label','Curvature Per Menorah Order','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(11) = uimenu(H_Menu3_Curvature,'Label','Curvature Distribution','Enable','on');
		P.GUI_Handles.Plots_Menu_Handles(12) = uimenu(H_Menu3_Curvature,'Label','Max Segment Curvature per Menorah Order','Enable','on');
	
	H_Menu2_CB = uimenu(P.GUI_Handles.Menus(3),'Label','Cell Body','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(13) = uimenu(H_Menu2_CB,'Label','CB Intensity','Enable','off');
		P.GUI_Handles.Plots_Menu_Handles(14) = uimenu(H_Menu2_CB,'Label','CB Area','Enable','off');
	
	H_Menu3_Vertices = uimenu(P.GUI_Handles.Menus(3),'Label','Vertices','Callback','');
		H_Menu31_Angles = uimenu(H_Menu3_Vertices,'Label','Angles','Callback','');
			H_Menu311 = uimenu(H_Menu31_Angles,'Label','Histograms','Callback','');
				P.GUI_Handles.Plots_Menu_Handles(15) = uimenu(H_Menu311,'Label','Histogram of all Angles');
				P.GUI_Handles.Plots_Menu_Handles(16) = uimenu(H_Menu311,'Label','Angles of Menorah Orders');
				P.GUI_Handles.Plots_Menu_Handles(16) = uimenu(H_Menu311,'Label','Midline Distance of Tips');
				P.GUI_Handles.Plots_Menu_Handles(17) = uimenu(H_Menu311,'Label','Histogram of Symmetry Indices','Enable','on');
				P.GUI_Handles.Plots_Menu_Handles(18) = uimenu(H_Menu311,'Label','Histogram of the Largest Angle','Enable','on');
				P.GUI_Handles.Plots_Menu_Handles(19) = uimenu(H_Menu311,'Label','Signed Midline Orientation of Junction Rectangles','Enable','on');
				P.GUI_Handles.Plots_Menu_Handles(20) = uimenu(H_Menu311,'Label','Distribution of Vertices Angles Relative To The Medial Axis','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(21) = uimenu(H_Menu311,'Label','Distribution of Vertices Angles Relative To The Medial Axis - Corrected','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(22) = uimenu(H_Menu311,'Label','Histogram of Smallest, Mid & Largest Angles','Enable','on');
				P.GUI_Handles.Plots_Menu_Handles(23) = uimenu(H_Menu31_Angles,'Label','Distribution of the Difference between Vertex and End2End Angles','Enable','off');
			H_Menu312 = uimenu(H_Menu31_Angles,'Label','Two Angles Plots','Callback','');
				P.GUI_Handles.Plots_Menu_Handles(24) = uimenu(H_Menu312,'Label','Menorah Orders of 3-Way Junctions');
				P.GUI_Handles.Plots_Menu_Handles(25) = uimenu(H_Menu312,'Label','All Angles VS Midline Distance');
				P.GUI_Handles.Plots_Menu_Handles(26) = uimenu(H_Menu312,'Label','Minimal and Maximal Angles of 3-Way junctions');
				P.GUI_Handles.Plots_Menu_Handles(27) = uimenu(H_Menu312,'Label','The Two Minimal Angles of each 3-Way junction','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(28) = uimenu(H_Menu312,'Label','Linearity-Symmetry of 3-Way junctions','Enable','on');
				P.GUI_Handles.Plots_Menu_Handles(29) = uimenu(H_Menu312,'Label','Sum of 2 Smallest VS Product of 2 Smallest','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(30) = uimenu(H_Menu312,'Label','Smallest Angle VS Diff between 2 Smallest','Enable','off');
			H_Menu313 = uimenu(H_Menu31_Angles,'Label','Three Angles Plots','Callback','');
				P.GUI_Handles.Plots_Menu_Handles(31) = uimenu(H_Menu313,'Label','2D Histogram Angles of 3-Way Junctions','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(32) = uimenu(H_Menu313,'Label','2D Histogram of Corrected Angles of 3-Way Junctions','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(33) = uimenu(H_Menu313,'Label','2D Histogram of Invariant Angles of 3-Way Junctions','Enable','off');
				P.GUI_Handles.Plots_Menu_Handles(34) = uimenu(H_Menu313,'Label','2D Histogram of Invariant Corrected Angles of 3-Way Junctions','Enable','off');
			
		H_Menu32_Angles = uimenu(H_Menu3_Vertices,'Label','Distances','Callback','');
			P.GUI_Handles.Plots_Menu_Handles(35) = uimenu(H_Menu32_Angles,'Label','Inter-Tip Distance');
			P.GUI_Handles.Plots_Menu_Handles(36) = uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The Medial Axis - Means','Enable','off');
			P.GUI_Handles.Plots_Menu_Handles(37) = uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The Medial Axis - Histogram');
			P.GUI_Handles.Plots_Menu_Handles(38) = uimenu(H_Menu32_Angles,'Label','Distances Of 3-Way Junctions From The Medial Axis - Histogram','Enable','off');
			P.GUI_Handles.Plots_Menu_Handles(39) = uimenu(H_Menu32_Angles,'Label','Distances Of Tips From The Medial Axis - Histogram','Enable','off');
			P.GUI_Handles.Plots_Menu_Handles(40) = uimenu(H_Menu32_Angles,'Label','Smallest Angle VS Distance From Medial Axis','Enable','off');
			P.GUI_Handles.Plots_Menu_Handles(41) = uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The CB','Enable','off');
		
		P.GUI_Handles.Plots_Menu_Handles(42) = uimenu(H_Menu3_Vertices,'Label','Angles VS Midline Distance');
		
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
		P.GUI_Handles.Plots_Menu_Handles(54) = uimenu(H_Menu7_Midline_Density,'Label','Menorah Orders Classification');
		P.GUI_Handles.Plots_Menu_Handles(55) = uimenu(H_Menu7_Midline_Density,'Label','Midline Density - Neuronal Length');
		P.GUI_Handles.Plots_Menu_Handles(56) = uimenu(H_Menu7_Midline_Density,'Label','Density of Points per Menorah order');
	H_Menu5_2D_Plots = uimenu(P.GUI_Handles.Menus(3),'Label','2D Plots','Callback','');
		P.GUI_Handles.Plots_Menu_Handles(57) = uimenu(H_Menu5_2D_Plots,'Label','Midline Distance VS Midline Orientation');
		P.GUI_Handles.Plots_Menu_Handles(58) = uimenu(H_Menu5_2D_Plots,'Label','Midline Distance VS Curvature');
		P.GUI_Handles.Plots_Menu_Handles(59) = uimenu(H_Menu5_2D_Plots,'Label','Midline Orientation VS Curvature');
		P.GUI_Handles.Plots_Menu_Handles(60) = uimenu(H_Menu5_2D_Plots,'Label','Midline Orientation VS Curvature VS Midlines Distance');

end