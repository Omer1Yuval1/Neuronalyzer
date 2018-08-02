function scores = probability_scores(Workspace,curvature_threshold)
    
    % This function computes for each junction the score for each possible pair of segments to be merged.
    % returns: scores struct which lists the compared features, their
    % single probabilies and the total resulting score
    
	Segments = Workspace.Segments;
	Vertices = Workspace.Vertices;
	
    scores = struct('Branch_Index',{},'Segment_Index_1',{},'Segment_Index_2',{},'Score',{});

	% order: angle at vertex, average vertex angle + chunk orientation, width at vertex
	weight_vector = [0,1,0]; % [Local_Angle_Score , Segment_Chunk_Orientation , Segment_Width].
	probability = [0,0,0];       
    
	V = [Segments.Vertices];
	V1 = V(1:2:end-1);
	V2 = V(2:2:end);
	
    for i=1:numel(Vertices) 
        
		Sr = find(V1 == Vertices(i).Vertex_Index | V2 == Vertices(i).Vertex_Index); % Row numbers of segments connected to the i-th vertex.
		Si = [Segments(Sr).Segment_Index]; % Indices of segments connected to the i-th vertex.
		
        % Remove: Skip vertices with missing segments (should be possible to remove this part after DB is updated)
		if(abs(Vertices(i).Order) ~= numel(Vertices(i).Rectangles))
			% disp(['Vertex order does not match the number rectangles. Index = ',num2str(i)]);
			continue;
		elseif(length(Sr) > 1)
			Cr = nchoosek(Sr,2); % All possible pairs of row numbers.
			Ci = nchoosek(Si,2); % All possible pairs of indices.
			% disp(2);
			for p=1:size(Cr,1)
				
				Pr = Cr(p,:); % The current pair of segments (row numbers).
				Pi = Ci(p,:); % The current pair of segments (row numbers).
				
				idx_vertex_seg1 = find([Segments(Pr(1)).Vertices] == Vertices(i).Vertex_Index);
				idx_vertex_seg2 = find([Segments(Pr(2)).Vertices] == Vertices(i).Vertex_Index);
				
				% Calculate end2end orientation for segment chunks:
				Segments = calculate_chunk(Segments,Vertices,Pr(1),curvature_threshold);
				Segments = calculate_chunk(Segments,Vertices,Pr(2),curvature_threshold);      
				
				% Always choose the orientation pointing out of the vector
				if(idx_vertex_seg1 == 2)
					orientation1 = Segments(Pr(1)).End2End_Orientation2;
				else
					orientation1 = Segments(Pr(1)).End2End_Orientation1;
				end
				
				if(idx_vertex_seg2 == 2)
					orientation2 = Segments(Pr(2)).End2End_Orientation2;
				else
					orientation2 = Segments(Pr(2)).End2End_Orientation1;
				end             
				
				% Find vertex angles and widths at vertex:
				rectangle1 = find([Vertices(i).Rectangles.Segment_Index] == Pi(1));
				rectangle2 = find([Vertices(i).Rectangles.Segment_Index] == Pi(2));        
				
				if(~isempty(rectangle1) && ~isempty(rectangle2))
					
					angle1 = Vertices(i).Rectangles(rectangle1).Angle;
					angle2 = Vertices(i).Rectangles(rectangle2).Angle;
					
					% Use the vertex angle only if the chunk is short enough:
					if(isempty(orientation1))
						orientation1 = angle1;
					end
					if(isempty(orientation2))
						orientation2 = angle2;
					end
					
					% Aligned rectangles correspond to a difference of pi:
					angle_difference = (max(angle1,angle2)-min(angle1,angle2));
					probability(1) = sin(angle_difference/2);                      
					
					% Probability using chunk orientation and vertex angle average
					new_angle1 = (angle1 + orientation1)/2; 
					new_angle2 = (angle2 + orientation2)/2;
					
					new_difference = max(new_angle1,new_angle2) - min(new_angle1,new_angle2);
					probability(2) = sin(new_difference/2);
					
					% Compare the rectangles' width:
					width1 = Vertices(i).Rectangles(rectangle1).Width;
					width2 = Vertices(i).Rectangles(rectangle2).Width;
					probability(3) = min(width1,width2)/max(width1,width2); 
				end
				
				% Write results to the scores struct:				
				scores(end+1).Segment_Index_1 = Pi(1);
				scores(end).Segment_Index_2 = Pi(2);
				scores(end).Segments = Pi;
				scores(end).Vertices = Vertices(i).Vertex_Index;
				scores(end).Probabilities = probability;
				scores(end).Score = dot(weight_vector,probability);
				
				scores(end).angle_average = [new_angle1,new_angle2];
				scores(end).vertex_angle = [angle1,angle2];
				scores(end).chunk_orientation = [orientation1,orientation2];
			end
		else
			% disp(3);
		end
		
		% Also add options for individual segments:
		for j=1:length(Si)
			scores(end+1).Segment_Index_1 = Si(j);
			scores(end).Segment_Index_2 = 0;
			scores(end).Segments = Si(j);
			scores(end).Vertices = Vertices(i).Vertex_Index;
			scores(end).Probabilities = 0;
			scores(end).Score = 0;
		end
	end
end