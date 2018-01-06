function Workspace1 = Vertex_Shape1(Workspace1)
	
	for i=1:numel(Workspace1.Vertices)
		if(length(Workspace1.Vertices(i).Rectangles_Angles) == 3)
			% Vertices Angles Diffs:
				Arr1 = zeros(3,4); % One row for each angle.
				
				Arr1 = [[1:3]',Workspace1.Vertices(i).Rectangles_Angles'];
				Arr1 = sortrows(Arr1,2); % Ascending (smallest angle 1st).
				
				Arr1(3,3) = Arr1(3,2) - Arr1(2,2); % Diff between angles 3 & 2.
				Arr1(3,4) = Arr1(2,1); % The number of the 2nd rect (in the list).
				
				Arr1(2,3) = Arr1(2,2) - Arr1(1,2); % Diff between angles 2 & 1.
				Arr1(2,4) = Arr1(1,1); % The number of the 1st rect (in the list).
				
				Arr1(1,3) = 360 - Arr1(3,3) - Arr1(2,3); % Diff between angles 3 & 1.
				Arr1(1,4) = Arr1(3,1); % The number of the 3rd rect (in the list).
				
				F1 = find([Arr1(:,1)] < 3 & [Arr1(:,4)] < 3); % Find the new angle.
				F23 = find([Arr1(:,1)] == 3 | [Arr1(:,4)] == 3); % Find the other angles (the two of the source rectangle).
				
				Workspace1.Vertices(i).Rects_Angles_Diffs = [Arr1(F1,3) , Arr1(F23(1),3) , Arr1(F23(2),3)]; % The new angle is First.
				
			% Straight Angles:
				F1 = find([Workspace1.Segments.Vertex1] == Workspace1.Vertices(i).Vertex_Index); % Find the segments of each vertex (pointing out from the vertex).
				F2 = find([Workspace1.Segments.Vertex2] == Workspace1.Vertices(i).Vertex_Index); % Find the segments that end in this vertex (pointing into the vertex).
				G1s = [Workspace1.Segments(F1).Line_Angle];
				G2s = mod([Workspace1.Segments(F2).Line_Angle] + 180,360); % Flip the angle of the root vertex\segment.
				if(length(G1s) + length(G2s) == 3)
					Workspace1.Vertices(i).Line_Angles = [G1s G2s];
					Arr2 = [[1:3]',Workspace1.Vertices(i).Line_Angles'];
					Arr2 = sortrows(Arr2,2); % Ascending.
					A2_32 = Arr2(3,2) - Arr2(2,2);
					A2_21 = Arr2(2,2) - Arr2(1,2);
					Workspace1.Vertices(i).Line_Angles_Diffs = sort([A2_21 A2_32 360-A2_21-A2_32]);
				end
		% else
			% Workspace1.Vertices(i).New_Angle = -1;
		end
	end
	
end