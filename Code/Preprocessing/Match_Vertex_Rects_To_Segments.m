function Match_Vertex_Rects_To_Segments(Workspace,Vertex_Row,Rectangles,Segments_Vertices)
	
	% TODO:
		% validate this code.
		% Delete the copied parts from the original function and use it as a tracing initiation function.
			% BG sampling and 1st step of each segment.
		% For short segments, use their end2end orientation.
		% If the number of detected peaks is < than the order,
			% Update the order.
			% Delete the corresponding segments (the ones for which a peak couldn't be detected).
	
	F1 = find(Segments_Vertices(:,1) == Workspace.Vertices(Vertex_Row).Vertex_Index || ...
			Segments_Vertices(:,2) == Workspace.Vertices(Vertex_Row).Vertex_Index); % Find all the segments that are connected to Vertex_Index.
	
	for s=F1 % For each segment that is connected to Vertex_Index.
		
		Workspace.Segments(s).Rectangles1 = struct('X',{},'Y',{},'Angle',{},'Width',{},'Length',{});
		Workspace.Segments(s).Rectangles2 = struct('X',{},'Y',{},'Angle',{},'Width',{},'Length',{});
		
		Sv = Workspace.Segments(s).Skeleton_Linear_Coordinates;
		[Sy,Sx] = ind2sub([Im_Rows,Im_Cols],Sv);
		
		Overlap = zeros(2,numel(Workspace.Vertices(v).Rectangles));
		for r=1:numel(Workspace.Vertices(v).Rectangles) % For each rectnalge r in vertex v.
			
			Width = Rectangles(r).Width / Scale_Factor; % Micrometers to pixels conversion.
			Length = Rectangles(r).Length / Scale_Factor; % Micrometers to pixels conversion.
			[XV,YV] = Get_Rect_Vector(Rectangles(r).Origin,Rectangles(r).Angle*180/pi,Width,Length,14);
			InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
			Overlap(1,r) = length(intersect(Sv,InRect1));
			
			Width = Skel_Vertex_Overlap_Factor * Rectangles(r).Width / Scale_Factor; % Convert length to pixels.
			Length = Rectangles(r).Length / Scale_Factor; % Convert length to pixels.
			[XV,YV] = Get_Rect_Vector(Rectangles(r).Origin,Rectangles(r).Angle*180/pi,Width,Length,14);
			InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
			Overlap(2,r) = length(intersect(Sv,InRect1));
			
			% hold on;
			% plot(XV,YV);
		end
		
		Fi = find([Overlap(1,:)] == max([Overlap(1,:)])); % Find the rectangles with the maximal intersection.
		
		if(length(Fi) > 1) % More than one maximum (including the case in which all values are zero.
			Fi = find([Overlap(2,:)] == max([Overlap(2,:)])); % Try again but this time use a larger rectangle.
			if(Messages)
				disp(['I used a larger rectangle to match a vertex (',num2str(v),') rectangle to this segment (',num2str(s),').']);
			end
		end
		
		if(length(Fi) > 1 || length(Fi) == 0) % If there's more than one maximal overlap value.
											% This also includes the case in which all values are zero (no overlap at all).
											% Or if the Rectangles sturcture is empty.
			% [Ry,Rx] = ind2sub([Im_Rows,Im_Cols],InRect1);
			if(Messages)
				disp(['I had to skip this vertex (',num2str(v),') for segment ',num2str(s),' because I could not find a good match between the vertex rectangles and the segment pixels']);
			end
			continue; % Skip this vertex.
		end
		
		Workspace.Vertices(v).Rectangles(Fi).Segment_Index = Workspace.Segments(s).Segment_Index; % Log in the segment index. Fi should have only 1 value.
	end
end