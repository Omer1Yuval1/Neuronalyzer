function Struct1 = Curvature_Distribution(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for b=1:numel(Workspace1.Branches)
		
		if(Workspace1.Branches(b).Curvature >= 0)
			Struct1(end+1).Property = Workspace1.Branches(b).Curvature;
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
	end
	
	% assignin('base','Struct1',Struct1);
	
end