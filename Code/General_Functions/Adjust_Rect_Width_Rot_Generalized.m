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
		
		[XDer1,XDer2] = differentiate(FitObject,xvf);
		% f2 = find(XDer2 == min(XDer2)); % Minimal 2nd derivative point.
		f2 = find(XDer1 == min(XDer1)); % Minimal 1st derivative point.
		W = xvf(f2(1))*Width_Ratio; % Taking f2(1) just in case there's more than one value in f2.
		
        %{
        Scale_Factor = 1; % 50/140;
        
        % Plot the rectangle with the chosen width:
			delete(findobj(gca,'-not','Type','image','-and','-not','Type','axes'));
			Np = 10;
			CM = hsv(Np);
			for i=Np:-1:1
				Wi = i;
				[XV,YV] = Get_Rect_Vector(Rotation_Origin,Rect_Angle,Wi,Rect_Length,Origin_Type);
				hold on;
				h = plot([XV,XV(1)],[YV,YV(1)],'Color',CM(i,:),'LineWidth',4);
				h.Color(4) = 0.5; % 1 - i/Np/1.2;
			end
		
			% [XVf,YVf] = Get_Rect_Vector(Rotation_Origin,Rect_Angle,W,Rect_Length,Origin_Type);
			% plot([XVf(1),XVf(2)],[YVf(1),YVf(2)],'Color',[0.8,0,0],'LineWidth',4);        
			
        % Plot the width VS score:
			Scale_Factor = 1; % 50/140;
			figure;
			plot([0,xvf.*Scale_Factor],FitObject([0,xvf.*Scale_Factor]),'Color',[0.8,0,0],'LineWidth',3); % Plot the fit object.
			hold on;
			% plot(xv.*Scale_Factor,yv,'.k','MarkerSize',30); % Plot raw points.
			plot(W.*Scale_Factor .* [1,1],[0,FitObject(W)],'--','Color',[0.5,0.5,0.5],'LineWidth',3); % Plot the final width value.
			plot(W.*Scale_Factor,FitObject(W),'.','Color',[0.1,0.6,0],'MarkerSize',50); % Plot the final width value.
			
			% plot([xvf(f2(1)).*Scale_Factor,xvf(f2(1)).*Scale_Factor],[0,FitObject(xvf(f2(1)))],'--','Color',[.5,.5,.5],'LineWidth',2);
			% plot(xvf(f2(1)).*Scale_Factor,FitObject(xvf(f2(1))),'.b','MarkerSize',50); % Plot the minimal 1st derivative point.
			
			xlabel('Width (\mum)');
			ylabel('Score');
			xlim([0,xv(1).*Scale_Factor]);
			ylim([min(yvf)-5,max(yvf)+10]);
			set(gca,'FontSize',36,'YTickLabels',round(get(gca,'YTick')./255,1));
			
			set(gca,'unit','normalize');
			set(gca,'position',[0.17,0.17,0.80,0.81]);
			set(gcf,'Position',[10,50,900,900]);
            grid on; grid minor;
        
        % disp(W);
        %}
	else
		W = -1;
		if(1)
			disp('Width Detection Failed. Returning -1.');
		end
    end
    
end