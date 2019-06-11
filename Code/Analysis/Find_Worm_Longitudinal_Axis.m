function S = Find_Worm_Longitudinal_Axis(Workspace,Plot1)
	
	% TODO: use scale-bar:
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	Initial_Radius = 120; % 60 ./ Scale_Factor;
	Min_Branch_Length = 300;
	
	% This functions uses a higher level perspective (the entire neuron) to detect the longitudinal axis of the worm.
	% It first performs closing to transform the neuron into a large blob.
	% Then it skeltonizes this blob to get its midline.
	
	% Better_Skeletonization_Threshold = 1000;
	BW_Threshold = 0.5;
	Smoothing_Parameter = 100000;
	Eval_Points_Num = 100;
	Eval_Points_Pixel_Ratio = 0.5;
	
	S = struct('Midline_Pixels',{},'Midline_Points',{},'Normal_Angles',{},'Boundary_Pixels',{},'Boundary_Points_Dorsal',{},'Boundary_Points_Ventral',{});
	
	Im_BW = imbinarize(Workspace.Image0,BW_Threshold);
	[R,C] = size(Im_BW);
	
	se = strel('disk',20);
	ImD1 = imdilate(Im_BW,se);
	ImD2 = imdilate(ImD1,se); % The Blob.
	
	Im_Skel = bwmorph(imclose(ImD2,strel('disk',100)),'skel',inf); % The skeleton of the blob. % Im_Axis = bwmorph(imclose(ImD2,strel('disk',100)),'thin',inf);
	Im_Skel_Pruned = bwskel(Im_Skel,'MinBranchLength',Min_Branch_Length);
	
	[Y_Skel,X_Skel] = find(Im_Skel);
	[Y_Skel_Pruned,X_Skel_Pruned] = find(Im_Skel_Pruned);
	
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
	S.Normal_Angles = atan2(XY_Der(:,2),XY_Der(:,1)) + (pi/2);
	
    Im_Perim = bwperim(ImD2);
	[Y,X] = find(Im_Perim);
    f = find(X == min(X));
    XY = Order_Connected_Pixels(Im_Perim,[X(f(1)),Y(f(1))]); % [Nx2].
	S.Boundary_Pixels = XY;
	
	S.Boundary_Points_Dorsal = S.Midline_Points + (Initial_Radius .* [cos(S.Normal_Angles) , sin(S.Normal_Angles)]);
	S.Boundary_Points_Ventral = S.Midline_Points - (Initial_Radius .* [cos(S.Normal_Angles) , sin(S.Normal_Angles)]);
	
	% TODO:
	% For each midline point (and a normal vector), match two boundary points (dorsal and ventral):
	% Boundary_Points
	
	if(Plot1)
		figure;
			subplot(2,1,1);
				imshow(Workspace.Image0); % imshow(ImD2);
				set(gca,'YDir','normal');
				hold on;
				
                for p=1:length(Vb)
                    plot(S.Midline_Points(p,1) +  40.*[0,cos(S.Normal_Angles(p))] , S.Midline_Points(p,2) +  40.*[0,sin(S.Normal_Angles(p))]);
                   % plot(S.Midline_Points(p,1) +  [0,XY_Der(p,1)] , S.Midline_Points(p,2) +  [0,XY_Der(p,2)]);
                end
				
				plot(X_Skel_Pruned,Y_Skel_Pruned,'.g','LineWidth',2);
				scatter(S.Midline_Points(:,1),S.Midline_Points(:,2),20,jet(size(S.Midline_Points,1)),'filled'); % plot(S.Midline_Points(:,1),S.Midline_Points(:,2),'.r','LineWidth',2);
				
				scatter(S.Boundary_Points_Dorsal(:,1),S.Boundary_Points_Dorsal(:,2),10,jet(size(S.Boundary_Points_Dorsal,1)),'filled');
				scatter(S.Boundary_Points_Ventral(:,1),S.Boundary_Points_Ventral(:,2),10,jet(size(S.Boundary_Points_Ventral,1)),'filled');
				% scatter(S.Boundary_Pixels(:,1),S.Boundary_Pixels(:,2),20,jet(size(S.Boundary_Pixels,1)),'filled');
                % XY = cell2mat(smoothn(num2cell(S.Boundary_Pixels,1),0.1)); % Smoothing.
                % plot(XY(:,1),XY(:,2),'.y','LineWidth',2);
				
			subplot(2,1,2);
				imshow(ImD2);
				set(gca,'YDir','normal');
				hold on;
				plot(X_Skel,Y_Skel,'.g','LineWidth',2);
				plot(S.Boundary_Pixels(:,1),S.Boundary_Pixels(:,2),'.y','LineWidth',2);
	end
	
	% Vertices = Workspace.Vertices;
	% Junctions = Vertices(find([Vertices.Vertex_Index] > 0));
	% J = [Junctions.Coordinate];
	% Junctions = [J(1:2:end)' , J(2:2:end)'];
	% Tips = Vertices(find([Vertices.Vertex_Index] < 0));
	% T = [Tips.Coordinate];
	% Tips = [T(1:2:end)' , T(2:2:end)'];
	% Im = Workspace.Image0;
	
end