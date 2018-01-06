function [Vertices_Arr,Segments_Arr] = Map_Branch(Segments1,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1)
	
	Vertices_Arr = Vertex_Index; % An array of vertices *indices*.
	Segments_Arr = find([Segments1.Segment_Index] == Segment_Index); % Array of segments' row numbers.	
	Segments_Arr1 = 0; % Just to get into the while loop.
	
	while(Vertex_Index > 0 && length(Segments_Arr1) > 0) % While not a tip && there are resutls.
	
		[Vertices_Arr1,Segments_Arr1] = ...
			Find_Next_Segments(Segments1,Segment_Index,Vertex_Index,Min_Segment_Length,Angle1,Max_Angle_Diff,Order1,0);
		
		Segments_Arr = [Segments_Arr,Segments_Arr1];
		Vertices_Arr = [Vertices_Arr,Vertices_Arr1];
			
		Vertex_Index = Vertices_Arr(end);
		Segment_Index = Segments1(Segments_Arr(end)).Segment_Index;
		Angle1 = Segments1(Segments_Arr(end)).Line_Angle;
	end
	
end