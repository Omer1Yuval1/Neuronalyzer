function Struct1 = Curvature_Longitudinal_Gradient(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for b=1:numel(Workspace1.Branches)
		if(Workspace1.Branches(b).Curvature >= 0)
			Struct1(end+1).Property = mean([Workspace1.Branches(b).Rectangles.Primary_Arc_Distance_From_CB]);
			Struct1(end).Weight = Workspace1.Branches(b).Curvature;
			Struct1(end).Order = Workspace1.Branches(b).Order;
			if(Workspace1.Branches(b).Rectangles(end).Distance_From_Primary > 0)
				Struct1(end).Dorsal_Ventral = 1; % (+1) for dorsal.
			elseif(Workspace1.Branches(b).Rectangles(end).Distance_From_Primary < 0)
				Struct1(end).Dorsal_Ventral = -1; % (-1) for ventral.
			else
				Struct1(end).Dorsal_Ventral = 0; % 0 for primary points.
			end
		end
	end
	
	% assignin('base','Struct1',Struct1);
	
end