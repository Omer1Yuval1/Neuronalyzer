function Workspace = Match_Segments_And_Vertices_Rectangles(Workspace,Messages)
	
	[Im_Rows,Im_Cols] = size(Workspace.Image0);
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	
	Step_Length = Workspace.Parameters.Auto_Tracing_Parameters.Global_Step_Length;
	Skel_Vertex_Overlap_Factor = Workspace.Parameters.Auto_Tracing_Parameters.Skel_Vertex_Overlap_Factor;
	Hist_Bins_Res = Workspace.Parameters(1).Auto_Tracing_Parameters(1).Hist_Bins_Res;
	[Counts0,Intensities0] = histcounts([Workspace.Image0(:)],[-Hist_Bins_Res:Hist_Bins_Res:260],'Normalization','probability');	
	Intensities0 = (Intensities0(1:end-1) + Intensities0(2:end)) / 2; % Convert bins to bins centers.	
	% Find peaks in the fitted data (the peaks are ordered from largest to smallest):
	BG_MinPeakHeight = Workspace.Parameters(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Height;
	BG_MinPeakDistance = Workspace.Parameters(1).Auto_Tracing_Parameters(1).Step_Normalization_Min_Peak_Distance;
	[yp0,xp0,Peaks_Width0,Peaks_Prominence0] = findpeaks(Counts0,Intensities0,'MinPeakProminence',BG_MinPeakHeight, ...
															'MinPeakDistance',BG_MinPeakDistance,'SortStr','descend');
	BG_Intensity0 = xp0(1); % The intensity (peak x-value) of the 1st (leftest) peak.
	BG_Peak_Width0 = Peaks_Width0(1); % The width of the 1st (leftest) peak.
	
	% Match a vertex rectangle to each skeleton segment:
	% Locations_Map = zeros(Im_Rows,Im_Cols);
	% Locations_Map_Steps = zeros(Im_Rows,Im_Cols);
	% for s=[109] % 1:length(Workspace.Segments) % First, match rectangles with the existing segments.
	for s=1:length(Workspace.Segments) % First, match rectangles with the existing segments.
		
		if(Workspace.Segments(s).Vertices(2) == -1)
			if(Messages)
				disp('A Second Vertex Could Not Be Detected. Check Function Segment_Skeleton - Last *else*');
			end
			continue;
		end
		
		Workspace.Segments(s).Rectangles1 = struct('X',{},'Y',{},'Angle',{},'Width',{},'Length',{});
		Workspace.Segments(s).Rectangles2 = struct('X',{},'Y',{},'Angle',{},'Width',{},'Length',{});
		
		Sv = Workspace.Segments(s).Skeleton_Linear_Coordinates;
		[Sy,Sx] = ind2sub([Im_Rows,Im_Cols],Sv);
		
		v1 = find([Workspace.Vertices.Vertex_Index] == Workspace.Segments(s).Vertices(1)); % Find the 1st vertex.
		v2 = find([Workspace.Vertices.Vertex_Index] == Workspace.Segments(s).Vertices(2)); % Find the 2nd vertex.
		V = [v1,v2];
		% V = 135;
		for v=1:length(V)
			Overlap = zeros(2,numel(Workspace.Vertices(V(v)).Rectangles));
			for r=1:numel(Workspace.Vertices(V(v)).Rectangles) % For each rectnalge r in vertex V(v).
				
				Width = Workspace.Vertices(V(v)).Rectangles(r).Width / Scale_Factor; % Convert length to pixels.
				Length = Workspace.Vertices(V(v)).Rectangles(r).Length / Scale_Factor; % Convert length to pixels.
				[XV,YV] = Get_Rect_Vector(Workspace.Vertices(V(v)).Rectangles(r).Origin,Workspace.Vertices(V(v)).Rectangles(r).Angle*180/pi,Width,Length,14);
				InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
				Overlap(1,r) = length(intersect(Sv,InRect1));
				
				Width = Skel_Vertex_Overlap_Factor * Workspace.Vertices(V(v)).Rectangles(r).Width / Scale_Factor; % Convert length to pixels.
				Length = Workspace.Vertices(V(v)).Rectangles(r).Length / Scale_Factor; % Convert length to pixels.
				[XV,YV] = Get_Rect_Vector(Workspace.Vertices(V(v)).Rectangles(r).Origin,Workspace.Vertices(V(v)).Rectangles(r).Angle*180/pi,Width,Length,14);
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
					disp(['I had to skip this vertex (',num2str(V(v)),') for segment ',num2str(s),' because I could not find a good match between the vertex rectangles and the segment pixels']);
				end
				continue; % Skip this vertex.
			end
			
			Workspace.Vertices(V(v)).Rectangles(Fi).Segment_Index = Workspace.Segments(s).Segment_Index; % Log in the segment index. Fi should have only 1 value.
			
			% [XV,YV] = Get_Rect_Vector(Workspace.Vertices(V(v)).Rectangles(Fi).Origin,...
								% Workspace.Vertices(V(v)).Rectangles(Fi).Angle*180/pi,...
								% Workspace.Vertices(V(v)).Rectangles(Fi).Width/Scale_Factor,Step_Length,14); % Vertices(V(v)).Rectangles(Fi).Length
			% InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
			
			% if(Workspace.Vertices(V(v)).Vertex_Index == -120)
				% assignin('base','XV',XV);
				% assignin('base','YV',YV);
			% end
			
			% Add the point on the vertex perimeter as the 1st tracing point of segment s (for both vertices):
			if(v == 1)
				Workspace.Segments(s).Rectangles1(1).X = Workspace.Vertices(V(v)).Rectangles(Fi).Origin(1); % Add the coordinate on the vertex circle and the center of the rectangle.
				Workspace.Segments(s).Rectangles1(1).Y = Workspace.Vertices(V(v)).Rectangles(Fi).Origin(2); % Add the coordinate on the vertex circle and the center of the rectangle.
				Workspace.Segments(s).Rectangles1(1).Angle = Workspace.Vertices(V(v)).Rectangles(Fi).Angle;
				Workspace.Segments(s).Rectangles1(1).Width = Workspace.Vertices(V(v)).Rectangles(Fi).Width;
				Workspace.Segments(s).Rectangles1(1).Length = Step_Length * Scale_Factor; % Vertices(V(v)).Rectangles(Fi).Length;
				
				Workspace.Segments(s).Rectangles1(1).BG_Intensity = BG_Intensity0;
				Workspace.Segments(s).Rectangles1(1).BG_Peak_Width = BG_Peak_Width0;
				
				% Locations_Map(InRect1) = Workspace.Segments(s).Segment_Index; % TODO: check collision even here.
				% Locations_Map_Steps(InRect1) = 1;
			elseif(v == 2)
				Workspace.Segments(s).Rectangles2(1).X = Workspace.Vertices(V(v)).Rectangles(Fi).Origin(1); % Add the coordinate on the vertex circle and the center of the rectangle.
				Workspace.Segments(s).Rectangles2(1).Y = Workspace.Vertices(V(v)).Rectangles(Fi).Origin(2); % Add the coordinate on the vertex circle and the center of the rectangle.
				Workspace.Segments(s).Rectangles2(1).Angle = Workspace.Vertices(V(v)).Rectangles(Fi).Angle;
				Workspace.Segments(s).Rectangles2(1).Width = Workspace.Vertices(V(v)).Rectangles(Fi).Width;
				Workspace.Segments(s).Rectangles2(1).Length = Step_Length * Scale_Factor; % Convert pixels to length.
				
				Workspace.Segments(s).Rectangles2(1).BG_Intensity = BG_Intensity0;
				Workspace.Segments(s).Rectangles2(1).BG_Peak_Width = BG_Peak_Width0;
				
				% Locations_Map(InRect1) = -Workspace.Segments(s).Segment_Index; % Taking the minus here.
				% Locations_Map_Steps(InRect1) = 1;
			end
		end
	end
	
end