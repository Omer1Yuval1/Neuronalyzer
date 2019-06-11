function [Sxy,Sliding_Win] = Map_Worm_Axes(W,S)
	
	% TODO:
		% Add the orientation of rectangles relative to the primary branch.
	
	Record = 1;
	if(Record)
		Vid1 = VideoWriter('Sliding Window','MPEG-4');
		open(Vid1);
		figure('WindowState','maximized');
	end
	
	MinPeakHeight = 0.05;
	Medial_Max_Error = 10; % um;
	
	Scale_Factor = W.User_Input.Scale_Factor;
	Win_Size = 20; % Size of sliding window in um.
	BinSize = 10;
	
	Sliding_Win = struct('Index',{},'Dorsal_Length',{},'Ventral_Length',{},'Dorsal_Radius',{},'Ventral_Radius',{});
	Sxy = [W.Segments.Rectangles]; % [X , Y , Width,Curvature , In_Dorsal , In_Ventral , Medial_Distance, Medial_Position].
	
	Np_Midline = length(S.Normal_Angles);
	
	In_Dorsal = inpolygon([Sxy.X],[Sxy.Y],[S.Midline_Points(:,1) ; flipud(S.Boundary_Points_Dorsal(:,1))],[S.Midline_Points(:,2) ; flipud(S.Boundary_Points_Dorsal(:,2))]); % All.
	In_Ventral = inpolygon([Sxy.X],[Sxy.Y],[S.Midline_Points(:,1) ; flipud(S.Boundary_Points_Ventral(:,1))],[S.Midline_Points(:,2) ; flipud(S.Boundary_Points_Ventral(:,2))]); % All.
	
	for p=1:numel(Sxy) % For each tracing point.
		
		Sxy(p).In_Dorsal = In_Dorsal(p);
		Sxy(p).In_Ventral = In_Ventral(p);
		
		Dp = ( ( Sxy(p).X -  S.Midline_Points(:,1) ).^2 + ( Sxy(p).Y -  S.Midline_Points(:,2) ).^2).^(.5); % Distances from all midlines points.
		f = find(Dp == min(Dp));
		f = f(1);
		
		if(Sxy(p).In_Dorsal) % If a dorsal pixel.
			Sxy(p).Medial_Distance = Dp(f) * Scale_Factor; % Pixels to um.
		elseif(Sxy(p).In_Ventral)
			Sxy(p).Medial_Distance = -Dp(f) * Scale_Factor; % Pixels to um.
		else
			Sxy(p).Medial_Distance = nan;
		end
		
		Sxy(p).Medial_Position = S.Midline_Arc_Length(f);
	end
	
	Sliding_Window_Vector = Win_Size+1:Np_Midline - Win_Size;
	Np_Win = length(Sliding_Window_Vector);
    
	Np = size(S.Midline_Points,1);
	Sliding_Win(Np).Index = 0;
	Midline_Points_Correction = nan(1,Np);
	for w=1:Np % For each (fitted) midline point.
		
		Sliding_Win(w).Index = w;
		Sliding_Win(w).Arc_Length = S.Midline_Arc_Length(w);
		
		d1 = abs([S.Midline_Arc_Length] - max(0,S.Midline_Arc_Length(w) - Win_Size));
		d2 = abs([S.Midline_Arc_Length] - min(S.Midline_Arc_Length(end),S.Midline_Arc_Length(w) + Win_Size));
		
		f1 = find(d1 == min(d1)); % Lower bound of current sliding window.
		f2 = find(d2 == min(d2)); % Upper bound of current sliding window.
		
		XY_0 = S.Midline_Points(f1:f2,:); % Window Midline Points.
		XY_D = S.Boundary_Points_Dorsal(f1:f2,:); % Window Dorsal Points.
		XY_V = S.Boundary_Points_Ventral(f1:f2,:); % Window Ventral Points.
		
		% Find pixels within the current window:
		In_DV = inpolygon([Sxy.X],[Sxy.Y],[XY_D(:,1) ; flipud(XY_V(:,1))],[XY_D(:,2) ; flipud(XY_V(:,2))]); % Entire window.
		In_D = inpolygon([Sxy.X],[Sxy.Y],[XY_D(:,1) ; flipud(XY_0(:,1))],[XY_D(:,2) ; flipud(XY_0(:,2))]); % Dorsal Side Only.
		In_V = inpolygon([Sxy.X],[Sxy.Y],[XY_V(:,1) ; flipud(XY_0(:,1))],[XY_V(:,2) ; flipud(XY_0(:,2))]); % Ventral Side Only.
		
		Sliding_Win(w).Dorsal_Length = sum(In_D)*Scale_Factor;
		Sliding_Win(w).Ventral_Length = sum(In_V)*Scale_Factor;
		
		Sliding_Win(w).Dorsal_Radius = max([Sxy(In_D).Medial_Distance]);
		Sliding_Win(w).Ventral_Radius = abs(min([Sxy(In_V).Medial_Distance]));
		
		Sliding_Win(w).InDV = find(In_DV); % Row numbers in Sxy of tracing coordingates.
		Sliding_Win(w).InD = find(In_D);
		Sliding_Win(w).InV = find(In_V);
		
		if(Record)
			% Histograms of distances from the midline.
			clf;
			Bins_1 = -50:2:50;
			% Bins_2 = 0:5:60;
			subplot(2,1,1);
				histogram([Sxy(In_DV).Medial_Distance],Bins_1,'Normalization','Probability');
				[yy,edges] = histcounts([Sxy(In_DV).Medial_Distance],Bins_1,'Normalization','Probability');
				xx = (edges(1:end-1) + edges(2:end)) ./ 2;
				
				hold on;
				findpeaks(yy,xx,'NPeaks',5,'SortStr','descend','MinPeakHeight',MinPeakHeight);
				[Hp,Lp,Wp,Pp] = findpeaks(yy,xx,'NPeaks',5,'SortStr','descend','MinPeakHeight',MinPeakHeight);
				
				f0 = find(abs(Lp) == min(abs(Lp))); % Find the peak closest to 0.
				% L0 = l(f0(1));
				
				if(~isempty(f0) && abs(Lp(f0(1))) <= Medial_Max_Error)
					
					Midline_Points_Correction(w) = Lp(f0(1));
					
					hold on;
					plot(Lp(f0(1)),Hp(f0(1)),'.g','MarkerSize',30);
				end
				
				set(gca,'FontSize',14);
				xlabel('Distance from Midline [um]','FontSize',16);
				ylabel('Count','FontSize',16);
				axis([Bins_1(1),Bins_1(end),0,0.3]); % 300.
				
			subplot(2,1,2); % subplot(2,3,[4,5,6]);
				imshow(W.Image0);
				set(gca,'YDir','normal');
				hold on;
				
				plot([Sxy(In_D).X],[Sxy(In_D).Y],'.b'); % ,'Color',[0,0.4470,0.7410]);
				plot([Sxy(In_V).X],[Sxy(In_V).Y],'.r'); % ,'Color',[0.8500,0.3250,0.0980]);
				
				plot([XY_D(:,1) ; flipud(XY_0(:,1)) ; XY_D(1,1)] , [XY_D(:,2) ; flipud(XY_0(:,2)) ; XY_D(1,2)],'LineWidth',3);
				plot([XY_V(:,1) ; flipud(XY_0(:,1)) ; XY_V(1,1)] , [XY_V(:,2) ; flipud(XY_0(:,2)) ; XY_V(1,2)],'LineWidth',3);
				
				plot(S.Midline_Points(w,1),S.Midline_Points(w,2),'.g','MarkerSize',20);
				
			F = getframe(gcf);
			writeVideo(Vid1,F);
		end
	end
	if(Record)
		close(Vid1);
	end
	
	assignin('base','Midline_Points_Correction',Midline_Points_Correction);
	
	figure;
	imshow(W.Image0);
	hold on;
    plot(S.Midline_Points(:,1),S.Midline_Points(:,2),'r','LineWidth',2);
    for w=1:Np
        if(~isnan(Midline_Points_Correction(w)))
            x = S.Midline_Points(w,1);
            y = S.Midline_Points(w,2);
            a = S.Normal_Angles(w);
            x = x + (Midline_Points_Correction(w)./Scale_Factor)*cos(a);
            y = y + (Midline_Points_Correction(w)./Scale_Factor)*sin(a);
            plot(x,y,'.g','MarkerSize',5);
        end
    end
	
	%{
	figure(2); clf(2);
		subplot(2,1,1); % Dislpay the raw image overlaid with the skeleton points with color separation of dorsal & ventral.
			imshow(W.Image0);
			set(gca,'YDir','normal');
			hold on;
			plot([Sxy(In_Dorsal).X] , [Sxy(In_Dorsal).Y],'.r');
			plot([Sxy(In_Ventral).X] , [Sxy(In_Ventral).Y],'.b');
		subplot(2,1,2);
			imshow(W.Image0);
			set(gca,'YDir','normal');
			hold on;
			D = rescale([Sxy.Medial_Distance]');
			scatter([Sxy.X],[Sxy.Y],10,[D,zeros(length(D),1),1-D],'filled');
		
	figure(3); clf(3);
		subplot(2,1,1);
			plot([Sliding_Win.Index],[Sliding_Win.Dorsal_Length],'LineWidth',2);
			hold on;
			plot([Sliding_Win.Index],[Sliding_Win.Ventral_Length],'LineWidth',2);
			plot([Sliding_Win.Index],[Sliding_Win.Dorsal_Length] + [Sliding_Win.Ventral_Length],'k','LineWidth',2);
			xlim([1,Np_Win]);
			xlabel('Midline Point Index');
			ylabel('# of Skeleton pixels');
			legend({'Dorsal','Ventral','All'});
			set(gca,'FontSize',16);
		subplot(2,1,2);
			plot([Sliding_Win.Index],[Sliding_Win.Dorsal_Radius],'LineWidth',2);
			hold on;
			plot([Sliding_Win.Index],[Sliding_Win.Ventral_Radius],'LineWidth',2);
			xlim([1,Np_Win]);
			xlabel('Midline Point Index');
			ylabel('Radius');
			legend({'Dorsal','Ventral'});
			set(gca,'FontSize',16);
	%}
	% Define a range of midline points.
	% Use it to define a dorsal and ventral window.
	
	% find the total length within each window.
	
	% show the histogram of length as a function of distance from the midline
end