function [CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(Im,CB_Perimeter,CB_Pixels,Scale_Factor,GS2BW_Threshold,Plot1)
	
	% TODO: add a step that finds the best perimeter point to start with.
	
	% Plot1 = 0;
	% [CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Im,0.9,Scale_Factor,1);
	
	Pixels1 = [];
	Pixels0 = [];
	
	SmoothingParameter = 0.95;
	Rect_Length = 25 * Scale_Factor;
	Rect_Width = 10 * Scale_Factor;
	Peak_Analysis_X_Extension = 1/6;
	Extension_Neglect_Length = Peak_Analysis_X_Extension / 3;
	
	Diff01 = 1; % TODO: scale. Difference in pixels between the rectangle length of 0 and 1 rectangles. The idea is to delete the 0s and assign 1 for the 1s rects in such a way that doesn't create gaps in the BW image.
	
	Rotation_Range = 20;
	Rotation_Res = 2;
	MinPeakProm = 0.2;
	% MinPeakDis = ;
	
	Width_Scan_Range = [1,2*Rect_Width];
	Width_Smoothing_Parameter = 0.5;
	Width_Ratio = 0.8;
	
	Im(CB_Pixels) = 0; % Set all CB pixels to 0 (so they won't be detected as signal).
	Im = im2bw(Im,GS2BW_Threshold);
	
	% Generate a CB perimeter matrix:
	[Sr,Sc] = size(Im);
	Im_BW = logical(zeros(Sr,Sc));
	if(length(CB_Perimeter))
		Im_BW(sub2ind([Sr,Sc],CB_Perimeter(:,2),CB_Perimeter(:,1))) = 1;
		Pixels_List = Order_Connected_Pixels(Im_BW,[CB_Perimeter(1,1),CB_Perimeter(1,2)],[CB_Perimeter(2,1),CB_Perimeter(2,2)]);
	end % Pixels_List is a [N,3] matrix such that [N,1:2] = [x,y] and [N,3] are the distances from one of the points (the 1st).
	CB_Center = [mean(Pixels_List(:,1)),mean(Pixels_List(:,2))];
	
	if(Plot1 || 0) % Plot CB perimeter pixels.
		% figure;
		% imshow(Im);
		hold on;
		plot(Pixels_List(:,1),Pixels_List(:,2),'b','LineWidth',3);
		% plot(CB_Perimeter(:,1),CB_Perimeter(:,2),'.b','MarkerSize',20); % plot(CB_Perimeter([8,43,81,132,158,160],1),CB_Perimeter([8,43,81,132,158,160],2),'.r','MarkerSize',20);
	end
	
	Np = size(Pixels_List,1); % Number of perimeter pixels.
	Scores = zeros(1,Np);
	Angles = zeros(1,Np);
	for p=1:Np % For each perimeter pixel.
		Angle = atan2d(Pixels_List(p,2) - CB_Center(2),Pixels_List(p,1) - CB_Center(1));
		Score = Rect_Scan_Generalized(Im,Pixels_List(p,:),Angle,Rect_Width,Rect_Length,Rotation_Range,Rotation_Res,14,Sr,Sc);
		
		M = find([Score(:,2)] == max([Score(:,2)]));
		Scores(p) = Score(M(1),2); % Mean Pixel Value.
		Angles(p) = Score(M(1),1); % Choose the angle of the rectangle with the best score.
		
		[XV,YV] = Get_Rect_Vector(Pixels_List(p,1:2),Angles(p),Rect_Width,Rect_Length-Diff01,14);
		Coordinates1 = InRect_Coordinates(Im,[XV',YV']);
		Pixels0 = [Pixels0,Coordinates1];
		
		if(0 && mod(p,4) == 0)
			hold on;
			plot([XV,XV(1)],[YV,YV(1)],'LineWidth',3);
			D = 60;
			axis([CB_Center(1)-D,CB_Center(1)+D,CB_Center(2)-D,CB_Center(2)+D]);
		end
	end
	
	CB_Vertices = struct('Coordinate',{},'Angle',{},'Rect_Length',{},'Rect_Width',{},'Score',{});
	if(Np)
		
		% MinPeakDis = 0;
		% MinPeakWidth = 0;
		% Scan_Perimeter_Pixels(Im,Pixels_List(:,1),Pixels_List(:,2),CB_Center,MinPeakProm,MinPeakDis,MinPeakWidth);
		
		Np_Add = round(Np*Peak_Analysis_X_Extension); % Number of points to add to the x-axis.
		X = 1:Np;
		X = [X , Np+X(1:Np_Add)]; % X must be increasing.
		Y = [Scores , Scores(1:Np_Add)];
		Angles = [Angles , Angles(1:Np_Add)]; % Extend also the angles vector to match angles and peaks (after peak analysis).
		Pixels_List = [Pixels_List ; Pixels_List(1:Np_Add,:)];
		
		% FitObject = fit(X',Y','smoothingspline','SmoothingParam',SmoothingParameter);
		% Y = FitObject(X);
		
		[Peaks,Locs] = findpeaks(Y,X,'MinPeakProminence',MinPeakProm);
		
		% Delete peaks at the edges (using Extension_Neglect_Length):
		F = find(Locs >= Extension_Neglect_Length & Locs <= (Np + Np_Add - Extension_Neglect_Length));
		Peaks = Peaks(F);
		Locs = Locs(F);
		
		% Merge duplicate peaks:
		Unique_Tolerance = 0;
		[C,ia,ic] = uniquetol(mod(Locs,2*pi),Unique_Tolerance); % Input(ia) = C.
		ia = sort(ia); % Sort just to have increasing indices. This doesn't make a significant difference.
		Peaks = Peaks(ia);
		Locs = Locs(ia);
		for p=1:length(Peaks) % For each peak.
			CB_Vertices(p).Coordinate = Pixels_List(Locs(p),1:2); % The coordinate on the CB perimeter.
			CB_Vertices(p).Angle = Angles(Locs(p));
			CB_Vertices(p).Score = Y(Locs(p)); % Y is the extended Scores array.
			CB_Vertices(p).Rect_Length = Rect_Length;
			CB_Vertices(p).Rect_Width = Adjust_Rect_Width_Rot_Generalized(Im,CB_Vertices(end).Coordinate,CB_Vertices(end).Angle, ...
														Rect_Length,Width_Scan_Range,14,Width_Smoothing_Parameter,Width_Ratio);
			% Width can be used to detect the primary branch (and probably also the axon).
			
			[XV,YV] = Get_Rect_Vector(CB_Vertices(p).Coordinate,CB_Vertices(p).Angle,CB_Vertices(p).Rect_Width,CB_Vertices(p).Rect_Length,14);
			Coordinates1 = InRect_Coordinates(Im,[XV',YV']);
			Pixels1 = [Pixels1,Coordinates1];
			
			if(Plot1)
				figure(1);
				% [XV,YV] = Get_Rect_Vector(CB_Vertices(p).Coordinate,CB_Vertices(p).Angle,CB_Vertices(p).Rect_Width,CB_Vertices(p).Rect_Length,14);
				hold on;
				plot([XV,XV(1)],[YV,YV(1)],'LineWidth',2);
				plot(mean([XV(1),XV(4)]),mean([YV(1),YV(4)]),'.r','MarkerSize',10);
			end
			
			CB_Vertices(p).Coordinates = InRect_Coordinates(Im,[XV',YV']); % The coordinates of all the branch outset pixels.
		end
		
		if(0)
			figure(1);
			D = 60;
			axis([CB_Center(1)-D,CB_Center(1)+D,CB_Center(2)-D,CB_Center(2)+D]);
			
			figure;
			% plot(X,Y,'.','MarkerSize',20);
			% hold on;
			% plot(X,Y);
			% hold on;
			findpeaks(Y,X,'MinPeakProminence',MinPeakProm);
			hold on;
			plot(X,Y,'k','LineWidth',3);
			
			xlabel('Perimeter Pixels Indices','FontSize',20);
			ylabel('Score','FontSize',20);
			set(gca,'FontSize',20);
			ylim([0,1.1]);
		end
	end
	
end