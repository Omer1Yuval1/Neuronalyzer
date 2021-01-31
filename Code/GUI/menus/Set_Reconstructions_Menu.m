function Set_Reconstructions_Menu(P)
	
	H = gobjects(1,27);
	
	H_Raw_Image = uimenu(P.GUI_Handles.Menus(2),'Label','Raw Image');
		H(1) = uimenu(H_Raw_Image,'Label','Raw Image - Grayscale','Checked','on');
		H(2) = uimenu(H_Raw_Image,'Label','Raw Image - RGB');
	
	H_CNN = uimenu(P.GUI_Handles.Menus(2),'Label','CNN');
		H(3) = uimenu(H_CNN,'Label','CNN Image - Grayscale');
		H(4) = uimenu(H_CNN,'Label','CNN Image - RGB');
	
	H_Binary = uimenu(P.GUI_Handles.Menus(2),'Label','Binary Image');
		H(5) = uimenu(H_Binary,'Label','Binary Image');
		H(6) = uimenu(H_Binary,'Label','Binary Image - RGB');
	
	H(7) = uimenu(P.GUI_Handles.Menus(2),'Label','Skeleton');
	
	H(8) = uimenu(P.GUI_Handles.Menus(2),'Label','Cell Body','Enable','off');
	H(9) = uimenu(P.GUI_Handles.Menus(2),'Label','Blob','Enable','on');
	
	H(10) = uimenu(P.GUI_Handles.Menus(2),'Label','Trace');
	
	H_Segments = uimenu(P.GUI_Handles.Menus(2),'Label','Segments');
		H(11) = uimenu(H_Segments,'Label','Segmentation');
		H(12) = uimenu(H_Segments,'Label','Segments by Length');
	
	H(13) = uimenu(P.GUI_Handles.Menus(2),'Label','Menorahs','Enable','off');
	
	H_Vertices = uimenu(P.GUI_Handles.Menus(2),'Label','Vertices');
		H(14) = uimenu(H_Vertices,'Label','Vertex Positions');
		H(15) = uimenu(H_Vertices,'Label','Junction Angles');
	
	H(18) = uimenu(P.GUI_Handles.Menus(2),'Label','Curvature');
	
	H0_1_8 = uimenu(P.GUI_Handles.Menus(2),'Label','Axes');
		H(19) = uimenu(H0_1_8,'Label','Axes');
		H(20) = uimenu(H0_1_8,'Label','Axes Mapping Process','Enable','off');
		
	H(21) = uimenu(P.GUI_Handles.Menus(2),'Label','Radial Distance');
	H(22) = uimenu(P.GUI_Handles.Menus(2),'Label','Azimuthal Angle');
	H(23) = uimenu(P.GUI_Handles.Menus(2),'Label','Midline Orientation');
	H(24) = uimenu(P.GUI_Handles.Menus(2),'Label','Longitudinal Gradient');
	H(25) = uimenu(P.GUI_Handles.Menus(2),'Label','Dorsal-Ventral');
	
	H0_1_7 = uimenu(P.GUI_Handles.Menus(2),'Label','PVD Orders');
		H(26) = uimenu(H0_1_7,'Label','PVD Orders - Points');
		H(27) = uimenu(H0_1_7,'Label','PVD Orders - Segments');
		
	
	for i=1:length(H)
		if(~isempty(properties(H(i))))
			set(H(i),'UserData',2);
		end
	end
	
	% set(H(:),'UserData',0);
	% P.GUI_Handles.Reconstruction_Menu_Handles = H;
	
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
	H = gobjects(1,0);
	
	F = find([S.parent] == 0);
	while(~isempty(F))
		
		for i=1:length(F)
			
			H(i) = uimenu(S(F(i)).parent,'Label',S(F(i)).name);
			
			f = find([S.parent] == S(F(i)).id); % Find all children of entry (F(i)).
			if(isempty(f)) % If no children, save the graphic handle.
				ii = ii + 1;
				H(ii) = H(i);
			else % Continue recursively.
				
			end
		end
		
	end
end