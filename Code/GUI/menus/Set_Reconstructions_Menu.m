function Set_Reconstructions_Menu(P)
	
	P.GUI_Handles.Reconstruction_Menu_Handles = gobjects(1,27);
	
	H_Raw_Image = uimenu(P.GUI_Handles.Menus(2),'Label','Raw Image');
		P.GUI_Handles.Reconstruction_Menu_Handles(1) = uimenu(H_Raw_Image,'Label','Raw Image - Grayscale');
		P.GUI_Handles.Reconstruction_Menu_Handles(2) = uimenu(H_Raw_Image,'Label','Raw Image - RGB');
	
	H_CNN = uimenu(P.GUI_Handles.Menus(2),'Label','CNN');
		P.GUI_Handles.Reconstruction_Menu_Handles(3) = uimenu(H_CNN,'Label','CNN Image - Grayscale');
		P.GUI_Handles.Reconstruction_Menu_Handles(4) = uimenu(H_CNN,'Label','CNN Image - RGB');
	
	H_Binary = uimenu(P.GUI_Handles.Menus(2),'Label','Binary Image');
		P.GUI_Handles.Reconstruction_Menu_Handles(5) = uimenu(H_Binary,'Label','Binary Image');
		P.GUI_Handles.Reconstruction_Menu_Handles(6) = uimenu(H_Binary,'Label','Raw + Binary Image - RGB');
	
	P.GUI_Handles.Reconstruction_Menu_Handles(7) = uimenu(P.GUI_Handles.Menus(2),'Label','Skeleton');
	
	P.GUI_Handles.Reconstruction_Menu_Handles(8) = uimenu(P.GUI_Handles.Menus(2),'Label','Cell Body');
	P.GUI_Handles.Reconstruction_Menu_Handles(9) = uimenu(P.GUI_Handles.Menus(2),'Label','Blob');
	
	P.GUI_Handles.Reconstruction_Menu_Handles(10) = uimenu(P.GUI_Handles.Menus(2),'Label','Trace');
	
	H_Segments = uimenu(P.GUI_Handles.Menus(2),'Label','Segments');
		P.GUI_Handles.Reconstruction_Menu_Handles(11) = uimenu(H_Segments,'Label','Segmentation');
		P.GUI_Handles.Reconstruction_Menu_Handles(12) = uimenu(H_Segments,'Label','Segments by Length');
	
	P.GUI_Handles.Reconstruction_Menu_Handles(13) = uimenu(P.GUI_Handles.Menus(2),'Label','Menorahs','Enable','off');
	
	H_Vertices = uimenu(P.GUI_Handles.Menus(2),'Label','Vertices');
		H1_Vertices_Angles = uimenu(H_Vertices,'Label','Angles');
			P.GUI_Handles.Reconstruction_Menu_Handles(14) = uimenu(H1_Vertices_Angles,'Label','Vertices Angles');
			P.GUI_Handles.Reconstruction_Menu_Handles(15) = uimenu(H1_Vertices_Angles,'Label','Vertices Angles - Corrected');
		H2_Vertices_Positions = uimenu(H_Vertices,'Label','Positions');
			P.GUI_Handles.Reconstruction_Menu_Handles(16) = uimenu(H2_Vertices_Positions,'Label','3-Way Junctions - Position');
			P.GUI_Handles.Reconstruction_Menu_Handles(17) = uimenu(H2_Vertices_Positions,'Label','Tips - Position');
	
	P.GUI_Handles.Reconstruction_Menu_Handles(18) = uimenu(P.GUI_Handles.Menus(2),'Label','Curvature');
	
	H0_1_8 = uimenu(P.GUI_Handles.Menus(2),'Label','Axes');
		P.GUI_Handles.Reconstruction_Menu_Handles(19) = uimenu(H0_1_8,'Label','Axes');
		P.GUI_Handles.Reconstruction_Menu_Handles(20) = uimenu(H0_1_8,'Label','Axes Mapping Process');
		
	P.GUI_Handles.Reconstruction_Menu_Handles(21) = uimenu(P.GUI_Handles.Menus(2),'Label','Radial Distance');
	P.GUI_Handles.Reconstruction_Menu_Handles(22) = uimenu(P.GUI_Handles.Menus(2),'Label','Azimuthal Angle');
	P.GUI_Handles.Reconstruction_Menu_Handles(23) = uimenu(P.GUI_Handles.Menus(2),'Label','Midline Orientation');
	P.GUI_Handles.Reconstruction_Menu_Handles(24) = uimenu(P.GUI_Handles.Menus(2),'Label','Longitudinal Gradient');
	P.GUI_Handles.Reconstruction_Menu_Handles(25) = uimenu(P.GUI_Handles.Menus(2),'Label','Dorsal-Ventral');
	
	H0_1_7 = uimenu(P.GUI_Handles.Menus(2),'Label','PVD Orders');
		P.GUI_Handles.Reconstruction_Menu_Handles(26) = uimenu(H0_1_7,'Label','PVD Orders - Points');
		P.GUI_Handles.Reconstruction_Menu_Handles(27) = uimenu(H0_1_7,'Label','PVD Orders - Segments');
	
	return;
	
	C = cell(30,3);
	C(1,:) = {1,'Raw Image',0,0};
		C(2,:) = {2,'Raw Image - Grayscale',1,1};
		C(3,:) = {3,'Raw Image - RGB',1,1};
	C(4,:) = {4,'Denoised Image',0,0};
		C(5,:) = {5,'Denoised Image - Grayscale',4};
		C(6,:) = {6,'Denoised Image - RGB',4};
	C(7,:) = {7,'Binary Image',0};
		C(8,:) = {8,'Binary Image',7};
		C(9,:) = {9,'Raw + Binary Image - RGB',7};
	
	S = cell2struct(C,{'id','name','parent'},2)
	H = gobjects(1,length(F));
	P.GUI_Handles.Reconstruction_Menu_Handles = gobjects(1,0);
	
	F = find([S.parent] == 0);
	while(~isempty(F))
		
		for i=1:length(F)
			
			H(i) = uimenu(S(F(i)).parent,'Label',S(F(i)).name);
			
			f = find([S.parent] == S(F(i)).id); % Find all children of entry (F(i)).
			if(isempty(f)) % If no children, save the graphic handle.
				ii = ii + 1;
				P.GUI_Handles.Reconstruction_Menu_Handles(ii) = H(i);
			else % Continue recursively.
				
			end
		end
		
	end
end