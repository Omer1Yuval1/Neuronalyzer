function [Segments] = calculate_chunk(Segments,Vertices,idx,curvature_threshold)
        % adds the chunk orientation and curvature to the Segments struct

        Segments(idx).End2End_Orientation1 = [];
        Segments(idx).End2End_Orientation2 = [];        
        
        vertices = Segments(idx).Vertices;
        
        % find coordinates of first vertex
        coordinates1 = Vertices([Vertices.Vertex_Index] == vertices(1)).Coordinate;        
        
        % assure that coordinates go from first vertex to second vertex
        if (Segments(idx).Skel_X(1) - coordinates1(1)) > (Segments(idx).Skel_X(end) - coordinates1(1))
            Segments(idx).Skel_Y = fliplr(Segments(idx).Skel_Y);
            Segments(idx).Skel_X = fliplr(Segments(idx).Skel_X);
        end
        
        Segments(idx).Curve = Get_Segment_Curvature(Segments(idx).Skel_X,Segments(idx).Skel_Y);
        
        Fc = find([Segments(idx).Curve] > curvature_threshold);
        if(~isempty(Fc))
            
            j = Fc(1); % index of first value above curvature_threshold starting from vertex1
            l = Fc(end); % index of first value above curvature_threshold starting from vertex2
      
            x_vertex1 = Segments(idx).Skel_X(1:j); 
            y_vertex1 = Segments(idx).Skel_Y(1:j);
            
            % change direction for second vertex so that angle is pointing out of vertex
            if j == numel(Segments(idx).Curve)
                x_vertex2 = fliplr(x_vertex1);
                y_vertex2 = fliplr(y_vertex1);
            else
                x_vertex2 = fliplr(Segments(idx).Skel_X(l:end));
                y_vertex2 = fliplr(Segments(idx).Skel_Y(l:end));
            end
            
            Segments(idx).End2End_Orientation2 = atan2((y_vertex2(end)-y_vertex2(1)),(x_vertex2(end)-x_vertex2(1)));
            Segments(idx).End2End_Orientation1 = atan2((y_vertex1(end)-y_vertex1(1)),(x_vertex1(end)-x_vertex1(1)));      
        end      
        
        % assure that end2end orientation is in the range of 0 to 2pi
        if Segments(idx).End2End_Orientation1 < 0 
            Segments(idx).End2End_Orientation1 = Segments(idx).End2End_Orientation1 + 2 * pi;
        end 
        
        if Segments(idx).End2End_Orientation2 < 0 
            Segments(idx).End2End_Orientation2 = Segments(idx).End2End_Orientation2 + 2 * pi;
        end 
end