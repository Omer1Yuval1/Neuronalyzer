function Struct1 = Menorahs_Receptive_Field_Length_Struct(Workspace1,Field_Name)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for m=1:numel(Workspace1.Menorahs)
		Fb = find([Workspace1.Branches.Menorah] == Workspace1.Menorahs(m).Menorah_Index & [Workspace1.Branches.Order] > 3); % 3.5, 4, 5 ...
		if(length(Fb) > 0) % If it has at least one branch of order >= 3.
			
			Struct1(end+1).Property = Workspace1.Menorahs(m).Total_Area / (abs(Workspace1.Menorahs(m).Max_Anterior - Workspace1.Menorahs(m).Max_Posterior) ... % The total area of the menorah,
										* Workspace1.Menorahs(m).Max_Distance_From_Primary); % divided by (the distance between the Menorahs extremes (max anterior & max posterior) X its height (max distance from the primary branch)).
			Struct1(end).Order = 0;
			Struct1(end).Weight = 1;
			Struct1(end).Dorsal_Ventral =  Workspace1.Menorahs(m).Dorsal_Ventral;
			
		end
	end
end