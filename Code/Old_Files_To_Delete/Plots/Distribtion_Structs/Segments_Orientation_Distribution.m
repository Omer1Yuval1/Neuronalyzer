function Struct1 = Segments_Orientation_Distribution(Workspace1)
	
	Struct1 = struct('Property',{},'Weight',{},'Dorsal_Ventral',{});
	
	for s=1:numel(Workspace1.Segments)
			Struct1(end+1).Property = Workspace1.Segments(s).Orientation;
			Struct1(end).Order = Workspace1.Segments(s).Order;
			Struct1(end).Weight = 1;
			Struct1(end).Dorsal_Ventral = Workspace1.Segments(s).Rectangles(end).Distance_From_Primary;
	end
	
	% assignin('base','Struct1',Struct1);
	
end