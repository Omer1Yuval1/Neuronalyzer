function Rectangles = Find_Vertex_Angles(Data,v,Cxy,Rc,Scale_Factor,Im_Rows,Im_Cols)
	
	Plot1 = 0;
	Plot2 = 0;
	Plot3 = 0;
	
	Peaks_Max_Num = Data.Vertices(v).Order;
	
	SmoothingParameter = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_SmoothingParameter;
	MinWidth = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Min_Max(1);
	MaxWidth = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Min_Max(2);
	Width_Ratio = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Rect_Width_Ratio;
	Width_SmoothingParameter = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Width_SmoothingParameter;
	Min_Final_Width = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Min_Width;
	Extension_Length = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Extension_Length;	
	W = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Width;	
	Rect_Length = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Scan_Rect_Length;
	
	Min_Score_Ratio = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_Min_Score_Ratio;	
	MinPeakDis = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakDis;	
	MinPeakWidth = Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakWidth;	
	MinPeakProm = 0.1; % Data.Parameters.Auto_Tracing_Parameters(1).Vertex_Angles_MinPeakProm;
	
	Angle_Res = 1*(pi/180); % 1 degree. old version: round(60 * Rc); % 360*
	N = round(2*pi/Angle_Res);
	Theta = linspace(0,2*pi,N);
	
	Unique_Tolerance = Angle_Res; % MinPeakDis; % 30 * (pi/180); % 10^(-4);
	
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
			Coordinates1 = InRect_Coordinates(Data.Info.Files(1).Binary_Image,[XV',YV']);
		end
		
		Filtered_Scores(1,t) = sum(Data.Info.Files(1).Binary_Image(Coordinates1)); %  / (Rect_Length*W); % Count 1-pixels and normalize to the area of the rectangle.
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
	[Peaks,Locs,~,Proms] = findpeaks(Filtered_Scores(1,:),Theta,'MinPeakProminence',MinPeakProm,'MinPeakDistance',MinPeakDis,'MinPeakWidth',MinPeakWidth);
	
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
	[~,ia,~] = uniquetol(mod(Locs,2*pi),Unique_Tolerance); % Mod 2*pi. % [C,ia,ic] = uniquetol(mod(Locs-1,2*pi)+1,Unique_Tolerance); % Modulo that starts from 1. TODO: Why???
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
	
	% List angles & detect rectangle width for the detected peaks:
	Ap = nan(1,length(Peaks));
	Cxy = nan(length(Peaks),2);
	Widths = zeros(1,length(Peaks));
	for p=1:length(Peaks) % For each peak.
		F1 = find(Theta == Locs(p)); % Find the central angle that corresponds to this peak.		
		Ap(p) = Filtered_Scores(2,F1); % List of convolution-derived angles (locs).
		Cxy(p,:) = Pxy(F1,:);
	end
	
	% Replace skeleton angles with the detected peaks, using skeleton angles for pair-wise matching
		% (additional peaks are ignored, only best matches are used, based on the predefined number of skeleton rectangles).
	Rectangles = Data.Vertices(v).Rectangles;
	Nskel = numel(Data.Vertices(v).Rectangles); % # of skeleton rectangles.
	Nconv = length(Peaks); % # of convolution peaks.
	
	if(Nskel) % If the Rectangles struct (containing skeleton angles) is not empty (has at least one row).
		Skel_Conv_Angle_Diffs = abs(transpose(mod([Data.Vertices(v).Rectangles.Angle],2*pi)) - mod(Ap,2*pi)); % [Nskel x 1] .* [Nconv x 1] = [Nskel x Nconv]. 
		Skel_Conv_Angle_Diffs = min(Skel_Conv_Angle_Diffs , 2*pi - Skel_Conv_Angle_Diffs); % Taking min(a,360-a), for cases where skel and conv angles are close to each other in polar but not cartesian coordinates (e.g. 1 and 359).
	end
	
	for r=1:Nskel % For each pre-defined skeleton direction (= segment connected to this vertex).
		
		Use_Skel = 0;
		
		F_min_Col = find(Skel_Conv_Angle_Diffs(r,:) == min(Skel_Conv_Angle_Diffs(r,:)),1); % Find the best match for skeleton angle r (along row r).
		F_min_Row = find(Skel_Conv_Angle_Diffs(r,F_min_Col) == min(Skel_Conv_Angle_Diffs(:,F_min_Col)),1); % Check if the minimum of row r is also the minimum along its column). In other words, check if the convolution angle that best matches skeleton angle r, is the best match across all skeleton angles (in other rows).
		
		if(isempty(F_min_Row)) % If the minimum in row r is not equal to the minimum in its column, use the skeleton.
			Use_Skel = 1;
		end
		
		% TODO: convert Ls to real length unit.
		seg_row = Data.Vertices(v).Rectangles(r).Segment_Row; % Row # of the corresponding segment.
		Ls = length(Data.Segments(seg_row).Skeleton_Linear_Coordinates); % Number of skeleton pixels (approximate segment length).
		
		if(Ls >= Rect_Length && ~Use_Skel) % If the segment is long enough for convolution scanning.
			
			Angle_Final =  Ap(F_min_Col); % Replace the most similar angle and set to the nan (to avoid using it for other rects).
			Cxy_r = Cxy(F_min_Col,:); % Rectangle-specific origin on the circumference of the junction circle (this is different from the junction center point).
			Lr = Rect_Length;
		else % Use the skeleton angle.
			Lr = Ls;
			Cxy_r = [Data.Vertices(v).X,Data.Vertices(v).Y]; % Rectangle-specific origin on the circumference of the junction circle (this is different from the junction center point).
			Angle_Final = Rectangles(r).Angle; % Angle is unchanged.
		end
		
        Wp = Adjust_Rect_Width_Rot_Generalized(Data.Info.Files(1).Binary_Image,Cxy_r,Angle_Final*180/pi,Lr,[MinWidth,MaxWidth],14,Width_SmoothingParameter,Width_Ratio,Im_Rows,Im_Cols);
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