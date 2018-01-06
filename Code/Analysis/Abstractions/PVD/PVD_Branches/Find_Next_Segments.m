function Best1 = Find_Next_Segments(Segments1,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Short_Segment_Flag)
	
	% Find the segments that touch this vertex (and are not the current checked segment):
	SV12 = find([Segments1.Vertex1] == Vertex_Index & [Segments1.Segment_Index] ~= Segment_Index);
	Sr = find([Segments1.Segment_Index] == Segment_Index); % Row number of current checked segment.
	
	Vertices_Arr = [];
	Segments_Arr = [];
	
	if(length(SV12) == 0) % Tip.
		return;
	end
	
	for i1=1:length(SV12)
		
		if(Segments1(SV12(i1)).Length > Min_Segment_Length || Segments1(SV12(i1)).Vertex2 < 0) % If it's a long segment. TODO: maybe I should use the straight length here too.	
			Diff1 = abs(Segments1(SV12(i1)).Line_Angle - Angle1); % ... just calculate the line-angle diff.
			Diff1 = min(Diff1,360-Diff1);
			
			Vertices_Arr1 = Segments1(SV12(i1)).Vertex2; % This array will contain all the vertices indices of the current path (without the 1st (given) one).
			Segments_Rows_Arr1 = SV12(i1);
		else % If it's a short segment, use recursion (find the next long enough segment).
			Segment_Index1 = Segments1(SV12(i1)).Segment_Index;
			Vertex_Index1 = Segments1(SV12(i1)).Vertex2;
			
			[Vertices_Arr1,Segments_Rows_Arr1] = Find_Next_Segments(Segments1,Segment_Index1,Vertex_Index1,Min_Segment_Length,Angle1,Max_Angle_Diff,1);			
			
			if(length(Segments_Rows_Arr1) == 0)
				continue;
			end
			
			Diff1 = abs(Segments1(Segments_Rows_Arr1(end)).Line_Angle - Angle1);
			Diff1 = min(Diff1,360-Diff1);
		end
		
		if(Diff1 < Max_Angle_Diff) % If the angle diff is better (smaller) than previous segments,
			Best1(end+1).Angle_Diff = Diff1;
			Best1(end).Best_Angle = Segments1(SV12(i1)).Line_Angle;
			Best1(end).Best_Vertex = Segments1(SV12(i1)).Vertex2;
			Best1(end).Best_Vertices_Arr = Vertices_Arr1;
			Best1(end).Last_Vertex = Vertices_Arr1(end);
			Best1(end).Best_Segments_Rows_Arr = Segments_Rows_Arr1;
			Best1(end).Last_Segment_Length = Segments1(Segments_Rows_Arr1(end)).Length;
			Best1(end).Width = Segments1(SV12(i1)).Width;
		end
	end
	
end