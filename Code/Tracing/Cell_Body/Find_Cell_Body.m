function [Workspace1,I6,CB_Perimeter,Ellipse_Ind] = Find_Cell_Body(Workspace1)
	
	MinPeakDistance = Workspace1.Parameters(1).Cell_Body(1).MinPeakDistance;
	MinPeakProminence = Workspace1.Parameters(1).Cell_Body(1).MinPeakProminence;
	MinPeakProminence_Normalized = Workspace1.Parameters(1).Cell_Body(1).MinPeakProminence_Normalized;
	MinPeakWidth = Workspace1.Parameters(1).Cell_Body(1).MinPeakWidth;
	Max_Num_Of_Branches = Workspace1.Parameters(1).Cell_Body(1).Max_Num_Of_Branches;
	Ellipse_Resolution = Workspace1.Parameters(1).Cell_Body(1).Ellipse_Resolution;
	Ellipse_Axes_Extension_Factor = Workspace1.Parameters(1).Cell_Body(1).Ellipse_Axes_Extension_Factor;
	
	Rect_Width = Workspace1.Parameters(1).Cell_Body(1).Rect_Width;
	Rect_Length = Rect_Width*Workspace1.Parameters.Cell_Body.Rect_Length_Width_Ratio; % X4 pixels.
	Step_Length = Rect_Length/Workspace1.Parameters.Cell_Body.Rect_Step_Length_Ratio; % /5 pixels.
	
	Rect_Width_Scan_Range = Workspace1.Parameters.Cell_Body.Rect_Width_Range;
	Rect_Width_Res = Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Width_Res;
	SP = Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Width_Smoothing_Parameter;
	
	Rotation_Range = Workspace1.Parameters(1).Cell_Body(1).Rect_Rotation_Range;
	Rotation_Res = Workspace1.Parameters(1).Cell_Body(1).Rotation_Res;
	Rotation_Origin = Workspace1.Parameters(1).Cell_Body(1).Rotation_Origin;
	
	Ellipse_Ind = 0;
	%
	
	% Convert to BW and do opening & closing:
	I1 = im2bw(Workspace1.Image0,Workspace1.Parameters(1).Cell_Body(1).BW_Threshold);
	sec = strel('disk',ceil(Workspace1.Parameters(1).Cell_Body(1).Open_Close_Disk/Workspace1.User_Input.Scale_Factor)); % TODO: Use scalebar.
	I2 = imopen(I1,sec); % I2 = bwareaopen(I1,5);
	I3 = imclose(I2,sec); % BW image in which only the cell body pixels are 1.
	
	% Display the cell body:
	% figure(2);
	% imshow(I3);
	% return;
	
	I3a = I3;
	CC3 = bwconncomp(I3);
	Cs = size(CC3.PixelIdxList{1,1},1);
	Ci = 1;
	for i=2:numel(CC3.PixelIdxList) % Find the biggest component.
		if(size(CC3.PixelIdxList{1,i},1) > Cs)
			Cs = size(CC3.PixelIdxList{1,i},1);
			Ci = i;
		end
	end
	for i=1:numel(CC3.PixelIdxList) % Delete all the other components.
		if(i == Ci)
			continue;
		end
		I3a(CC3.PixelIdxList{1,i}) = 0;
	end
	% figure(7), imshow(I3a);
	
	% Find the perimeter pixels:
	I4 = bwperim(I3a,Workspace1.Parameters(1).Cell_Body(1).Perimeter_Connectivty); % Perimeter pixels.
	[rows cols] = find(I4==1); % Coordinates of all 1-pixels in the perimeter image (I4).
	CB_Perimeter = [rows cols];
	CB_Perimeter_Ind = find(I4==1); % Linear indices of all 1-pixels in the perimeter image (I4).
	
	% The image without the cell body: 
	F = find(I3 == 1);
	I6 = Workspace1.Image0;
	I6(F) = 0;
	% figure(1), imshow(I6);
	% figure(1);
	% imshow(Workspace1.Image0);
	hold on;
	plot(cols,rows,'.b');
	% set(gca,'YDir','normal');
	
	return;
	
	% Find the radii of the ellipse.
	ParA = EllipseDirectFit([cols rows]);
	[ParG,code] = AtoG(ParA); % Conversion from algebraic to geometric parametrs in order to enlage the radii.
	% ParG = [Center(1:2), Axes(1:2), Angle]'
	ParG(3) = ParG(3) + Workspace1.Parameters(1).Cell_Body(1).Ellipse_Axes_Extension_Factor; % Extension of the ellipse axes.
	ParG(4) = ParG(4) + Workspace1.Parameters(1).Cell_Body(1).Ellipse_Axes_Extension_Factor; % ".
	ParA = GtoA(ParG); % Coversion back to algebraic form.
	Cx = ParG(1); % The center point of the ellipse.
	Cy = ParG(2); % ".
	
	% Set the min & max x-values:
	xmin = min([cols])-Ellipse_Axes_Extension_Factor;
	xmax = max([cols])+Ellipse_Axes_Extension_Factor;
	arr = [];
	
	syms x y;
	eqn = ParA(1)*x^2 + ParA(2)*x*y + ParA(3)*y^2 + ParA(4)*x + ParA(5)*y + ParA(6) == 0;
	tsym = solve(simplify(eqn),y);
	tfun = matlabFunction(tsym, 'vars', {'x'});
	eqn_der = diff(tsym,x);
	tfun_der = matlabFunction(eqn_der, 'vars', {'x'});
	
	% Find all the pixels along the ellipse:
	Vxy = [];
	Vdyy = [];
	for xi=xmin-Ellipse_Axes_Extension_Factor:0.1:xmax+Ellipse_Axes_Extension_Factor
		yy = double(real(tfun(xi))); % y-values of the ellipse at xi.
		if((yy(1)) ~= (yy(2))) % If the point is on the ellipse.
			
			yyd = double(real(tfun_der(xi))); % y'-values of the ellipse at x.
			
			Vxy(end+1,1) = round(xi);
			Vxy(end,2) = round(yy(1));
			Vdyy(end+1) = mod(atand(yyd(1))-90,360);
			
			Vxy(end+1,1) = round(xi);
			Vxy(end,2) = round(yy(2));
			Vdyy(end+1) = mod(atand(yyd(2))+90,360);
		end
	end
	[Vxy,ia,ic] = unique(Vxy,'rows');
	Vxy(:,3) = Vdyy(ia);
	% assignin('base','Vxy',Vxy);
	
	EXV = ceil(xmin:xmax);
	EYV = ceil(double(real(tfun(EXV))));
	% Ellipse_Ind = [sub2ind(size(Workspace1.Image0),EYV(1,:),EXV) sub2ind(size(Workspace1.Image0),EYV(2,:),EXV)];
	Ellipse_Ind = Vxy(:,1:2);
	% assignin('base','Ellipse_Ind',Ellipse_Ind);
	
	% Calculate the perpendicular direction at each point along the ellipse contour,
	% using the derivative at each point:
	v1 = [];
	for xi=1:length(Vxy(:,1)) % For each pixel on the ellipse.			
		
		arr = Rect_Scan_Generalized(I6,[Vxy(xi,1),Vxy(xi,2)],Vxy(xi,3),Rect_Width,Rect_Length,Rotation_Range,Rotation_Res);
		paths = Choose_Paths_Generalized(arr(:,1),arr(:,2),MinPeakProminence,MinPeakDistance,SP);
		
		v1(1,end+1) = Vxy(xi,1);
		v1(2,end) = Vxy(xi,2);
		v1(3,end) = mod(paths(1,1),360); % Angle of the best rectangle at this coordinate.
		v1(4,end) = paths(1,2); % Score of the best rectangle at this coordinate.
		
		% Plot the normal (!!! Do not delete !!!):
		% if(paths(1,2) > 0) % If the score (of the best peak) is 0, it means that no peaks were found.
			% % [XV1,YV1] = Get_Rect_Vector([Vxy(xi,1),Vxy(xi,2)],Vxy(xi,3),Rect_Width,Rect_Length,14); % Perpendicular rectangle.
			% % % plot(XV1,YV1,'r');
			% [XV2,YV2] = Get_Rect_Vector([Vxy(xi,1),Vxy(xi,2)],v1(3,end),Rect_Width,Rect_Length,14); % Best-score rectangle.
			% % hold on;
			% plot(XV2,YV2,'g');
		% end
		
		% Plot the ellipse contour pixels:
		% figure(1);
		hold on;
		plot(Vxy(xi,1),Vxy(xi,2),'.r'); 
		% hold off;
	end
	
	% Find all the "stand-alone" zeros (zeros that have at least one non-zero neighbor):
	for i=1:3
		F = find([v1(4,2:end-1)] == 0 & ([v1(4,3:end)] > 0 | [v1(4,1:end-2)] > 0)) + 1;
		v1(:,F) = []; % Delete these zeros.
	end
	v1 = [ [0,0,0,0]' , v1];
	v1(5,:) = 1:size(v1,2); % Add an index to each point in the 5th row.
	v1(4,:) = v1(4,:) ./ max(v1(4,:)); % Normalization of the scores along the ellipse contour. TODO: how does this help?
	% assignin('base','v1',v1);
	
	% if(Workspace1.Parameters.Auto_Tracing_Parameters.Plot_On_Off)
	if(0)
		figure(3);
		plot(v1(5,:),v1(4,:),'.k','MarkerSize',10);
		hold on;
		findpeaks(v1(4,:),v1(5,:),'MinPeakProminence',MinPeakProminence_Normalized, ...
			'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'Annotate','extents');
		set(gca,'FontSize',22);
		xlabel('Pixel Index Along the Ellipse Contour');
		ylabel('Normalized Score');
	end
	[yp,xp] = findpeaks(v1(4,:),v1(5,:),'MinPeakProminence',MinPeakProminence_Normalized, ...
		'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth); % xp are the indexes\columns # in v1.
	
	for i=1:length(xp) % For each peak.
		Workspace1.Path(end+1).Rectangle_Index = i;
		Workspace1.Path(end).Step_Index = i;
		Workspace1.Path(end).Coordinates = [v1(1,xp(i)) v1(2,xp(i))];
		Workspace1.Path(end).Angle = v1(3,xp(i));
		
		Step_Parameters.Step_Coordinates = Workspace1.Path(end).Coordinates;
		Step_Parameters.Step_Routes(1,1) = Workspace1.Path(end).Angle;
		Step_Parameters.Rect_Length = Rect_Length;
		Step_Parameters.Rect_Width = Rect_Width;
		Step_Parameters.Branch_Step_Index = 1;
		
		W = Adjust_Rect_Width_Rot(Workspace1,Step_Parameters);
			
		Workspace1.Path(end).Width = W*Workspace1.User_Input.Scale_Factor;
		
		Workspace1.Path(end).Score = v1(4,xp(i));
		Workspace1.Path(end).Is_Mapped = 0;
		Workspace1.Path(end).Connection = 0;
		Workspace1.Path(end).Current_Branch_Step_Index = 1;
		Workspace1.Path(end).Rect_Length = Step_Length*Workspace1.User_Input.Scale_Factor;
		
		[XV,YV] = Get_Rect_Vector(Workspace1.Path(end).Coordinates,Workspace1.Path(end).Angle,W,Rect_Length,14);
		
		figure(1);
		hold on;
		plot(XV,YV,'Color',[0,.7,0],'LineWidth',3);
		% % % fill(XV,YV,'g');
		plot([XV(2),XV(3)],[YV(2),YV(3)],'r','LineWidth',3);
		% hold off;		
	end
	
end