function branches = construct_branches(Workspace,curvature_threshold)
	
	% returns branches for one image (= Workspace)
	% plot_branches determines whether result is plotted
	
	new_branches_fix = struct('Branch_Index',{},'Segment_Index',{},'Segments_Indices',{},'Vertices',{},'Skeleton_Linear_Coordinates',{},'treated',{});
    
    scores = probability_scores(Workspace,curvature_threshold);
	
	segments_to_merge = merge_candidates(scores);
	[branches_fix, branches] = merge_segments(segments_to_merge,Workspace);
    
    flag = 0;
    while ~sum(isempty(branches)) % keep merging until all branches are "fix"
        count = 0;
        [fix_branches, branches] = merge_branches(branches);
        new_branches_fix = [new_branches_fix, fix_branches];
        
        % assures that the same branch will not occur several times (can happen in different order of merging processes)
        for i = 1:numel(branches)-1
            if length(unique([branches(i).Segments_Indices])) == length(unique([branches(i+1).Segments_Indices]))
                if sum(unique([branches(i).Segments_Indices]) == unique([branches(i+1).Segments_Indices])) == length(unique([branches(i).Segments_Indices]))
                    count = count+1; 
                end
                if count == numel(branches)-1
                    flag = 1;
                    break;
                end
            end
        end
   
        if flag == 1
            new_branches_fix = [new_branches_fix, branches(1)];
            break;
        end       
    end  
    
    branches = [branches_fix, new_branches_fix];
    
    branches = rmfield(branches,'treated');
    branches = rmfield(branches,'Segment_Index');
    
    for i = 1:numel(branches)
        branches(i).Branch_Index = i;
        branches(i).Segments_Indices = unique(branches(i).Segments_Indices);
    end
    
    % TODO: adapt add_segments functions so that deleted segments are merged to the correct branch
    Deleted_Segments = Workspace.Segments(find([Workspace.Segments.Delete] == -1));
	branches = add_segments(branches,Deleted_Segments); 
end