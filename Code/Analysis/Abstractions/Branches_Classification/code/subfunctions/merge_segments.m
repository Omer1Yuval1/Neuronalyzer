function [branches_fix, branches] = merge_segments(scores,Workspace)
    % merges the segments that are indicated to merge in the scores struct
    % keeps the segments that form a branch on their own in the separate branches_fix struct

    branches = struct('Branch_Index',{},'Segment_Index',{}, 'Segments_Indices', {}, 'Vertices', {}, 'Skeleton_Linear_Coordinates', {}, 'treated', {});
    % all the branches that will not be merged as they don't contain common segments with other ones any more
    branches_fix = struct('Branch_Index',{},'Segment_Index',{}, 'Segments_Indices', {}, 'Vertices', {}, 'Skeleton_Linear_Coordinates', {}, 'treated', {});    
    
    Segments = Workspace.Segments;
    
    % segments that are going to be merged
    occuring_segments = unique([scores.segment_idx]);
    
    % segments that have no vertices in common    
    missing_segments = times(double(~ismember([Segments.Segment_Index],occuring_segments)), [Segments.Segment_Index]);
    missing_segments = missing_segments(find(missing_segments ~= 0));
    
    % write the segments that are not merged to a separate struct
    for i = 1:numel(missing_segments)
        idx = find([Segments.Segment_Index] == missing_segments(i));
        branches_fix(i).Segment_Index = missing_segments(i);
        branches_fix(i).Segments_Indices = missing_segments(i);
        branches_fix(i).Vertices = Segments(idx).Vertices;
    end
       
    for i = 1:numel(scores)
        segments = scores(i).segment_idx;
        segment1 = segments(1);
        segment2 = segments(2);
        
        idx1 = find([Segments.Segment_Index] == segment1);
        idx2 = find([Segments.Segment_Index] == segment2);
        
        % write results to branches struct
        branches(i).Branch_Index = i;
        branches(i).Segment_Index = [Segments(idx1).Segment_Index, Segments(idx2).Segment_Index];
        branches(i).Segments_Indices = branches(i).Segment_Index;
        branches(i).Vertices = [Segments(idx1).Vertices, Segments(idx2).Vertices];  
    end
end