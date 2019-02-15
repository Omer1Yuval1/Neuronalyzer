function Reconstruction_Index(GP,Active_Workspace_Index)
	
	% GP is a short for GUI_Parameters.
	
	% TODO:
		% Move out: Worm_Radius_um.
	
	Worm_Radius_um = 45;
	
	figure(1);
	hold on;
	
	Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
	
	switch GP.General.Active_Plot
		case 'Original Image'
			imshow(GP.Workspace(1).Workspace.Image0,'Parent',GP.Handles.Axes);		
		case 'Segmentation'
			Reconstruct_Segmented_Trace(GP.Workspace(Active_Workspace_Index).Workspace,GP.Handles.Analysis); % Reconstruct_Segments(GP.Workspace(1).Workspace);
		case 'Medial Axis'
			X = GP.Workspace(Active_Workspace_Index).Workspace.Medial_Axis(:,1);
			Y = GP.Workspace(Active_Workspace_Index).Workspace.Medial_Axis(:,2);
			plot(X,Y,'LineWidth',3);
			
			Wi = GP.Workspace(Active_Workspace_Index).Workspace;
			for s=1:numel(Wi.Segments) % Go over each segment.
				if(~isempty(Wi.Segments(s).Rectangles))
					C = zeros(numel(Wi.Segments(s).Rectangles),1);
					for r=1:numel(Wi.Segments(s).Rectangles)
						Dr = ( (Wi.Segments(s).Rectangles(r).X - [Wi.Medial_Axis(:,1)]).^2 + (Wi.Segments(s).Rectangles(r).Y - [Wi.Medial_Axis(:,2)]).^2).^.5;
						Dr = Dr .* GP.Workspace(Active_Workspace_Index).Workspace.User_Input.Scale_Factor;
						C(r) = min(1,max(0,(min(Dr) ./ Worm_Radius_um)));
					end
					scatter([Wi.Segments(s).Rectangles.X]',[Wi.Segments(s).Rectangles.Y]',10,[C,0.*C,1-C],'filled');
					drawnow;
				end
			end
		case 'Vertices Angles'
			Reconstruct_Vertices(GP.Workspace(Active_Workspace_Index).Workspace);
		case 'Curvature'
			Reconstruct_Curvature(GP.Workspace(Active_Workspace_Index).Workspace,GP.Handles.Analysis.Slider.Value);
		otherwise
			Reconstruct_Trace(GP.Workspace(Active_Workspace_Index).Workspace);
			
		%{
		case 'Volume - Initial Guess'
			Reconstruct_Initial_Guess_Volume(GP.Workspace(1).Workspace);
		case 'Trace'
			
		case 'Full Trace'
			Reconstruct_Trace_Full(GP.Workspace(1).Workspace);
		case 'Skeleton'
			Reconstruct_Trace_Pixels(GP.Workspace(1).Workspace);
		case 'Vertices Angles - Skeleton'
			Reconstruct_Skeleton_Vertices(GP);
		case 'Dorsal-Ventral'
			Reconstruct_Dorsal_Ventral(GP.Workspace(1).Workspace);
		case 'Longitudinal Gradient'
			Reconstruct_Gradient(GP.Workspace(1).Workspace);
		case 'Menorah Orders'
			Reconstruct_Menorah_Orders(GP.Workspace(1).Workspace);
		case 'Individual Menorahs'
			Reconstruct_Menorahs(GP.Workspace(1).Workspace);
		case 'Persistence Length'
			Reconstruct_Persistence_Length(GP.Workspace(1).Workspace,GP.Reconstruction_Value,GP.Slider_Value);
		case 'Curviness Length'
			% Reconstruct_Least_Mean_Squared(GP.Workspace(1).Workspace,GP.Reconstruction_Value,GP.Slider_Value);
		% case {13,14}
			% Reconstruct_Length(GP.Workspace(1).Workspace,GP.Slider_Value,GP.Reconstruction_Value);
		%}
	end
	
	hold on;
	Scale_Factor = GP.Workspace(1).Workspace.User_Input.Scale_Factor;
	plot([20,20+50*(1/Scale_Factor)],[20,20],'w','LineWidth',3);
	text(15+25,25,['50 \mum'],'FontSize',20,'Color','w');
	
	% hold on;
	% Compass1 = imread('Compass.tif');
	% imshow(Compass1);
	% imshow(imresize(Compass1,1)); % 0.1*GP.Workspace(1).Workspace.Parameters.General_Parameters.Im_Rows));
	
	function Set_Dynamic_Sliders_Values(Handles,Min_Value,Max_Value)
		set(Handles.Dynamic_Slider_Min,'Enable','on');
		set(Handles.Dynamic_Slider_Max,'Enable','on');
		if(Handles.Dynamic_Slider_Min.Min ~= Min_Value || Handles.Dynamic_Slider_Min.Max ~= Max_Value || ...
			Handles.Dynamic_Slider_Max.Min ~= Min_Value || Handles.Dynamic_Slider_Max.Max ~= Max_Value) % Update the slider only if the max or min have changed. Otherwise, keep the last chosen values.
			Handles.Dynamic_Slider_Min.Min = Min_Value; % Scale dynamic sliders.
			Handles.Dynamic_Slider_Min.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Max.Min = Min_Value;% ".
			Handles.Dynamic_Slider_Max.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Min.Value = Min_Value;
			Handles.Dynamic_Slider_Max.Value = Max_Value;
			Handles.Dynamic_Slider_Text_Min.String = [num2str(Handles.Dynamic_Slider_Min.Value),char(181),'m']; % Update sliders text.
			Handles.Dynamic_Slider_Text_Max.String = [num2str(Handles.Dynamic_Slider_Max.Value),char(181),'m']; % ".
		end
	end
	
end