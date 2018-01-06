function [Step_Routes,Step_Normalization] = Normalize_Rects_Values(im,Step_Parameters,Parameters1)
	
	if(Step_Parameters.Trial_Step_Index == 0) % If not in a trial or in the first step of a trial.
		
		% Create a sub-matrix:
		[XVb,YVb] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Previous_Angle,3*Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,Parameters1.Auto_Tracing_Parameters(1).Rect_Rotation_Origin); % Create a BIG rectangle poylgon at the current point.
		[XVs,YVs] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Previous_Angle,Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,Parameters1.Auto_Tracing_Parameters(1).Rect_Rotation_Origin); % Create a SMALL rectangle poylgon at the current point.
		
		XV1 = [XVs(1) ; XVs(2) ; XVb(2) ; XVb(1)]; % 1st BG rect.
		YV1 = [YVs(1) ; YVs(2) ; YVb(2) ; YVb(1)]; % "
		XV2 = [XVs(3) ; XVs(4) ; XVb(4) ; XVb(3)]; % 2nd BG rect.
		YV2 = [YVs(3) ; YVs(4) ; YVb(4) ; YVb(3)]; % ".
		
		% Extract the values of the pixels inside the oriented rectangle in the filtered sub-matrix:
		[Rect_Value0,Values_Vector0] = Get_Rect_Score(im,[XVs',YVs']); % The signal values.
		[Rect_Value1,Values_Vector1] = Get_Rect_Score(im,[XV1,YV1]);
		[Rect_Value2,Values_Vector2] = Get_Rect_Score(im,[XV2,YV2]);
		
		Values_Vector12 = [Values_Vector1 ; Values_Vector2];
		
		Hist_Bins_Res = Parameters1(1).Auto_Tracing_Parameters(1).Hist_Bins_Res;
		[Counts0,Intensities0] = histcounts([Values_Vector0],[-Hist_Bins_Res:Hist_Bins_Res:260],'Normalization','probability');
		[Counts12,Intensities12] = histcounts([Values_Vector12],[-Hist_Bins_Res:Hist_Bins_Res:260],'Normalization','probability');
		
		% Counts0 = Counts0 / max(1,max(Counts0)); % Normalization to [0,1].
		% Counts12 = Counts12 / max(1,max(Counts12)); % Normalization to [0,1].
		Intensities0 = (Intensities0(1:end-1) + Intensities0(2:end)) / 2; % Convert bins to bins centers.
		Intensities12 = (Intensities12(1:end-1) + Intensities12(2:end)) / 2; % Convert bins to bins centers.
		
		% Find peaks in the fitted data (the peaks are ordered from largest to smallest):
		[yp0,xp0,Peaks_Width0,Peaks_Prominence0] = findpeaks(Counts0,Intensities0,'MinPeakProminence',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Prominence,'MinPeakDistance',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance,'SortStr','descend');
		[yp12,xp12,Peaks_Width12,Peaks_Prominence12] = findpeaks(Counts12,Intensities12,'MinPeakProminence',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Prominence,'MinPeakDistance',Parameters1(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance,'SortStr','descend');
		
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
			
			% figure(1); % Draw the rectangles 
			% hold on;
			% plot([XV1;XV1(1)],[YV1;YV1(1)],'b','LineWidth',3);
			% plot([XV2;XV2(1)],[YV2;YV2(1)],'b','LineWidth',3);
			% % plot(XVs,YVs,'r','LineWidth',3);
			% hold off;
			
			% figure(8);
				% imshow(Im);
				% hold on;
				% plot(InRect_ImF_Coordinates(:,1),InRect_ImF_Coordinates(:,2),'.r');
				% hold off;
				% set(gca,'YDir','normal');
		end
		
		if(length(xp12))
			Min1 = xp12(1); % The intensity of the 1st (leftest) peak.
			PW12 = Peaks_Width12(1);
			Step_Parameters.Step_Normalization.Noise_Size = Min1;
			Step_Parameters.Step_Normalization.Noise_Width = PW12;
		else % If there are no background peaks.
			Min1 = Step_Parameters.Step_Normalization.Noise_Size;
			PW12 = Step_Parameters.Step_Normalization.Noise_Width;
		end
		
		if(length(xp0))
			PW0 = Peaks_Width0(1);
			Step_Parameters.Step_Normalization.Signal_Width = PW0;
		else % If there are no signal peaks.
			if(isfield(Step_Parameters.Step_Normalization,'Signal_Width'))
				PW0 = Step_Parameters.Step_Normalization.Signal_Width;
			else
				PW0 = 0;
				Step_Parameters.Step_Normalization.Signal_Width = 0;
			end
		end
	else % If it's a 2nd+ step of a trial.
		Min1 = Step_Parameters.Step_Normalization.Noise_Size;
		PW12 = Step_Parameters.Step_Normalization.Noise_Width;
		PW0 = Step_Parameters.Step_Normalization.Signal_Width;
	end
	
	% Step_Parameters.Step_Routes(:,2) = (Step_Parameters.Step_Routes(:,2) - Min1) ./ (PW12 + 0.5*PW0);
	Step_Parameters.Step_Routes(:,2) = (Step_Parameters.Step_Routes(:,2) - Min1) ./ (PW12);
	
	% TODO: understand why it's not possible to output this: 'Step_Parameters.Step_Normalization'.
	Step_Normalization = Step_Parameters.Step_Normalization;
	Step_Routes = Step_Parameters.Step_Routes;
end