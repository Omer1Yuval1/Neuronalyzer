function Workspace = Match_Vertex_Rects_To_Segments(Workspace)
	
	% This function matches vertices angles and skeleon segments.
	% It runs at the begining of the tracing code. These matchings are used as starting point for the tracing.
	% For each vertex it tries to match each angle to a segment (that is known to be connected to this vertex).
	% It then updates the vertices and segments DBs with the matching information.
	% Finally, if angle is not matched with any segment, it gets deteled and the vertex order is updated.
	% Also, if a segment is not matched with any angle, it gets deleted as well and its vertices are merged.
	% This can either happen if no overlap is detected or if the # of rectangles is smaller than the # of segment.
	% If the order of a vertex is 2, the whole vertex should be deleted and the 2 segment should be merged.
	
	% TODO:
		% 0. When 2 segments are merged (and their mutual vertex is deleted), their other vertices are not yet updated.
			% I should update the segment index in each of remaining vertices.
		% 1. %%% unmatched segments (in the case of less rects than segments) are not yet deleted.
		% 2. If there are "tip" segments, their tip vertex should be deleted as well.
		% ****
		
	% Consider implementing somewhere else:
		% The angles of short segments are determined by their end2end orientation (and not the vertices angle).
		% This should happen in the vertices angles code.
		% Look at vertex i=114 to validate.
		
	[Im_Rows,Im_Cols] = size(Workspace.Image0);
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	
	for v=1:numel(Workspace.Vertices)
		% disp(v);
		
		% This is done in each iteration because segments get deleted:
		Segments_Vertices = [Workspace.Segments.Vertices];
		Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)'];
		
		% Find all the segments that are connected to Vertex_Index:
		F1 = find(Segments_Vertices(:,1) == Workspace.Vertices(v).Vertex_Index | ...
				Segments_Vertices(:,2) == Workspace.Vertices(v).Vertex_Index);
		
		Rectangles = Workspace.Vertices(v).Rectangles;
		% S = struct('Segment_Row',{},'Min_Distances',{},'Overlaps',{},'Rectangle_Index',{});
		Min_Distances = zeros(numel(Rectangles),length(F1));
		Overlaps = zeros(numel(Rectangles),length(F1));
		
		for r=1:numel(Rectangles) % For each rectnalge r in vertex v.
			
			Width = Rectangles(r).Width ./ Scale_Factor; % Micrometers to pixels conversion.
			Length = Rectangles(r).Length ./ Scale_Factor; % Micrometers to pixels conversion.
			
			[XV,YV] = Get_Rect_Vector(Rectangles(r).Origin,Rectangles(r).Angle*180/pi,Width,Length,14);
			InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
			[Ay,Ax] = ind2sub([Im_Rows,Im_Cols],InRect1); % Convert linear coordinates to subscripts.

			for s=1:length(F1) % For each segment that is connected to Vertex_Index.
				Sv = Workspace.Segments(F1(s)).Skeleton_Linear_Coordinates; % Get the segment's linear coordinates.
				[Sy,Sx] = ind2sub([Im_Rows,Im_Cols],Sv); % Convert linear coordinates to subscripts.
				
				% Find the minimal distance between each of the vertex r-angle pixels and the current segment (its skeleton pixels):
				D = zeros(1,length(Ax));
				for a=1:length(Ax)
					D(a) = min(( (Ax(a) - Sx).^2 + (Ay(a) - Sy).^2 ).^0.5); % Minimal distance between pixel [Ax(a),Ay(a)] and the segment.
				end
				%%% S(s).Segment_Index = Workspace.Segments(F1(s)).Segment_Index;
				% S(s).Segment_Row = F1(s);
				% S(s).Min_Distances(r) = mean(D); % Mean distance of rectangle r from segment s.
				% S(s).Overlaps(r) = length(find(D == 0)); % Number of overlapping points.
				% disp(D);
				
				Min_Distances(r,s) = mean(D); % Mean distance of rectangle r from segment s.
				Overlaps(r,s) = length(find(D == 0)); % Number of overlapping points.;
				
				%%% if(v == 113)
				% if(Workspace.Vertices(v).Vertex_Index == 136)
					% hold on;
					% plot(XV,YV);
					% hold on;
					% plot(Sx,Sy,'.r');
				% end
			end
		end
		% if(Workspace.Vertices(v).Vertex_Index == 134)
            % disp(222);
        % end
		% TODO: the initial values for the distance are 0. not a good idea...mmm why??
		% Find the optimal rect-segment matches:
		[Workspace.Vertices(v).Rectangles.Segment_Index] = deal(0); % Reset all values to 0 (not a possible segment index).
		[Workspace.Vertices(v).Rectangles.Segment_Row] = deal(0); % Reset all values to 0 (not a possible segment index).
		M = max(Min_Distances(:)) + 1; % Save the max distance +1 to mark chosen segment and avoid them in the next iterations.
		for r=1:numel(Rectangles) % For each rectnalge r in vertex v.
			f1 = find([Overlaps(r,:)] == max([Overlaps(r,:)]));
			if(length(f1) == 1) % If only one best match.
				Workspace.Vertices(v).Rectangles(r).Segment_Index = Workspace.Segments(F1(f1)).Segment_Index;
				Workspace.Vertices(v).Rectangles(r).Segment_Row = F1(f1);
			else % Use the mean distance to determine the best match.
				f1 = find([Min_Distances(r,:)] == min([Min_Distances(r,:)])); % Taking 'abs' to avoid the (-1).
				% Note: in case there are 2+ minimal distances, just take the 1st.
				Workspace.Vertices(v).Rectangles(r).Segment_Index = Workspace.Segments(F1(f1(1))).Segment_Index;
				Workspace.Vertices(v).Rectangles(r).Segment_Row = F1(f1(1));
				if(length(f1) > 1)
					disp('I found multiple minimal distance values (in "Match_Vertex_Rects_To_Segments")');
				end
			end
			Overlaps(:,f1(1)) = -1; % Set to (-1) all the values of the chosen segment so it won't be taken into account in the next iterations.
			Min_Distances(:,f1(1)) = M; % ...Assuming (-1) is always below the minimum (since the minimum overlap or distance is 0).
		end
		
		% Delete unmatched rectangles (marked as Segment_Index=0):
		Workspace.Vertices(v).Rectangles(find([Workspace.Vertices(v).Rectangles.Segment_Index] == 0)) = [];
		
		% if(Workspace.Vertices(v).Vertex_Index == 134)
			% disp(111);
		% end
		
		% **** TODO: counting the number of rects doesn't make sense. I have to count the number of matches.
		if(numel(Workspace.Vertices(v).Rectangles) < length(F1)) % If the # of rects is smaller than the # of segment connected to vertex v.
			Workspace.Vertices(v).Order = numel(Workspace.Vertices(v).Rectangles); % Update the vertex order.
			
			Sv = [Workspace.Vertices(v).Rectangles.Segment_Row]; % A vector of matched segments connected to vertex v.
			
			% Mark unmatched segments by setting their v vertex to (-1):
				% This has to happen before the next "if" (deletion of order 2 vertices) since this "if" marks the vertex for deletion.
			[~,ia] = intersect(F1,Sv); % Find the indices of the matched segments in F1.
			F4 = F1;
			F4(ia) = []; % An array of row numbers of unmatched segments connected to vertex v.
			for k=1:length(F4) % For each unmatched segment.
				Workspace.Segments(F4(k)).Vertices(find([Workspace.Segments(F4(k)).Vertices] == ...
															Workspace.Vertices(v).Vertex_Index)) = -1;
			end
			
			% Delete order 2 vertices and merge their segments.
			if(Workspace.Vertices(v).Order == 2) % In this case Sv contains two values (segments row numbers).
				
				if(Workspace.Segments(Sv(1)).Vertices(1) == Workspace.Vertices(v).Vertex_Index)
					s1 = fliplr(Workspace.Segments(Sv(1)).Skeleton_Linear_Coordinates);
					v1 = Workspace.Segments(Sv(1)).Vertices(2); % The new 1st vertex is the other vertex of the 1st segment.
				else
					s1 = Workspace.Segments(Sv(1)).Skeleton_Linear_Coordinates;
					v1 = Workspace.Segments(Sv(1)).Vertices(1); % ".
				end
				if(Workspace.Segments(Sv(2)).Vertices(2) == Workspace.Vertices(v).Vertex_Index)
					s2 = fliplr(Workspace.Segments(Sv(2)).Skeleton_Linear_Coordinates);
					v2 = Workspace.Segments(Sv(2)).Vertices(1); % The new 2nd vertex is the other vertex of the 2nd segment.
				else
					s2 = Workspace.Segments(Sv(2)).Skeleton_Linear_Coordinates;
					v2 = Workspace.Segments(Sv(2)).Vertices(2); % ".
				end
				
				% Merge the 2nd segment into the 1st, update the vertices and skeleton coordinates of the 1st,
					% and delete the 2nd. Also, delete the mutual vertex and update the segment index where the 2nd
					% segment appears in the vertices DB:
				Workspace.Segments(Sv(1)).Skeleton_Linear_Coordinates = [s1,s2];
				Workspace.Segments(Sv(1)).Vertices = [v1,v2];
				
				F2 = find([Workspace.Vertices.Vertex_Index] == v2 & [Workspace.Vertices.Vertex_Index] > 0); % Find the remaining vertex (v2) where the 2nd segment appears.
				if(~isempty(F2) && isfield(Workspace.Vertices(F2).Rectangles,'Segment_Index')) % If vertex v2 (still) exists && if v2 was visited earlier in the loop (and the 'Segment_Index' field was added to it).
					F3 = find([Workspace.Vertices(F2).Rectangles.Segment_Index] == Workspace.Segments(Sv(2)).Segment_Index); % Find the specific rectangle corresponding to the 2nd segment.
					if(~isempty(F3)) % If segment s2 was matched to any of the rectangles of vertex v2.
						Workspace.Vertices(F2).Rectangles(F3).Segment_Index = Workspace.Segments(Sv(1)).Segment_Index; % Update the segment index to be s1 (instead of s2).
					end
				end
				
				Workspace.Segments(Sv(2)).Segment_Index = -1; % Marking the 2nd segment for deletion.
				Workspace.Segments(Sv(2)).Vertices = [0,0]; % Setting the vertices to values that won't be found in later iterations of the loop.
				Workspace.Vertices(v).Vertex_Index = -1; % Marking the mutual vertex for deletion.
			end
		end
		
		Workspace.Vertices(v).Rectangles = rmfield(Workspace.Vertices(v).Rectangles,'Segment_Row');
	end
	
	Workspace.Segments(find([Workspace.Segments.Segment_Index] == -1)) = [];
	Workspace.Vertices(find([Workspace.Vertices.Vertex_Index] == -1)) = [];
	
	% After matching segments to rectangles, find segments that weren't matched at least in one vertex.
	% Then delete the segments and their corresponding rectangles (in the other vertex).
	Segments_Vertices = [Workspace.Segments.Vertices];
	Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)'];
	Fs1 = find([Segments_Vertices(:,1)] == -1);
	Fs2 = find([Segments_Vertices(:,2)] == -1);
	for s = 1:length(Fs1)
		si = Workspace.Segments(Fs1(s)).Segment_Index;
		vi = Workspace.Segments(Fs1(s)).Vertices(2);
		vr = find([Workspace.Vertices.Vertex_Index] == vi & [Workspace.Vertices.Vertex_Index] > 0);
		
		if(~isempty(vr)) % If the vertex hasn't already been deleted.
			sr = find([Workspace.Vertices(vr).Rectangles.Segment_Index] == si);
			Workspace.Vertices(vr).Rectangles(sr) = []; % Delete the rectangle that matches segment si.
			if(numel(Workspace.Vertices(vr).Rectangles) == 0)
				Workspace.Vertices(vr).Vertex_Index = -1; % If the rects num is 0, mark for deletion.
			else
				Workspace.Vertices(vr).Order = numel(Workspace.Vertices(vr).Rectangles); % Otherwise, update its order.
			end
		end
		% disp(['Segment Deleted ',num2str(Workspace.Segments(Fs1(s)).Segment_Index)]);
		
		Workspace.Segments(Fs1(s)).Segment_Index = -1; % Finally, mark the segment for the deletion.
	end
	for s = 1:length(Fs2)
		si = Workspace.Segments(Fs2(s)).Segment_Index;
		vi = Workspace.Segments(Fs2(s)).Vertices(1);
		vr = find([Workspace.Vertices.Vertex_Index] == vi & [Workspace.Vertices.Vertex_Index] > 0);
		
		if(~isempty(vr)) % If the vertex hasn't already been deleted.
			sr = find([Workspace.Vertices(vr).Rectangles.Segment_Index] == si);
			Workspace.Vertices(vr).Rectangles(sr) = []; % Delete the rectangle that matches segment si.
			if(numel(Workspace.Vertices(vr).Rectangles) == 0)
				Workspace.Vertices(vr).Vertex_Index = -1; % If the rects num is 0, mark for deletion.
			else
				Workspace.Vertices(vr).Order = numel(Workspace.Vertices(vr).Rectangles); % Otherwise, update its order.
			end
		end
		% disp(['Segment Deleted ',num2str(Workspace.Segments(Fs2(s)).Segment_Index)]);
		
		Workspace.Segments(Fs2(s)).Segment_Index = -1; % Finally, mark the segment for the deletion.
	end
	
	Workspace.Segments(find([Workspace.Segments.Segment_Index] == -1)) = [];
	Workspace.Vertices(find([Workspace.Vertices.Vertex_Index] == -1)) = [];
end