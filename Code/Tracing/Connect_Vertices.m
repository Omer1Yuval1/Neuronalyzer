function Data = Connect_Vertices(Data,Ax)
	
	% TODO: I'm currently not using the collision condition.
	
	Plot0 = 1;
	Plot1 = 0;
	Plot2 = 0;
	Messages = 0;
	
	if(Messages)
		assignin('base','Workspace_Trace_0',Data);
	end
	
	if(Plot0)
		% imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
		% set(Ax,'YDir','normal');
		h = animatedline(Ax,'LineStyle','none','Marker','.','MarkerEdgeColor',[0,.8,0],'MarkerSize',5); % h = animatedline('Color','r','LineWidth',3);
	end
	
	Data = Add_Starting_Tracing_Steps(Data);
	
	[Data.Segments,Traced_Segments] = Trace_Short_Segments(Data); % TODO: detect width. Currently using 1pixel.
	
	if(Messages)
		assignin('base','Workspace_Pre',Data);
	end
	
	[Im_Rows,Im_Cols] = size(Data.Info.Files.Raw_Image{1});
	
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor; % Data.User_Input.Scale_Factor;
	% Set Initial Background Normalization Values (used in case local normalization fails):
		% (currently only used for the 1st step in each segment (from both sides)).
	Step_Length = Data.Parameters.Auto_Tracing_Parameters.Global_Step_Length;
	
	% Rect_Scan_Length_Width_Ratio = Data.Parameters.Auto_Tracing_Parameters.Rect_Scan_Length_Width_Ratio;
	Rect_Length_Width_Func = Data.Parameters.Tracing.Rect_Length_Width_Func;
	
	MinPeakProminence = Data.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Prominence;
	MinPeakDistance = Data.Parameters.Auto_Tracing_Parameters.Step_Min_Peak_Distance;
	% Skel_Overlap_Treshold = Data.Parameters.Auto_Tracing_Parameters.Skel_Overlap_Treshold;
	Trace_Skel_Max_Distance = Data.Parameters.Auto_Tracing_Parameters.Trace_Skel_Max_Distance;
	Rect_Width_Num_Of_Last_Steps = Data.Parameters.Auto_Tracing_Parameters.Rect_Width_Num_Of_Last_Steps;
	Wmin = Data.Parameters.Auto_Tracing_Parameters.Min_Rect_Width; % In pixels.
	Max_Rect_Width_Ratio = Data.Parameters.Auto_Tracing_Parameters.Max_Rect_Width_Ratio;
	Global_Max_Rect_Width = (Wmin .* Scale_Factor) .* Data.Parameters.Auto_Tracing_Parameters.MaxMin_Rect_Width_Ratio; % Pixels converted to micrometers.
	Width_Ratio = Data.Parameters.Auto_Tracing_Parameters.Width_Ratio;
	Width_Smoothing_Parameter = Data.Parameters.Auto_Tracing_Parameters.Rect_Width_Smoothing_Parameter;
	Step_Scores_Smoothing_Parameter = Data.Parameters.Auto_Tracing_Parameters.Step_Scores_Smoothing_Parameter;
	
	% Move to parameters file:
	Rotation_Range = Data.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Range; % 100. % Rotation in angles to each side relative to previous rect orientation.
	Rotation_Res = 3; % Data.Parameters.Auto_Tracing_Parameters.Rotation_Res;
	Width_Scan_Ratio = 2;
	Min_Scan_Width = 1; % Pixels.
	Scores_Fit_Sampling_Ratio = 3;
	Origin_Type = Data.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin; % 0 = Center of the rectangle. 14 = one of the sides.
	
	% Min_Step_Num_Collision = round(1/Step_Length); % TODO: define better.
	% Self_Collision_Overlap_Ratio = Data.Parameters.Auto_Tracing_Parameters.Self_Collision_Overlap_Ratio; % 0.6;
	Image_Margin_Threshold = 20;
	
	Step_Params = struct('Origin_Type',{});
	Step_Params(1).Origin_Type = Data.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin; % 0 = Center of the rectangle. 14 = one of the sides.
	
	if(0) % Plot rectangles of steps and vertices centers.
		hold on;
		XY = [Data.Vertices.Coordinate];
		plot(Ax,[XY(1:2:end)],[XY(2:2:end)],'.m','MarkerSize',10);
		
		for v=1:numel(Data.Vertices)
			for r=1:numel(Data.Vertices(v).Rectangles)
				[XV,YV] = Get_Rect_Vector(Data.Vertices(v).Rectangles(r).Origin,Data.Vertices(v).Rectangles(r).Angle*180/pi,...
							Data.Vertices(v).Rectangles(r).Width,Data.Vertices(v).Rectangles(r).Length,14);
				
				plot(Ax,XV,YV,'LineWidth',3);
			end
		end
	end
	
	% Generate a matrix of segment indices at each segment's set of pixels (using the skeleton):
	Segments_Map = zeros(Im_Rows,Im_Cols);
	for s=1:numel(Data.Segments)
		Segments_Map([Data.Segments(s).Skeleton_Linear_Coordinates]) = Data.Segments(s).Segment_Index;
	end
	% return;
	if(Plot0)
		Vi = [Data.Vertices.Coordinate];
		Vi = [Vi(1:2:end-1)',Vi(2:2:end)'];
		
		hold(Ax,'on');
		% viscircles(Vi,[Data.Vertices.Center_Radius]');
		
		for s=Traced_Segments % Plot the short segment for which the skeleton is used.
			plot(Ax,[Data.Segments(s).Rectangles.X],[Data.Segments(s).Rectangles.Y],'r','LineWidth',2);
		end
	end % assignin('base','Segments_Map',Segments_Map);
	
	% return;
	Segments_Array = ones(1,numel(Data.Segments));
	Segments_Array(Traced_Segments) = 0; % Ignore short segments for which the skeleton is used instead.
	
	% Segments_Array = zeros(1,numel(Data.Segments)); Segments_Array(334) = 1; % Use row number (not segment index).
	%%% Segments_Array = zeros(1,numel(Data.Segments)); Segments_Array([139]) = 1;
	%%% Segments_Array = zeros(1,numel(Data.Segments)); Segments_Array([129]) = 1;
	
	Step_Num = 0;
	while(1)
		F0 = find(Segments_Array == 1);
		if(length(F0) == 0)
			break;
		end
		
		Step_Num = Step_Num + 1;
		for s=F0 % 1:length(Data.Segments) % For each Segment.
			
			if(numel(Data.Segments(s).Rectangles1) == 0 || numel(Data.Segments(s).Rectangles2) == 0) % If the one of the two vertices does not have a rectangle.
				% Data.Segments(s) = Connect_Using_Skeleton(Data.Segments(s),Im_Rows,Im_Cols,Scale_Factor);
				Segments_Array(s) = -2;
				if(Messages)
					disp(['One of the vertices of segment ',num2str(s),' does not have a rectangle (= start point)']);
				end
				continue;
			end
			NoPeaks_V12_Flag = 0;
			
			% Go one step forward (using the center of mass of the rectangle as a rotation origin):
			for v=1:2 % For each end-point of segment s.
				% disp(['v = ',num2str(v)]);
				% Segment_Index = ((-1)^(v-1))*Data.Segments(s).Segment_Index;
				if(v == 1)
					Field0 = 'Rectangles1';
				elseif(v == 2)
					Field0 = 'Rectangles2';
				end
				
				Step_Params.Rotation_Origin = [Data.Segments(s).(Field0)(end).X,Data.Segments(s).(Field0)(end).Y];
				Step_Params.Angle = (Data.Segments(s).(Field0)(end).Angle)*180/pi;
				Step_Params.Width = (Data.Segments(s).(Field0)(end).Width) / Scale_Factor; % Conversion from micrometers to pixels.
				Step_Params.Step_Length = Step_Length; % Step_Params.Width / Data.Parameters.Auto_Tracing_Parameters.Rect_Width_StepLength_Ratio; % Data.Segments(s).(Field0)(end).Length;
				Step_Params.Scan_Length = Rect_Length_Width_Func(Step_Params.Width);
				Step_Params.Scan_Width = Step_Params.Width ./ Width_Scan_Ratio;
				Step_Params.BG_Intensity = Data.Segments(s).(Field0)(end).BG_Intensity;
				Step_Params.BG_Peak_Width = Data.Segments(s).(Field0)(end).BG_Peak_Width;
				
				Step_Params.Rotation_Origin = [Step_Params.Rotation_Origin(1)+Step_Length*cosd(Step_Params.Angle),Step_Params.Rotation_Origin(2)+Step_Length*sind(Step_Params.Angle)]; % New Origin. Translation of the previous point one step (Step_Length) forward (without rotation).
				
				if(0)
					disp(s);
					assignin('base','Data',Data);
					assignin('base','Step_Params.Rotation_Origin',Step_Params.Rotation_Origin);
					assignin('base','Angle',Step_Params.Angle);
					assignin('base','Width',Step_Params.Width);
					assignin('base','Scan_Length',Step_Params.Scan_Length);
					assignin('base','Rotation_Range',Rotation_Range);
					assignin('base','Rotation_Res',Rotation_Res);
					assignin('base','Rotation_Res',Rotation_Res);
					assignin('base','Origin_Type',Origin_Type);
				end
				
				Scores = Rect_Scan_Generalized(Data.Info.Files.Raw_Image{1},Step_Params.Rotation_Origin,Step_Params.Angle,max(Min_Scan_Width,Step_Params.Scan_Width),Step_Params.Scan_Length,Rotation_Range, ...
												Rotation_Res,Origin_Type,Im_Rows,Im_Cols,0);
				
				[Scores,Step_Params.BG_Intensity,Step_Params.BG_Peak_Width] = Normalize_Rects_Values_Generalized(Data.Info.Files.Raw_Image{1},Scores,Step_Params.Rotation_Origin,Step_Params.Angle,Step_Params.Width,Step_Params.Scan_Length, ...
													Step_Params.BG_Intensity,Step_Params.BG_Peak_Width,Data.Parameters,Im_Rows,Im_Cols);
				
				FitObject = fit(Scores(:,1),Scores(:,2),'smoothingspline','SmoothingParam',Step_Scores_Smoothing_Parameter);
				Scores_Fit = zeros(size(Scores,1).*Scores_Fit_Sampling_Ratio,2);
				Scores_Fit(:,1) = linspace(Scores(1,1),Scores(end,1),size(Scores,1).*Scores_Fit_Sampling_Ratio);
				Scores_Fit(:,2) = FitObject(Scores_Fit(:,1));
				
				[Locs1] = Trace_Peak_Analysis(Data,Step_Params,s,v,Scores_Fit,[Im_Rows,Im_Cols]);
				
				if(v == Plot2) % && Step_Num < 2)
					figure(2);
					clf(2);
					% findpeaks(Scores(:,2),Scores(:,1),'SortStr','descend','NPeaks',1);
					findpeaks(Scores(:,2),Scores(:,1),'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'Annotate','extents');
					hold on;
					plot(Ax,Scores(:,1),Scores(:,2),'.');
					waitforbuttonpress;
				end
				
				% assignin('base','Step_Params',Step_Params);
				
				% TODO: Check what pixels lie within the ragion of the current step:
				F1 = []; % An array of pixels overlap between the current step and the skeleton.
				if(~isempty(Locs1)) % If a peak was detected.
					
					% Note: using the Scan_Width to detect overlaps with other segments:
					[XV,YV] = Get_Rect_Vector(Step_Params.Rotation_Origin,Locs1,Step_Params.Scan_Width,Step_Params.Scan_Length,Data.Parameters.Auto_Tracing_Parameters.Rect_Rotation_Origin);
					if(min(XV) > 0 && min(YV) > 0 && max(XV) <= Im_Cols && max(YV) <= Im_Rows)
						InRect1 = InRect_Coordinates(Data.Info.Files.Raw_Image{1},[XV',YV']); % Get the linear indices of the pixels within the rectangle.
						f1 = Segments_Map(InRect1);
						F1 = find(f1 ~= Data.Segments(s).Segment_Index & f1 > 0); % Detect collisions with other segments.
						% F2 = find(f1 == Segment_Index); % Detect "BG tracing".
						% hold on;
						% plot(XV,YV,'r','LineWidth',3);
					end
				end
				
				if(~isempty(F1) && ~isempty(Locs1)) % If there's a collision with another segment.
					Data.Segments(s) = Connect_Using_Skeleton(Data.Segments(s),Im_Rows,Im_Cols,Scale_Factor);
					
					Data.Segments(s).Rectangles = [Data.Segments(s).Rectangles1,flip(Data.Segments(s).Rectangles2)]; % Flipping only the order of points and ***not the angle***.
					Data.Segments(s).Rectangles = rmfield(Data.Segments(s).Rectangles,{'Length','Angle','BG_Intensity','BG_Peak_Width'}); % Delete unnecessary fields.
					
					Segments_Array(s) = -1;
					if(Messages)
						disp(['Oh No, I(',num2str(s),') Lost My Segment. Using skeleton to complete the missing part.']);
					end
					break;
				else % If we're still on the current path (according to the skeleton), OR if there's no peak.
					if(isempty(Locs1)) % If no peaks were detected.
						NoPeaks_V12_Flag = NoPeaks_V12_Flag + 1;
						if(NoPeaks_V12_Flag == 2) % If both directions have no peaks.
							Data.Segments(s) = Connect_Using_Skeleton(Data.Segments(s),Im_Rows,Im_Cols,Scale_Factor);
							
							Data.Segments(s).Rectangles = [Data.Segments(s).Rectangles1,flip(Data.Segments(s).Rectangles2)]; % Flipping only the order of points and ***not the angle***.
							Data.Segments(s).Rectangles = rmfield(Data.Segments(s).Rectangles,{'Length','Angle','BG_Intensity','BG_Peak_Width'}); % Delete unnecessary fields.
							
							Segments_Array(s) = -1;
							if(Messages)
								disp(['I could not find any peaks for both directions. Using skeleton to complete the missing part. Segment ',num2str(s)]);
							end
							break; % If both vertices have no peaks, do not continue, break (to avoid inf).
						else
							continue;
						end
					else % If a peak was detected.
						W = Adjust_Rect_Width_Rot_Generalized(Data.Info.Files.Raw_Image{1},Step_Params.Rotation_Origin,Step_Params.Angle,...
										Step_Params.Scan_Length,[Wmin,Max_Rect_Width_Ratio*Data.Segments(s).(Field0)(end).Width/Scale_Factor], ...
																	Origin_Type,Width_Smoothing_Parameter,Width_Ratio,Im_Rows,Im_Cols); % Input width in pixels.
						
						if(W < 0) % If width detection failed.
							% TODO: in the n 1st steps, use also the vertex rectangle in the average.
							W = mean([Data.Segments(s).(Field0)(max(1,end-Rect_Width_Num_Of_Last_Steps):end).Width]); % Value is in micrometers.
							if(Messages)
								disp('Width Detection Failed.');
							end
							% TODO: if (-2), then terminate because it's an image boundaries alert.
						else
							W = mean([W*Scale_Factor,[Data.Segments(s).(Field0)(max(1,end-Rect_Width_Num_Of_Last_Steps):end).Width]]); % In micrometers.
							W = min(W,Global_Max_Rect_Width); % Both in micrometers.
						end
						
						Data.Segments(s).(Field0)(end+1).X = Step_Params.Rotation_Origin(1);
						Data.Segments(s).(Field0)(end).Y = Step_Params.Rotation_Origin(2);
						Data.Segments(s).(Field0)(end).Width = W; % Value already in micrometers.
						Data.Segments(s).(Field0)(end).Length = Step_Length * Scale_Factor; % Conversion from pixels to micrometers.
						Data.Segments(s).(Field0)(end).BG_Intensity = Step_Params.BG_Intensity;
						Data.Segments(s).(Field0)(end).BG_Peak_Width = Step_Params.BG_Peak_Width;
						Data.Segments(s).(Field0)(end).Angle = mod(Locs1,360)*pi/180; % Make sure the angle is positive (mod) and convert to radians.
						
						if(Plot0 && mod(Step_Num,1) == 0)
							% plot(Step_Params.Rotation_Origin(1),Step_Params.Rotation_Origin(2),'.b','MarkerSize',30);
							addpoints(h,Step_Params.Rotation_Origin(1),Step_Params.Rotation_Origin(2));
							% drawnow;
							% plot(Step_Params.Rotation_Origin(1),Step_Params.Rotation_Origin(2),parula(s,:),'.','MarkerSize',24);
							% plot([XV,XV(1)],[YV,YV(1)],'r');
						end
					end
					
					dx = Data.Segments(s).Rectangles1(end).X - Data.Segments(s).Rectangles2(end).X;
					dy = Data.Segments(s).Rectangles1(end).Y - Data.Segments(s).Rectangles2(end).Y;
					D12 = (dx.^2 + dy.^2) .^ .5;
					% TODO: generalize and validate by checking the skeleton coverage:
					if(D12 <= 2.*Step_Params.Step_Length) % Check if the two tracing parts of the same segment are close enough.
						% Do NOT add pi to the 2nd set of vectors (steps) because this will change the data.
						% The vectors\rectangles from the two directions will have "opposite" directions.
						Segments_Array(s) = 0; 
						% Merge the Rectangles structs of the two directions:
						Data.Segments(s).Rectangles = [Data.Segments(s).Rectangles1,flip(Data.Segments(s).Rectangles2)]; % Flipping only the order of points and ***not the angle***.
						Data.Segments(s).Rectangles = rmfield(Data.Segments(s).Rectangles,{'Length','Angle','BG_Intensity','BG_Peak_Width'}); % Delete unnecessary fields.
						if(Messages)
							disp('YooHoo! I Found My Twin!');
						end
						break;
					end
					
					if(Plot1 == v)
						% [XV,YV] = Get_Rect_Vector(Rotation_Origin,Locs1(F),Width,Scan_Length,Origin_Type); % Using the length of the scanning rectangle.
						[XV,YV] = Get_Rect_Vector(Step_Params.Rotation_Origin,Data.Segments(s).(Field0)(end).Angle*180/pi,W/Scale_Factor,Step_Length,Origin_Type); % Using the length of the scanning rectangle.
						% XV = [XV,XV(1)];
						% YV = [YV,YV(1)];
						figure(1);
						hold on;
						plot(XV,YV,'LineWidth',3);
						hold on;
						[SkelY,SkelX] = ind2sub([Im_Rows,Im_Cols],Data.Segments(s).Skeleton_Linear_Coordinates);
						% plot(SkelX,SkelY,'r');
						plot(SkelX,SkelY,'.r');
						% disp(Step_Length);
						% disp(Data.Segments(s).(Field0)(end).Angle);
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
		drawnow;
	end
	% assignin('base','Segments1',Data.Segments);
	% figure; imshow(abs(Locations_Map));
	
	% Clean the Database:
	Data.Segments = rmfield(Data.Segments,'Skeleton_Linear_Coordinates');
	Data.Segments = rmfield(Data.Segments,'Rectangles1');
	Data.Segments = rmfield(Data.Segments,'Rectangles2');
	
	if(Messages)
		assignin('base','Workspace_Trace_1',Data);
	end
	% assignin('base','Segments_Array',Segments_Array);
	% figure; imshow(Locations_Map);
	% set(gca,'YDir','normal');
	% assignin('base','Data',Data);
end