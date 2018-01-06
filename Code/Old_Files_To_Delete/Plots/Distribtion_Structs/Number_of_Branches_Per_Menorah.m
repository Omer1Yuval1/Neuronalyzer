function Struct1 = Number_of_Branches_Per_Menorah(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for m=1:max([Workspace1.Branches.Menorah]) % For each Menorah index.
		
		Fb = find([Workspace1.Branches.Menorah] == m & [Workspace1.Branches.Order] == 2); % The secondary segments of the menorah.
		
		if(length(Fb) > 0)
			F = find([Workspace1.Branches.Menorah] == m & [Workspace1.Branches.Order] == 4)
			Struct1(end+1).Property = length(F); % Number of branches of menorah 'm'. x-axis.
			Struct1(end).Order = 0;
			Struct1(end).Weight = 1; % y-axis.
			Struct1(end).Dorsal_Ventral = Workspace1.Menorahs(find([Workspace1.Menorahs.Menorah_Index] == m)).Dorsal_Ventral;
		end
	end
	
	% assignin('base','Struct1',Struct1);
end