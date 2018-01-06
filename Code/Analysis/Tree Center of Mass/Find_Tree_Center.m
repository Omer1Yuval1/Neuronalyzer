% function [Distance_Matrix_Num,Distance_Matrix_Length] = Find_Tree_Center(Workspace1)
function [Cxy_Num,Cxy_Length] = Find_Tree_Center(Workspace1)
	
	Vertices1 = Workspace1.Vertices;
	Segments1 = Workspace1.Segments;
	Mv = max(abs([Vertices1.Vertex_Index]));
	Distance_Matrix_Num = zeros(Mv,Mv);
	Distance_Matrix_Length = zeros(Mv,Mv);
	N1 = 1; % Distance between a vertex and itself.
	L1 = 0;
	
	F = find([Vertices1.Vertex_Order] == -1); % Find all the cell body vertices.
	Fs = []; % Array of cell body segments (rows).
	for i=1:length(F)
		F1 = find([Segments1.Vertex1] == Vertices1(F(i)).Vertex_Index); % Current CB segment row number.
		Fs(end+1,:) = [F1,Segments1(F1).Vertex1]; % [Segment row # , Vertex Index].
	end
	
	% Based on the number of vertices (shortest route):
	for i=1:numel(Vertices1)
		Vertex_Index = Vertices1(i).Vertex_Index;
		Distance_Matrix_Num(abs(Vertex_Index),abs(Vertex_Index)) = N1; % The distance of a vertex from itself.
		Distance_Matrix_Length(abs(Vertex_Index),abs(Vertex_Index)) = L1; % The distance of a vertex from itself.
		[Distance_Matrix_Num,Distance_Matrix_Length] = Vertices_Recursive_Walk(Vertex_Index,Vertex_Index,0,N1+1,L1,Segments1,Fs,Distance_Matrix_Num,Distance_Matrix_Length);
	end	
	
	Distance_Matrix_Num_Sums = sum(Distance_Matrix_Num);
	F1 = find(Distance_Matrix_Num_Sums == min(Distance_Matrix_Num_Sums));
	F1 = F1(1);
	F12 = find([Workspace1.Vertices.Vertex_Index] == F1 | [Workspace1.Vertices.Vertex_Index] == -F1);
	Cxy_Num = Workspace1.Vertices(F12).Coordinates;
	
	Distance_Matrix_Length_Sums = sum(Distance_Matrix_Length);
	F2 = find(Distance_Matrix_Length_Sums == min(Distance_Matrix_Length_Sums));
	F2 = F2(1);
	F22 = find([Workspace1.Vertices.Vertex_Index] == F2 | [Workspace1.Vertices.Vertex_Index] == -F2);
	Cxy_Length = Workspace1.Vertices(F22).Coordinates;
	
end