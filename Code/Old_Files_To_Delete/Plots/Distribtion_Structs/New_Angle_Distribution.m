function Struct1 = New_Angle_Distribution(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for v=1:numel(Workspace1.Vertices)
		if(length(Workspace1.Vertices(v).Rects_Angles_Diffs) == 3 && isequal(Workspace1.Vertices(v).Order,[2,3,3]))
			Struct1(end+1).Property = Workspace1.Vertices(v).Rects_Angles_Diffs(1);
			Struct1(end).Order = 0;
			Struct1(end).Weight = 1;
			Struct1(end).Dorsal_Ventral = Workspace1.Vertices(v).Dorsal_Ventral;
		end
	end
	
end