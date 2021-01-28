function Data = Map_Worm_Axes(Data,Plot,Record,Ax)
	
	% This function uses an estimated midline to run a sliding window and find the worm axes.
	% It first corrects the estimated midline and then uses it to find the other axes by detecting peaks within each window.
	
	% TODO:
		% Add the orientation of rectangles relative to the primary branch.
		% Preallocate memory for the other axes in Data.Axes.
		% Move parameters to parameter file.
	
	Smoothing_Parameter = 100000;
	
	if(Plot || Record)
		Vid1 = VideoWriter('Sliding Window','MPEG-4');
		open(Vid1);
		figure('WindowState','maximized');
		imshow(Data.Info.Files(1).Raw_Image);
		set(gca,'YDir','normal');
		hold on;
	end
	
	MinPeakHeight = 0.05;
	Axis_1_Dist = 20; % um;
	Axis_2_Dist = 40; % um;
	Axes_Max_Error = 5; % um;
	
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	Win_Size = 40; % *20*. Size of sliding window in um.
	BinSize = 10;
	Np_Midline = numel(Data.Axes.Axis_0);
	
	Sliding_Win = struct('Index',{},'Dorsal_Length',{},'Ventral_Length',{},'Dorsal_Radius',{},'Ventral_Radius',{});
	
	Data = Collect_All_Neuron_Points(Data); % [X, Y, Length, Angle, Curvature].
	Data.Points = Find_Distance_From_Midline(Data.Points,Data.Axes,Scale_Factor,0);
	
	Sliding_Window_Vector = Win_Size+1:Np_Midline - Win_Size;
	Np_Win = length(Sliding_Window_Vector);
    
	Sliding_Win(Np_Midline).Index = 0;
	Dynamic_Midline_Error = 0;
	Dynamic_Position_Axis_1_Dorsal = Axis_1_Dist;
	Dynamic_Position_Axis_1_Ventral = -Axis_1_Dist;
	Dynamic_Position_Axis_2_Dorsal = Axis_2_Dist;
	Dynamic_Position_Axis_2_Ventral = -Axis_2_Dist;
	for w=1:Np_Midline % For each (fitted) midline point. % [round(Np_Midline./2):-1:1,round(Np_Midline./2)+1:Np_Midline]
		
		Sliding_Win(w).Index = w;
		Sliding_Win(w).Arc_Length = Data.Axes.Axis_0(w).Arc_Length;
		
		d1 = abs([Data.Axes.Axis_0.Arc_Length] - max(0,Data.Axes.Axis_0(w).Arc_Length - Win_Size));
		d2 = abs([Data.Axes.Axis_0.Arc_Length] - min(Data.Axes.Axis_0(end).Arc_Length,Data.Axes.Axis_0(w).Arc_Length + Win_Size));
		
		f1 = find(d1 == min(d1)); % Lower bound of current sliding window.
		f2 = find(d2 == min(d2)); % Upper bound of current sliding window.
		
		XY_0 = [ [Data.Axes.Axis_0(f1:f2).X]' , [Data.Axes.Axis_0(f1:f2).Y]' ]; % Window Midline Data.Points.
		XY_D = [ [Data.Axes.Axis_2_Dorsal(f1:f2).X]' , [Data.Axes.Axis_2_Dorsal(f1:f2).Y]' ]; % Window Dorsal Data.Points.
		XY_V = [ [Data.Axes.Axis_2_Ventral(f1:f2).X]' , [Data.Axes.Axis_2_Ventral(f1:f2).Y]' ]; % Window Ventral Data.Points.
		
		% Find pixels within the current window:
		In_DV = inpolygon([Data.Points.X],[Data.Points.Y],[XY_D(:,1) ; flipud(XY_V(:,1))],[XY_D(:,2) ; flipud(XY_V(:,2))]); % Entire window.
		In_D = inpolygon([Data.Points.X],[Data.Points.Y],[XY_D(:,1) ; flipud(XY_0(:,1))],[XY_D(:,2) ; flipud(XY_0(:,2))]); % Dorsal Side Only.
		In_V = inpolygon([Data.Points.X],[Data.Points.Y],[XY_V(:,1) ; flipud(XY_0(:,1))],[XY_V(:,2) ; flipud(XY_0(:,2))]); % Ventral Side Only.
		
		Sliding_Win(w).Dorsal_Length = sum(In_D)*Scale_Factor;
		Sliding_Win(w).Ventral_Length = sum(In_V)*Scale_Factor;
		
		Sliding_Win(w).Dorsal_Radius = max([Data.Points(In_D).Midline_Distance]);
		Sliding_Win(w).Ventral_Radius = abs(min([Data.Points(In_V).Midline_Distance]));
		
		Sliding_Win(w).InDV = find(In_DV); % Row numbers in Data.Points of tracing coordingates.
		Sliding_Win(w).InD = find(In_D);
		Sliding_Win(w).InV = find(In_V);
		
		Bins_1 = -50:2:50;
		[yy,edges] = histcounts([Data.Points(In_DV).Midline_Distance],Bins_1,'Normalization','Probability'); % +Dynamic_Midline_Error
		xx = (edges(1:end-1) + edges(2:end)) ./ 2;
		[Hp,Lp,Wp,Pp] = findpeaks(yy,xx,'NPeaks',5,'SortStr','descend','MinPeakHeight',MinPeakHeight);
		
		% Classify and filter peaks:
		% f0 = find(abs(Lp) == min(abs(Lp))); % Find the peak x-position closest to 0.z
		f0 = find(abs(Lp) <= Axes_Max_Error); % Find the peak x-position closest to 0, within the pre-defined error.
		f1_V = find(Lp >= (-Axis_1_Dist-Axes_Max_Error) & Lp <= (-Axis_1_Dist+Axes_Max_Error));
		f1_D = find(Lp >= (Axis_1_Dist-Axes_Max_Error) & Lp <= (Axis_1_Dist+Axes_Max_Error));
		f2_V = find(Lp >= (-Axis_2_Dist-Axes_Max_Error) & Lp <= (-Axis_2_Dist+Axes_Max_Error));
		f2_D = find(Lp >= (Axis_2_Dist-Axes_Max_Error) & Lp <= (Axis_2_Dist+Axes_Max_Error));
		
		if(~isempty(f0)) % If a peak was found and if it is within the predefined midline error limit.
			Dynamic_Midline_Error = Lp(f0(1)); % Dynamic_Midline_Error + Lp(f0(1));
		end
		Data.Axes.Axis_0(w).X1 = Data.Axes.Axis_0(w).X + (Dynamic_Midline_Error./Scale_Factor).*cos(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		Data.Axes.Axis_0(w).Y1 = Data.Axes.Axis_0(w).Y + (Dynamic_Midline_Error./Scale_Factor).*sin(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		
		% Find the peaks for the other axes, using the dynamic correction for the midline:
		if(~isempty(f1_V))
			Dynamic_Position_Axis_1_Ventral = Lp(f1_V(1));
		end
		Data.Axes.Axis_1_Ventral(w).X = Data.Axes.Axis_0(w).X + (Dynamic_Position_Axis_1_Ventral./Scale_Factor).*cos(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		Data.Axes.Axis_1_Ventral(w).Y = Data.Axes.Axis_0(w).Y + (Dynamic_Position_Axis_1_Ventral./Scale_Factor).*sin(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		
		if(~isempty(f1_D))
			Dynamic_Position_Axis_1_Dorsal = Lp(f1_D(1));
		end
		Data.Axes.Axis_1_Dorsal(w).X = Data.Axes.Axis_0(w).X + (Dynamic_Position_Axis_1_Dorsal./Scale_Factor).*cos(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		Data.Axes.Axis_1_Dorsal(w).Y = Data.Axes.Axis_0(w).Y + (Dynamic_Position_Axis_1_Dorsal./Scale_Factor).*sin(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		
		if(~isempty(f2_V))
			Dynamic_Position_Axis_2_Ventral = Lp(f2_V(1));
		end
		Data.Axes.Axis_2_Ventral(w).X = Data.Axes.Axis_0(w).X + (Dynamic_Position_Axis_2_Ventral./Scale_Factor).*cos(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		Data.Axes.Axis_2_Ventral(w).Y = Data.Axes.Axis_0(w).Y + (Dynamic_Position_Axis_2_Ventral./Scale_Factor).*sin(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		
		if(~isempty(f2_D))
			Dynamic_Position_Axis_2_Dorsal = Lp(f2_D(1));
		end
		Data.Axes.Axis_2_Dorsal(w).X = Data.Axes.Axis_0(w).X + (Dynamic_Position_Axis_2_Dorsal./Scale_Factor).*cos(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		Data.Axes.Axis_2_Dorsal(w).Y = Data.Axes.Axis_0(w).Y + (Dynamic_Position_Axis_2_Dorsal./Scale_Factor).*sin(Data.Axes.Axis_0(w).Tangent_Angle + (pi/2));
		
		if(Plot)
			
			delete(findobj(gca,'-not','Type','image','-and','-not','Type','axes')); % Ax
			
			% Histograms of distances from the midline.
			%{
			clf;
			% Bins_2 = 0:5:60;
			subplot(2,1,1);
				histogram([Data.Points(In_DV).Midline_Distance],Bins_1,'Normalization','Probability'); % +Dynamic_Midline_Error
				hold on;
				findpeaks(yy,xx,'NPeaks',5,'SortStr','descend','MinPeakHeight',MinPeakHeight);
				
				set(gca,'FontSize',14);
				xlabel('Distance from Midline [um]','FontSize',16);
				ylabel('Count','FontSize',16);
				axis([Bins_1(1),Bins_1(end),0,0.3]); % 300.
				
			subplot(2,1,2); % subplot(2,3,[4,5,6]);
			%}
				% imshow(Data.Info.Files(1).Raw_Image);
				% set(gca,'YDir','normal');
				% hold on;
				x0 = max(1,f1-60);
				
				% plot([Data.Axes.Axis_0(x0:f1).X1],[Data.Axes.Axis_0(x0:f1).Y1],'Color',[0.6,0,0],'LineWidth',3);
				% plot([Data.Axes.Axis_1_Dorsal(x0:f1).X],[Data.Axes.Axis_1_Dorsal(x0:f1).Y],'Color',[0,0.8,0.8],'LineWidth',3);
				% plot([Data.Axes.Axis_1_Ventral(x0:f1).X],[Data.Axes.Axis_1_Ventral(x0:f1).Y],'Color',[0,0.8,0.8],'LineWidth',3);
				
				% TODO: use the color to show the density of points at each distance. Or just the distance.
				O_D = rescale(abs([Data.Points(In_D).Midline_Distance]))';
				O_V = rescale(abs([Data.Points(In_V).Midline_Distance]))';
				
				scatter([Data.Points(In_D).X],[Data.Points(In_D).Y],20,[1-O_D,0.*O_D,O_D],'filled'); % plot([Data.Points(In_D).X],[Data.Points(In_D).Y],'.b');
				scatter([Data.Points(In_V).X],[Data.Points(In_V).Y],20,[1-O_V,0.*O_V,O_V],'filled'); % plot([Data.Points(In_V).X],[Data.Points(In_V).Y],'.r');
				
				% Display the running window:
				% plot([XY_D(:,1) ; flipud(XY_V(:,1)) ; XY_D(1,1)] , [XY_D(:,2) ; flipud(XY_V(:,2)) ; XY_D(1,1)],'Color',[0.8,0.4,0],'LineWidth',3);
				% plot(XY_D(1,1) , XY_D(1,2),'.r');
				% plot([XY_D(:,1) ; flipud(XY_0(:,1)) ; XY_D(1,1)] , [XY_D(:,2) ; flipud(XY_0(:,2)) ; XY_D(1,2)],'k','LineWidth',3);
				% plot([XY_V(:,1) ; flipud(XY_0(:,1)) ; XY_V(1,1)] , [XY_V(:,2) ; flipud(XY_0(:,2)) ; XY_V(1,2)],'k','LineWidth',3);
				
				%{
				% Plot the center points of the window:
				plot([Data.Axes.Axis_0(w).X1],[Data.Axes.Axis_0(w).Y1],'.g','MarkerSize',20);
				plot([Data.Axes.Axis_1_Dorsal(w).X],[Data.Axes.Axis_1_Dorsal(w).Y],'.m','MarkerSize',20);
				plot([Data.Axes.Axis_1_Ventral(w).X],[Data.Axes.Axis_1_Ventral(w).Y],'.m','MarkerSize',20);
				plot([Data.Axes.Axis_2_Dorsal(w).X],[Data.Axes.Axis_2_Dorsal(w).Y],'.y','MarkerSize',20);
				plot([Data.Axes.Axis_2_Ventral(w).X],[Data.Axes.Axis_2_Ventral(w).Y],'.y','MarkerSize',20);
				%}
				
			drawnow;
			
			if(w > 800)
				Np = 1000;
				XY_All = []; % zeros(2,Np0,5);
				XY_All_Fit = zeros(2,Np,5);
				XY_All(:,:,1) = [Data.Axes.Axis_0.X ; Data.Axes.Axis_0.Y];
				XY_All(:,:,2) = [Data.Axes.Axis_1_Dorsal.X ; Data.Axes.Axis_1_Dorsal.Y];
				XY_All(:,:,3) = [Data.Axes.Axis_1_Ventral.X ; Data.Axes.Axis_1_Ventral.Y];
				XY_All(:,:,4) = [Data.Axes.Axis_2_Dorsal.X ; Data.Axes.Axis_2_Dorsal.Y];
				XY_All(:,:,5) = [Data.Axes.Axis_2_Ventral.X ; Data.Axes.Axis_2_Ventral.Y];
				
				CM = lines(7);
				CM = CM([7,1,1,3,3],:);
				% Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0,0.8,0.8 ; 0,0,1 ; 0.8,0.8,0 ; 0.5,0.5,0.5];
				for ii=1:5
					pp = cscvn(XY_All(:,:,ii)); % Fit a cubic spline.
					Vb = linspace(pp.breaks(1),pp.breaks(end),Np);
					XY_All_Fit(:,:,ii) = fnval(pp,Vb); % XY = fnval(pp,Vb);
					if(ii <= 3)
						plot(gca,XY_All_Fit(1,1:750,ii),XY_All_Fit(2,1:750,ii),'Color',CM(ii,:),'LineWidth',5);
					else
						plot(gca,XY_All_Fit(1,:,ii),XY_All_Fit(2,:,ii),'Color',CM(ii,:),'LineWidth',5);
					end
				end
				
				figure(5); clf(5);
				Bins_1 = -40:4:40;
				histogram([Data.Points(In_DV).Midline_Distance],Bins_1,'Normalization','Probability');
				% hold on;
				% findpeaks(yy,xx,'NPeaks',5,'SortStr','descend','MinPeakHeight',MinPeakHeight);
				
				set(gcf,'Position',[10,50,900,900]);
				set(gca,'unit','normalize');
				xlabel(['Midline Distance (',char(181),'m)']);
				ylabel(['Count']);
				set(gca,'position',[0.18,0.17,0.78,0.8],'FontSize',36);
				axis tight;
				
				waitforbuttonpress;
			end
			if(Record)
				F = getframe(gcf);
				writeVideo(Vid1,F);
			end
		end
	end
	
	if(Plot && Record)
		if(Plot)
			set(gcf,'Position',[114,469,1692,498]);
			set(gca,'unit','normalize');
			set(gca,'position',[0,0,1,1]);
		end
		close(Vid1);
	end
	
	if(Plot == 2)
		X0 = [Data.Axes.Axis_0.X];
		Y0 = [Data.Axes.Axis_0.Y];
	end
	
	% Update the corrected midline points (this is done in a separate loop to allow for fitting\smoothing after finding the correction factor for all points):
	% X = [Data.Axes.Axis_0.X] + ([Data.Axes.Axis_0.Correction_Pix]./Scale_Factor).*cos([Data.Axes.Axis_0.Tangent_Angle] + (pi/2));
	% Y = [Data.Axes.Axis_0.Y] + ([Data.Axes.Axis_0.Correction_Pix]./Scale_Factor).*sin([Data.Axes.Axis_0.Tangent_Angle] + (pi/2));
	
	% After the midline correction, find again the arc-lengths and tangents:
	XY = cell2mat(smoothn(num2cell([[Data.Axes.Axis_0.X1]' , [Data.Axes.Axis_0.Y1]'],1),Smoothing_Parameter)); % Smoothing. % XY = cell2mat(smoothn(num2cell([X' , Y'],1),Smoothing_Parameter)); % Smoothing.
	Data.Axes.Axis_0 = rmfield(Data.Axes.Axis_0,{'X1','Y1'});
	
	pp = cscvn(transpose(XY)); % Fit a cubic spline.
	Vb = linspace(pp.breaks(1),pp.breaks(end),Np_Midline);
	XY = transpose(fnval(pp,Vb));
	dxy = sum((XY(2:end,:) - XY(1:end-1,:)).^2,2).^(0.5);
	Midline_Arc_Length = cumsum([0 ; dxy]) .* Scale_Factor; % pixels to real length units (um).
	
	pp_Der1 = fnder(pp,1);
	XY_Der = transpose(fnval(pp_Der1,Vb)); % [Nx2].
	Tangent_Angles = atan2(XY_Der(:,2),XY_Der(:,1));
	
	% TODO: replace with a single assignment operation:
	for w=1:Np_Midline
		Data.Axes.Axis_0(w).X = XY(w,1);
		Data.Axes.Axis_0(w).Y = XY(w,2);
		Data.Axes.Axis_0(w).Arc_Length = Midline_Arc_Length(w);
		Data.Axes.Axis_0(w).Tangent_Angle = Tangent_Angles(w);
    end
	
	% Now update the signed midline distance for all points after correcting the midline:
	Data.Points = Find_Distance_From_Midline(Data.Points,Data.Axes,Scale_Factor,1);
	Data.Vertices = Find_Distance_From_Midline(Data.Vertices,Data.Axes,Scale_Factor,1);
	
	if(Plot == 2)
		figure;
		imshow(Data.Info.Files(1).Raw_Image);
		hold on;
		plot(X0,Y0,'r','LineWidth',2);
		plot([Data.Axes.Axis_0.X],[Data.Axes.Axis_0.Y],'g','LineWidth',2);
	end
	
	
	% Define a range of midline points.
	% Use it to define a dorsal and ventral window.
	
	% find the total length within each window.
	
	% show the histogram of length as a function of distance from the midline
end