function Struct1 = Branches_Gradient(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for b=1:numel(Workspace1.Branches)
		
		Struct1(end+1).Property = mean([Workspace1.Branches(b).Rectangles.Primary_Arc_Distance_From_CB]);
		Struct1(end).Order = Workspace1.Branches(b).Order;
		Struct1(end).Weight = 1;
		
		Distance_From_Primary1 = mean([Workspace1.Branches(b).Rectangles.Distance_From_Primary]);
		if(Distance_From_Primary1 > 0)
			Struct1(end).Dorsal_Ventral = 1;
		elseif(Distance_From_Primary1 < 0)
			Struct1(end).Dorsal_Ventral = -1;
		else
			Struct1(end).Dorsal_Ventral = 0;
		end
	end
	
	% assignin('base','Struct1',Struct1);
	
end