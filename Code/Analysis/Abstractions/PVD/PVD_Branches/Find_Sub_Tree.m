function Vertices_Arr = Find_Sub_Tree(Workspace1,Vertex_Index)
	
	% Segments_Arr = []; % Segments row numbers.
	Vertices_Arr = []; % Segments row numbers.
	Vertices_Arr_Temp = Vertex_Index;
	
	% while (length(Vertices_Arr_Temp) > 0)
	for i=1:13
		L = length(Vertices_Arr_Temp);
		for j=1:L
			F1 = find([Workspace1.Segments.Vertex1] == Vertices_Arr_Temp(j));
			
			Vertices_Arr_Temp = [Vertices_Arr_Temp,Workspace1.Segments(F1).Vertex2];
			Vertices_Arr = [Vertices_Arr,Workspace1.Segments(F1).Vertex2];
		end
		Vertices_Arr_Temp(1:L) = [];
	end	
	% display(Vertices_Arr);
end