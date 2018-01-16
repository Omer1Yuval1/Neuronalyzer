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
			D = max(1,floor(Step_Params.Scan_Length));
			Skel_Points = [Sx(F(1):min(length(Sx),F(1)+D))',Sy(F(1):min(length(Sx),F(1)+D))']; % Skel_Angle = atan2d(P1(2)-P0(2),P1(1)-P0(1));
		else
			D = min(F(1)-1,floor(Step_Params.Scan_Length));
			Skel_Points = [Sx(F(1):-1:F(1)-D)',Sy(F(1):-1:F(1)-D)']; % Skel_Angle = atan2d(P1(2)-P0(2),P1(1)-P0(1));
		end
		% b = [Skel_Points,zeros(size(Skel_Points,1),1)]; % Skel coordinates [x,y,0].
		
		b = mod(atan2d(Skel_Points(end,2) - Skel_Points(1,2),Skel_Points(end,1) - Skel_Points(1,1)),360);
		% if(v==1)
			% disp(b);
		% end
		% P0_Skel = [Sx(F(1)),Sy(F(1))];
		% P1_Skel = [Sx(F(1)+D),Sy(F(1)+D)];
		
		% if(v == 1)
			% hold on;
			% scatter(Skel_Points(:,1),Skel_Points(:,2),10,jet(size(Skel_Points,1)));
		% end
		
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
			
			% a = [Step_Params.Rotation_Origin - [mean(XV(2:3)),mean(YV(2:3))] , 0];
			% Skel_Score = zeros(1,size(b,1));
			% for k=1:size(b,1)
				% bi = b(k,:) - [Step_Params.Rotation_Origin,0];
				% Skel_Score(k) = norm(cross(a,bi)) / norm(a); % TOOD: validate.
			% end
			a = Locs1(p);
			
			Peaks_Scores(p,1) = A; % Orientation.
			Peaks_Scores(p,2) = Proms1(p); % Prominence. Thresholded during peak analysis.
			% Peaks_Scores(p,3) = Skel_Score; % Skeleton. Set to -1 if below threshold.
			
			% Peaks_Scores(p,3) = mean(Skel_Score);
			c = max([a,b]) - min([a,b]); % Angle difference. always positive.
			Peaks_Scores(p,3) = min(c,360-c);
		end
		
		Peaks_Scores = Peaks_Scores * Workspace.Parameters.Auto_Tracing_Parameters.Tracing_Scores_Weights; % [p,3] X [3,1] = [p,1].
		[~,I] = sort(Peaks_Scores); % TODO: Make sure each array is sorted using the correct orientation (ascend \ descend).
		Peaks1 = Peaks1(I(1));
		Locs1 = Locs1(I(1));
		Proms1 = Proms1(I(1));
		% disp(Locs1);
		
		return;
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
end