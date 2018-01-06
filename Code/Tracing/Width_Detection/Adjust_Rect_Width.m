function W = Adjust_Rect_Width(Workspace1,Step_Parameters)
	
	xv = zeros(1,length(1:ceil(2*Step_Parameters.Rect_Width)));
	yv = xv;
	W = ceil(2*Step_Parameters.Rect_Width);
	
	% for i=1:floor((ceil(2*Step_Parameters.Rect_Width)-1)/S) % For each width.
	for w=1:ceil(2*Step_Parameters.Rect_Width) % Scan from 1-pixel width to 2 times the previous step width.
		[XV,YV] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Step_Routes(1,1),w,Step_Parameters.Rect_Length,Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Rotation_Origin);
		PV1 = Get_Rect_Score(Workspace1.Image0,[XV' YV']);
		xv(w) = w; % The width.
		yv(w) = PV1; % The mean pixel value.
	end
	
	FitObject = fit(xv',yv','smoothingspline','SmoothingParam',Workspace1.Parameters(1).Auto_Tracing_Parameters(1).Rect_Width_Smoothing_Parameter);
	
	xvf = linspace(min(xv),max(xv),1000); % Width.
	yvf = FitObject(xvf); % Mean pixel value.
	
	[XDer1,XDer2] = differentiate(FitObject,xvf);
	% f2 = find(XDer2 == max(XDer2)); % Maximal 2nd derivative point.
	f2 = find(XDer1 == min(XDer1)); % Minimal 1st derivative point.
	W = xvf(f2(1))*Workspace1.Parameters.Auto_Tracing_Parameters.Width_Ratio; % 0.8. Taking f2(1) just in case there's more than one value in f2 (more than one minimal value).
	
end