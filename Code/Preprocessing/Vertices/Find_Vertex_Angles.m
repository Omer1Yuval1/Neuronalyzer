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
	
	% Part of the range is duplicated becuase the x-axis is angle. So find duplicated peaks and delete them:
	% [C,ia,ic] = uniquetol(mod(Locs-1,2*pi)+1,Unique_Tolerance); % Modulo that starts from 1. TODO: Why???
	[C,ia,ic] = uniquetol(mod(Locs,2*pi),Unique_Tolerance); % Mod 2*pi.
	ia = sort(ia);
	Peaks = Peaks(ia);
	Locs = Locs(ia);
	% Widths = Widths(ia);
	Proms = Proms(ia);
	
	% Detect width of peaks, assign an updated score value and sort by this score:
	Scores = zeros(1,length(Peaks));
	Widths = zeros(1,length(Peaks));
	for p=1:length(Peaks)
		Widths(p) = max([Min_Final_Width,Adjust_Rect_Width_Rot_Generalized(Workspace.Im_BW,Cxy,Locs(p)*180/pi,Rect_Length,...
								[MinWidth,MaxWidth],14,Width_SmoothingParameter,Width_Ratio,Im_Rows,Im_Cols)]);
		[XV,YV] = Get_Rect_Vector(Cxy,Locs(p)*180/pi,Widths(p),Rect_Length,14);
		
		if(min(XV) >= 1 && max(XV) <= Im_Cols && min(YV) >= 1 && max(YV) <= Im_Rows)
			InRect1 = InRect_Coordinates(Workspace.Im_BW,[XV',YV']);
			Scores(p) = length(sum(Workspace.Im_BW(InRect1))) ./ length(InRect1); % Number of "1" pixels divided by the total # of pixels within the rectangle.
		else
			Scores(p) = 0; % Number of "1" pixels divided by the total # of pixels within the rectangle.
		end
	end
	[~,Ip] = sort(Scores,'descend'); % Sort the normalized scores.
	
	%{
	Overlaps = zeros(1,length(Peaks));
	if(Vertex_Type == 1) % If it's a tip.
		for p=1:length(Peaks) % Assign a score to each peak based on it's pixel overlap with the corresponding segment.
			W = max([1,Adjust_Rect_Width_Rot_Generalized(Workspace.Im_BW,Cxy,Locs(p)*180/pi,Rect_Length,[MinWidth,MaxWidth],14,Width_SmoothingParameter,Width_Ratio)]);
			[XV,YV] = Get_Rect_Vector(Cxy,Locs(p)*180/pi,W,Rect_Length,14);
			InRect1 = InRect_Coordinates(Workspace.Im_BW,[XV',YV']);
			Overlaps(p) = length(intersect(Segment_Coordinates,InRect1)) / length(InRect1);
			hold on;
			plot(XV,YV,'r','LineWidth',3);
			disp(length(InRect1));
		end
		% disp(Overlaps);
		[~,Ip] = sort(Overlaps,'descend'); % Sort the filtered peaks by pixel overlap with the corresponding segment.
	else % Not a tip.
		[~,Ip] = sort(Proms,'descend'); % Sort the filtered peaks by prominence.
	end
	%}
	
	Peaks = Peaks(Ip);
	Locs = Locs(Ip);
	Widths = Widths(Ip);
	Proms = Proms(Ip);
	
	% Take 1st Peaks_Max_Num (e.g. 3) peaks:
	np = length(Peaks);
	Peaks = Peaks(1:min(np,Peaks_Max_Num));
	Locs = Locs(1:min(np,Peaks_Max_Num));
	Widths = Widths(1:min(np,Peaks_Max_Num));
	Proms = Proms(1:min(np,Peaks_Max_Num));
	
	% disp(mod(Locs,2*pi));
	
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
	
	Ap = nan(1,length(Peaks));
	dA = nan(1,length(Peaks));
	Cxy = nan(length(Peaks),2);
	for p=1:length(Peaks) % List angles.
		F1 = find(Theta == Locs(p)); % Find the central angle that corresponds to this peak.		
		Ap(p) = Filtered_Scores(2,F1);
		Cxy(p,:) = Pxy(F1,:);
	end
	
	Rectangles = Workspace.Vertices(v).Rectangles;
	for r=1:numel(Workspace.Vertices(v).Rectangles) % For each pre-defined skeleton direction (= segment connected to this vertex).
		As = mod(Workspace.Vertices(v).Rectangles(r).Angle,2*pi); % Skeleton angle r.
		
		dA = nan(1,length(Peaks));
		for p=1:length(Peaks) % Find angle diff for each peak.
			if(~isnan(Ap(p)))
				dA(p) = max([As,Ap(p)]) - min([As,Ap(p)]); % Positive angle different (bigger minus smaller).
			else
				dA(p) = nan;
			end
		end
		
		Fmin = find(dA == min(dA),1); % Find minimum angle difference between the skeleton and peaks.
			
		if(~isempty(Fmin)) % Update the parameters of this vertex direction.
			Rectangles(r).Origin = Cxy(Fmin,:);
			Rectangles(r).Width = Widths(Fmin) * Scale_Factor; % Conversion from pixels to micrometers.
			Rectangles(r).Length = Rect_Length * Scale_Factor; % Conversion from pixels to micrometers.
			Rectangles(r).Angle = Ap(Fmin);
			
			Ap(Fmin) = nan; % Remove the chosen angle value from the list.
			
			if(Plot1)
				D = 8;
				axis([Cxy(1)+[-D,+D],Cxy(2)+[-D,+D]]);
				
				[XV,YV] = Get_Rect_Vector(Pxy(F1,:),Rectangles(p).Angle*180/pi,Widths(p),Rect_Length,14);
				
				plot([XV,XV(1)],[YV,YV(1)],'LineWidth',4); % plot([XV,XV(1)],[YV,YV(1)],'Color',[0,0.7,0],'LineWidth',3);
				drawnow;
				waitforbuttonpress;
				% plot(Pxy(F1,1),Pxy(F1,2),'.b','MarkerSize',15);
			end
		end
	end
	
	if(Plot1 || Plot3)
		figure(1);
		hold on;
		viscircles(Cxy,Rc,'Color',[0,0.8,0],'LineWidth',8);
		plot(Cxy(1),Cxy(2),'.','Color',[0,0.8,0],'MarkerSize',30);
	end
	
end