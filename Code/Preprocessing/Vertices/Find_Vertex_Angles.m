function Rectangles = Find_Vertex_Angles(Workspace,v,Cxy,Rc,Scale_Factor,Im_Rows,Im_Cols)
	
	Plot1 = 0;
	Plot2 = 0;
	Plot3 = 0;
	
	Peaks_Max_Num = Workspace.Vertices(v).Order;
	
	SmoothingParameter = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_SmoothingParameter;
	MinWidth = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Min_Max(1);
	MaxWidth = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Min_Max(2);
	Width_Ratio = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Ratio;
	Width_SmoothingParameter = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Width_SmoothingParameter;
	Min_Final_Width = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Min_Width;
	Extension_Length = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Extension_Length;	
	W = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Width;	
	Rect_Length = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Length;
	
	Min_Score_Ratio = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Min_Score_Ratio;	
	MinPeakDis = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakDis;	
	MinPeakWidth = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakWidth;	
	MinPeakProm = Workspace.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakProm;
	
	Angle_Res = 1*(pi/180); % 1 degree. old version: round(60 * Rc); % 360*
	N = round(2*pi/Angle_Res);
	Theta = linspace(0,2*pi,N);
	
	Unique_Tolerance = Angle_Res; % 10^(-4);
	
	Polar_Extension = 2:find(abs([Theta-Extension_Length]) == min(abs([Theta-Extension_Length]))); % TODO: why start from 2?
	Extension_Neglect_Length = 20*pi/180;
	
	Filtered_Scores = zeros(3,length(Theta)); % An array of scores for each perimeter point. 1st row  = score. 2nd row = angle. 3rd row = width.
	Pxy = [Rc*cos(Theta') + Cxy(1) , Rc*sin(Theta') + Cxy(2)]; % Coordinates on the perimeter of the center circle.
	
	if(Plot3)
		CM = hsv(16);
		Vt = round(1:N/16:N);
	end
	
	for t=1:length(Theta) % For each angle. Scan for signal around (and outside) the vertex center using a series of straight lines.
		
		[XV,YV] = Get_Rect_Vector(Pxy(t,:),Theta(t)*180/pi,W,Rect_Length,14); % Theta(t) is the direction perpendicular to the circle at the current point (rotation origin = Pxy).
		
		Coordinates1 = [];
		if(min(XV) >= 1 && max(XV) <= Im_Cols && min(YV) >= 1 && max(YV) <= Im_Rows)
			Coordinates1 = InRect_Coordinates(Workspace.Im_BW,[XV',YV']);
		end
		
		Filtered_Scores(1,t) = sum(Workspace.Im_BW(Coordinates1)); %  / (Rect_Length*W); % Count 1-pixels and normalize to the area of the rectangle.
		Filtered_Scores(2,t) = Theta(t); % Take the average of all the angles values that got the best score (for a specific width value).				
		
		if(Plot3 && ismember(t,Vt)) % Draw the convolving rectangles and the peak analysis.
			hold on;
			figure(1);
			plot([XV,XV(1)],[YV,YV(1)],'Color',CM(find(t == Vt,1),:),'LineWidth',3);
		end
	end
	if(max(Filtered_Scores(1,:)) > 0)
		Filtered_Scores(1,:) = Filtered_Scores(1,:) ./ max(Filtered_Scores(1,:)); % Normalize Scores to [0,1].
	end
	
	Pxy = [Pxy ; Pxy(Polar_Extension,:)];
	Theta = [Theta,Theta(Polar_Extension)+2*pi];
	Filtered_Scores = [Filtered_Scores,Filtered_Scores(:,Polar_Extension)];
	
	FitObject = fit(Theta',Filtered_Scores(1,:)','smoothingspline','SmoothingParam',SmoothingParameter);
	Raw_Scores = Filtered_Scores(1,:); % TODO: delete.
	Filtered_Scores(1,:) = FitObject(Theta);
	
	% Find Peaks:
	[Peaks,Locs,~,Proms] = findpeaks(Filtered_Scores(1,:),Theta,'MinPeakProminence',MinPeakProm,...
											'MinPeakDistance',MinPeakDis,'MinPeakWidth',MinPeakWidth);
	
	% Delete peaks at the edges (using Extension_Neglect_Length):
	% This is done to avoid a situation in which:
		% 1. One peak is chosen out two adjacent peaks (angle distance criterion in peak analysis).
		% 2. These two peaks are and the edge of the angle range, but one of them, in one of the edges, is not
			% detected because it's too close to the edge (and is thus cut from one side).
	F = find(Locs >= Extension_Neglect_Length & Locs <= (2*pi + Extension_Length - Extension_Neglect_Length));
	Peaks = Peaks(F);
	Locs = Locs(F);
	% Widths = Widths(F);
	Proms = Proms(F);
	
	% Part of the range is duplicated because the x-axis is angle. Find duplicated peaks and delete them:
	[C,ia,ic] = uniquetol(mod(Locs,2*pi),Unique_Tolerance); % Mod 2*pi. % [C,ia,ic] = uniquetol(mod(Locs-1,2*pi)+1,Unique_Tolerance); % Modulo that starts from 1. TODO: Why???
	ia = sort(ia);
	Peaks = Peaks(ia);
	Locs = Locs(ia);
	% Widths = Widths(ia);
	Proms = Proms(ia);
	
	if(Plot2)
		
		figure(2);
		hold on;
		plot(Theta,Raw_Scores,'.','Color',[.5,.5,.5],'MarkerSize',10);
		plot(Theta,Filtered_Scores(1,:),'k','LineWidth',6); % Fit.
		% plot(Locs,Peaks,'.','Color',[0,0.8,0],'MarkerSize',15);
		
		findpeaks(Filtered_Scores(1,:),Theta,'MinPeakProminence',MinPeakProm,'MinPeakDistance',MinPeakDis,'MinPeakWidth',MinPeakWidth,'Annotate','extents');
		
		xlabel(['Angle (',char(176),')']);
		ylabel('Score');
		set(gca,'FontSize',36,'XTick',(0:30:720).*pi./180,'XTickLabels',0:30:720);
		% xlim([0,2.*pi]);
		xlim([0,max(Theta)]);
		ylim([-0.02,1.02]);
		
		set(gca,'unit','normalize');
		set(gca,'position',[0.07,0.16,0.91,0.8]);
	end
	
	% List angles & Detect rectangle width for the detected peaks:
	Ap = nan(1,length(Peaks));
	Cxy = nan(length(Peaks),2);
	Widths = zeros(1,length(Peaks));
	for p=1:length(Peaks) % For each peak.
		F1 = find(Theta == Locs(p)); % Find the central angle that corresponds to this peak.		
		Ap(p) = Filtered_Scores(2,F1); % List angles (locs).
		Cxy(p,:) = Pxy(F1,:);
	end
	
	% Replace skeleton angles with the detected peaks, using skeleton angles for pair-wise matching
		% (additional peaks are ignored, only best matches are used, based on the predefined number of skeleton rectangles).
	Rectangles = Workspace.Vertices(v).Rectangles;
	for r=1:numel(Workspace.Vertices(v).Rectangles) % For each pre-defined skeleton direction (= segment connected to this vertex).
		As = mod(Workspace.Vertices(v).Rectangles(r).Angle,2*pi); % Skeleton angle r.
		
		seg_row = Workspace.Vertices(v).Rectangles(r).Segment_Row;
		Ls = length(Workspace.Segments(seg_row).Skeleton_Linear_Coordinates); % Number of skeleton pixels (approximate segment length).
		
		if(Ls >= Rect_Length) % If the segment is long enough for convolution scanning.
			dA = nan(1,length(Peaks));
			for p=1:length(Peaks) % Find angle diff for each peak.
				if(~isnan(Ap(p)))
					dA(p) = max([As,Ap(p)]) - min([As,Ap(p)]); % Positive angle different (bigger minus smaller).
				else
					dA(p) = nan;
				end
			end
			Fmin = find(dA == min(dA),1); % Find minimum angle difference between the skeleton and peaks.
			Lr = Rect_Length;
			
			if(~isempty(Fmin)) % Update the parameters of this vertex direction.
				Cxy_r = Cxy(Fmin,:);
				Angle_Final =  Ap(Fmin); % Replace the most similar angle and set to the nan (to avoid using it for other rects).
				Ap(Fmin) = nan; % Remove the chosen angle value from the list.
			else
				Cxy_r = Workspace.Vertices(v).Coordinate;
				Angle_Final = Rectangles(r).Angle; % Angle is unchanged.
			end
		else % Use the skeleton angle.
			Fmin = [];
			Lr = Ls;
			Cxy_r = Workspace.Vertices(v).Coordinate;
			Angle_Final = Rectangles(r).Angle; % Angle is unchanged.
        end
		
        Wp = Adjust_Rect_Width_Rot_Generalized(Workspace.Im_BW,Cxy_r,Angle_Final*180/pi,Lr,[MinWidth,MaxWidth],14,Width_SmoothingParameter,Width_Ratio,Im_Rows,Im_Cols);
        Widths(r) = max([Min_Final_Width,Wp]); % Rectangle width.
		
		Rectangles(r).Origin = Cxy_r;
		Rectangles(r).Width = Widths(r) * Scale_Factor; % Conversion from pixels to micrometers.
		Rectangles(r).Length = Lr * Scale_Factor; % Conversion from pixels to micrometers.
		Rectangles(r).Angle = Angle_Final;
		
		if(Plot1)
			D = 20;
			axis([Rectangles(r).Origin(1)+[-D,+D],Rectangles(r).Origin(2)+[-D,+D]]);
			
			[XV,YV] = Get_Rect_Vector(Rectangles(r).Origin,Rectangles(r).Angle*180/pi,Widths(r),Lr,14);
			
			plot([XV,XV(1)],[YV,YV(1)],'LineWidth',3); % plot([XV,XV(1)],[YV,YV(1)],'Color',[0,0.7,0],'LineWidth',3);
			drawnow;
			waitforbuttonpress;
		end
	end
	
	if(Plot3)
		figure(1);
		hold on;
		viscircles(Cxy,Rc,'Color',[0,0.8,0],'LineWidth',8);
		plot(Cxy(1),Cxy(2),'.','Color',[0,0.8,0],'MarkerSize',30);
	end
	
end