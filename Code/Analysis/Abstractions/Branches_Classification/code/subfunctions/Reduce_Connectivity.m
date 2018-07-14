function Workspace = Reduce_Connectivity(Workspace,Length_Threshold)
	
	% Length_Threshold is in micrometers.
	
	Segments_Reduced = Workspace.Segments; % A copy of the segments DB that will be used to make temporary changes (exclude nonrelevant segments).
	Vertices_Reduced = Workspace.Vertices; % A copy of the Vertices DB that will be used to make temporary changes (exclude nonrelevant segments).
	
	[Vertices_Reduced.Delete] = deal(0);
	[Segments_Reduced.Delete] = deal(0);
        
    f1 = find([Workspace.Segments.Length] < Length_Threshold); % Find short segments.
	
	for i=f1 % For each short segment. Exclude short segments and merge their vertices.
		Segments_Vertices = [Segments_Reduced.Vertices];
		Segments_Vertices = [Segments_Vertices(1:2:end)', Segments_Vertices(2:2:end)']; % [v1,v2].
		
		% Find the row numbers of the two vertices connected by the i-th segment:
		v1 = find([Vertices_Reduced.Vertex_Index] == Segments_Reduced(i).Vertices(1)); % 1st vertex.
		v2 = find([Vertices_Reduced.Vertex_Index] == Segments_Reduced(i).Vertices(2)); % 2nd vertex.         
		
		if(Vertices_Reduced(v1).Order > 1 && Vertices_Reduced(v2).Order > 1) % If neither v1 nor v2 is a tip.
			Vertices_Reduced(v1).Rectangles = [Vertices_Reduced(v1).Rectangles , Vertices_Reduced(v2).Rectangles]; % Merge the rectangles structs into v1's.
            
            f2 = find([Vertices_Reduced(v1).Rectangles.Segment_Index] == Segments_Reduced(i).Segment_Index); % Find the row numbers of the rectangles that correspond to segment i within the merged rectangles struct.
			Vertices_Reduced(v1).Rectangles(f2) = []; % Delete the two rectangle entries that belong to the i-th segment.
			Vertices_Reduced(v1).Order = numel(Vertices_Reduced(v1).Rectangles); % Update the vertex order.
			
            f2A = find([Segments_Vertices(:,1)] == Vertices_Reduced(v2).Vertex_Index); % Find v2 in the 1st vertices column.
            f2B = find([Segments_Vertices(:,2)] == Vertices_Reduced(v2).Vertex_Index); % Find v2 in the 2nd vertices column.
			
			% assignin('base','Vertices_Reduced',Vertices_Reduced);
            % assignin('base','Segments_Reduced',Segments_Reduced);
            
			% Replace every occurance of v2 in the segments DB with v1:
			for j=1:length(f2A)
                Segments_Reduced(f2A(j)).Vertices(1) = Segments_Reduced(i).Vertices(1);
			end
			for j=1:length(f2B)
				Segments_Reduced(f2B(j)).Vertices(2) = Segments_Reduced(i).Vertices(1); % Update the connectivity in the Segments DB. Replace every occurance of v2 with v1.
			end
			
			% Mark v2 for deletion in the vertices DB (but only if v2~=v1):
			if(v2 ~= v1)
				Vertices_Reduced(v2).Delete = 1; % Mark for the deletion. 
			end
			Segments_Reduced(i).Delete = 1; % Mark the i-th segment for deletion.
        end
    end
	
	% Delete the excluded segments and vertices:
	Vertices_Reduced(find([Vertices_Reduced.Delete] == 1)) = [];
	Segments_Reduced(find([Segments_Reduced.Delete] == 1)) = [];
	% Deleted_Segments = Segments_Reduced(find([Segments_Reduced.Delete] == 1));
	
	Workspace.Segments = Segments_Reduced;
	Workspace.Vertices = Vertices_Reduced;
end