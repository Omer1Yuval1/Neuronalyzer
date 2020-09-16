function Workspace = Match_Vertex_Rects_To_Segments(Workspace)
	
	% This function matches vertices angles and skeleton segments.
	% It runs at the beginning of the tracing code. These matchings are used as starting points for the tracing.
	% For each vertex it tries to match each angle to a segment (that is known to be connected to this vertex).
	% It then updates the vertices and segments DBs with the matching information.
	
	% Finally, if angle is not matched with any segment, it gets deleted and the vertex order is updated.
	% Also, if a segment is not matched with any angle, it gets deleted as well and its vertices are merged.
	
	% This can either happen if no overlap is detected or if the # of rectangles is smaller than the # of segment.
	% If the order of a vertex is 2, the whole vertex should be deleted and the 2 segment should be merged.
	
	% TODO
		% remove the overlap array.
		% do not remove segments (unless they are too short), but not due to non-overlap.
		
		% 0. When 2 segments are merged (and their mutual vertex is deleted), their other vertices are not yet updated...
			% I should update the segment index in each of remaining vertices.
			
		% 1. %%% unmatched segments (in the case of less rects than segments) are not yet deleted.
		% 2. If there are "tip" segments, their tip vertex should be deleted as well.
		% ****
		
	[Im_Rows,Im_Cols] = size(Workspace.Image0);
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	
	Skel_Angle_Min_Length = round(Workspace.Parameters.Tracing.Skel_Angle_Min_Length); % In pixels.
	Min_Segment_Length = Workspace.Parameters.Tracing.Min_Segment_Length;
	
	for v=1:numel(Workspace.Vertices)
		% disp(v);
		
		Nr = numel(Workspace.Vertices(v).Rectangles);
		
		% This is done in each iteration because segments get deleted:
		Segments_Vertices = [Workspace.Segments.Vertices];
		Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)'];
		
		% Find all the segments that are connected to Vertex_Index v:
		F1 = find(Segments_Vertices(:,1) == Workspace.Vertices(v).Vertex_Index | Segments_Vertices(:,2) == Workspace.Vertices(v).Vertex_Index); % Row numbers of segments.
		
		% Rectangles = Workspace.Vertices(v).Rectangles;
		% S = struct('Segment_Row',{},'Rect_Skel_Dist',{},'Overlaps',{},'Rectangle_Index',{});
		Rect_Skel_Dist = inf(Nr,length(F1)); % [# of rects X # of segments].
		Rect_Skel_Dist_Min = nan(1,Nr); % Indices of minimum values in the rows of Rect_Skel_Dist.
		Overlaps = inf(Nr,length(F1)); % [# of rects X # of segments].
		
		for r=1:Nr % For each rectangle r in vertex v.
			
			Width = Workspace.Vertices(v).Rectangles(r).Width ./ Scale_Factor; % Micrometers to pixels conversion.
			Length = Workspace.Vertices(v).Rectangles(r).Length ./ Scale_Factor; % Micrometers to pixels conversion.
			
			[XV,YV] = Get_Rect_Vector(Workspace.Vertices(v).Rectangles(r).Origin,Workspace.Vertices(v).Rectangles(r).Angle*180/pi,Width,Length,14);
			InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
			[Ay,Ax] = ind2sub([Im_Rows,Im_Cols],InRect1); % Convert linear coordinates to subscripts.
			
			for s=1:length(F1) % For each segment that is connected to Vertex_Index.
				Sv = Workspace.Segments(F1(s)).Skeleton_Linear_Coordinates; % Get the segment's linear coordinates.
				[Sy,Sx] = ind2sub([Im_Rows,Im_Cols],Sv); % Convert linear coordinates to subscripts.
				Ls = sum((sum( [(Sx(2:end) - Sx(1:end-1)).^2 ; (Sy(2:end) - Sy(1:end-1)).^2] )).^0.5); % Segment arc-length.
				Np = length(Sv); % Number of skeleton pixels.
				
				if(Ls < Min_Segment_Length) % For short segments, use the skeleton to determine the vertex angle.
					Lr = min([Np,Skel_Angle_Min_Length]);
					
					if(Workspace.Segments(F1(s)).Vertices(1) == Workspace.Vertices(v).Vertex_Index)
						O = [Sx(1),Sy(1)]; % Origin.
						a = mod(atan2(mean(Sy(1:Lr)) - Sy(1) , mean(Sx(1:Lr)) - Sx(1)),2*pi);
					elseif(Workspace.Segments(F1(s)).Vertices(2) == Workspace.Vertices(v).Vertex_Index) % If it's the 2nd vertex, flip the coordinates order.
						O = [Sx(end),Sy(end)]; % Origin.
						a = mod(atan2(mean(Sy(end-Lr+1:end)) - Sy(end) , mean(Sx(end-Lr+1:end)) - Sx(end)),2*pi);
					end
					
					Rect_Skel_Dist(r,s) = 0; % Since the skeleton is used to determine the angle, the rect-skel distance is set to 0.
					
					% Update the vertex rectangle details:
					Workspace.Vertices(v).Rectangles(r).Origin = O;
					Workspace.Vertices(v).Rectangles(r).Angle = a;
					Workspace.Vertices(v).Rectangles(r).Width = 1 .* Scale_Factor;
					Workspace.Vertices(v).Rectangles(r).Length = Lr .* Scale_Factor;
				else
					% Find the minimal distance between each of the vertex rectangle pixels and the current segment (its skeleton pixels):
					D = ( (Ax - Sx').^2 + (Ay - Sy').^2 ).^0.5;
					D = min(D,[],1); % Minimum across segment pixels.
					
					Rect_Skel_Dist(r,s) = mean(D); % Mean distance of rectangle r from segment s.
					Overlaps(r,s) = length(find(D == 0)); % Number of overlapping points.
				end
				
				if(0 && Workspace.Vertices(v).Vertex_Index == 57)
					hold on;
					plot(XV,YV);
					hold on;
					if(1 || Workspace.Segments(F1(s)).Segment_Index == 58)
						plot(Sx,Sy,'.r');
					end
				end
			end
			
			Rect_Skel_Dist_Min(r) = find(Rect_Skel_Dist(r,:) == min(Rect_Skel_Dist(r,:)),1);
			
		end % This loop generates a matrix (Rect_Skel_Dist) of rect-segment min distances.
		
		% Find the optimal rect-segment matches:
		[Workspace.Vertices(v).Rectangles.Segment_Index] = deal(nan); % Reset all values to nan.
		[Workspace.Vertices(v).Rectangles.Segment_Row] = deal(nan); % Reset all values to nan.
		
		if(length(unique(Rect_Skel_Dist_Min)) == length(Rect_Skel_Dist_Min) || length(Rect_Skel_Dist_Min) == 1) % If all segment indices are different for different vertex rectangles OR if a it's tip.
			for r=1:Nr % For each rectangle r in vertex v.
				s = Rect_Skel_Dist_Min(r);
				Workspace.Vertices(v).Rectangles(r).Segment_Index = Workspace.Segments(F1(s)).Segment_Index;
				Workspace.Vertices(v).Rectangles(r).Segment_Row = F1(s);
			end
		else
			disp('Error matching vertex rectangles to segments (Match_Vertex_Rects_To_Segments.m)');
		end
end