function W = Adjust_Rect_Width_Rot(Workspace1,Step_Parameters)
	
	% Description:
		% This function detects the local apparent width of the neuron.
		% Calling functions: Find_Cell_Body, Add_CB_Branch, Trace1.
	% Input:
		% Workspace1 and Step_Parameters: structures containing general and step-specific parameters (respectively).
	% Output:
		% The local apparent width of the neuron (in pixels).
	
	[XV,YV] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Step_Routes(1,1),2*Step_Parameters.Rect_Width(end),2*Step_Parameters.Rect_Length,Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Rotation_Origin); % The vector of the biggest rectangle.
	Im_Cropped = Workspace1.Image0(floor(min(YV)):ceil(max(YV)),floor(min(XV)):ceil(max(XV)));
	
	Im_Cropped_Rotated = imrotate(Im_Cropped,Step_Parameters.Step_Routes(1,1));
	Sr2 = size(Im_Cropped_Rotated,1);
	Sc2 = size(Im_Cropped_Rotated,2);
	Cy = (Sr2 + 1)/2;
	Cx = (Sc2 + 1)/2;
	
	Lr = max(ceil(Cy-Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Width_Range(2)),1);
	Ur = min(floor(Cy+Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Width_Range(2)),Sr2);
	Lc = max(ceil(Cx-Step_Parameters.Rect_Length),1);
	Uc = min(floor(Cx+Step_Parameters.Rect_Length),Sc2);
	
	xv = zeros(1,ceil((Ur-Lr+1)/2));
	yv = xv;
	i = 1;
	% figure(6); clf(6); imshow(Im_Cropped_Rotated); set(gca,'YDir','normal'); hold on;
	while Lr+i-1 <= Ur-i+1
		xv(i) = Ur-i+1 - (Lr+i-1) + 1;
		Im_Cropped_Rotated1 = Im_Cropped_Rotated(Lr+i-1:Ur-i+1,Lc:Uc);
		yv(i) = mean(Im_Cropped_Rotated1(:)); % TODO: Maybe do it in one step.
		% plot([Lc Lc Uc Uc Lc] , [Lr+i-1 Ur-i+1 Ur-i+1 Lr+i-1 Lr+i-1]);
		i = i + 1;
	end
	
	FitObject = fit(xv',yv','smoothingspline','SmoothingParam',Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Width_Smoothing_Parameter);
	xvf = linspace(min(xv),max(xv),2*length(xv)); % Width.
	yvf = FitObject(xvf); % Mean pixel value.
	
	[XDer1 XDer2] = differentiate(FitObject,xvf);
	% f2 = find(XDer2 == min(XDer2)); % Minimal 2nd derivative point.
	f2 = find(XDer1 == min(XDer1)); % Minimal 1st derivative point.
	W = xvf(f2(1))*Workspace1.Parameters.Auto_Tracing_Parameters.Width_Ratio; % Taking f2(1) just in case there's more than one value in f2.
end