function Reconstruction_Index(GUI_Parameters)
	
	figure(1);
	hold on;	
	
	switch GUI_Parameters.General.Active_Plot
		case 'Original Image'
			imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
		case 'Volume - Initial Guess'
			Reconstruct_Initial_Guess_Volume(GUI_Parameters.Workspace(1).Workspace);
		case 'Trace'
			
		case 'Full Trace'
			Reconstruct_Trace_Full(GUI_Parameters.Workspace(1).Workspace);
		case 'Skeleton'
			Reconstruct_Trace_Pixels(GUI_Parameters.Workspace(1).Workspace);
		
		case 'Segmentation'
			Reconstruct_Segmented_Trace(GUI_Parameters.Workspace(1).Workspace); % Reconstruct_Segments(GUI_Parameters.Workspace(1).Workspace);
		case 'Menorah Orders'
			Reconstruct_Menorah_Orders(GUI_Parameters.Workspace(1).Workspace);
		case 'Individual Menorahs'
			Reconstruct_Menorahs(GUI_Parameters.Workspace(1).Workspace);
		case 'Vertices Angles'
			Reconstruct_Vertices(GUI_Parameters);
		case 'Vertices Angles - Skeleton'
			Reconstruct_Skeleton_Vertices(GUI_Parameters);
		case 'Dorsal-Ventral'
			Reconstruct_Dorsal_Ventral(GUI_Parameters.Workspace(1).Workspace);
		case 'Longitudinal Gradient'
			Reconstruct_Gradient(GUI_Parameters.Workspace(1).Workspace);
		case 'Curvature'
			Reconstruct_Curvature(GUI_Parameters.Workspace(1).Workspace,2,GUI_Parameters.Handles.Slider.Value);
			% Reconstruct_Curviness(GUI_Parameters.Workspace(1).Workspace,GUI_Parameters.Slider_Value,GUI_Parameters.Reconstruction_Value);
		case 'Persistence Length'
			Reconstruct_Persistence_Length(GUI_Parameters.Workspace(1).Workspace,GUI_Parameters.Reconstruction_Value,GUI_Parameters.Slider_Value);
		case 'Curviness Length'
			% Reconstruct_Least_Mean_Squared(GUI_Parameters.Workspace(1).Workspace,GUI_Parameters.Reconstruction_Value,GUI_Parameters.Slider_Value);
		% case {13,14}
			% Reconstruct_Length(GUI_Parameters.Workspace(1).Workspace,GUI_Parameters.Slider_Value,GUI_Parameters.Reconstruction_Value);
		otherwise
			Reconstruct_Trace(GUI_Parameters.Workspace(1).Workspace);
	end
	
	hold on;
	Scale_Factor = GUI_Parameters.Workspace(1).Workspace.User_Input.Scale_Factor;
	plot([20,20+50*(1/Scale_Factor)],[20,20],'w','LineWidth',3);
	text(8+25,75,['50 \mum'],'FontSize',20,'Color','w');
	
	% hold on;
	% Compass1 = imread('Compass.tif');
	% imshow(Compass1);
	% imshow(imresize(Compass1,1)); % 0.1*GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Im_Rows));
	
end