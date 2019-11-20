function Reconstruction_Index(GP,ii)
	
	% GP is a short for GUI_Parameters.
	
	% TODO:
		% Move out: Worm_Radius_um.
	
	Worm_Radius_um = 45;
	
	if(1)
		figure(1);
		hold on;
	else
		figure;
		GP.Handles.Axes = axes;
		% XY = [1140,1250,550,660];
		hold on;
	end
	
	Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
	
	switch GP.General.Active_Plot
		case 'Raw Image - Grayscale'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
		case 'Raw Image - RGB'
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
		case 'CNN Image - Grayscale'
			imshow(GP.Workspace(ii).Workspace.NN_Probabilities,'Parent',GP.Handles.Axes);
		case 'CNN Image - RGB'
			imshow(GP.Workspace(ii).Workspace.NN_Probabilities,'Parent',GP.Handles.Axes);
			colormap hot;
		case 'Binary Image'
			imshow(GP.Workspace(ii).Workspace.Im_BW,'Parent',GP.Handles.Axes);
			
		case 'Raw + Binary Image - RGB'
			Im_RGB = repmat(GP.Workspace(ii).Workspace.Image0(:,:,1),[1,1,3]);
			Im_RGB(:,:,1) = Im_RGB(:,:,1) .* uint8(~GP.Workspace(ii).Workspace.Im_BW);
			Im_RGB(:,:,2) = Im_RGB(:,:,2) .* uint8(GP.Workspace(ii).Workspace.Im_BW);
			imshow(Im_RGB,'Parent',GP.Handles.Axes);
		case 'Skeleton'
			[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Pixel_Trace_Post_Proccessing(GP.Workspace(ii).Workspace.Im_BW);
			imshow(Im1_NoiseReduction);
			
			%{
			% Color connected components:
			CC = bwconncomp(Im1_NoiseReduction);
			for c=1:length(CC.PixelIdxList)
				[y,x] = ind2sub(size(Im1_NoiseReduction),CC.PixelIdxList{c});
				hold on;
				plot(x,y,'.','MarkerSize',7);
			end
			%}
		case 'Blob'
			Find_Worm_Longitudinal_Axis(GP.Workspace(ii).Workspace,1,GP.Handles.Axes);
		case 'Segmentation'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			if(isfield(GP.Workspace(ii).Workspace,'Segments'))
				Reconstruct_Segmented_Trace(GP.Workspace(ii).Workspace,GP.Handles.Analysis); % Reconstruct_Segments(GP.Workspace(1).Workspace);
			end
		case 'Segments by Length'
			
			Max_Length = 50; % [um].
			CM = jet(1000);
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
					y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
					c = [GP.Workspace(ii).Workspace.Segments(s).Length];
					if(isnan(c) || c <= 0)
						plot(x,y,'Color','w','LineWidth',3);
					else
						plot(x,y,'Color',CM(round(rescale(c,1,1000,'InputMin',0,'InputMax',Max_Length)),:),'LineWidth',3);
					end
				end
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
		case 'Axes Mapping Process'
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			Map_Worm_Axes(GP.Workspace(ii).Workspace,GP.Workspace(ii).Workspace.Neuron_Axes,1,0,GP.Handles.Axes);
		case 'Midline Distance'
			
			N = 2 .* [GP.Workspace(ii).Workspace.All_Points.Half_Radius];
			
			X = [GP.Workspace(ii).Workspace.All_Points.X];
			Y = [GP.Workspace(ii).Workspace.All_Points.Y];
			O = rescale(abs([GP.Workspace(ii).Workspace.All_Points.Midline_Distance]) ./ N)';
			
			[~,~,Ic] = histcounts(O,1000);
			F = find(Ic ~=0);
			Ic = Ic(F);
			X = X(F);
			Y = Y(F);
			
			CM = hsv(1000);
			
			% CM = [O,.5.*O,1-O];
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			scatter(X,Y,5,CM(Ic,:),'filled');
			% scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM,'filled');
		case 'Midline Orientation'
			
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Midline_Orientation])';
			CM = [O,0.*O,1-O];
			
			% O = round(rescale([GP.Workspace(ii).Workspace.All_Points.Midline_Orientation],1,100)');
			% CM = jet(100);
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],100,CM,'filled');
			% scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM(O,:),'filled');
			
		case 'Longitudinal Gradient'
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			
			O = round(rescale([GP.Workspace(ii).Workspace.All_Points.Axis_0_Position],1,100)');
			CM = jet(100);
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM(O,:),'filled');
			
			%{
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],5,CM,'filled');
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Axis_0_Position])';
			CM = [O,0.*O,1-O];
			%}
		case {'Vertices Angles','Vertices Angles - Corrected'}
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			Reconstruct_Vertices(GP.Workspace(ii).Workspace);
		case {'3-Way Junctions - Position','Tips - Position'}
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			
			switch GP.General.Active_Plot
				case '3-Way Junctions - Position'
					Vertex_Order = 3;
					Junction_Classes = [112,233,234,334,344];
				case 'Tips - Position'
					Vertex_Order = 1;
					Junction_Classes = 1:4;
			end
			
			Max_PVD_Orders = length(Junction_Classes);
			CM = lines(Max_PVD_Orders);
			
			for o=1:Max_PVD_Orders
				Fo = find([GP.Workspace(ii).Workspace.All_Vertices.Class] == Junction_Classes(o) & [GP.Workspace(ii).Workspace.All_Vertices.Order] == Vertex_Order);
				X = [GP.Workspace(ii).Workspace.All_Vertices(Fo).X];
				Y = [GP.Workspace(ii).Workspace.All_Vertices(Fo).Y];
				
				hold on;
				scatter(X,Y,40,CM(o,:),'filled');
			end
			
			case 'Curvature'
			Curvature_Min_Max = [0,0.2];
			% Medial_Dist_Range = [0,60];
			
			O = rescale([GP.Workspace(ii).Workspace.All_Points.Curvature],'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))';
			CM = [O,0.*O,1-O];
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			scatter([GP.Workspace(ii).Workspace.All_Points.X],[GP.Workspace(ii).Workspace.All_Points.Y],100,CM,'filled');
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
			
			% C = lines(Class_Num+1);
			Class_Indices = [1,2,3,3.5,4,5];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0,0.8,0.8 ; 0,0,1 ; 0.8,0.8,0 ; 0.5,0.5,0.5]; % [1,2,3,3.5,4,5].
			
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			hold on;
			for s=1:numel(GP.Workspace(ii).Workspace.Segments)
				if(numel(GP.Workspace(ii).Workspace.Segments(s).Rectangles))
					x = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.X];
					y = [GP.Workspace(ii).Workspace.Segments(s).Rectangles.Y];
					c = find(Class_Indices == GP.Workspace(ii).Workspace.Segments(s).Class);
					if(isempty(c)) % isnan(c)
						plot(x,y,'Color',Class_Colors(end,:),'LineWidth',2);
					else
						plot(x,y,'Color',Class_Colors(c,:),'LineWidth',2);
					end
				end
			end
		otherwise
			imshow(GP.Workspace(ii).Workspace.Image0,'Parent',GP.Handles.Axes);
			Reconstruct_Trace(GP.Workspace(ii).Workspace);
	end
	
	set(gca,'YDir','normal');
	
	% axis(XY);
	
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