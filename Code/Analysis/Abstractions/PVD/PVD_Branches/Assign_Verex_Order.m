function Workspace1 = Assign_Verex_Order(Workspace1)
	
	for i=1:numel(Workspace1.Vertices)
		F = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(i).Vertex_Index | ...
				[Workspace1.Segments.Vertex2] == Workspace1.Vertices(i).Vertex_Index);
		
		Workspace1.Vertices(i).Order = sort([Workspace1.Segments(F).Order]);		
	end
	
end