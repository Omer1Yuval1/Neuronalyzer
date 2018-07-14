function scores = probability_scores(Workspace,curvature_threshold)
    
    % finds all segments that share a vertex and calculates scores for all
    % pairs that could be possibly merged
    % returns: scores struct which lists the compared features, their
    % single probabilies and the total resulting score
    
    Segments = Workspace.Segments;
    Vertices = Workspace.Vertices;
  
    scores = struct('segment_idx',{},'vertex_idx',{},'probabilities',{},'score',{});
    
    % order: angle at vertex, average vertex angle + chunk orientation, width at vertex
    weight_vector = [0,1,0];
    probability = [0,0,0];       
    
    for i=1:numel(Vertices) 
        segments = []; % iterate over vertices and save all segments that share this vertex
        for j=1:numel(Segments)
            vertices = [Segments(j).Vertices];
            if vertices(1) == Vertices(i).Vertex_Index || vertices(2) == Vertices(i).Vertex_Index
                segments = [segments,Segments(j).Segment_Index];         
            end
        end
        
        % skip vertices with missing segments (should be possible to remove this part after DB is updated)
        if Vertices(i).Order == 3 && numel(Vertices(i).Rectangles) == 2 
            continue;
        end
        
        if length(segments)>=2
                combos = nchoosek(segments,2); % all possible combinations
                
            combo_size = size(combos);
            begin = numel(scores)+1;
            stop = numel(scores)+combo_size(1);
            
            % [number of combinations that will be added to the scores
            % list; indices of where to start adding new values and total
            % size at the end
            V = [1:combo_size(1); begin:1:stop];

            for iv=V %iv(1) = number of combinations; iv(2) for indexing
                
                % the pair of segments that is looked at
                combination = combos(iv(1), :);

                idx_seg1 = find([Segments.Segment_Index] == combination(1));
                idx_seg2 = find([Segments.Segment_Index] == combination(2));  
                
                idx_vertex_seg1 = find([Segments(idx_seg1).Vertices] == Vertices(i).Vertex_Index);
                idx_vertex_seg2 = find([Segments(idx_seg2).Vertices] == Vertices(i).Vertex_Index);
                
                % calculate end2end orientation for segment chunks
                Segments = calculate_chunk(Segments,Vertices,idx_seg1,curvature_threshold);
                Segments = calculate_chunk(Segments,Vertices,idx_seg2,curvature_threshold);      
                
                % always choose the orientation pointing out of the vector
                if idx_vertex_seg1 == 2
                    orientation1 = Segments(idx_seg1).End2End_Orientation2;
                else
                    orientation1 = Segments(idx_seg1).End2End_Orientation1;
                end
                
                if idx_vertex_seg2 == 2
                    orientation2 = Segments(idx_seg2).End2End_Orientation2;
                else
                    orientation2 = Segments(idx_seg2).End2End_Orientation1;
                end             
                
                % find vertex angles and widths at vertex
                rectangle1 = find([Vertices(i).Rectangles.Segment_Index] == combination(1));
                rectangle2 = find([Vertices(i).Rectangles.Segment_Index] == combination(2));        
				
                if ~isempty(rectangle1) && ~isempty(rectangle2)
                    
                    angle1 = Vertices(i).Rectangles(rectangle1).Angle;
                    angle2 = Vertices(i).Rectangles(rectangle2).Angle;
                    
                    % use only vertex angle if chunk is too short
                    if isempty(orientation1)
                        orientation1 = angle1;
                    end
                    if isempty(orientation2)
                        orientation2 = angle2;
                    end
                    
                    % aligned rectangles correspond to a difference of pi 
                    angle_difference = (max(angle1, angle2)-min(angle1, angle2));
                    probability(1) = sin(angle_difference/2);                      
                          
                    % probability using chunk orientation and vertex angle average
                    new_angle1 = (angle1 + orientation1)/2; 
                    new_angle2 = (angle2 + orientation2)/2;
                    
                    new_difference = max(new_angle1, new_angle2) - min(new_angle1, new_angle2);
                    probability(2) = sin(new_difference/2);
                    
                    % compare the rectangles' width:
                    width1 = Vertices(i).Rectangles(rectangle1).Width;
                    width2 = Vertices(i).Rectangles(rectangle2).Width;
                    probability(3) = min(width1, width2)/max(width1, width2); 
                end
              
                % write results to scores struct
                scores(iv(2)).angle_average = [new_angle1, new_angle2];
                scores(iv(2)).vertex_angle = [angle1, angle2];
                scores(iv(2)).chunk_orientation = [orientation1, orientation2];
                scores(iv(2)).vertex_idx = Vertices(i).Vertex_Index;
                scores(iv(2)).segment_idx = combination;
                scores(iv(2)).probabilities = probability;
                scores(iv(2)).score = dot(weight_vector, probability);
            end
        end
    end         
end