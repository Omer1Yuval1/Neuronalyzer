function W = Adjust_Rect_Width_Rot_Generalized(Im,Rotation_Origin,Rect_Angle,Rect_Length,Rect_Width_Min_Max,Origin_Type,Smoothing_Parameter,Width_Ratio,Im_Rows,Im_Cols)
	
	% Description:
		% This function detects the local apparent width of the neuron.
		% Calling functions: Find_Cell_Body, Add_CB_Branch, Trace1.
	% Input:
		% Im: The grayscale image.
		% Rotation_Origin:
		% Rect_Angle:
		% Rect_Length:
		% Rect_Width_Min_Max:
		% Origin_Type:
		% Smoothing_Parameter:
		% Width_Ratio: the final width value is a ratio of the value extracted from the spline.
	% Output:
		% The local apparent width of the neuron (in pixels).
	
	Plot2 = 0; % Set to 1 to visualize results.
	
	[XV,YV] = Get_Rect_Vector(Rotation_Origin,Rect_Angle,Rect_Width_Min_Max(2),Rect_Length,Origin_Type); % The vector of the biggest rectangle.
	
	if(any([XV,YV] < 1) || any(XV > Im_Cols) || any(YV > Im_Rows)) % If any of the rectangle's corners is out of the image boundaries.
		W = -2;
		if(1)
			disp('Image Boundaries Alert.');
		end
		return;
	end	
	
	Im_Cropped = Im(floor(min(YV)):ceil(max(YV)),floor(min(XV)):ceil(max(XV)));
	
	Im_Cropped_Rotated = imrotate(Im_Cropped,Rect_Angle);
	Sr2 = size(Im_Cropped_Rotated,1);
	Sc2 = size(Im_Cropped_Rotated,2);
	Cy = (Sr2 + 1)/2;
	Cx = (Sc2 + 1)/2;
	
	Lr = max(ceil(Cy-Rect_Width_Min_Max(2)),1);
	Ur = min(floor(Cy+Rect_Width_Min_Max(2)),Sr2);
	Lc = max(ceil(Cx-Rect_Length),1);
	Uc = min(floor(Cx+Rect_Length),Sc2);
	
	xv = zeros(1,ceil((Ur-Lr+1)/2));
	yv = xv;
	
	if(length(xv) > 1)
		i = 1;
		% figure(6); clf(6); imshow(Im_Cropped_Rotated); set(gca,'YDir','normal'); hold on;
		while Lr+i-1 <= Ur-i+1
			xv(i) = Ur-i+1 - (Lr+i-1) + 1;
			Im_Cropped_Rotated1 = Im_Cropped_Rotated(Lr+i-1:Ur-i+1,Lc:Uc);
			yv(i) = mean(Im_Cropped_Rotated1(:)); % TODO: Maybe do it in one step.
			% plot([Lc Lc Uc Uc Lc] , [Lr+i-1 Ur-i+1 Ur-i+1 Lr+i-1 Lr+i-1]);
			i = i + 1;
		end
		
		FitObject = fit(xv',yv','smoothingspline','SmoothingParam',Smoothing_Parameter);
		xvf = linspace(min(xv),max(xv),2*length(xv)); % Width.
		yvf = FitObject(xvf); % Mean pixel value.
		
		[XDer1 XDer2] = differentiate(FitObject,xvf);
		% f2 = find(XDer2 == min(XDer2)); % Minimal 2nd derivative point.
		f2 = find(XDer1 == min(XDer1)); % Minimal 1st derivative point.
		W = xvf(f2(1))*Width_Ratio; % Taking f2(1) just in case there's more than one value in f2.
		
		if(Plot2)
			figure(2);
			hold on;
			plot(xvf,yvf,'LineWidth',3);
			hold on;
			plot(W,FitObject(W),'.','MarkerSize',30);
			xlabel('Width (pixels)');
			ylabel('Mean Pixel Value');
			figure(1);
			disp(W);
		end
	else
		W = -1;
		if(1)
			disp('Width Detection Failed.');
		end
	end
	
end