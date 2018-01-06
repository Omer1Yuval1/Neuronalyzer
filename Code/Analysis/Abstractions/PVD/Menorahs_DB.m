function Workspace1 = Menorahs_DB(Workspace1)
	
	Workspace1.Menorahs = struct('Menorah_Index',{},'Total_Length',{},'Dorsal_Ventral',{}, ...
						'Primary_Arc_Distance_From_CB',{});
	Menorah_Num = max([Workspace1.Branches.Menorah]);
	Max_Distance = max(Workspace1.Parameters.General_Parameters.Im_Rows,Workspace1.Parameters.General_Parameters.Im_Cols);
	
	for i=1:Menorah_Num % For each Menorah.
		Fm = find([Workspace1.Branches.Menorah] == i); % Find all the branches of this menorah.
		
		Workspace1.Menorahs(i).Primary_Arc_Distance_From_CB = Workspace1.Branches(Fm(1)).Rectangles(1).Primary_Arc_Distance_From_CB; % Distance of the 1st point from the CB.
		Workspace1.Menorahs(i).Menorah_Index = i;
		Workspace1.Menorahs(i).Total_Length = sum([Workspace1.Branches(Fm).Length]);
		Workspace1.Menorahs(i).Primary_Coordinate = [Workspace1.Branches(Fm(1)).Rectangles(1).X,Workspace1.Branches(Fm(1)).Rectangles(1).Y];
		
		Fm1 = find([Workspace1.Branches.Menorah] == i & [Workspace1.Branches.Order] >= 3);
		if(length(Fm1) > 0)
			Workspace1.Menorahs(i).IsMenorah = 1;
		else
			Workspace1.Menorahs(i).IsMenorah = 0;
		end
		
		if(Workspace1.Branches(Fm(1)).Rectangles(end).Distance_From_Primary > 0)
			Workspace1.Menorahs(i).Dorsal_Ventral = 1;
		elseif(Workspace1.Branches(Fm(1)).Rectangles(end).Distance_From_Primary < 0)
			Workspace1.Menorahs(i).Dorsal_Ventral = -1;
		else
			Workspace1.Menorahs(i).Dorsal_Ventral = 0;
		end
		
		% Total_Area = 0;
		Anterior_Length = 0;
		Posterior_Length = 0;
		for j=1:length(Fm) % For each branch that belongs to the i-th Menorahs.
			
			if(j == 1)
				Max_Anterior = max([Workspace1.Branches(Fm(j)).Rectangles.Primary_Arc_Distance_From_CB]); % Find its most anterior and posterior coordinates.
				Max_Posterior = min([Workspace1.Branches(Fm(j)).Rectangles.Primary_Arc_Distance_From_CB]); % ".
				Max_Distance_From_Primary = max(abs([Workspace1.Branches(Fm(j)).Rectangles.Distance_From_Primary])); % Find the most distant coordinate from the primary (in absolute value).
			else
				Max_Anterior = max(Max_Anterior,max([Workspace1.Branches(Fm(j)).Rectangles.Primary_Arc_Distance_From_CB])); % Find its most anterior and posterior coordinates.
				Max_Posterior = min(Max_Posterior,min([Workspace1.Branches(Fm(j)).Rectangles.Primary_Arc_Distance_From_CB])); % ".
				Max_Distance_From_Primary = max(Max_Distance_From_Primary,max(abs([Workspace1.Branches(Fm(j)).Rectangles.Distance_From_Primary]))); % Find the most distant coordinate from the primary (in absolute value).
			end
			
			FA = find([Workspace1.Branches(Fm(j)).Rectangles.Primary_Arc_Distance_From_CB] > Workspace1.Menorahs(i).Primary_Arc_Distance_From_CB);
			FP = find([Workspace1.Branches(Fm(j)).Rectangles.Primary_Arc_Distance_From_CB] < Workspace1.Menorahs(i).Primary_Arc_Distance_From_CB);
			Anterior_Length = Anterior_Length + sum([Workspace1.Branches(Fm(j)).Rectangles(FA).Step_Length]);
			Posterior_Length = Posterior_Length + sum([Workspace1.Branches(Fm(j)).Rectangles(FP).Step_Length]);
			
			% V1 = [Workspace1.Branches(Fm(j)).Rectangles.Step_Length];
			% V2 = [Workspace1.Branches(Fm(j)).Rectangles.Width];
			% V3 = sum(V1 .* V2);
			% Total_Area = Total_Area + sum([Workspace1.Branches(Fm(j)).Rectangles.Step_Length] .* [Workspace1.Branches(Fm(j)).Rectangles.Width]);
		end
		Workspace1.Menorahs(i).Max_Anterior = Max_Anterior;
		Workspace1.Menorahs(i).Max_Posterior = Max_Posterior;
		Workspace1.Menorahs(i).Anterior_Length = Anterior_Length;
		Workspace1.Menorahs(i).Posterior_Length = Posterior_Length;
		% Workspace1.Menorahs(i).Total_Area = Total_Area;
	end
	
	% Calculate Menorahs Overlap:
	for m=1:numel(Workspace1.Menorahs) % For each menorah.
		Vcb = [Workspace1.Menorahs.Primary_Arc_Distance_From_CB] - Workspace1.Menorahs(m).Primary_Arc_Distance_From_CB;
		
		Vcb1 = Vcb; % Find the adjacent menorah from the anterior side. The chosen value must be positive.
		Max1 = max(Vcb1);
		Vcb1(find(Vcb1 < 0 | [Workspace1.Menorahs.Dorsal_Ventral] ~= Workspace1.Menorahs(m).Dorsal_Ventral | [Workspace1.Menorahs.IsMenorah] == 0)) = Max1 + 2; % Now, the minimal value is the desired value.
		Vcb1(m) = Max1 + 1; % Ignore the value of the current tested menorah (but if it's the first anterior menorah, it will have the smallest value).
		F1 = find(Vcb1 == min(Vcb1) & Vcb1 >= 0); % Find the closest menorah on the same side (anterior\posterior). The smallest positive value.
		
		
		Vcb2 = Vcb; % Find the adjacent menorah from the posterior side. The chosen value must be negative.
		Min1 = min(Vcb2);
		Vcb2(find(Vcb2 > 0 | [Workspace1.Menorahs.Dorsal_Ventral] ~= Workspace1.Menorahs(m).Dorsal_Ventral | [Workspace1.Menorahs.IsMenorah] == 0)) = Min1 - 2; % Now, the maximal value is the desired value. >=0 is anterior.
		Vcb2(m) = Min1 - 1; % Ignore the value of the current tested menorah (but if it's the first anterior menorah, it will have the largest value).
		F2 = find(Vcb2 == max(Vcb2) & Vcb2 <= 0); % Find the closest menorah on the same side (anterior\posterior). The largest negative value.
		
		if(length(F1) > 0 & F1 ~= m & Workspace1.Menorahs(m).IsMenorah == 1)
			Workspace1.Menorahs(m).Anterior_Overlap = Workspace1.Menorahs(F1(1)).Max_Posterior - Workspace1.Menorahs(m).Max_Anterior;
		end
		
		if(length(F2) > 0 & F2 ~= m & Workspace1.Menorahs(m).IsMenorah == 1)
			Workspace1.Menorahs(m).Posterior_Overlap = Workspace1.Menorahs(m).Max_Posterior - Workspace1.Menorahs(F2(1)).Max_Anterior;
		end
	end
end