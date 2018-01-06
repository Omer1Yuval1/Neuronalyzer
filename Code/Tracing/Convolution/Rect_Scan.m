function arr = Rect_Scan(im,Step_Parameters,Parameters1);
	
	%	1---------2
	%	|	 |	  ------>
	%	4---------3
	% Step_Parameters.Step_Coordinates is the rotation origin coordinates (x,y).
	% a is angle of the vector (in degrees). The rotation will be around this angle.
	% All the variables are in degrees or micrometers.
	
	aa = Step_Parameters.Previous_Angle;
	
	Rects_Num = round(Parameters1(1).Auto_Tracing_Parameters(1).Rect_Rotation_Range/Parameters1(1).Auto_Tracing_Parameters(1).Rotation_Res); % Number of rectangles.
	arr = zeros(2*Rects_Num+1,3);
	[XV0,YV0] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Previous_Angle,Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,Parameters1.Auto_Tracing_Parameters(1).Rect_Rotation_Origin);
	% clf(11);
	% TODO: Maybe the problems(?) has sth to do with that fact that I'm checking now Rects_Num+1 rects.
	% parfor i=1:2*Rects_Num+1 % Clockwise Rotation around Step_Parameters.Step_Coordinates.
	for i=1:2*Rects_Num+1
		
		if(i <= Rects_Num + 1)
			[XV1,YV1] = rotate_vector_origin(XV0,YV0,Step_Parameters.Step_Coordinates,Parameters1(1).Auto_Tracing_Parameters(1).Rotation_Res*(i-1));
			aa = Step_Parameters.Previous_Angle + Parameters1(1).Auto_Tracing_Parameters(1).Rotation_Res*(i-1);
			% hold on; figure(11), plot(XV1,YV1);
		else
			[XV1,YV1] = rotate_vector_origin(XV0,YV0,Step_Parameters.Step_Coordinates,-Parameters1(1).Auto_Tracing_Parameters(1).Rotation_Res*(i-Rects_Num-1));		
			aa = Step_Parameters.Previous_Angle - Parameters1(1).Auto_Tracing_Parameters(1).Rotation_Res*(i-Rects_Num-1);
			% hold on; figure(11), plot(XV1,YV1);
		end
		
		% Mat1 = im( floor(min(Rxy(:,2))):ceil(max(Rxy(:,2))) , floor(min(Rxy(:,1))):ceil(max(Rxy(:,1))) ); % A sub-matrix of im - the smallest bounding rectangle of the polygon. TODO: change also the polygin vector.
		Mean_Pixel_Value = Get_Rect_Score(im,[XV1' YV1']); % Average pixel value.
		
		arr(i,:) = [i,Mean_Pixel_Value,aa]; % i = rect index. Mean_Pixel_Value = rect mean value. a = angle (global). abs(a-aa) = angle diff with the previous rect.
		
		% hold on; figure(1), plot(XV1,YV1);
		% figure(3);
		% hold on;
		% plot(XV1,YV1,'LineWidth',3);		
		
		% figure(1);
		% hold on;
		% plot(XV1,YV1,'LineWidth',3);
	end
	% figure(3);
	% hold on;
	% plot(Step_Parameters.Step_Coordinates(1),Step_Parameters.Step_Coordinates(2),'.r','MarkerSize',40);
	% axis equal;

	% figure(1);
	% hold on;
	% plot(Step_Parameters.Step_Coordinates(1),Step_Parameters.Step_Coordinates(2),'.r','MarkerSize',40);
	
	% TODO: how come arr is already sorted here (by v)?
end