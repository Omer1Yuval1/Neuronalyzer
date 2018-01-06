function Tracing_Step(Image0,Vertices,Segments,Step_Params)
	
	% 1. Scan for signal:
	Scores = Rect_Scan_Generalized(Image0,Step_Params.Rotation_Origin,Step_Params.Angle,Step_Params.Width, ...
									Step_Params.Scan_Length,Step_Params.Rotation_Range,Step_Params.Rotation_Res,Step_Params.Origin_Type);
	
	% 2. Normalize Scores:
	% TODO: generalize - get rid of the Paramters1 as input.
	[Scores,BG_Intensity,BG_Peak_Width] = Normalize_Rects_Values_Generalized(Image0,Scores,Step_Params.Rotation_Origin, ...
											Step_Params.Angle,Step_Params.Width,Step_Params.Scan_Length,Step_Params.BG_Intensity, ...
											Step_Params.BG_Peak_Width,Parameters1);
	% 3. Find Peaks:
	[Peaks1,Locs1,Widths1,Proms1] = findpeaks(Scores(:,2),Scores(:,1),'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance);
	if(Plot2) % v == 2)
		% display(Angle);
		figure(2);
		clf(2);
		plot(Scores(:,1),Scores(:,2),'.');
		% findpeaks(Scores(:,2),Scores(:,1),'SortStr','descend','NPeaks',1);
		findpeaks(Scores(:,2),Scores(:,1),'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance);
	end
	
	% 4. Peaks Filtering using the Constraints from the Skeleton:
	Skeleton_Overlap = zeros(1,length(Peaks1)); % The amount of overlap of each peak.
	for p=1:length(Peaks1) % For each peak, find the overlap between its InRect_Coordinates and the skeleton of the relevant segment.
		[XV,YV] = Get_Rect_Vector(Rotation_Origin,Locs1(p),Width,Scan_Length,Origin_Type); % Using the length of the scanning rectangle.
		InRect1 = InRect_Coordinates(Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
		Skeleton_Overlap(p) = length(intersect(InRect1,Segments(s).Skeleton_Linear_Coordinates)) / Width; % Number of overlapping pixels, normalized to rect width (to allow the use a global threshold.
	end
	
	Skeleton_Overlap(find(Skeleton_Overlap < Skel_Overlap_Treshold)) = 0; % Set the values below the threshold to 0.
	F = find(Skeleton_Overlap >= Skel_Overlap_Treshold); % Find the peaks with normalized overlap above the threshold.
	if(length(F) > 1) % Check if there's more than 1 peak after thresholding the normalized overlap with the skeleton.
		% TODO\TOTHINK: the following row can be merged with the previous 'find'.
		% 				but it is not such a bad idea to separate it as a test step (test for multiple maxima).
		F = find(Skeleton_Overlap > 0 & Skeleton_Overlap == max(Skeleton_Overlap)); % Take the one with the higher overlap value.
		if(length(F) > 1) % If there's more than one maximum, just take one of them (and let me know).
			% disp(Locs1(F));
			F = F(1); % TODO: maybe use the skeleton to choose.
			disp('I found multiple optimal routes (multiple directions with the maximal overlap with the skeleton).');
			
			if(Plot2)
				figure(2);
				clf(2);
				findpeaks(Scores(:,2),Scores(:,1),'MinPeakDistance',15,'MinPeakProminence',0.3);
				hold on;
				plot(Scores(:,1),Scores(:,2),'.');
			end
		end
		if(Plot1)
			[XV,YV] = Get_Rect_Vector(Rotation_Origin,Locs1(F),Width,Scan_Length,Origin_Type); % Using the length of the scanning rectangle.
			XV = [XV,XV(1)];
			YV = [YV,YV(1)];
			figure(1);
			hold on;
			plot(XV,YV);
		end
	elseif(length(F) == 0) % No peaks above the threshold (e.g. a fake gap).
		% TODO: Use the skeleton to force a peak.
		disp('I found no peaks above the overlap threshold');
	end
	Peaks1 = Peaks1(F); % Delete all peaks but the chosen one (if there's one).
	Locs1 = Locs1(F); % Delete all peaks but the chosen one (if there's one).
	% Widths1 = Widths1(F); % Delete all peaks but the chosen one (if there's one).
	% Proms1 = Proms1(F); % Delete all peaks but the chosen one (if there's one).
	
	% 5. Choose the Best Route:
	
	% 6. Detect Local Branch Width:
	
	
end