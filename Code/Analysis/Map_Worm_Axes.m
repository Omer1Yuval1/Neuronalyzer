function Sliding_Window_Struct = Map_Worm_Axes(W,S)
	
	Record = 1;
	if(Record)
		Vid1 = VideoWriter('Sliding Window','MPEG-4');
		open(Vid1);
		figure('WindowState','maximized');
	end
	
	
	Sliding_Window_Struct = struct('Index',{},'Dorsal_Length',{},'Ventral_Length',{},'Dorsal_Radius',{},'Ventral_Radius',{});
	
	Win_Size = 25; % Points.
	
	Np_Midline = length(S.Normal_Angles);
	
	Im_Skel = Pixel_Trace_Post_Proccessing(W.Im_BW);
	[Fy,Fx] = find(Im_Skel);
	Np_Skel = length(Fx);
	Sxy = [Fx,Fy,zeros(Np_Skel,3)]; % [N x 4] = N x [X,Y,D,V,Distance]. All pixels of the neuron's skeleton.
	
	In_Dorsal = inpolygon(Sxy(:,1),Sxy(:,2),[S.Midline_Points(:,1) ; flipud(S.Boundary_Points_Dorsal(:,1))],[S.Midline_Points(:,2) ; flipud(S.Boundary_Points_Dorsal(:,2))]); % All.
	In_Ventral = inpolygon(Sxy(:,1),Sxy(:,2),[S.Midline_Points(:,1) ; flipud(S.Boundary_Points_Ventral(:,1))],[S.Midline_Points(:,2) ; flipud(S.Boundary_Points_Ventral(:,2))]); % All.
	Sxy(:,3:4) = [In_Dorsal , In_Ventral];
	
	for p=1:size(Sxy,1) % For each skeleton point.
		Dp = ( ( Sxy(p,1) -  S.Midline_Points(:,1) ).^2 + ( Sxy(p,2) -  S.Midline_Points(:,2) ).^2).^(.5);
		Sxy(p,5) = min(Dp);
	end
	
	Sliding_Window_Vector = Win_Size+1:Np_Midline - Win_Size;
	Np_Win = length(Sliding_Window_Vector);
	
	Sliding_Window_Struct(Np_Win).Index = 0;
    
	for w=1:Np_Win
		
		Ww = Sliding_Window_Vector(w)-Win_Size:Sliding_Window_Vector(w)+Win_Size;
		
		XY_0 = S.Midline_Points(Ww,:); % Window Midline Points.
		XY_D = S.Boundary_Points_Dorsal(Ww,:); % Window Dorsal Points.
		XY_V = S.Boundary_Points_Ventral(Ww,:); % Window Ventral Points.
		
		% Find pixels within the current window:
		% In_DV = inpolygon(Sxy(:,1),Sxy(:,2),[XY_D(:,1) ; flipud(XY_V(:,1))],[XY_D(:,2) ; flipud(XY_V(:,2))]); % Entire window.
		In_D = inpolygon(Sxy(:,1),Sxy(:,2),[XY_D(:,1) ; flipud(XY_0(:,1))],[XY_D(:,2) ; flipud(XY_0(:,2))]); % Dorsal Side Only.
		In_V = inpolygon(Sxy(:,1),Sxy(:,2),[XY_V(:,1) ; flipud(XY_0(:,1))],[XY_V(:,2) ; flipud(XY_0(:,2))]); % Ventral Side Only.
		
		Sliding_Window_Struct(w).Index = w;
		
		Sliding_Window_Struct(w).Dorsal_Length = sum(In_D);
		Sliding_Window_Struct(w).Ventral_Length = sum(In_V);
		
		Sliding_Window_Struct(w).Dorsal_Radius = max(Sxy(In_D,5));
		Sliding_Window_Struct(w).Ventral_Radius = max(Sxy(In_V,5));
		
		
		if(Record)
			% Histograms of distances from the midline.
			clf;
			subplot(2,2,1);
				histogram(Sxy(In_D,5),15);
				title('Dorsal');
			subplot(2,2,2);
				histogram(Sxy(In_V,5),15);
				title('Ventral');
			subplot(2,2,[3,4]);
				imshow(W.Image0);
				set(gca,'YDir','normal');
				hold on;
				
				plot(Sxy(In_D,1),Sxy(In_D,2),'.b'); % ,'Color',[0,0.4470,0.7410]);
				plot(Sxy(In_V,1),Sxy(In_V,2),'.r'); % ,'Color',[0.8500,0.3250,0.0980]);
				
				plot([XY_D(:,1) ; flipud(XY_0(:,1)) ; XY_D(1,1)] , [XY_D(:,2) ; flipud(XY_0(:,2)) ; XY_D(1,2)],'LineWidth',3);
				plot([XY_V(:,1) ; flipud(XY_0(:,1)) ; XY_V(1,1)] , [XY_V(:,2) ; flipud(XY_0(:,2)) ; XY_V(1,2)],'LineWidth',3);
			
			F = getframe(gca);
			writeVideo(Vid1,F);
		end
	end
	if(Record)
		close(Vid1);
	end
	
    figure(2); clf(2);
		subplot(2,1,1);
			imshow(W.Image0);
			set(gca,'YDir','normal');
			hold on;
			plot(Sxy(In_Dorsal,1) , Sxy(In_Dorsal,2),'.r');
			plot(Sxy(In_Ventral,1) , Sxy(In_Ventral,2),'.b');
		subplot(2,1,2);
			imshow(W.Image0);
			set(gca,'YDir','normal');
			hold on;
			D = rescale(Sxy(:,5));
			scatter(Sxy(:,1),Sxy(:,2),10,[D,zeros(length(D),1),1-D],'filled');
	
	figure(3); clf(3);
		subplot(2,1,1);
			plot([Sliding_Window_Struct.Index],[Sliding_Window_Struct.Dorsal_Length],'LineWidth',2);
			hold on;
			plot([Sliding_Window_Struct.Index],[Sliding_Window_Struct.Ventral_Length],'LineWidth',2);
			plot([Sliding_Window_Struct.Index],[Sliding_Window_Struct.Dorsal_Length] + [Sliding_Window_Struct.Ventral_Length],'k','LineWidth',2);
			xlim([1,Np_Win]);
			xlabel('Midline Point Index');
			ylabel('# of Skeleton pixels');
			legend({'Dorsal','Ventral','All'});
			set(gca,'FontSize',16);
		subplot(2,1,2);
			plot([Sliding_Window_Struct.Index],[Sliding_Window_Struct.Dorsal_Radius],'LineWidth',2);
			hold on;
			plot([Sliding_Window_Struct.Index],[Sliding_Window_Struct.Ventral_Radius],'LineWidth',2);
			xlim([1,Np_Win]);
			xlabel('Midline Point Index');
			ylabel('Radius');
			legend({'Dorsal','Ventral'});
			set(gca,'FontSize',16);
	% Define a range of midline points.
	% Use it to define a dorsal and ventral window.
	
	% find the total length within each window.
	
	% show the histogram of length as a function of distance from the midline
end