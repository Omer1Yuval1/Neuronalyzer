function Points = Find_Distance_From_Midline(Points,Axes,Scale_Factor,Step)
	
	% This function computes the signed distance of each point from the midline.
	% Dorsal is defined as positive distance and ventral as negative.
	% The midline points are given from head to tail.
	% Step=1 indicates that the other axes (besides the midline) can now be computed too.
	
	% Ap is the local tilting angle of the plane.
	
	[In_D,On_D] = inpolygon([Points.X],[Points.Y],[[Axes.Axis_0.X] , fliplr([Axes.Axis_2_Dorsal.X])],[[Axes.Axis_0.Y] , fliplr([Axes.Axis_2_Dorsal.Y])]); % All.
	[In_V,On_V] = inpolygon([Points.X],[Points.Y],[[Axes.Axis_0.X] , fliplr([Axes.Axis_2_Ventral.X])],[[Axes.Axis_0.Y] , fliplr([Axes.Axis_2_Ventral.Y])]); % All.
	In_Dorsal = In_D | On_D;
	In_Ventral = In_V | On_V;
	
	for p=1:numel(Points) % For each tracing point (= rectangle).
		
		if(p == 8521)
			disp(1);
		end
		
		% Find the corresponding midline point:
		Dp = ( ( Points(p).X -  [Axes.Axis_0.X] ).^2 + ( Points(p).Y -  [Axes.Axis_0.Y] ).^2).^(.5); % Distances from all midlines points.
		f = find(Dp == min(Dp),1);
		
		Points(p).Midline_Tangent_Angle = Axes.Axis_0(f).Tangent_Angle;
		
		if(In_Dorsal(p) && ~In_Ventral(p)) % If a dorsal pixel.
			Points(p).Midline_Distance = Dp(f) * Scale_Factor; % Pixels to um.
			
			if(Step)
				R3 = min(( ([Axes.Axis_1_Dorsal.X] - Axes.Axis_0(f).X).^2 + ([Axes.Axis_1_Dorsal.Y] - Axes.Axis_0(f).Y).^2 ).^(.5));
				R4 = min(( ([Axes.Axis_2_Dorsal.X] - Axes.Axis_0(f).X).^2 + ([Axes.Axis_2_Dorsal.Y] - Axes.Axis_0(f).Y).^2 ).^(.5));
				% R3 = ( (Axes.Axis_1_Dorsal(f).X - Axes.Axis_0(f).X).^2 + (Axes.Axis_1_Dorsal(f).Y - Axes.Axis_0(f).Y).^2 ).^(.5);
				% R4 = ( (Axes.Axis_2_Dorsal(f).X - Axes.Axis_0(f).X).^2 + (Axes.Axis_2_Dorsal(f).Y - Axes.Axis_0(f).Y).^2 ).^(.5);
			end
		elseif(In_Ventral(p) && ~In_Dorsal(p))
			Points(p).Midline_Distance = -Dp(f) * Scale_Factor; % Pixels to um.
			
			if(Step)
				R3 = min(( ([Axes.Axis_1_Ventral.X] - Axes.Axis_0(f).X).^2 + ([Axes.Axis_1_Ventral.Y] - Axes.Axis_0(f).Y).^2 ).^(.5));
				R4 = min(( ([Axes.Axis_2_Ventral.X] - Axes.Axis_0(f).X).^2 + ([Axes.Axis_2_Ventral.Y] - Axes.Axis_0(f).Y).^2 ).^(.5));
			end
		elseif(~In_Ventral(p) && ~In_Dorsal(p))
			Points(p).Midline_Distance = nan;
			
			if(Step)
				R3 = nan;
				R4 = nan;
			end
			disp(['Point not found on either the dorsal or ventral side. Distance = ',num2str(Dp(f)),'.']);
		else % Both.
			Points(p).Midline_Distance = 0;
			
			if(Step)
				R3 = 0;
				R4 = 0;
			end
			disp(['Point found in both dorsal and ventral. Distance = ',num2str(Dp(f)),'.']);
		end
		
		if(Step)
			Points(p).Half_Radius = R3 * Scale_Factor; % Pixels to um.
			Points(p).Radius = R4 * Scale_Factor; % Pixels to um.
		end
		Points(p).Axis_0_Position = Axes.Axis_0(f).Arc_Length;
		
		if(isfield(Points,'Angle')) % Do for the all-points structure but not for the vertices structure.
			Medial_Angle = mod(Axes.Axis_0(f).Tangent_Angle,2*pi); % [0,2*pi].
			
			d1 = max(Medial_Angle,Points(p).Angle) - min(Medial_Angle,Points(p).Angle); %  [0,2*pi]. Take the diff and make sure it is positive.
			d2 = min(d1,2*pi-d1); % [0,pi]. Take the smallest diff between the angles to obtain an angle within [0,pi].
			d3 = min(d2,pi-d2); % [0,pi/2]. Now do the same (smallest diff) but within [0,pi] to obtain an angle within [0,pi/2].
			
			Points(p).Midline_Orientation = d3; % [0,pi/2].
		end
		
		%{
		if(~isnan(Points(p).Midline_Distance))
			Ap = W.Parameters.Angle_Correction.Corrected_Plane_Angle_Func(abs(Points(p).Midline_Distance) .* Scale_Factor); % Input: distance (in um) from the medial axis.
			Points(p).Corrected_Angle = Correct_Projected_Angle(Points(p).Angle,Medial_Angle,Ap);
		else
			Points(p).Corrected_Angle = nan;
		end
		%}
	end
end