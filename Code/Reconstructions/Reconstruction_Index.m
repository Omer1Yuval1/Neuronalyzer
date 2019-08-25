function Reconstruction_Index(GP,ii)
	
	% GP is a short for GUI_Parameters.
	
	% TODO:
		% Move out: Worm_Radius_um.
	
	Worm_Radius_um = 45;
	
	figure(1);
	hold on;
	
	Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
	
	switch GP.General.Active_Plot
		case 'Original Image'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
		case 'Original Image - RGB'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			colormap hot;
		case 'Cell Body' % Detect and display CB and the outsets of the branches connected to it:
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			CB_BW_Threshold = GP.Workspace(ii).Workspace.Parameters.Cell_Body.BW_Threshold;
			Scale_Factor = GP.Workspace(ii).Workspace.User_Input.Scale_Factor;
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(GP.Workspace(ii).Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			% set(gca,'YDir','normal','Position',[0,0,1,1]);
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(GP.Workspace(ii).Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
		case 'Probability Image'
			imshow(GP.Workspace(ii).Workspace.NN_Probabilities,'Parent',GP.Handles.Axes);
		case 'Probability Image - RGB'
			imshow(GP.Workspace(ii).Workspace.NN_Probabilities,'Parent',GP.Handles.Axes);
			colormap hot;
		case 'Binary Image'
			imshow(GP.Workspace(ii).Workspace.Im_BW,'Parent',GP.Handles.Axes);
		case 'Skeleton'
			[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Pixel_Trace_Post_Proccessing(GP.Workspace(ii).Workspace.Im_BW);
			imshow(Im1_NoiseReduction);
			% Color connected components:
			CC = bwconncomp(Im1_NoiseReduction);
			for c=1:length(CC.PixelIdxList)
				[y,x] = ind2sub(size(Im1_NoiseReduction),CC.PixelIdxList{c});
				hold on;
				plot(x,y,'.','MarkerSize',7);
			end
		case 'Segmentation'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			if(isfield(GP.Workspace(ii).Workspace,'Segments'))
				Reconstruct_Segmented_Trace(GP.Workspace(ii).Workspace,GP.Handles.Analysis); % Reconstruct_Segments(GP.Workspace(1).Workspace);
			end
		case 'Axes'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			
			%{
			Np = str2num(GP.Handles.Tracing.Midline_Points_Num.String);
			
			XY = [GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0.X ; GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0.Y];
			
			pp = cscvn(XY); % Fit a cubic spline.
			Vb = linspace(pp.breaks(1),pp.breaks(end),Np);
			XY = fnval(pp,Vb);
			
			hold on;
			plot(XY(1,:),XY(2,:),'LineWidth',3);
			plot(XY(1,:),XY(2,:),'.','MarkerSize',20);
			
			for p=1:numel(GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0)
				x = GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0(p).X;
				y = GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0(p).Y;
				a = GP.Workspace(ii).Workspace.Neuron_Axes.Axis_0(p).Tangent_Angle + (pi/2);
				
				plot(x + 40.*[0,cos(a)] , y + 40.*[0,sin(a)]);
			end
			%}
		case 'Midline Orientation'
			
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Midline_Orientation])';
			CM = [O,0.*O,1-O];
			
			% O = round(rescale([GP.Workspace(ii).Workspace.All_Points.Midline_Orientation],1,100)');
			% CM = jet(100);
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],20,CM,'filled');
			% scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM(O,:),'filled');
			
		case 'Vertices Angles'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			Reconstruct_Vertices(GP.Workspace(ii).Workspace);
		case 'Curvature'
			Curvature_Min_Max = [0,0.2];
			% Medial_Dist_Range = [0,60];
			
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Curvature],'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))';
			CM = [O,0.*O,1-O];
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],20,CM,'filled');
			% Reconstruct_Curvature(GP.Workspace(ii).Workspace,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),1);
		case 'PVD Orders - Points'
			
			Class_Num = max([GP.Workspace(ii).Workspace.All_Points.Class]);
			C = lines(Class_Num+1);
			% figure;
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			Midline_Distance = [GP.Workspace(ii).Workspace.All_Points.X];
			Midline_Orientation = [GP.Workspace(ii).Workspace.All_Points.Y];
			Classes = [GP.Workspace(ii).Workspace.All_Points.Class];
			Classes(isnan(Classes)) = Class_Num + 1;
			
			scatter(Midline_Distance,Midline_Orientation,10,C(Classes,:),'filled');
		
		case 'PVD Orders - Segments'
			Class_Num = max([GP.Workspace(ii).Workspace.All_Points.Class]);
			C = lines(Class_Num+1);
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
					y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
					c = [GP.Workspace(ii).Workspace.Segments(s).Class];
					if(isnan(c))
						plot(x,y,'Color',C(end,:),'LineWidth',3);
					else
						plot(x,y,'Color',C(c,:),'LineWidth',5);
					end
				end
			end
		otherwise
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			Reconstruct_Trace(GP.Workspace(ii).Workspace);
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
	
	%{
	hold on;
	Scale_Factor = GP.Workspace(1).Workspace.User_Input.Scale_Factor;
	plot([20,20+50*(1/Scale_Factor)],[20,20],'w','LineWidth',3);
	text(15+25,25,['50 \mum'],'FontSize',20,'Color','w');
	%}
	
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