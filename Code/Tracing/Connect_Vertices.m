function Workspace = Connect_Vertices(Workspace)
	
	% TODO: I'm currently not using the collision condition.
	
	Plot0 = 0;
	Plot1 = 0;
	Plot2 = 0;
	Messages = 0;
	
	if(Messages)
		assignin('base','Workspace_Trace_0',Workspace);
	end
	
	if(Plot0)
		% figure(1);
		imshow(Workspace.Image0);
		set(gca,'YDir','normal');
		h = animatedline('LineStyle','none','Marker','.','MarkerEdgeColor',[0,.8,0],'MarkerSize',12);
		% h = animatedline('Color','r','LineWidth',3);
	end
	
	Workspace = Match_Vertex_Rects_To_Segments(Workspace);
	
	% assignin('base','Workspace_SSS',Workspace);
	% return;
	
	% Workspace = Match_Segments_And_Vertices_Rectangles(Workspace,Messages);
	Workspace = Add_Starting_Tracing_Steps(Workspace);
	
	% TODO: choose the threshold to be the length of the scanning rectangle (based on the width):
	[Workspace,Traced_Segments] = Trace_Short_Segments(Workspace); % TODO: detect width. Currently using 1pixel.
	% disp(Traced_Segments);
	% return;
	
	if(Messages)
		assignin('base','Workspace_Pre',Workspace);
	end
	
	[Im_Rows,Im_Cols] = size(Workspace.Image0);
	
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	% Set Initial Background Normalization Values (used in case local normalization fails):
		% (currently only used for the 1st step in each segment (from both sides)).
	Step_Length = Workspace.Parameters.Auto_Tracing_Parameters.Global_Step_Length;
	
	% Rect_Scan_Length_Width_Ratio = Workspace.Parameters.Auto_Tracing_Parameters.Rect_Scan_Length_Width_Ratio;
	Rect_Length_Width_Func = Workspace.Parameters.Tracing.Rect_Length_Width_Func;
	
	MinPeakProminence = Workspace.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Prominence;
	MinPeakDistance = Workspace.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Distance;
	% Skel_Overlap_Treshold = Workspace.Parameters.Auto_Tracing_Parameters.Skel_Overlap_Treshold;
	Trace_Skel_Max_Distance = Workspace.Parameters.Auto_Tracing_Parameters.Trace_Skel_Max_Distance;
	Rect_Width_Num_Of_Last_Steps = Workspace.Parameters.Auto_Tracing_Parameters.Rect_Width_Num_Of_Last_Steps;
	Wmin = Workspace.Parameters.Auto_Tracing_Parameters.Min_Rect_Width; % In pixels.
	Max_Rect_Width_Ratio = Workspace.Parameters.Auto_Tracing_Parameters.Max_Rect_Width_Ratio;
	Global_Max_Rect_Width = (Wmin .* Scale_Factor) .* Workspace.Parameters.Auto_Tracing_Parameters.MaxMin_Rect_Width_Ratio; % Pixels converted to micrometers.
	Width_Ratio = Workspace.Parameters.Auto_Tracing_Parameters.Width_Ratio;
	Width_Smoothing_Parameter = Workspace.Parameters.Auto_Tracing_Parameters.Rect_Width_Smoothing_Parameter;
	Step_Scores_Smoothing_Parameter = Workspace.Parameters.Auto_Tracing_Parameters.Step_Scores_Smoothing_Parameter;
	
	% Move to parameters file:
	Rotation_Range = Workspace.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Range; % 100. % Rotation in angles to each side relative to previous rect orientation.
	Rotation_Res = 3; % Workspace.Parameters.Auto_Tracing_Parameters.Rotation_Res;
	Width_Scan_Ratio = 2;
	Min_Scan_Width = 1; % Pixels.
	Scores_Fit_Sampling_Ratio = 3;
	Origin_Type = Workspace.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin; % 0 = Center of the rectangle. 14 = one of the sides.
	
	Min_Step_Num_Collision = round(1/Step_Length); % TODO: define better.
	Self_Collision_Overlap_Ratio = Workspace.Parameters.Auto_Tracing_Parameters.Self_Collision_Overlap_Ratio; % 0.6;
	Image_Margin_Threshold = 20;
	
	Step_Params = struct('Origin_Type',{});
	Step_Params(1).Origin_Type = Workspace.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin; % 0 = Center of the rectangle. 14 = one of the sides.
	
	if(0) % Plot rectangles of steps and vertices centers.
		hold on;
		XY = [Workspace.Vertices.Coordinate];
		plot([XY(1:2:end)],[XY(2:2:end)],'.m','MarkerSize',10);
		
		for v=1:numel(Workspace.Vertices)
			for r=1:numel(Workspace.Vertices(v).Rectangles)
				[XV,YV] = Get_Rect_Vector(Workspace.Vertices(v).Rectangles(r).Origin,Workspace.Vertices(v).Rectangles(r).Angle*180/pi,...
							Workspace.Vertices(v).Rectangles(r).Width,Workspace.Vertices(v).Rectangles(r).Length,14);
				
				plot(XV,YV,'LineWidth',3);
			end
		end
	end
	
	% Generate a matrix of segment indices at each segment's set of pixels (using the skeleton):
	Segments_Map = zeros(Im_Rows,Im_Cols);
	for s=1:numel(Workspace.Segments)
		Segments_Map([Workspace.Segments(s).Skeleton_Linear_Coordinates]) = Workspace.Segments(s).Segment_Index;
	end
	% return;
	if(Plot0)
		Vi = [Workspace.Vertices.Coordinate];
		Vi = [Vi(1:2:end-1)',Vi(2:2:end)'];
		viscircles(Vi,[Workspace.Vertices.Center_Radius]');
		
		for s=Traced_Segments % Plot the short segment for which the skeleton is used.
			hold on;
			plot([Workspace.Segments(s).Rectangles.X],[Workspace.Segments(s).Rectangles.Y],'r','LineWidth',2);
		end
	end % assignin('base','Segments_Map',Segments_Map);
	
	% return;
	Segments_Array = ones(1,numel(Workspace.Segments));
	Segments_Array(Traced_Segments) = 0; % Ignore short segments for which the skeleton is used instead.
	
	% Segments_Array = zeros(1,numel(Workspace.Segments)); Segments_Array([127:141,118,119]) = 1;
	% Segments_Array = zeros(1,numel(Workspace.Segments)); Segments_Array([139]) = 1;
	% Segments_Array = zeros(1,numel(Workspace.Segments)); Segments_Array([129]) = 1;
	
	Step_Num = 0;
	while(1)
		F0 = find(Segments_Array);
		if(length(F0) == 0)
			break;
		end
		
		Step_Num = Step_Num + 1;
		for s=F0 % 1:length(Workspace.Segments) % For each Segment.
			
			if(numel(Workspace.Segments(s).Rectangles1) == 0 || numel(Workspace.Segments(s).Rectangles2) == 0) % If the one of the two vertices does not have a rectangle.
				Segments_Array(s) = 0;
				if(Messages)
					disp(['One of the vertices of segment ',num2str(s),' does not have a rectangle (= start point)']);
				end
				continue;
			end
			NoPeaks_V12_Flag = 0;
			
			% Go one step forward (using the center of mass of the rectangle as a rotation origin):
			for v=1:2 % For each end-point of segment s.
				% disp(['v = ',num2str(v)]);
				% Segment_Index = ((-1)^(v-1))*Workspace.Segments(s).Segment_Index;
				if(v == 1)
					Field0 = 'Rectangles1';
				elseif(v == 2)
					Field0 = 'Rectangles2';
				end
				
				Step_Params.Rotation_Origin = [Workspace.Segments(s).(Field0)(end).X,Workspace.Segments(s).(Field0)(end).Y];
				Step_Params.Angle = (Workspace.Segments(s).(Field0)(end).Angle)*180/pi;
				Step_Params.Width = (Workspace.Segments(s).(Field0)(end).Width) / Scale_Factor; % Conversion from micrometers to pixels.
				Step_Params.Step_Length = Step_Length; % Step_Params.Width / Workspace.Parameters.Auto_Tracing_Parameters.Rect_Width_StepLength_Ratio; % Workspace.Segments(s).(Field0)(end).Length;
				Step_Params.Scan_Length = Rect_Length_Width_Func(Step_Params.Width);
				Step_Params.Scan_Width = Step_Params.Width ./ Width_Scan_Ratio;
				Step_Params.BG_Intensity = Workspace.Segments(s).(Field0)(end).BG_Intensity;
				Step_Params.BG_Peak_Width = Workspace.Segments(s).(Field0)(end).BG_Peak_Width;
				
				Step_Params.Rotation_Origin = [Step_Params.Rotation_Origin(1)+Step_Length*cosd(Step_Params.Angle),Step_Params.Rotation_Origin(2)+Step_Length*sind(Step_Params.Angle)]; % New Origin. Translation of the previous point one step (Step_Length) forward (without rotation).
				
				if(0)
					disp(s);
					assignin('base','Workspace',Workspace);
					assignin('base','Step_Params.Rotation_Origin',Step_Params.Rotation_Origin);
					assignin('base','Angle',Step_Params.Angle);
					assignin('base','Width',Step_Params.Width);
					assignin('base','Scan_Length',Step_Params.Scan_Length);
					assignin('base','Rotation_Range',Rotation_Range);
					assignin('base','Rotation_Res',Rotation_Res);
					assignin('base','Rotation_Res',Rotation_Res);
					assignin('base','Origin_Type',Origin_Type);
				end
				
				Scores = Rect_Scan_Generalized(Workspace.Image0,Step_Params.Rotation_Origin,Step_Params.Angle,max(Min_Scan_Width,Step_Params.Scan_Width),Step_Params.Scan_Length,Rotation_Range, ...
												Rotation_Res,Origin_Type,Im_Rows,Im_Cols);
				
				[Scores,Step_Params.BG_Intensity,Step_Params.BG_Peak_Width] = Normalize_Rects_Values_Generalized(Workspace.Image0,Scores,Step_Params.Rotation_Origin,Step_Params.Angle,Step_Params.Width,Step_Params.Scan_Length, ...
													Step_Params.BG_Intensity,Step_Params.BG_Peak_Width,Workspace.Parameters,Im_Rows,Im_Cols);
				
				FitObject = fit(Scores(:,1),Scores(:,2),'smoothingspline','SmoothingParam',Step_Scores_Smoothing_Parameter);
				Scores_Fit = zeros(size(Scores,1).*Scores_Fit_Sampling_Ratio,2);
				Scores_Fit(:,1) = linspace(Scores(1,1),Scores(end,1),size(Scores,1).*Scores_Fit_Sampling_Ratio);
				Scores_Fit(:,2) = FitObject(Scores_Fit(:,1));
				
				[Locs1] = Trace_Peak_Analysis(Workspace,Step_Params,s,v,Scores_Fit,[Im_Rows,Im_Cols]);
				
				% if(round(Step_Params.Rotation_Origin(1)) == 146 && round(Step_Params.Rotation_Origin(2)) == 414)
					% assignin('base','Step_Params',Step_Params);
					% assignin('base','Im_Rows',Im_Rows);
					% assignin('base','Im_Cols',Im_Cols);
					% assignin('base','Step_Scores_Smoothing_Parameter',Step_Scores_Smoothing_Parameter);
					% assignin('base','s',s);
					% assignin('base','v',v);
				% end
				
				if(v == Plot2) % && Step_Num < 2)
					figure(2);
					clf(2);
					% findpeaks(Scores(:,2),Scores(:,1),'SortStr','descend','NPeaks',1);
					findpeaks(Scores(:,2),Scores(:,1),'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'Annotate','extents');
					hold on;
					plot(Scores(:,1),Scores(:,2),'.');
					waitforbuttonpress;
				end
				
				% assignin('base','Step_Params',Step_Params);
				
				% TODO: Check what pixels lie within the ragion of the current step:
				F1 = []; % An array of pixels overlap between the current step and the skeleton.
				if(~isempty(Locs1)) % If a peak was detected.
					
					% Note: using the Scan_Width to detect overlaps with other segments:
					[XV,YV] = Get_Rect_Vector(Step_Params.Rotation_Origin,Locs1,Step_Params.Scan_Width,Step_Params.Scan_Length,Workspace.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin);
					if(min(XV) > 0 && min(YV) > 0 && max(XV) <= Im_Cols && max(YV) <= Im_Rows)
						InRect1 = InRect_Coordinates(Workspace.Image0,[XV',YV']); % Get the linear indices of the pixels within the rectangle.
						f1 = Segments_Map(InRect1);
						F1 = find(f1 ~= Workspace.Segments(s).Segment_Index & f1 > 0); % Detect collisions with other segments.
						% F2 = find(f1 == Segment_Index); % Detect "BG tracing".
						% hold on;
						% plot(XV,YV,'r','LineWidth',3);
					end
				end
				
				if(~isempty(F1) && ~isempty(Locs1)) % If there's a collision with another segment.
					Segments_Array(s) = 0;
					if(Messages)
						% disp(f1);
						disp(['Oh No, I(',num2str(s),') Lost My Segment.']);
					end
					break;
				else % If we're still on the corrent path (according to the skeleton), OR if there's no peak.
					if(isempty(Locs1)) % If no peaks were detected.
						NoPeaks_V12_Flag = NoPeaks_V12_Flag + 1;
						if(NoPeaks_V12_Flag == 2) % If both directions have no peaks.
							Workspace.Segments(s) = Connect_Using_Skeleton(Workspace.Segments(s),Im_Rows,Im_Cols,Scale_Factor);
							Segments_Array(s) = 0;
							if(Messages)
								disp(['I could not find any peaks for both direction. Using skeleton to complete the missing part. Segment ',num2str(s),' tracing is terminated.']);
							end
							break; % If both vertices have no peaks, do not continue, break (to avoid inf).
						else
							continue;
						end
					else % If a peak was detected.
						W = Adjust_Rect_Width_Rot_Generalized(Workspace.Image0,Step_Params.Rotation_Origin,Step_Params.Angle,...
										Step_Params.Scan_Length,[Wmin,Max_Rect_Width_Ratio*Workspace.Segments(s).(Field0)(end).Width/Scale_Factor], ...
																	Origin_Type,Width_Smoothing_Parameter,Width_Ratio,Im_Rows,Im_Cols); % Input width in pixels.
						if(0 && Step_Num == 4) % Used to test the width calculation at a specific step.
							assignin('base','Workspace',Workspace);
							assignin('base','Step_Params.Rotation_Origin',Step_Params.Rotation_Origin);
							assignin('base','Angle',Step_Params.Angle);
							assignin('base','Scan_Length',Step_Params.Scan_Length);
							assignin('base','Wmin',Wmin);
							assignin('base','Origin_Type',Origin_Type);
							assignin('base','Width_Smoothing_Parameter',Width_Smoothing_Parameter);
							assignin('base','Width_Ratio',Width_Ratio);
						end
						if(W < 0) % If width detection failed.
							% TODO: in the n 1st steps, use also the vertex rectangle in the average.
							W = mean([Workspace.Segments(s).(Field0)(max(1,end-Rect_Width_Num_Of_Last_Steps):end).Width]); % Value is in micrometers.
							if(Messages)
								disp('Width Detection Failed.');
							end
							% TODO: if (-2), then terminate because it's an image boundaries alert.
						else
							W = mean([W*Scale_Factor,[Workspace.Segments(s).(Field0)(max(1,end-Rect_Width_Num_Of_Last_Steps):end).Width]]); % In micrometers.
							W = min(W,Global_Max_Rect_Width); % Both in micrometers.
						end
						
						Workspace.Segments(s).(Field0)(end+1).X = Step_Params.Rotation_Origin(1);
						Workspace.Segments(s).(Field0)(end).Y = Step_Params.Rotation_Origin(2);
						Workspace.Segments(s).(Field0)(end).Width = W; % Value already in micrometers.
						Workspace.Segments(s).(Field0)(end).Length = Step_Length * Scale_Factor; % Conversion from pixels to micrometers.
						Workspace.Segments(s).(Field0)(end).BG_Intensity = Step_Params.BG_Intensity;
						Workspace.Segments(s).(Field0)(end).BG_Peak_Width = Step_Params.BG_Peak_Width;
						Workspace.Segments(s).(Field0)(end).Angle = mod(Locs1,360)*pi/180; % Make sure the angle is positive (mod) and convert to radians.
						
						if(Plot0 && mod(Step_Num,1) == 0)
							% figure(1);
							hold on;
							% plot(Step_Params.Rotation_Origin(1),Step_Params.Rotation_Origin(2),'.b','MarkerSize',30);
							addpoints(h,Step_Params.Rotation_Origin(1),Step_Params.Rotation_Origin(2));
							drawnow;
							% plot(Step_Params.Rotation_Origin(1),Step_Params.Rotation_Origin(2),parula(s,:),'.','MarkerSize',24);
							% plot([XV,XV(1)],[YV,YV(1)],'r');
						end
					end
					
					dx = Workspace.Segments(s).Rectangles1(end).X - Workspace.Segments(s).Rectangles2(end).X;
					dy = Workspace.Segments(s).Rectangles1(end).Y - Workspace.Segments(s).Rectangles2(end).Y;
					D12 = (dx.^2 + dy.^2) .^ .5;
					% TODO: generalize and validate by checking the skeleton coverage:
					if(D12 <= 2.*Step_Params.Step_Length) % Check if the two tracing parts of the same segment are close enough.
						% Do NOT add pi to the 2nd set of vectors (steps) because this will change the data.
						% The vectors\rectangles from the two directions will have "opposite" directions.
						Segments_Array(s) = 0; 
						% Merge the Rectangles structs of the two directions:
						Workspace.Segments(s).Rectangles = [Workspace.Segments(s).Rectangles1,flip(Workspace.Segments(s).Rectangles2)]; % Flipping only the order of points and ***not the angle***.
						Workspace.Segments(s).Rectangles = rmfield(Workspace.Segments(s).Rectangles,{'Length','Angle','BG_Intensity','BG_Peak_Width'}); % Delete uncessary fields.
						if(Messages)
							disp('YooHoo! I Found My Twin!');
						end
						break;
					end
					
					if(Plot1 == v)
						% [XV,YV] = Get_Rect_Vector(Rotation_Origin,Locs1(F),Width,Scan_Length,Origin_Type); % Using the length of the scanning rectangle.
						[XV,YV] = Get_Rect_Vector(Step_Params.Rotation_Origin,Workspace.Segments(s).(Field0)(end).Angle*180/pi,W/Scale_Factor,Step_Length,Origin_Type); % Using the length of the scanning rectangle.
						% XV = [XV,XV(1)];
						% YV = [YV,YV(1)];
						figure(1);
						hold on;
						plot(XV,YV,'LineWidth',3);
						hold on;
						[SkelY,SkelX] = ind2sub([Im_Rows,Im_Cols],Workspace.Segments(s).Skeleton_Linear_Coordinates);
						plot(SkelX,SkelY,'r');
						plot(SkelX,SkelY,'.r');
						% disp(Step_Length);
						% disp(Workspace.Segments(s).(Field0)(end).Angle);
					end
				end
				% waitforbuttonpress;
			end
		end
		% figure(1);
		% k = waitforbuttonpress;
		% if(k)
			% break;
		% end
	end
	% assignin('base','Segments1',Workspace.Segments);
	% figure; imshow(abs(Locations_Map));
	
	% Clean the Database:
	Workspace.Segments = rmfield(Workspace.Segments,'Skeleton_Linear_Coordinates');
	Workspace.Segments = rmfield(Workspace.Segments,'Rectangles1');
	Workspace.Segments = rmfield(Workspace.Segments,'Rectangles2');
	
	if(Messages)
		assignin('base','Workspace_Trace_1',Workspace);
	end
	% assignin('base','Workspace_Trace_1',Workspace);
	% figure; imshow(Locations_Map);
	% set(gca,'YDir','normal');
	% assignin('base','Workspace',Workspace);
end