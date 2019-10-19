function All_Points = Find_Distance_From_Midline(W,All_Points,Worm_Axes,Scale_Factor,Step)
	
	% This function computes the signed distance of each point from the midline.
	% Dorsal is defined as positive distance and ventral as negative.
	% The midline poitns are gived from head to tail.
	% Step=1 indicates that the other axes (besides the midline) can now be computed too.
	
	% Ap is the local tilting angle of the plane.
	
	[In_D,On_D] = inpolygon([All_Points.X],[All_Points.Y],[[Worm_Axes.Axis_0.X] , fliplr([Worm_Axes.Axis_2_Dorsal.X])],[[Worm_Axes.Axis_0.Y] , fliplr([Worm_Axes.Axis_2_Dorsal.Y])]); % All.
	[In_V,On_V] = inpolygon([All_Points.X],[All_Points.Y],[[Worm_Axes.Axis_0.X] , fliplr([Worm_Axes.Axis_2_Ventral.X])],[[Worm_Axes.Axis_0.Y] , fliplr([Worm_Axes.Axis_2_Ventral.Y])]); % All.
	In_Dorsal = In_D | On_D;
	In_Ventral = In_V | On_V;
	
	for p=1:numel(All_Points) % For each tracing point (= rectangle).
		
		% Find the corresponding midline point:
		Dp = ( ( All_Points(p).X -  [Worm_Axes.Axis_0.X] ).^2 + ( All_Points(p).Y -  [Worm_Axes.Axis_0.Y] ).^2).^(.5); % Distances from all midlines points.
		f = find(Dp == min(Dp));
		f = f(1);
		
		All_Points(p).Midline_Tangent_Angle = Worm_Axes.Axis_0(f).Tangent_Angle;
		
		if(In_Dorsal(p) && ~In_Ventral(p)) % If a dorsal pixel.
			All_Points(p).Midline_Distance = Dp(f) * Scale_Factor; % Pixels to um.
			
			if(Step)
				R3 = ( (Worm_Axes.Axis_1_Dorsal(f).X - Worm_Axes.Axis_0(f).X).^2 + (Worm_Axes.Axis_1_Dorsal(f).Y - Worm_Axes.Axis_0(f).Y).^2 ).^(.5);
				R4 = ( (Worm_Axes.Axis_2_Dorsal(f).X - Worm_Axes.Axis_0(f).X).^2 + (Worm_Axes.Axis_2_Dorsal(f).Y - Worm_Axes.Axis_0(f).Y).^2 ).^(.5);
			end
		elseif(In_Ventral(p) && ~In_Dorsal(p))
			All_Points(p).Midline_Distance = -Dp(f) * Scale_Factor; % Pixels to um.
			
			if(Step)
				R3 = ( (Worm_Axes.Axis_1_Ventral(f).X - Worm_Axes.Axis_0(f).X).^2 + (Worm_Axes.Axis_1_Ventral(f).Y - Worm_Axes.Axis_0(f).Y).^2 ).^(.5);
				R4 = ( (Worm_Axes.Axis_2_Ventral(f).X - Worm_Axes.Axis_0(f).X).^2 + (Worm_Axes.Axis_2_Ventral(f).Y - Worm_Axes.Axis_0(f).Y).^2 ).^(.5);
			end
		elseif(~In_Ventral(p) && ~In_Dorsal(p))
			All_Points(p).Midline_Distance = nan;
			
			if(Step)
				R3 = nan;
				R4 = nan;
			end
			disp(['Point not found on either the dorsal or ventral side. Distance = ',num2str(Dp(f)),'.']);
		else % Both.
			All_Points(p).Midline_Distance = 0;
			
			if(Step)
				R3 = 0;
				R4 = 0;
			end
			disp(['Point found in both dorsal and ventral. Distance = ',num2str(Dp(f)),'.']);
		end
		
		if(Step)
			All_Points(p).Half_Radius = R3 * Scale_Factor; % Pixels to um.
			All_Points(p).Radius = R4 * Scale_Factor; % Pixels to um.
		end
		All_Points(p).Axis_0_Position = Worm_Axes.Axis_0(f).Arc_Length;
		
		if(isfield(All_Points,'Angle')) % Do for the all-points structure but not for the vertices structure.
			Medial_Angle = mod(Worm_Axes.Axis_0(f).Tangent_Angle,2*pi); % [0,2*pi].
			
			d1 = max(Medial_Angle,All_Points(p).Angle) - min(Medial_Angle,All_Points(p).Angle); %  [0,2*pi]. Take the diff and make sure it is positive.
			d2 = min(d1,2*pi-d1); % [0,pi]. Take the smallest diff between the angles to obtain an angle within [0,pi].
			d3 = min(d2,pi-d2); % [0,pi/2]. Now do the same (smallest diff) but within [0,pi] to obtain an angle within [0,pi/2].
			
			All_Points(p).Midline_Orientation = d3; % [0,pi/2].
		end
		
		%{
		if(~isnan(All_Points(p).Midline_Distance))
			Ap = W.Parameters.Angle_Correction.Corrected_Plane_Angle_Func(abs(All_Points(p).Midline_Distance) .* Scale_Factor); % Input: distance (in um) from the medial axis.
			All_Points(p).Corrected_Angle = Correct_Projected_Angle(All_Points(p).Angle,Medial_Angle,Ap);
		else
			All_Points(p).Corrected_Angle = nan;
		end
		%}
	end
end