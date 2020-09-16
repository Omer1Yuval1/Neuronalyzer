function Locs1 = Trace_Peak_Analysis(Workspace,Step_Params,s,v,Scores,ImSize)
	
	% This function find peaks in the convolution function.
	% It uses the skeleton constraint to filter out peaks that are too far, and to sort those that satisfy the condition.
	
	L = Step_Params.Scan_Length;
	Locs1 = [];
	
	Trace_Skel_Max_Distance = Workspace.Parameters.Auto_Tracing_Parameters.Trace_Skel_Max_Distance;
	
	[Sy,Sx] = ind2sub(ImSize,Workspace.Segments(s).Skeleton_Linear_Coordinates); % Get segment skeleton coordinates.
	O = Step_Params.Rotation_Origin; % Coordinate of the current tracing point.
	O_DSkel = ((Sx-O(1)).^2 + (Sy-O(2)).^2).^.5; % Distances of the point from all skeleton pixels.
	
	if(min(O_DSkel) <= Trace_Skel_Max_Distance) % First, check that the origin satisfied the skeleton distance constraint
		% Find peaks and check the skeleton constraint for the potential peaks (using the corresponding point on the parallel side of the scanning rectnagle).
		[Peaks1,Locs1,~,~] = findpeaks(Scores(:,2),Scores(:,1),'MinPeakProminence',Workspace.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Prominence,'MinPeakDistance',Workspace.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Distance);
		
		if(~isempty(Peaks1))
			Op_DSkel = nan(1,length(Peaks1));
			for p=1:length(Peaks1) % Find the next point for each potential peak (direction) and its distance from the skeleton (using the scanning rect length).
				Op = [O(1)+L*cosd(Locs1(p)),O(2)+L*sind(Locs1(p))];
				Op_DSkel(p) = min((Sx-Op(1)).^2 + (Sy-Op(2)).^2).^.5; % Distances of potential next point p from all skeleton pixels.
			end
			
			Op_DSkel(Op_DSkel > Trace_Skel_Max_Distance) = nan; % Set to nan peaks that are too far off the skeleton.
			
			[~,I] = sort(Op_DSkel); % Find the indices I that sort the distances in increasing order.
			
			I(isnan(Op_DSkel(I))) = []; % Remove indices that correspond to nan values in the skeleton distance vector Op_DSkel.
			
			if(~isempty(I) && ~isnan(Op_DSkel(I(1)))) % If the best peak is not a nan.
				Locs1 = Locs1(I(1));
				% Peaks1 = Peaks1(I(1));
				% Proms1 = Proms1(I(1));
			else
				Locs1 = [];
			end
		end % Else Locs1 = [];
	end % Else Locs1 = [];
end