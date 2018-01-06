function Struct1 = Segments_Length_Struct(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for s=1:numel(Workspace1.Segments)
		Struct1(end+1).Property = Workspace1.Segments(s).Length;
		Struct1(end).Order = Workspace1.Segments(s).Order;
		Struct1(end).Weight = 1;
		
		Distance_From_Primary1 = mean([Workspace1.Segments(s).Rectangles.Distance_From_Primary]);
		if(Distance_From_Primary1 > 0)
			Struct1(end).Dorsal_Ventral = 1;
		elseif(Distance_From_Primary1 < 0)
			Struct1(end).Dorsal_Ventral = -1;
		else
			Struct1(end).Dorsal_Ventral = 0;
		end
	end
	
end