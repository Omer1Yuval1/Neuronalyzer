function [Segments_Reduced,Vertices_Reduced] = Reduce_Connectivity(Workspace,Length_Threshold)
	
	% Length_Threshold is in micrometers.
	
	Segments_Reduced = Workspace.Segments; % A copy of the segments DB that will be used to make temporary changes (exclude nonrelevant segments).
	Vertices_Reduced = Workspace.Vertices; % A copy of the segments DB that will be used to make temporary changes (exclude nonrelevant segments).
	
	Segments_Vertices = [Workspace.Segments.Vertices];
	Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)']; % [v1,v2].
	
	f1 = find([Workspace.Segments.Length] < Length_Threshold); % Find short segments.
	for i=1:length(f1) % Exclude short segments and merge their vertices.
		Segments_Reduced(f1(i)).Segment_Index = -1; % Mark for deletion.
		
		v1 = find([Workspace.Vertices.Vertex_Index] == Segments_Reduced(f1(i)).Vertices(1)); % Find the row# of the 1st vertex.
		v2 = find([Workspace.Vertices.Vertex_Index] == Segments_Reduced(f1(i)).Vertices(2)); % Find the row# of the 2nd vertex.
		
		if(Workspace.Vertices(v1).Order == -1) % v1 is a tip.
			% No need to add the rectnalges to v2.
		elseif(Workspace.Vertices(v2).Order == -1) % v2 is a tip.
			% No need to add the rectnalges to v1.
		else % No tips.
			Vertices_Reduced(v1).Rectangles = [Vertices_Reduced(v1).Rectangles ; Vertices_Reduced(v2).Rectangles]; % Merge the rectangles struct.
			
			f2 = find([Vertices_Reduced(v1).Rectangles.Segment_Index] == Segments_Reduced(f1(i)).Segment_Index);
			Vertices_Reduced(v1).Rectangles(f2) = []; % Delete the two rectangles that belong to that segment.
			Vertices_Reduced(v1).Order = numel(Vertices_Reduced(v1).Rectangles); % Update the vertex order.
			
			f2A = find([Segments_Vertices(:,1)] == Vertices_Reduced(v2).Vertex_Index); % Find v2 in the 1st vertices column.
			f2B = find([Segments_Vertices(:,2)] == Vertices_Reduced(v2).Vertex_Index); % Find v2 in the 2nd vertices column.
			for j=1:length(f2A)
				Segments_Reduced(f2A(j)).Vertices(1) = v1; % Update the connectivity in the Segments DB. Replace every occurance of v2 with v1.
			end
			for j=1:length(f2B)
				Segments_Reduced(f2B(j)).Vertices(2) = v1; % Update the connectivity in the Segments DB. Replace every occurance of v2 with v1.
			end
			
			Vertices_Reduced(v2).Vertex_Index = -1; % Mark for the deletion.
		end
	end
	
end