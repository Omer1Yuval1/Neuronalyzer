function [new_branches_fix,new_branches] = merge_branches(branches)
    % merges all branches that have common segments (first iteration) or branches (following iterations)
    % returns the merged branches and the branches that cannot be merged any more in separate struct
    % (idea is the same as in merge_segments)

    new_branches = struct('Branch_Index',{},'Segment_Index',{}, 'Segments_Indices', {}, 'Vertices', {}, 'Skeleton_Linear_Coordinates', {}, 'treated', {});
    new_branches_fix = struct('Branch_Index',{},'Segment_Index',{}, 'Segments_Indices', {}, 'Vertices', {}, 'Skeleton_Linear_Coordinates', {}, 'treated', {});
    
    % segments (first iteration) or branches that are going to be merged
    occuring_segments = unique([branches.Segment_Index]);
    
    multiple_idx = find((hist([branches.Segment_Index], [occuring_segments])>1));
    
    % segments that occur in at least two branches
    common_segments = occuring_segments(multiple_idx);
    
    % get the branches that have no common segment with any other branch
    missing_segments = [];
    for i = 1:numel(branches)
        segments = branches(i).Segment_Index;
        if ~sum(ismember(common_segments, segments(1))) && ~sum(ismember(common_segments, segments(2))) %sum to get logical scalar value
            missing_segments = [missing_segments, i];
        end
    end
    
    for missing_segment = missing_segments
        new_branches_fix = [new_branches_fix, branches(missing_segment)];
    end
    
    
     for j = 1:length(common_segments) 
       
        common_segment = common_segments(j);     
        indices = find(arrayfun(@(branches) ismember(common_segment, branches.Segment_Index), branches));
        
        coordinates = {};
        commons = {};
              
        % save results
        for i = 1:length(indices)
            idx = indices(i);
            if i==1
                new_branches(j).Segment_Index = [branches(idx).Branch_Index]; % "the branches are the new segments"
            else 
                new_branches(j).Segment_Index = [new_branches(j).Segment_Index, branches(idx).Branch_Index];
            end
            new_branches(j).Segments_Indices = [new_branches(j).Segments_Indices, branches(idx).Segments_Indices];
            new_branches(j).Vertices = [new_branches(j).Vertices, branches(idx).Vertices];
        end
        
        % assure common segment coordinates are not saved two times 
        new_branches(j).Branch_Index = j;
     end
end