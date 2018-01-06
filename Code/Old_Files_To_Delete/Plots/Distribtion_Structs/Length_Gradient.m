function Struct1 = Length_Gradient(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for b=1:numel(Workspace1.Segments)
		for r=1:numel(Workspace1.Segments(b).Rectangles)
			Struct1(end+1).Property = Workspace1.Segments(b).Rectangles(r).Primary_Arc_Distance_From_CB;
			Struct1(end).Weight = Workspace1.Segments(b).Rectangles(r).Step_Length;
			Struct1(end).Order = Workspace1.Segments(b).Order;
			if(Workspace1.Segments(b).Rectangles(r).Distance_From_Primary > 0)
				Struct1(end).Dorsal_Ventral = 1; % (+1) for dorsal.
			elseif(Workspace1.Segments(b).Rectangles(r).Distance_From_Primary < 0)
				Struct1(end).Dorsal_Ventral = -1; % (-1) for ventral.
			else
				Struct1(end).Dorsal_Ventral = 0; % 0 for primary points.
			end
		end
	end
	
	% assignin('base','Struct1',Struct1);
	
end