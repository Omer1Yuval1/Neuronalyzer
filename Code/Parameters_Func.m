function P = Parameters_Func(Scale_Factor,P)
	
	General_Parameters.Version_Num = '2.0';
	
	General_Parameters.Image_Format = @(x) im2uint8(x(:,:,1));
	
	General_Parameters.Plot1 = 0;
	Auto_Tracing_Parameters.Plot_On_Off = General_Parameters(1).Plot1;
	Auto_Tracing_Parameters.Plot_Trace = 1;
	
	General_Parameters.Graphs_Plot1 = 1;
	General_Parameters.Trace_Plot1 = 0; % TODO: use an array with tracing method numbers.
	General_Parameters.Message = 0;
	
	Cell_Body(1).Rect_Rotation_Range = 60;
	Cell_Body(1).Rotation_Res = 2;
	Cell_Body(1).Rotation_Origin = 14;
	Cell_Body(1).Rect_Length_Width_Ratio = 2;
	Cell_Body(1).Rect_Step_Length_Ratio = 5;
	Cell_Body(1).Rect_Width = 1/Scale_Factor;
	Cell_Body(1).Rect_Width_Range = [0.1 4]./Scale_Factor;
	Cell_Body(1).MinPeakDistance = 10; % Used to detects the cell body branches.
	Cell_Body(1).MinPeakProminence = 25; % ".
	Cell_Body(1).MinPeakProminence_Normalized = 0.05; % ".
	Cell_Body(1).MinPeakWidth = 3; % ".
	Cell_Body(1).Max_Num_Of_Branches = 4;
	Cell_Body(1).BW_Threshold = 0.9;
	Cell_Body(1).Open_Close_Disk = 1.5;
	Cell_Body(1).Perimeter_Connectivty = 8;
	Cell_Body(1).Ellipse_Axes_Extension_Factor = 1.1/Scale_Factor;
	Cell_Body(1).Ellipse_Resolution = 0.035 / Scale_Factor;
	
	Tracing(1).Min_Segment_Length = 5 ./ Scale_Factor; % Min segment length. Micrometers converted to pixels.
	
	% Note: the result is in pixels:
	W_Min = 0.3571 ./ Scale_Factor; % 1 pixel for Scale_Factor = 50/140.
	W_Max = 2.8571 ./ Scale_Factor; % 8 pixels for Scale_Factor = 50/140.
	L_Min = 1.0714 ./ Scale_Factor; % 3 pixels for Scale_Factor = 50/140.
	L_Max = 3.5714 ./ Scale_Factor; % 10 pixels for Scale_Factor = 50/140.
	m = (L_Max - L_Min) ./ (W_Max - W_Min);
	Tracing(1).Rect_Length_Width_Func = @(w) (w<=W_Min).*(L_Min) + (w>W_Max).*L_Max + (w>W_Min).*(w<=W_Max).*(m .* (w-W_Min)+L_Min);
	% Tracing(1).Rect_Length_Width_Func = @(w) 2.*w;
	
	% Skeleton
	Tracing(1).Skel_Angle_Min_Length = 1.7857 ./ Scale_Factor; % In particular used with the skeleton since the segment width is 1 (=W_Min).	
	
	Auto_Tracing_Parameters(1).Rect_Length_Width_Ratio = 2;
	Auto_Tracing_Parameters(1).Global_Step_Length = 1; % In pixels.
	Auto_Tracing_Parameters(1).Min_Rect_Width = .35/Scale_Factor; % Micrometers converted to pixels.
	Auto_Tracing_Parameters(1).Max_Rect_Width_Ratio = 2; % Upper bound for width scanning (2 rects on both sides of the signal rect). Multiplication factor with the previous step width. Micrometers converted to pixels.
	Auto_Tracing_Parameters(1).MaxMin_Rect_Width_Ratio = 8; % Global upper bound ratio (in Micrometers).
	Auto_Tracing_Parameters(1).Width_Ratio = 0.95; % Ratio of the calculated width.
	% TODO: This value may too big - bigger than the pixel resolution:
	Auto_Tracing_Parameters(1).Rect_Width_Res = 0.1/Scale_Factor; % The scanning resolution for adjusting the rectangle's width.
	Auto_Tracing_Parameters(1).Rect_Width_Smoothing_Parameter = 0.5; % TODO: should also be a function of Scale_Factor.
	Auto_Tracing_Parameters(1).Rect_Width_Num_Of_Last_Steps = 6; % XXX
	Auto_Tracing_Parameters(1).Skel_Vertex_Overlap_Factor = 2;
	
	% Vertex center
	Auto_Tracing_Parameters(1).Vertex_Center_Radius_Vector = .1:.01:5; % Radii vector (of increasing concentric circles) for junction center detection.
	Auto_Tracing_Parameters(1).Vertex_Center_Cirle_Res = 500*Scale_Factor;
	Auto_Tracing_Parameters(1).Vertex_Center_Min_Radius = 4*Scale_Factor;
	Auto_Tracing_Parameters(1).Vertex_Center_Frame_Size = 5*Scale_Factor; % [6.5]. Neighborhood to test new potential centers around the approximated center. ~2.3 pixels for Scale_Factor=50/140.
	Auto_Tracing_Parameters(1).Vertex_Center_Scan_Res = .25*Scale_Factor; % vertical\horizontal distance between potential centers. ~0.35 pixels for Scale_Factor=50/140.
	
	% Vertex angles
	Auto_Tracing_Parameters(1).Vertex_Angles_SmoothingParameter = 0.99;
	Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Min_Max = [.5,6];
	Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Ratio = .9;
	Auto_Tracing_Parameters(1).Vertex_Angles_Width_SmoothingParameter = 0.5;
	Auto_Tracing_Parameters(1).Vertex_Angles_Min_Width = 1; % Pixels.
	Auto_Tracing_Parameters(1).Vertex_Angles_Extension_Length = 60*pi/180;
	Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Width = 3; % Scanning rectangle width.
	Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Length = 1.8 ./ Scale_Factor; % um to px (~5px for 0.3571 um/px).
	Auto_Tracing_Parameters(1).Vertex_Angles_Min_Score_Ratio = 0.95;
	Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakDis = 20*(pi/180); % 10 degrees.
	Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakWidth = 5*(pi/180); % 5 degrees.
	Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakProm = .15; % .15
	
	Auto_Tracing_Parameters.Zoom_Box = 10/Scale_Factor;
	Auto_Tracing_Parameters(1).Rect_Rotation_Origin = 14; % Center: 0 ; Between corners 1&4: 14.
	Auto_Tracing_Parameters(1).Rect_Rotation_Range = 70; % Rotation angle (to one side, in degrees).
	Auto_Tracing_Parameters(1).Rotation_Res = 5; % 5,10; % Rotation resolution (in degrees).
	% Auto_Tracing_Parameters(1).Max_Angle_Diff = 150; % Max angle diff between successive steps.
	Auto_Tracing_Parameters(1).Step_Min_Peak_Distance = 15; % [degrees]. Used in 'findpeaks' to merge peaks with distance smaller than this value (using the smallest x-value as the resolution).
	Auto_Tracing_Parameters(1).Step_Min_Peak_Prominence = 0.4; % 0.5, 0.3, 0.1, 60, 400, 1000, 0.02; % Definition: the vertical distance between a peak and it's heighest minima.
	
	Auto_Tracing_Parameters.Trace_Skel_Max_Distance = 1.5; % .5/Scale_Factor; % In pixels (converted to micrometers).
	Auto_Tracing_Parameters.Normalization_Width_Factor = 3; % Multiplication factor of the width of the BG sampling rectangles.
	% Auto_Tracing_Parameters(1).Filter_Rect_Width = 3/Scale_Factor;
	Auto_Tracing_Parameters.Hist_Bins_Res = 5;
	Auto_Tracing_Parameters.Step_Scores_Smoothing_Parameter = 0.05;
	% Auto_Tracing_Parameters.Step_Normalization_Min_Peak_Prominence = 0.07; % 0.8; % 1,1.5,1.7,2.
	Auto_Tracing_Parameters.Step_Normalization_Min_Peak_Height = 0.07; % 0.8; % 1,1.5,1.7,2.
	Auto_Tracing_Parameters.Step_Normalization_Min_Peak_Distance = 30; % 20.
	
	Auto_Tracing_Parameters.Tracing_Scores_Weights = [0;0;1];
	
	% Curvature
	Analysis.Curvature.Sample_Length = 1.8; % Micrometers. Sampling length from each side of the point. ~5 pixels for Scale_Factor=50/40.
	Analysis.Curvature.Min_Points_Num = 3;
	Analysis.Curvature.SmoothingParameter = 0.01;
	Analysis.Curvature.Min_Points_Num_Smoothing = 5;
	
	% Projection correction:
	Angle_Correction.Worm_Radius_um = 40;
	Angle_Correction.Corrected_Plane_Angle_Func = @(d) asin(d./Angle_Correction.Worm_Radius_um); % Input (d): distance (in um) from the medial axis. The resulting angle is in radians.
	
	Neural_Network.Threshold = 0.5;
	Neural_Network.Min_CC_Size = 1;
	
	if(nargin == 1)
		P.General_Parameters = General_Parameters;
		P.Cell_Body = Cell_Body;
		P.Tracing = Tracing;
		P.Auto_Tracing_Parameters = Auto_Tracing_Parameters;
		% P.Manual_Tracing_Parameters = Manual_Tracing_Parameters;
		P.Analysis = Analysis;
		P.Neural_Network = Neural_Network;
		P.Angle_Correction = Angle_Correction;
	elseif(nargin == 2)
		if(~isfield(P,'General_Parameters'))
			P.General_Parameters = General_Parameters;
		end
		if(~isfield(P,'Cell_Body'))
			P.Cell_Body = Cell_Body;
		end
		if(~isfield(P,'Tracing'))
			P.Tracing = Tracing;
		end
		if(~isfield(P,'Auto_Tracing_Parameters'))
			P.Auto_Tracing_Parameters = Auto_Tracing_Parameters;
		end
		% if(~isfield(P,'Manual_Tracing_Parameters'))
		% 	P.Manual_Tracing_Parameters = Manual_Tracing_Parameters;
		% end
		if(~isfield(P,'Analysis'))
			P.Analysis = Analysis;
		end
		if(~isfield(P,'Neural_Network') || length(fields(Neural_Network)) ~= length(fields(P.Neural_Network)))
			P.Neural_Network = Neural_Network;
		end
		if(~isfield(P,'Angle_Correction'))
			P.Angle_Correction = Angle_Correction;
		end
	end
	
end