function Workspace = Detect_Primary_Branch(Workspace,CB_Distance_Threshold)
	
	% This function detects the 1st order branches (also called "primary branches").
	% These are two of the branches that are connected to cell body.
	
	[Workspace.CB.Vertices.Vertices_Indices] = deal([]);
	CB_Vertices = [];
	
	% Match vertices with CB vertices:
	for c=1:numel(Workspace.CB.Vertices) % For each CB vertex.
        for v=1:numel(Workspace.Vertices)
            D = ( (Workspace.CB.Vertices(c).Coordinate(1) - Workspace.Vertices(v).Coordinate(1)).^2 + ...
					(Workspace.CB.Vertices(c).Coordinate(2) - Workspace.Vertices(v).Coordinate(2)).^2 )^.5;
			
			if(D <= CB_Distance_Threshold)
				Workspace.CB.Vertices(c).Vertices_Indices(end+1) = Workspace.Vertices(v).Vertex_Index;
				CB_Vertices(end+1) = Workspace.Vertices(v).Vertex_Index;
			end
		end
	end
	
	for b=1:numel(Workspace.Branches)
		if(intersect(Workspace.Branches(b).Vertices,CB_Vertices))
			Workspace.Branches(b).Order = 1;
		end
	end
	
	F1 = find([Workspace.Branches.Order] == 1);
	[~,I] = sort([Workspace.Branches(F1).Length],'descend'); % Sort in ascending order.
	
	F1 = F1(I);
	if(length(F1) > 2)
		[Workspace.Branches(F1(3:end)).Order] = deal(2); % Set the non-1st order branches to 2.
	end
	
end