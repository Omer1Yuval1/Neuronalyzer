function Data = Match_Vertex_Rects_To_Segments_Skel(Data)
	
	% This function matches vertices angles and skeleton segments.
	% It runs at the beginning of the tracing code. These matchings are used as starting points for the tracing.
	% For each vertex it tries to match each angle to a segment (that is known to be connected to this vertex).
	% It then updates the vertices and segments DBs with the matching information.
	
	[Im_Rows,Im_Cols] = size(Data.Info.Files(1).Raw_Image);
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor; % Data.User_Input.Scale_Factor;
	
	Skel_Angle_Min_Length = round(Data.Parameters.Tracing.Skel_Angle_Min_Length); % In pixels.
	Min_Segment_Length = Data.Parameters.Tracing.Min_Segment_Length;
	
	Segments_Vertices = [Data.Segments.Vertices];
	Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)'];
	
	for v=1:numel(Data.Vertices)
        
		Data.Vertices(v).Rectangles = struct('Origin',{},'Angle',{},'Width',{},'Length',{},'Segment_Index',{},'Segment_Row',{});
		
		% Find all the segments that are connected to Vertex_Index v:
		F1 = find(Segments_Vertices(:,1) == Data.Vertices(v).Vertex_Index | Segments_Vertices(:,2) == Data.Vertices(v).Vertex_Index); % Row numbers of segments.
		Nr = Data.Vertices(v).Order; % This should be equal to length(F1).
		
		% for r=1:Nr % For each rectangle r in vertex v.
			
			for s=1:length(F1) % For each segment that is connected to Vertex_Index.
				Sv = Data.Segments(F1(s)).Skeleton_Linear_Coordinates; % Get the segment's linear coordinates.
				[Sy,Sx] = ind2sub([Im_Rows,Im_Cols],Sv); % Convert linear coordinates to subscripts.
				
				Np = length(Sv); % Number of skeleton pixels.
				
				Lr = min([Np,Skel_Angle_Min_Length]);
				
				if(Data.Segments(F1(s)).Vertices(1) == Data.Vertices(v).Vertex_Index)
					O = [Sx(1),Sy(1)]; % Origin.
					a = mod(atan2(mean(Sy(1:Lr)) - Sy(1) , mean(Sx(1:Lr)) - Sx(1)),2*pi);
				elseif(Data.Segments(F1(s)).Vertices(2) == Data.Vertices(v).Vertex_Index) % If it's the 2nd vertex, flip the coordinates order.
					O = [Sx(end),Sy(end)]; % Origin.
					a = mod(atan2(mean(Sy(end-Lr+1:end)) - Sy(end) , mean(Sx(end-Lr+1:end)) - Sx(end)),2*pi);
				end
				
				% Update the vertex rectangle details:
				Data.Vertices(v).Rectangles(s).Origin = O;
				Data.Vertices(v).Rectangles(s).Angle = a;
				Data.Vertices(v).Rectangles(s).Width = 1 .* Scale_Factor; % Setting the width to 1 pixel as an initial value when using the skeleton.
				Data.Vertices(v).Rectangles(s).Length = 1 .* Scale_Factor;% ".
				
				Data.Vertices(v).Rectangles(s).Segment_Index = Data.Segments(F1(s)).Segment_Index;
				Data.Vertices(v).Rectangles(s).Segment_Row = F1(s);
                
                % O1 = [O(1)+3*cos(a),O(2)+3*sin(a)]; hold on; plot([O(1),O1(1)],[O(2),O1(2)],'LineWidth',3);
			end
		% end
	end
end