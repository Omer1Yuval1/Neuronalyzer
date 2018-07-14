function [branches] = add_segments(branches, Deleted_Segments)
    
    % TODO: find appropriate criteria for determining which branch the segments should be merged with and update function accordingly
    for i = 1: numel(Deleted_Segments)
        vertices = Deleted_Segments(i).Vertices;
        
        indices = find(arrayfun(@(branches) ismember(vertices(1), branches.Vertices), branches));
        
        branches(indices(1)).old_segments = [[branches(indices(1)).old_segments], [Deleted_Segments.Segment_Index]];
    end

end