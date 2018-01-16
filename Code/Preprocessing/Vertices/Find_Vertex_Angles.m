function Rectangles = Find_Vertex_Angles(Im_BW,Cxy,Rc,Im_Rows,Im_Cols,Scale_Factor,Peaks_Max_Num)
	
	Plot1 = 0;
	Plot2 = 0;
	Plot3 = 0;
	
	% TODO: Move to the parameters func:
	SmoothingParameter = 0.99;
	MinWidth = .5;
	MaxWidth = 6;
	Width_Ratio = .9;
	Width_SmoothingParameter = 0.5;
	Min_Final_Width = 1;
	
	Angle_Res = 1*(pi/180); % 1 degree. old version: round(60 * Rc); % 360*
	N = round(2*pi/Angle_Res);
	Theta = linspace(0,2*pi,N);
	Extension_Length = 60*pi/180;
	Unique_Tolerance = Angle_Res; % 10^(-4);
	
	Polar_Extension = 2:find(abs([Theta-Extension_Length]) == min(abs([Theta-Extension_Length]))); % TODO: why start from 2?
	Extension_Neglect_Length = 20*pi/180;
	
	W = 3; % Scanning rectangle width.
	Va = 0; % (-5:5)*pi/180; % Angle range for rotation around each perimeter point. Not in Use!!!
	Vw = 2:.1:8; % :.5:5; % TODO: scale.
	Rect_Length = 5; % In pixels.
	
	Min_Score_Ratio = 0.95;
	MinPeakDis = 20*(pi/180); % 10 degrees.
	MinPeakWidth = 5*(pi/180); % 5 degrees.
	MinPeakProm = .15; % .15
	
	% switch Vertex_Type
		% case 3
			% Peaks_Max_Num = 4;
		% case 1
			% Peaks_Max_Num = 1;
	% end
	
	Filtered_Scores = zeros(3,length(Theta)); % An array of scores for each perimeter point. 1st row  = score. 2nd row = angle. 3rd row = width.
	Pxy = [Rc*cos(Theta') + Cxy(1) , Rc*sin(Theta') + Cxy(2)]; % Coordinates on the perimeter of the center circle.
	
	for t=1:length(Theta) % For each angle. Scan for signal around (and outside) the vertex center using a series of straight lines.
		
		Rects_Scores = zeros(length(Va),length(Vw)); % Rows are angles, cols are width values.
		% for w=1:length(Vw) % For each rectangle width.
			for a=1:length(Va) % For each angle (rotation using a center perimeter point (t) as the rotation origin).
				
				% [XV,YV] = Get_Rect_Vector(Pxy(t,:),(Va(a)+Theta(t))*180/pi,Vw(w),Rect_Length,14); % Theta(t) is the direction perpendicular to the circle at the current point (rotation origin = Pxy).
				% W = Adjust_Rect_Width_Rot_Generalized(Im_BW,Pxy(t,:),(Va(a)+Theta(t))*180/pi,Rect_Length,[1,6],14,0.5,0.8);
				
				[XV,YV] = Get_Rect_Vector(Pxy(t,:),Theta(t)*180/pi,W,Rect_Length,14); % Theta(t) is the direction perpendicular to the circle at the current point (rotation origin = Pxy).
				Coordinates1 = InRect_Coordinates(Im_BW,[XV',YV']);
				% assignin('base','Im_BW',Im_BW);
				% assignin('base','XV',XV);
				% assignin('base','YV',YV);
				% Filtered_Scores(1,t) = length(find(Im_BW(Coordinates1))); %  / (Rect_Length*W); % Count 1-pixels and normalize to the area of the rectangle.
				Filtered_Scores(1,t) = sum(Im_BW(Coordinates1)); %  / (Rect_Length*W); % Count 1-pixels and normalize to the area of the rectangle.
				Filtered_Scores(2,t) = Theta(t); % Take the average of all the angles values that got the best score (for a specific width value).
				% Filtered_Scores(3,t) = W; % Take the average of all the width values that got the best score (for a specific angle value).
				
				% Coordinates1 = InRect_Coordinates(Im_BW,[XV',YV']);
				% Rects_Scores(a,w) = length(find(Im_BW(Coordinates1))) / (Rect_Length*Vw(w)); % Count 1-pixels and normalize to the area of the rectangle.
				
				if(Plot3 && mod(t,30) == 0) % Draw the convolving rectangles and the peak analysis.
					hold on;
					figure(1);
					plot([XV,XV(1)],[YV,YV(1)],'LineWidth',3);
				end
			end
		% end
	end
	if(max(Filtered_Scores) > 0)
		Filtered_Scores(1,:) = Filtered_Scores(1,:) ./ max(Filtered_Scores(1,:)); % Normalize Scores to [0,1].
	end
	
	Pxy = [Pxy ; Pxy(Polar_Extension,:)];
	Theta = [Theta,Theta(Polar_Extension)+2*pi];
	Filtered_Scores = [Filtered_Scores,Filtered_Scores(:,Polar_Extension)];
	
	FitObject = fit(Theta',Filtered_Scores(1,:)','smoothingspline','SmoothingParam',SmoothingParameter);
	Raw_Scores = Filtered_Scores(1,:); % TODO: delete.
	Filtered_Scores(1,:) = FitObject(Theta);
	
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
		Widths(p) = max([Min_Final_Width,Adjust_Rect_Width_Rot_Generalized(Im_BW,Cxy,Locs(p)*180/pi,Rect_Length,[MinWidth,MaxWidth],14,Width_SmoothingParameter,Width_Ratio)]);
		[XV,YV] = Get_Rect_Vector(Cxy,Locs(p)*180/pi,Widths(p),Rect_Length,14);
		InRect1 = InRect_Coordinates(Im_BW,[XV',YV']);
		Scores(p) = length(sum(Im_BW(InRect1))) ./ length(InRect1); % Number of "1" pixels divided by the total # of pixels within the rectangle.
	end
	[~,Ip] = sort(Scores,'descend'); % Sort the normalized scores.
	
	% % assignin('base','Locs',Locs);
	% Overlaps = zeros(1,length(Peaks));
	% if(Vertex_Type == 1) % If it's a tip.
		% for p=1:length(Peaks) % Assign a score to each peak based on it's pixel overlap with the corresponding segment.
			% W = max([1,Adjust_Rect_Width_Rot_Generalized(Im_BW,Cxy,Locs(p)*180/pi,Rect_Length,[MinWidth,MaxWidth],14,Width_SmoothingParameter,Width_Ratio)]);
			% [XV,YV] = Get_Rect_Vector(Cxy,Locs(p)*180/pi,W,Rect_Length,14);
			% InRect1 = InRect_Coordinates(Im_BW,[XV',YV']);
			% Overlaps(p) = length(intersect(Segment_Coordinates,InRect1)) / length(InRect1);
			% hold on;
			% plot(XV,YV,'r','LineWidth',3);
			% disp(length(InRect1));
		% end
		% % disp(Overlaps);
		% [~,Ip] = sort(Overlaps,'descend'); % Sort the filtered peaks by pixel overlap with the corresponding segment.
	% else % Not a tip.
		% [~,Ip] = sort(Proms,'descend'); % Sort the filtered peaks by prominence.
	% end
	
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
		plot(Theta,Filtered_Scores(1,:),'k','LineWidth',4); % Fit.
		hold on;
		plot(Theta,Raw_Scores,'.r','MarkerSize',10);
		hold on;
		plot(Locs,Peaks,'.b','MarkerSize',15);
		
		findpeaks(Filtered_Scores(1,:),Theta,'MinPeakProminence',MinPeakProm,...
											'MinPeakDistance',MinPeakDis,'MinPeakWidth',MinPeakWidth,'Annotate','extents');
		
		% findpeaks(Filtered_Scores(1,:),Theta,'MinPeakProminence',MinPeakProm,'MinPeakDistance',MinPeakDis,...
		% 			'MinPeakWidth',MinPeakWidth,'Annotate','extents');
		xlabel('Angle (radians)','FontSize',20);
		ylabel('Score','FontSize',20);
		set(gca,'FontSize',20);
		xlim([0,max(Theta)]);
	end
	% disp(Widths);
	Rectangles = struct('Origin',{},'Angle',{},'Width',{},'Length',{});
	for p=1:length(Peaks)
		F1 = find(Theta == Locs(p)); % Find the central angle that corresponds to this peak.		
		Rectangles(p).Angle = Filtered_Scores(2,F1);
		% Rectangles(p).Width = Adjust_Rect_Width_Rot_Generalized(Im_BW,Pxy(F1,:),Theta(F1)*180/pi,Rect_Length,[1,6],14,0.5,0.8);
		Rectangles(p).Width = Widths(p) * Scale_Factor; % Conversion to micrometers.
		% Rectangles(p).Width = max([1,Widths(p)]);
		% Rectangles(p).Width = Filtered_Scores(3,F1);
		Rectangles(p).Length = Rect_Length * Scale_Factor; % Conversion from pixels to micrometers.
		Rectangles(p).Origin = Pxy(F1,:);
		
		if(Plot1)
			[XV,YV] = Get_Rect_Vector(Pxy(F1,:),Rectangles(p).Angle*180/pi,Widths(p),Rect_Length,14);
			plot([XV,XV(1)],[YV,YV(1)],'Color',[0,0.7,0],'LineWidth',3);
			drawnow;
			% plot(Pxy(F1,1),Pxy(F1,2),'.b','MarkerSize',15);
		end
	end
	if(Plot1 || Plot3)
		figure(1);
		hold on;
		viscircles(Cxy,Rc,'Color','r');
		plot(Cxy(1),Cxy(2),'.r','MarkerSize',30);
	end
	
end