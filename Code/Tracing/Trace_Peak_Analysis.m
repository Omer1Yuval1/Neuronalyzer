function Locs1 = Trace_Peak_Analysis(Workspace,Step_Params,s,v,Scores,ImSize)
	
	% TODO: explain what does this function do.
	% Tracing_Scores_Weights = [Orientation,Prominence,Skeleton].
	
	% assignin('base','Workspace',Workspace);
	% assignin('base','s',s);
	
	[Peaks1,Locs1,~,Proms1] = findpeaks(Scores(:,2),Scores(:,1),'MinPeakProminence',Workspace.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Prominence,'MinPeakDistance',Workspace.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Distance);
	
	if(~isempty(Peaks1)) % If at least one peak was found.
		
		Peaks_Scores = zeros(length(Peaks1),length(Workspace.Parameters.Auto_Tracing_Parameters.Tracing_Scores_Weights));
		
		[Sy,Sx] = ind2sub(ImSize,Workspace.Segments(s).Skeleton_Linear_Coordinates);
		DSkel = ((Sx-Step_Params.Rotation_Origin(1)).^2 + (Sy-Step_Params.Rotation_Origin(2)).^2).^.5; % Distances of the rect origin from skeleton pixels.
		F = find(DSkel == min(DSkel)); % Find the closest skeleton pixel to the rect origin.
		if(v == 1)
			D = max(length(Sx),floor(Step_Params.Scan_Length));
			Skel_Points = [Sx(F(1):min(length(Sx),F(1)+D))',Sy(F(1):min(length(Sx),F(1)+D))']; % Skel_Angle = atan2d(P1(2)-P0(2),P1(1)-P0(1));
		else
			D = min(F(1)-1,floor(Step_Params.Scan_Length));
			Skel_Points = [Sx(F(1):-1:F(1)-D)',Sy(F(1):-1:F(1)-D)']; % Skel_Angle = atan2d(P1(2)-P0(2),P1(1)-P0(1));
		end
		b = [Skel_Points,zeros(size(Skel_Points,1),1)];
		% P0_Skel = [Sx(F(1)),Sy(F(1))];
		% P1_Skel = [Sx(F(1)+D),Sy(F(1)+D)];
		
		for p=1:length(Peaks1) % For each peak, find the overlap between its InRect_Coordinates and the skeleton of the relevant segment.			
			
			A = abs(Locs1(p) - Step_Params.Angle); % Angle diff between the peak location and the angle of the previous step.
			A = min(A,360-A);
			
			% TODO: decide what rect length I want to use - step or scan.
			[XV,YV] = Get_Rect_Vector(Step_Params.Rotation_Origin,Locs1(p),Step_Params.Width,Step_Params.Step_Length,Workspace.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin); % Using the length of the scanning rectangle.
			X23 = mean([XV(2),XV(3)]);
			Y23 = mean([YV(2),YV(3)]);
			[Sy,Sx] = ind2sub(ImSize,Workspace.Segments(s).Skeleton_Linear_Coordinates); % Segment's skeleton coordinates.
			Skel_Score = min([((Sx-X23).^2 + (Sy-Y23).^2).^.5]); % Minimal distance from the segment's skeleton.
			
			if(Skel_Score > Workspace.Parameters.Auto_Tracing_Parameters.Trace_Skel_Max_Distance)
				Skel_Score = -1;
			end
			% InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
			% Skel_Score = length(intersect(InRect1,Workspace.Segments(s).Skeleton_Linear_Coordinates)) / (length(InRect1)*Step_Params.Width);
			
			a = [Step_Params.Rotation_Origin - [mean(XV(2:3)),mean(YV(2:3))] , 0];
			Skel_Score = zeros(1,size(b,1));
			for k=1:size(b,1)
				bi = b(k,:) - [Step_Params.Rotation_Origin,0];
				Skel_Score(k) = norm(cross(a,bi)) / norm(a); % TOOD: validate.
			end
			
			Peaks_Scores(p,1) = A; % Orientation.
			Peaks_Scores(p,2) = Proms1(p); % Prominence. Thresholded during peak analysis.
			% Peaks_Scores(p,3) = Skel_Score; % Skeleton. Set to -1 if below threshold.
			
			Peaks_Scores(p,3) = mean(Skel_Score);
		end
		
		Peaks_Scores = Peaks_Scores * Workspace.Parameters.Auto_Tracing_Parameters.Tracing_Scores_Weights; % [p,3] X [3,1] = [p,1].
		% disp(Locs1);
		if(any(Peaks_Scores + 1)) % If at least one of the scores is > (-1).
			[~,I] = sort(Peaks_Scores); % TODO: Make sure each array is sorted using the correct orientation (ascend \ descend).
			Peaks1 = Peaks1(I(1));
			Locs1 = Locs1(I(1));
			Proms1 = Proms1(I(1));
		else % If all scores are (-1), which means they didn't pass a threshold test.
			Peaks1 = [];
			Locs1 = [];
			Proms1 = [];
		end
    end
	
		%{
		F = find(Skeleton_Overlap <= Trace_Skel_Max_Distance); % Find the peaks with normalized overlap above the threshold.
		if(length(F) > 1) % Check if there's more than 1 peak after thresholding the normalized overlap with the skeleton.
			% TODO\TOTHINK: the following row can be merged with the previous 'find'.
			% 				but it is not such a bad idea to separate it as a test step (test for multiple maxima).
			% F = find(Skeleton_Overlap > 0 & Skeleton_Overlap == max(Skeleton_Overlap)); % Take the one with the higher overlap value.
			Peaks1 = Peaks1(F); % Take only the peaks with good skeleton overlap.
			Locs1 = Locs1(F); % Take only the peaks with good skeleton overlap.
			
			% F = find(Peaks1 == max(Peaks1)); % Take the highest peak. % TODO: alternatively, I could take the peak with the most similar angle compared to the previous one.
			D1 = abs(Locs1-Angle);
			D2 = min(D1,360-D1);
			F = find(D2 == min(D2)); % Take the peak with the most similar angle compared to the previous step.
			if(length(F) > 1) % If there's more than one maximum, just take one of them (and let me know).
				F = F(1); % TODO: maybe use the skeleton to choose.
				if(Messages)
					disp('I found multiple optimal routes (multiple directions with the maximal overlap with the skeleton).');
				end
			end
		elseif(length(F) == 0) % No peaks above the threshold (e.g. a fake gap) * ONLY AFTER FILTERING*.
			% TODO: Use the skeleton to force a peak.
			if(v == 1)
				NoPeaks_V12_Flag = 1;
				if(Messages)
					disp('I found no peaks above the overlap threshold for vertex 1 after skeleton filtering.');
				end
				continue;
			elseif(NoPeaks_V12_Flag) % No peaks were found AFTER FITERING for both vertices. Here v must be 2.
				if(Messages)
					disp('I found no peaks above the overlap threshold for both vertices after skeleton filtering.');
				end
				Segments_Array(s) = 0;
				break;
			else % No peaks only for v=2.
				if(Messages)
					disp('I found no peaks above the overlap threshold for vertex 2 after skeleton filtering.');
				end
				continue;
			end
		end % If there's only one peak, do nothing.
		Peaks1 = Peaks1(F); % Delete all peaks but the chosen one (if there's one).
		Locs1 = Locs1(F); % Delete all peaks but the chosen one (if there's one).
		% Widths1 = Widths1(F); % Delete all peaks but the chosen one (if there's one).
		% Proms1 = Proms1(F); % Delete all peaks but the chosen one (if there's one).
		
		if(Plot1 == v && length(F) > 0) % && numel(Workspace.Segments(s).(Field0)) == 2) % At this point in the code, Peaks1 and Locs1 cannot have more than one value.
			% [XV,YV] = Get_Rect_Vector(Rotation_Origin,Locs1(F),Width,Scan_Length,Origin_Type); % Using the length of the scanning rectangle.
			[XV,YV] = Get_Rect_Vector(Rotation_Origin,Locs1,Width,Step_Length,Origin_Type); % Using the length of the scanning rectangle.
			XV = [XV,XV(1)];
			YV = [YV,YV(1)];
			figure(1);
			hold on;
			plot(XV,YV,'LineWidth',3);
		end
		% TODO: Check for collision in the locations map.
	else % No Peaks. length(Peaks1) == 0.
		NoPeaks_V12_Flag = NoPeaks_V12_Flag + 1; % 1 for vertex 1 and 2 for both 1&2.
		if(NoPeaks_V12_Flag == 2) % if no peaks were found for both vertices (directions) of the same segment (even after trying to use the skeleton).
			Segments_Array(s) = 0;
			if(Messages)
				disp(['I could not find any peaks for both direction (even not using the skeleton). Segment ',num2str(s),' tracing is terminated']);
			end
			break;
		else
			if(Messages)
				disp(['No Peaks were found for vertex ',num2str(v),'. Continue.']);
			end
			% disp(NoPeaks_V12_Flag);
			continue;
		end
	end % If both vertices have no peaks, do not continue, break (to avoid inf).
	%}
end