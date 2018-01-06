function [Vertices_Arr,Segments_Arr] = Find_Next_Segments(Segments1,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1,Short_Segment_Flag)
	
	% Find the segments that touch this vertex (and are not the current checked segment):
	SV12 = find([Segments1.Vertex1] == Vertex_Index & [Segments1.Segment_Index] ~= Segment_Index);
	Sr = find([Segments1.Segment_Index] == Segment_Index); % Row number of current checked segment.
	
	Vertices_Arr = [];
	Segments_Arr = [];
	
	if(length(SV12) == 0) % Tip.
		return;
	end
	
	Best1 = struct('Angle_Diff',{},'Best_Angle',{},'Best_Vertex',{},'Best_Vertices_Arr',{},'Best_Segments_Rows_Arr',{},'Width',{});
	
	for i1=1:length(SV12)
		Manual_Edit = 0;
		
		if(Segments1(SV12(i1)).Order > 0) % If the segment order was edited by the user and if it's not smaller than the previous segment order (if it is, ignore the manual edit).
			
			if(abs(Segments1(SV12(i1)).Order) > Order1) % If the order is bigger than the current checked segment.
				% display(Vertex_Index);
				continue; % Do not even include this segment as an option (for the current branch\order).
			end			
			Manual_Edit = 1;
			Vertices_Arr1 = Segments1(SV12(i1)).Vertex2; % Vertex Index.
			Segments_Rows_Arr1 = SV12(i1); % Segment row #.
			
		elseif(Segments1(SV12(i1)).Length > Min_Segment_Length || Segments1(SV12(i1)).Vertex2 < 0) % If it's a long segment. TODO: maybe I should use the straight length here too.	
			Diff1 = abs(Segments1(SV12(i1)).Line_Angle - Angle1); % ... just calculate the line-angle diff.
			Diff1 = min(Diff1,360-Diff1);
			
			Vertices_Arr1 = Segments1(SV12(i1)).Vertex2; % This array will contain all the vertices indices of the current path (without the 1st (given) one).
			Segments_Rows_Arr1 = SV12(i1);
		else % If it's a short segment, use recursion (find the next long enough segment).
			Segment_Index1 = Segments1(SV12(i1)).Segment_Index;
			Vertex_Index1 = Segments1(SV12(i1)).Vertex2;
			
			[Vertices_Arr1,Segments_Rows_Arr1] = Find_Next_Segments(Segments1,Segment_Index1,Vertex_Index1,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1,1);			
			
			if(length(Segments_Rows_Arr1) == 0)
				continue;
			end
			
			Diff1 = abs(Segments1(Segments_Rows_Arr1(end)).Line_Angle - Angle1);
			Diff1 = min(Diff1,360-Diff1);
		end
		
		if(Manual_Edit || Diff1 < Max_Angle_Diff) % If the angle diff is better (smaller) than previous segments,
			
			if(Manual_Edit)				
				Best1(end+1).Manual_Edit = 1;
				Best1(end).Best_Vertices_Arr = Vertices_Arr1;
				Best1(end).Best_Segments_Rows_Arr = Segments_Rows_Arr1;
			else
				Best1(end+1).Angle_Diff = Diff1;
				Best1(end).Best_Angle = Segments1(SV12(i1)).Line_Angle;
				Best1(end).Best_Vertex = Segments1(SV12(i1)).Vertex2;
				Best1(end).Best_Vertices_Arr = Vertices_Arr1;
				Best1(end).Last_Vertex = Vertices_Arr1(end);
				Best1(end).Best_Segments_Rows_Arr = Segments_Rows_Arr1;
				Best1(end).Last_Segment_Length = Segments1(Segments_Rows_Arr1(end)).Length;
				Best1(end).Width = Segments1(SV12(i1)).Width;
				Best1(end).Manual_Edit = 0;
				if(Order1 > 1)
					Best1(end).Last_Segment_Orientation = abs(Segments1(Segments_Rows_Arr1(end)).Orientation);
				end
			end
		end
	end
	
	if(numel(Best1) > 0)
		B2 = find([Best1.Manual_Edit] == 1);
		if(length(B2) == 0)
			switch Order1
				case 2
					% if( length(find([Best1.Last_Vertex] > 0)) > 0 && length(find([Best1.Last_Vertex] < 0)) > 0 ) % If the last vertex (in the recursive process) is a tip and there's another non-tip vertex, delete the tip.
							% Best1(find([Best1.Last_Vertex] < 0)) = [];
					% elseif(length(find([Best1.Last_Vertex] > 0)) == 0 && length(find([Best1.Last_Vertex] < 0)) > 1) % If there're only tips and at least 2,
					if(length(find([Best1.Last_Vertex] > 0)) == 0 && length(find([Best1.Last_Vertex] < 0)) > 1) % If there're only tips and at least 2,
						Best1(find([Best1.Last_Segment_Length] < max([Best1.Last_Segment_Length]))) = []; % Take the longest one.
					end
					% B2 = find([Best1.Angle_Diff] == min([Best1.Angle_Diff]));
					B2 = find([Best1.Last_Segment_Orientation] == max([Best1.Last_Segment_Orientation]));
				case 3
					B2 = find([Best1.Last_Segment_Orientation] == min([Best1.Last_Segment_Orientation]));
				otherwise % case {1,1.5,3.5,4,5,6,7,8,9,10}
					
					if( length(find([Best1.Last_Vertex] > 0 & [Best1.Angle_Diff] < Max_Angle_Diff)) > 0 && length(find([Best1.Last_Vertex] < 0)) > 0 ) % If the last vertex (in the recursive process) is a tip and there's another non-tip vertex, delete the tip.
							Best1(find([Best1.Last_Vertex] < 0)) = [];
					elseif(length(find([Best1.Last_Vertex] > 0)) == 0 && length(find([Best1.Last_Vertex] < 0)) > 1) % If there're only tips vertices and at least two tips,
						Best1(find([Best1.Last_Segment_Length] < max([Best1.Last_Segment_Length]))) = []; % Take the longest one.
					% else % if all the vertices are non-tips.
					end
					
					if(length(find([Best1.Width] < 0.8*max([Best1.Width]))) > 0) % TODO: move parameter.
						B2 = find([Best1.Width] == max([Best1.Width])); % Take the largest width value.
					else % If the width values are approximately similar.
						B2 = find([Best1.Angle_Diff] == min([Best1.Angle_Diff])); % Take the best orientation segment.
					end
			end
		end
		
		% TODO: this array may contain duplicate values:
		if(~Short_Segment_Flag)
			Vertices_Arr = [Best1(B2(1)).Best_Vertices_Arr]; % An array of vertices *indices*.
			Segments_Arr = [Best1(B2(1)).Best_Segments_Rows_Arr]; % Array of segments' row numbers.			
		else
			Vertices_Arr = [Vertex_Index,Best1(B2(1)).Best_Vertices_Arr]; % An array of vertices *indices*.
			Segments_Arr = [Sr,Best1(B2(1)).Best_Segments_Rows_Arr]; % Array of segments' row numbers.
		end
	end
	
end