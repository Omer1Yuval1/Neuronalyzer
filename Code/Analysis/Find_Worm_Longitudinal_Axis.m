function Worm_Axes = Find_Worm_Longitudinal_Axis(Data,Plot1,Ax)
	
	% TODO: use scale-bar:
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	Initial_Radius = 120; % 60 ./ Scale_Factor;
	Min_Branch_Length = 300;
	Mask_Size = 100;
	
	% This functions uses a higher level perspective (the entire neuron) to detect the longitudinal axis of the worm.
	% It first performs closing to transform the neuron into a large blob.
	% Then it skeletonizes this blob to get its midline.
	
	% Better_Skeletonization_Threshold = 1000;
	Smoothing_Parameter = 100000;
	Eval_Points_Num = 100;
	Eval_Points_Pixel_Ratio = 0.5;
	
	S = struct('Midline_Pixels',{},'Midline_Points',{},'Tangent_Angles',{},'Boundary_Pixels',{},'Boundary_Points_Dorsal',{},'Boundary_Points_Ventral',{});
	Worm_Axes = struct('Axis_0',{},'Axis_1_Dorsal',{},'Axis_1_Ventral',{},'Axis_2_Dorsal',{},'Axis_2_Ventral',{});
	Worm_Axes(1).Axis_0 = struct('X',{},'Y',{},'Arc_Length',{},'Tangent_Angle',{});
	Worm_Axes(1).Axis_2_Dorsal = struct('X',{},'Y',{});
	Worm_Axes(1).Axis_2_Ventral = struct('X',{},'Y',{});
	
	[ImB,XYper] = Neuron_To_Blob(Data.Info.Files(1).Binary_Image); % Data.Info.Files(1).Raw_Image.
	S(1).Boundary_Pixels = XYper;
    
    % Im_Skel = bwmorph(ImB,'skel',inf); % The skeleton of the blob.
	% Im_Skel = bwmorph(imclose(ImB,strel('disk',Mask_Size)),'skel',inf); % The skeleton of the blob. % Im_Axis = bwmorph(imclose(ImB,strel('disk',100)),'thin',inf);
	Im_Skel_Pruned = bwskel(ImB,'MinBranchLength',Min_Branch_Length);
    % Im_Skel_Pruned = bwskel(Im_Skel,'MinBranchLength',Min_Branch_Length);
	
	% Save midline pixels ordered from head (left) to tail:
	[Y,X] = find(bwmorph(Im_Skel_Pruned,'endpoints')); % End points of the midline.
	f = find(X == min(X)); % Find the midline pixel with the smallest x-value (conventionally the head point).
	XY = Order_Connected_Pixels(Im_Skel_Pruned,[X(f(1)),Y(f(1))]); % [Nx2].
	S(1).Midline_Pixels = [XY(:,1) , XY(:,2)];
	
	% Smooth & Fit Midline:		
	XY = cell2mat(smoothn(num2cell(XY,1),Smoothing_Parameter)); % Smoothing.
	pp = cscvn(transpose(XY)); % Fit a cubic spline.
	Vb = linspace(pp.breaks(1),pp.breaks(end),Eval_Points_Pixel_Ratio*size(S.Midline_Pixels,1));
	XY = fnval(pp,Vb);
	S.Midline_Points = transpose(XY);
    dxy = sum((S.Midline_Points(2:end,:) - S.Midline_Points(1:end-1,:)).^2,2).^(0.5);
	S.Midline_Arc_Length = cumsum([0 , transpose(dxy)]) .* Scale_Factor; % pixels to real length units (um).
	
	pp_Der1 = fnder(pp,1);
	XY_Der = transpose(fnval(pp_Der1,Vb)); % [Nx2].
	% XY_Der = XY_Der ./ (sqrt(sum(XY_Der.^2,2));
	S.Tangent_Angles = atan2(XY_Der(:,2),XY_Der(:,1));
	
   %{
	Im_Perim = bwperim(ImB);
	[Y,X] = find(Im_Perim);
    f = find(X == min(X));
    XY = Order_Connected_Pixels(Im_Perim,[X(f(1)),Y(f(1))]); % [Nx2].
	S.Boundary_Pixels = XY;
	%}
	
	S.Boundary_Points_Dorsal = S.Midline_Points + (Initial_Radius .* [cos(S.Tangent_Angles + (pi/2)) , sin(S.Tangent_Angles + (pi/2))]);
	S.Boundary_Points_Ventral = S.Midline_Points + (Initial_Radius .* [cos(S.Tangent_Angles - (pi/2)) , sin(S.Tangent_Angles - (pi/2))]);
	
	Np = size(S.Midline_Points,1);
	Worm_Axes.Axis_0(Np).X = nan; % Memory preallocation.
	for i=1:Np % For each midline point.
		Worm_Axes.Axis_0(i).X = S.Midline_Points(i,1);
		Worm_Axes.Axis_0(i).Y = S.Midline_Points(i,2);
		Worm_Axes.Axis_0(i).Arc_Length = S.Midline_Arc_Length(i);
		Worm_Axes.Axis_0(i).Arc_Length = S.Midline_Arc_Length(i);
		Worm_Axes.Axis_0(i).Tangent_Angle = S.Tangent_Angles(i); % Tangent vectors are oriented from head to tail. +(pi/2) points to the dorsal side.
		
		Worm_Axes.Axis_2_Dorsal(i).X = S.Boundary_Points_Dorsal(i,1);
		Worm_Axes.Axis_2_Dorsal(i).Y = S.Boundary_Points_Dorsal(i,2);
		
		Worm_Axes.Axis_2_Ventral(i).X = S.Boundary_Points_Ventral(i,1);
		Worm_Axes.Axis_2_Ventral(i).Y = S.Boundary_Points_Ventral(i,2);
	end
	
	% TODO:
	% For each midline point (and a normal vector), match two boundary points (dorsal and ventral):
	% Boundary_Points
	
	switch(Plot1)
		case 1
			if(nargin >= 3 && ~isempty(Ax))
				HI = imshow(ImB,'Parent',Ax);
			else
				HI = imshow(ImB.*0.8);
			end
			set(gca,'units','normalized','Position',[0,0,1,1]);
			% set(gca,'YDir','normal');
			% drawnow;
			hold on;
			% HI = imshow(Data.Info.Files(1).Raw_Image);
			set(HI,'AlphaData',Data.Info.Files(1).Raw_Image);
			
			% Plot dorsal arrows:
			%{
			for p=1:15:length(Vb)
				% plot(S.Midline_Points(p,1) +  40.*[0,cos(S.Tangent_Angles(p))] , S.Midline_Points(p,2) +  40.*[0,sin(S.Tangent_Angles(p))]);
			   quiver(S.Midline_Points(p,1),S.Midline_Points(p,2) , cos(S.Tangent_Angles(p)-pi/2),sin(S.Tangent_Angles(p)-pi/2),'LineWidth',1,'AutoScaleFactor',40,'MaxHeadSize',3,'Color','k');
			end
			%}
			
			scatter(S.Midline_Points(:,1),S.Midline_Points(:,2),30,jet(size(S.Midline_Points,1)),'filled'); % plot(X,Y,'.b','LineWidth',2);
			plot(S.Boundary_Pixels(:,1),S.Boundary_Pixels(:,2),'.','Color',[0.8,0,0],'MarkerSize',15); % [0.8,0,0], [0.5,0.5,0]
			
		case 2
			[Y,X] = find(Im_Skel_Pruned);
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax); % imshow(ImB);
			set(gca,'YDir','normal');
			hold on;
			
			for p=1:length(Vb)
				plot(S.Midline_Points(p,1) +  40.*[0,cos(S.Tangent_Angles(p))] , S.Midline_Points(p,2) +  40.*[0,sin(S.Tangent_Angles(p))]);
			   % plot(S.Midline_Points(p,1) +  [0,XY_Der(p,1)] , S.Midline_Points(p,2) +  [0,XY_Der(p,2)]);
			end
			
			plot(X,X,'.g','LineWidth',2);
			scatter(S.Midline_Points(:,1),S.Midline_Points(:,2),20,jet(size(S.Midline_Points,1)),'filled'); % plot(S.Midline_Points(:,1),S.Midline_Points(:,2),'.r','LineWidth',2);
			
			scatter(S.Boundary_Points_Dorsal(:,1),S.Boundary_Points_Dorsal(:,2),10,jet(size(S.Boundary_Points_Dorsal,1)),'filled');
			scatter(S.Boundary_Points_Ventral(:,1),S.Boundary_Points_Ventral(:,2),10,jet(size(S.Boundary_Points_Ventral,1)),'filled');
			% scatter(S.Boundary_Pixels(:,1),S.Boundary_Pixels(:,2),20,jet(size(S.Boundary_Pixels,1)),'filled');
			% XY = cell2mat(smoothn(num2cell(S.Boundary_Pixels,1),0.1)); % Smoothing.
			% plot(XY(:,1),XY(:,2),'.y','LineWidth',2);
	end
	
	% Vertices = Data.Vertices;
	% Junctions = Vertices(find([Vertices.Vertex_Index] > 0));
	% J = [Junctions.Coordinate];
	% Junctions = [J(1:2:end)' , J(2:2:end)'];
	% Tips = Vertices(find([Vertices.Vertex_Index] < 0));
	% T = [Tips.Coordinate];
	% Tips = [T(1:2:end)' , T(2:2:end)'];
	% Im = Data.Info.Files(1).Raw_Image;
	
end