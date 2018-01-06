function [Distance_Matrix_Num,Distance_Matrix_Length] = Vertices_Recursive_Walk(Vertex0_Index,Vertex_Index,Previous_Vertex_Index,N1,L1,Segments1,Fs,Distance_Matrix_Num,Distance_Matrix_Length)
	
	F1 = find([Segments1.Vertex1] == Vertex_Index & [Segments1.Vertex2] ~= Previous_Vertex_Index); % Find all the segments that are connected to the i-th vertex.
	F2 = find([Segments1.Vertex2] == Vertex_Index & [Segments1.Vertex1] ~= Previous_Vertex_Index); % ". Exclude the segment connected to the previous vertex.
	% Loops are not a problem since there's a separate field for loops and a segment cannot be connected to itself (from two directions) via the Vertex1 and Vertex2 fields.
	
	if(length(Fs) > 0)
		F3 = find(Fs(:,2) == Vertex_Index); % Try to find the current checked vertex in the cell body segments\vertices array.
		if(length(F3) > 0) % If it's a cell body vertex.
			Fs(F3,:) = []; % Delete the row of the current cell-body segment.
			F1 = [F1,Fs(:,1)'];
			Fs = []; % This array should be used only once per vertex.
		end
	end
	
	for j=1:length(F1) % For each segment connected to the i-th vertex (1->2).
		Distance_Matrix_Num(abs(Vertex0_Index),abs(Segments1(F1(j)).Vertex2)) = N1; % Negative values get positive index. This is ok since abs(i) is unique even for negative values.
		L2 = L1 + Segments1(F1(j)).Length;
		Distance_Matrix_Length(abs(Vertex0_Index),abs(Segments1(F1(j)).Vertex2)) = L2; % Negative values get positive index. This is ok since abs(i) is unique even for negative values.
		[Distance_Matrix_Num,Distance_Matrix_Length] = Vertices_Recursive_Walk(Vertex0_Index,Segments1(F1(j)).Vertex2,Vertex_Index,N1+1,L2,Segments1,Fs,Distance_Matrix_Num,Distance_Matrix_Length);
	end
	
	for j=1:length(F2) % For each segment connected to the i-th vertex (2->1).
		Distance_Matrix_Num(abs(Vertex0_Index),abs(Segments1(F2(j)).Vertex1)) = N1; % Negative values get positive index. This is ok since abs(i) is unique even for negative values.
		L2 = L1 + Segments1(F2(j)).Length;
		Distance_Matrix_Length(abs(Vertex0_Index),abs(Segments1(F2(j)).Vertex1)) = L2; % Negative values get positive index. This is ok since abs(i) is unique even for negative values.
		[Distance_Matrix_Num,Distance_Matrix_Length] = Vertices_Recursive_Walk(Vertex0_Index,Segments1(F2(j)).Vertex1,Vertex_Index,N1+1,L2,Segments1,Fs,Distance_Matrix_Num,Distance_Matrix_Length);
	end
end