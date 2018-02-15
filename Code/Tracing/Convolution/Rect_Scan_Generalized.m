function Scores = Rect_Scan_Generalized(im,Origin0,Angle,Rect_Width,Rect_Length,Rotation_Range,Rotation_Res,Origin_Type,Im_Rows,Im_Cols)

	%	1---------2
	%	|	 |	  ------>
	%	4---------3
	% Origin0 is the rotation origin coordinates (x,y).
	% Angle is angle of the vector (in degrees). The rotation will be around this angle.
	% All the angle variables are in degrees.
	
	Rects_Num = round(Rotation_Range/Rotation_Res); % Number of rectangles (to each side (clockwise\counterclockwise)).
	Scores = zeros(2*Rects_Num+1,2);
	aa = Angle;
	[XV0,YV0] = Get_Rect_Vector(Origin0,Angle,Rect_Width,Rect_Length,Origin_Type);
	
	for i=1:2*Rects_Num+1 % Clockwise Rotation around origin0.
		
		if(i <= Rects_Num+1)
			[XV1,YV1] = rotate_vector_origin(XV0,YV0,[Origin0(1) Origin0(2)],Rotation_Res*(i-1));
			Angle = aa + Rotation_Res*(i-1);
		else
			[XV1,YV1] = rotate_vector_origin(XV0,YV0,[Origin0(1) Origin0(2)],-Rotation_Res*(i-Rects_Num-1));		
			Angle = aa - Rotation_Res*(i-Rects_Num-1);
		end
		
		if(any([XV1,YV1] < 1) || any(XV1 > Im_Cols) || any(YV1 > Im_Rows)) % If any of the rectangle's corners is out of the image boundaries.
			Mean_Pixel_Value = 0;
			if(0)
				disp('Image Boundaries Alert. Terminating Segment Tracing');
			end
		else
			Mean_Pixel_Value = Get_Rect_Score(im,[XV1' YV1']); % Average pixel value.
		end
		Scores(i,:) = [Angle,Mean_Pixel_Value]; % i = rect index. Mean_Pixel_Value = rect mean value. Angle = angle (global). abs(Angle-aa) = angle diff with the previous rect.
		
		% if(1 && ismember(i,1:2:2*Rects_Num+1))
			% % disp(2*Rects_Num+1);
			% figure(1);
			% hold on;
			% plot([XV1,XV1(1)],[YV1,YV1(1)],'LineWidth',2);
			% % plot([XV1,XV1(1)],[YV1,YV1(1)],'--','LineWidth',4);
			% % assignin('base','XV1',XV1);
			% % assignin('base','YV1',YV1);
		% end
	end
	Scores = sortrows(Scores,1);
	
end