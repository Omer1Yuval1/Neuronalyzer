function [Scores,BG_Intensity,BG_Peak_Width] = Normalize_Rects_Values_Generalized(Image0,Scores,Step_Origin,Previous_Angle,Rect_Width,Rect_Length,BG_Intensity,BG_Peak_Width,Parameters1,Im_Rows,Im_Cols)
	
	% TODO: replace 260 & 265 with parameters.
	
	% Create a sub-matrix:
	Origin_Type = Parameters1.Auto_Tracing_Parameters(1).Rect_Rotation_Origin;
	Normalization_Width_Factor = Parameters1.Auto_Tracing_Parameters.Normalization_Width_Factor;
	
	[XVb,YVb] = Get_Rect_Vector(Step_Origin,Previous_Angle,Normalization_Width_Factor*Rect_Width,Rect_Length,Origin_Type); % Create a BIG rectangle poylgon at the current point.
	[XVs,YVs] = Get_Rect_Vector(Step_Origin,Previous_Angle,Rect_Width,Rect_Length,Origin_Type); % Create a SMALL rectangle poylgon at the current point.
	
	XV1 = [XVs(1) ; XVs(2) ; XVb(2) ; XVb(1)]; % 1st BG rect.
	YV1 = [YVs(1) ; YVs(2) ; YVb(2) ; YVb(1)]; % "
	XV2 = [XVs(3) ; XVs(4) ; XVb(4) ; XVb(3)]; % 2nd BG rect.
	YV2 = [YVs(3) ; YVs(4) ; YVb(4) ; YVb(3)]; % ".
	
	% Extract the values of the pixels inside the oriented rectangle in the filtered sub-matrix:
	% [Rect_Value0,Values_Vector0] = Get_Rect_Score(Image0,[XVs',YVs']); % The signal values.
	if(any([XV1',YV1',XV2',YV2'] < 1) || any([XV1',XV2'] > Im_Cols) || any([YV1',YV2'] > Im_Rows)) % If any of the rectangle's corners is out of the image boundaries.
		Values_Vector1 = 0;
		Values_Vector2 = 0;
		if(0)
			disp('Image Boundaries Alert.');
		end
	else
		[~,Values_Vector1] = Get_Rect_Score(Image0,[XV1,YV1]);
		[~,Values_Vector2] = Get_Rect_Score(Image0,[XV2,YV2]);
	end
	Values_Vector12 = [Values_Vector1 ; Values_Vector2];
	
	Hist_Bins_Res = Parameters1(1).Auto_Tracing_Parameters(1).Hist_Bins_Res;
	% [Counts0,Intensities0] = histcounts([Values_Vector0],[-Hist_Bins_Res:Hist_Bins_Res:260],'Normalization','probability');
	[Counts12,Intensities12] = histcounts([Values_Vector12],[-Hist_Bins_Res:Hist_Bins_Res:265],'Normalization','probability');
	
	% Intensities0 = (Intensities0(1:end-1) + Intensities0(2:end)) / 2; % Convert bins to bins centers.
	Intensities12 = (Intensities12(1:end-1) + Intensities12(2:end)) / 2; % Convert bins to bins centers.
	
	% Find peaks in the fitted data (the peaks are ordered from largest to smallest):
	% [yp0,xp0,Peaks_Width0,Peaks_Prominence0] = findpeaks(Counts0,Intensities0,'MinPeakProminence',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Prominence,'MinPeakDistance',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance);
	[yp12,xp12,Peaks_Width12,Peaks_Prominence12] = findpeaks(Counts12,Intensities12,'MinPeakHeight',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Height,'MinPeakDistance',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance);
	
	if(0) % if(Parameters1.Auto_Tracing_Parameters.Plot_On_Off)
		figure(5);
			clf(5);
			histogram([Values_Vector0],[-Hist_Bins_Res:Hist_Bins_Res:260],'Normalization','probability');
			hold on;
			histogram([Values_Vector12],[-Hist_Bins_Res:Hist_Bins_Res:260],'Normalization','probability');
			hold on;
			findpeaks(Counts0,Intensities0,'MinPeakProminence',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Prominence,'MinPeakDistance',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance,'SortStr','descend');
			findpeaks(Counts12,Intensities12,'MinPeakProminence',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Prominence,'MinPeakDistance',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance,'SortStr','descend');
			axis([-Hist_Bins_Res,265,0,1.2]);
			
		if(0)
			figure(1); % Draw the rectangles 
				hold on;
				plot([XV1;XV1(1)],[YV1;YV1(1)],'b','LineWidth',3);
				plot([XV2;XV2(1)],[YV2;YV2(1)],'b','LineWidth',3);
				% plot(XVs,YVs,'r','LineWidth',3);
				hold off;
			
			figure(8);
				imshow(Im);
				hold on;
				plot(InRect_ImF_Coordinates(:,1),InRect_ImF_Coordinates(:,2),'.r');
				hold off;
				set(gca,'YDir','normal');
		end
	end
	
	if(length(xp12)) % The BG peaks vector.
		BG_Intensity = xp12(1); % The intensity (peak x-value) of the 1st (leftest) peak.
		BG_Peak_Width = Peaks_Width12(1);
	else % If there are no background peaks.
		if(0)
			plot(Intensities12,Counts12);
		end
		disp('Step Normalization: Detection of BG peak failed. Using values from the previous step.');
	end
	
	Scores(:,2) = (Scores(:,2) - BG_Intensity) ./ (BG_Peak_Width);
	
end