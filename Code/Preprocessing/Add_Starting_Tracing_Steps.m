function Workspace = Add_Starting_Tracing_Steps(Workspace)
	
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
	
	% for s=[109] % 1:length(Workspace.Segments) % First, match rectangles with the existing segments.
	for s=1:length(Workspace.Segments) % For each segment, add the 1st two steps, one from each side.
		
		Workspace.Segments(s).Rectangles1 = struct('X',{},'Y',{},'Angle',{},'Width',{},'Length',{});
		Workspace.Segments(s).Rectangles2 = struct('X',{},'Y',{},'Angle',{},'Width',{},'Length',{});
		
		v1 = find([Workspace.Vertices.Vertex_Index] == Workspace.Segments(s).Vertices(1)); % Find the 1st vertex.
		v2 = find([Workspace.Vertices.Vertex_Index] == Workspace.Segments(s).Vertices(2)); % Find the 2nd vertex.
		V = unique([v1,v2]); % If it's a loop, v1 and v2 are identical, thus, no need to visit this vertex twice.
		
		for v=1:length(V) % For each of the two vertices of segment s.
			
			% disp(V(v));
			% disp(s);
			
			Fi = find([Workspace.Vertices(V(v)).Rectangles.Segment_Index] == Workspace.Segments(s).Segment_Index);
			
			for f=1:length(Fi) % In the case of a loop, Fi will have multiple values (2 rectangles for one of the segments, and maybe more for others). These two rectnalges are the two starting points of the segment.
				% Add the point on the vertex perimeter as the 1st tracing point of segments (for both vertices):
				if(v == 1)
					% disp(V(v));
					Workspace.Segments(s).Rectangles1(1).X = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Origin(1); % Add the coordinate on the vertex circle and the center of the rectangle.
					Workspace.Segments(s).Rectangles1(1).Y = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Origin(2); % Add the coordinate on the vertex circle and the center of the rectangle.
					Workspace.Segments(s).Rectangles1(1).Angle = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Angle;
					Workspace.Segments(s).Rectangles1(1).Width = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Width;
					Workspace.Segments(s).Rectangles1(1).Length = Step_Length * Scale_Factor; % Vertices(V(v)).Rectangles(Fi).Length;
					
					Workspace.Segments(s).Rectangles1(1).BG_Intensity = BG_Intensity0;
					Workspace.Segments(s).Rectangles1(1).BG_Peak_Width = BG_Peak_Width0;
				elseif(v == 2)
					Workspace.Segments(s).Rectangles2(1).X = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Origin(1); % Add the coordinate on the vertex circle and the center of the rectangle.
					Workspace.Segments(s).Rectangles2(1).Y = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Origin(2); % Add the coordinate on the vertex circle and the center of the rectangle.
					Workspace.Segments(s).Rectangles2(1).Angle = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Angle;
					Workspace.Segments(s).Rectangles2(1).Width = Workspace.Vertices(V(v)).Rectangles(Fi(f)).Width;
					Workspace.Segments(s).Rectangles2(1).Length = Step_Length * Scale_Factor; % Convert pixels to length.
					
					Workspace.Segments(s).Rectangles2(1).BG_Intensity = BG_Intensity0;
					Workspace.Segments(s).Rectangles2(1).BG_Peak_Width = BG_Peak_Width0;
				end
			end
		end
	end
	
end