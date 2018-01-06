function Struct1 = Menorahs_Branches_Gradient(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	% assignin('base','Workspace1',Workspace1);
	
	for m=1:max([Workspace1.Branches.Menorah])
		
		Fm = find([Workspace1.Branches.Menorah] == m & [Workspace1.Branches.Order] == 2); % The secondary segments of the menorah.
		if(length(Fm) == 0)
			continue;
		end
		
		Mean1 = mean([Workspace1.Branches(Fm(end)).Rectangles.Distance_From_Primary]); % Used to differentiate between dorsal and ventral.
		
		if(Mean1 > 0)
			Dorsal_Ventral = 1;
		elseif(Mean1 < 0)
			Dorsal_Ventral = -1;
		else
			Dorsal_Ventral = 0;
		end
		
		% for o=2:.5:max([Workspace1.Branches.Order])
		for o=2:.5:max([Workspace1.Branches.Order])
			F = find([Workspace1.Branches.Menorah] == m & [Workspace1.Branches.Order] == o);			
			Struct1(end+1).Property = Workspace1.Branches(Fm(1)).Rectangles.Primary_Arc_Distance_From_CB; % Take the 1st second segment.
			Struct1(end).Order = o;
			Struct1(end).Weight = length(F);
			Struct1(end).Dorsal_Ventral = Dorsal_Ventral;
		end
		
	end
	
end