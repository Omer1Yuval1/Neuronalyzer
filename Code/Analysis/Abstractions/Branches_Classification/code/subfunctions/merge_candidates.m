function [scores] = merge_candidates(scores)
    % takes the scores struct and determines which of all possibilites at one vertex will actually be merged
    % => returns updated scores struct where all lines that will not be merged are deleted
    
    for i = 1:numel(scores)
        scores(i).treated = 0;
    end
        
    while any([scores.treated] == 0)
        not_treated = find([scores.treated] == 0);
        
        for vertex = (unique([scores(not_treated).vertex_idx])) % go over all vertices that have not been looked at so far

            merge_options = find([scores(not_treated).vertex_idx] == vertex);

            idx_max = find([scores(not_treated(merge_options)).score] == max([scores(not_treated(merge_options)).score]));
            
            % if two options have the same score choose one of them % TODO: find a good criterion to decide which to choose
            if length(idx_max)>1
                idx_max = idx_max(1);
            end

            segments_to_connect = scores(not_treated(merge_options(idx_max))).segment_idx;
            
            scores(not_treated(merge_options(idx_max))).treated = 1;
            
            seg1 = segments_to_connect(1);
            seg2 = segments_to_connect(2);
            
            % find other options at the vertex apart from that that is already set to be merged
            not_max = find([scores(not_treated(merge_options)).score] ~= max([scores(not_treated(merge_options)).score]));
            
            % make sure every segment is merged only with one other one
            for i = 1:numel(scores(not_treated(merge_options(not_max))))
                segments = scores(not_treated(merge_options(not_max(i)))).segment_idx;
                if any(segments == seg1) || any(segments == seg2)
                    scores(not_treated(merge_options(not_max(i)))).treated = -1;
                end    
            end
        end
        % delete all segments that should not be connected
        scores(find([scores.treated] == -1)) = [];      
    end
end