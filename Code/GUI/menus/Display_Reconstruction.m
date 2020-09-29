function Display_Reconstruction(P,Data,Label)
	
	% P is the handle class containing all project and gui data.
	% Data = P.Data(p), where p is the current selected project. It is passed separately as a struct for faster reading (reading a handle class property in a loop is very slow).
	
	Undock = 0;
	LineWidth_1 = 2; % [2,6].
	DotSize_1 = 10; % 80;
	DotSize_2 = 15; % 80;
	
	if(~Undock)
		Ax = P.GUI_Handles.View_Axes;
		delete(allchild(Ax));
	else
		H = figure;
		% [ImRows,ImCols] = size(Data.Image0);
		hold on;
	end
	
	% Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
	
	p = P.GUI_Handles.Current_Project;
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	
	
	switch(Label)
		case 'Raw Image - Grayscale'
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
		case 'Raw Image - RGB'
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			colormap(Ax,'hot');
		case 'Cell Body' % Detect and display CB and the outsets of the branches connected to it:
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			CB_BW_Threshold = Data.Parameters.Cell_Body.BW_Threshold;
			
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Data.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			% set(gca,'YDir','normal','Position',[0,0,1,1]);
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(Data.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
			
			% plot(CB_Perimeter(:,1),CB_Perimeter(:,2),'LineWidth',4);
		case 'CNN Image - Grayscale'
			imshow(Data.Info.Files.Denoised_Image{1},'Parent',Ax);
		case 'CNN Image - RGB'
			imshow(Data.Info.Files.Denoised_Image{1},'Parent',Ax);
			colormap(Ax,'hot');
		case 'Binary Image'
			imshow(Data.Info.Files.Binary_Image{1},'Parent',Ax);
		case 'Raw + Binary Image - RGB'
			Im_RGB = repmat(Data.Info.Files.Raw_Image{1}(:,:,1),[1,1,3]);
			Im_RGB(:,:,1) = Im_RGB(:,:,1) .* uint8(~Data.Info.Files.Binary_Image{1});
			Im_RGB(:,:,2) = Im_RGB(:,:,2) .* uint8(Data.Info.Files.Binary_Image{1});
			imshow(Im_RGB,'Parent',Ax);
		case 'Skeleton'
			[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Pixel_Trace_Post_Proccessing(Data.Info.Files.Binary_Image{1},Scale_Factor);
			imshow(Im1_NoiseReduction,'Parent',Ax);
			
			%
			for s=1:numel(Data.Segments)
				if(numel(Data.Segments(s).Rectangles))
					x = [Data.Segments(s).Rectangles.X];
					y = [Data.Segments(s).Rectangles.Y];
					hold on;
					plot(x,y,'LineWidth',1); % plot(x,y,'.','MarkerSize',30,'Color',rand(1,3));
				end
			end
			%}
			% [Y,X] = find(Im1_branchpoints); hold on; plot(X,Y,'.k','MarkerSize',30);
			% [Y,X] = find(Im1_endpoints); hold on; plot(X,Y,'.r','MarkerSize',30);
			
			%{
			% Color connected components:
			CC = bwconncomp(Im1_NoiseReduction);
			for c=1:length(CC.PixelIdxList)
				[y,x] = ind2sub(size(Im1_NoiseReduction),CC.PixelIdxList{c});
				hold on;
				plot(x,y,'.','MarkerSize',7);
			end
			%}
		case 'Blob'
			% Find_Worm_Longitudinal_Axis(Data,1); % GP.Handles.Axes
		case {'Trace','Segmentation'}
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold(Ax,'on');
			
			Ns =  numel(Data.Segments);
			if(isfield(Data,'Segments'))
				for s=1:Ns
					if(numel(Data.Segments(s).Rectangles))
						x = [Data.Segments(s).Rectangles.X];
						y = [Data.Segments(s).Rectangles.Y];
						if(length(x) > 1)
							[x,y] = Smooth_Points(x,y,100);
						end
						
						switch(Label)
							case 'Trace'
								plot(Ax,x,y,'LineWidth',LineWidth_1,'Color',[0.12,0.56,1]);
							case 'Segmentation'
								plot(Ax,x,y,'LineWidth',LineWidth_1);
						end
					end
					P.GUI_Handles.Waitbar.Value = s ./ Ns;
				end
			end
			
			% Plot the vertices:
			%
			XY = [Data.Vertices.Coordinate];
			scatter(Ax,XY(1:2:end-1),XY(2:2:end),5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
			%}
		case 'Segments by Length'
			
			Max_Length = 50; % [um].
			CM = jet(1000);
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			for s=1:numel(Data.Segments)
				if(numel(Data.Segments(s).Rectangles))
					x = [Data.Segments(s).Rectangles.X];
					y = [Data.Segments(s).Rectangles.Y];
					c = [Data.Segments(s).Length];
					if(isnan(c) || c <= 0)
						plot(x,y,'Color','w','LineWidth',3);
					else
						plot(x,y,'Color',CM(round(rescale(c,1,1000,'InputMin',0,'InputMax',Max_Length)),:),'LineWidth',3);
					end
				end
			end
			
			XY = [Data.Vertices.Coordinate];
			scatter(Ax,XY(1:2:end-1),XY(2:2:end),5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
		case 'Axes'
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			
			%{
			Np = str2num(GP.Handles.Tracing.Midline_Points_Num.String);
			
			XY = [Data.Neuron_Axes.Axis_0.X ; Data.Neuron_Axes.Axis_0.Y];
			
			pp = cscvn(XY); % Fit a cubic spline.
			Vb = linspace(pp.breaks(1),pp.breaks(end),Np);
			XY = fnval(pp,Vb);
			
			hold on;
			plot(XY(1,:),XY(2,:),'LineWidth',3);
			plot(XY(1,:),XY(2,:),'.','MarkerSize',20);
			
			for p=1:numel(Data.Neuron_Axes.Axis_0)
				x = Data.Neuron_Axes.Axis_0(p).X;
				y = Data.Neuron_Axes.Axis_0(p).Y;
				a = Data.Neuron_Axes.Axis_0(p).Tangent_Angle + (pi/2);
				
				plot(x + 40.*[0,cos(a)] , y + 40.*[0,sin(a)]);
			end
			%}
		case 'Axes Mapping Process'
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			Map_Worm_Axes(Data,Data.Neuron_Axes,1,0,GP.Handles.Axes);
		case {'Radial Distance','Angular Coordinate'}
			
			Min_Max = [0,pi./2];
			CM_Lims = [1,1000];
			CM = hsv(CM_Lims(2));
			
			switch GP.General.Active_Plot
				case 'Radial Distance'
					Field_1 = 'Radial_Distance_Corrected';
				case 'Angular Coordinate'
					Field_1 = 'Angular_Coordinate';
			end
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			
			for s=1:numel(Data.Segments)
				
				Fs = find([[Data.All_Points.Segment_Index]] == Data.Segments(s).Segment_Index & ~isnan([Data.All_Points.(Field_1)]) );
				
				X = [Data.All_Points(Fs).X];
				Y = [Data.All_Points(Fs).Y];
				if(length(X) > 1)
					[X,Y] = Smooth_Points(X,Y,100);
				end
				
				C = abs([Data.All_Points(Fs).(Field_1)]);
				C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Min_Max(1),'InputMax',Min_Max(2))),:);
				
				X(end+1) = nan;
				Y(end+1) = nan;
				C(end+1,:) = nan(1,3);
				h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
			end
		case 'Midline Orientation'
			
			Min_Max = [0,pi./2];
			CM_Lims = [1,1000];
			c = linspace(0,1,CM_Lims(2))';
			CM = [1-c,c,0.*c+0.1]; % CM = jet(CM_Lims(2));
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			
			for s=1:numel(Data.Segments)

				Fs = find([[Data.All_Points.Segment_Index]] == Data.Segments(s).Segment_Index);
			
				X = [Data.All_Points(Fs).X];
				Y = [Data.All_Points(Fs).Y];
				if(length(X) > 1)
					[X,Y] = Smooth_Points(X,Y,100);
				end
				
				C = [Data.All_Points(Fs).Midline_Orientation];
				C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Min_Max(1),'InputMax',Min_Max(2))),:);
				
				X(end+1) = nan;
				Y(end+1) = nan;
				C(end+1,:) = nan(1,3);
				h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
			end
		case 'Longitudinal Gradient'
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			
			Min_Max = [0,800]; % um.
			CM_Lims = [1,1000];
			CM = jet(CM_Lims(2));			
			imshow(Data.Image0); % ,'Parent',GP.Handles.Axes
			hold on;
			
			for s=1:numel(Data.Segments)

				Fs = find([[Data.All_Points.Segment_Index]] == Data.Segments(s).Segment_Index);
			
				X = [Data.All_Points(Fs).X];
				Y = [Data.All_Points(Fs).Y];
				if(length(X) > 1)
					[X,Y] = Smooth_Points(X,Y,100);
				end
				
				C = [Data.All_Points(Fs).Axis_0_Position];
				C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Min_Max(1),'InputMax',Min_Max(2))),:);
				
				X(end+1) = nan;
				Y(end+1) = nan;
				C(end+1,:) = nan(1,3);
				h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
			end
		case 'Dorsal-Vental'
			
			Field_1 = 'Radial_Distance_Corrected';
			
			X = [Data.All_Points.X];
			Y = [Data.All_Points.Y];
			Dist = [Data.All_Points.(Field_1)];
			
			D = find(Dist <= 0);
			V = find(Dist > 0);
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold(Ax,'on');
			scatter(X(D),Y(D),DotSize_1,'b','filled');
			scatter(X(V),Y(V),DotSize_1,'r','filled');
		
		case {'Vertices Angles','Vertices Angles - Corrected'}
			
			a = 5;
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			Reconstruct_Vertices(Data);
			
			%{
			F1 = find([Data.All_Points.Vertex_Order] >= 3); % Find rectangles of junctions.
			X = [Data.All_Points(F1).X];
			Y = [Data.All_Points(F1).Y];
			A = [Data.All_Points(F1).Angle];
			Vx = [X ; X + a.*cos(A)];
			Vy = [Y ; Y + a.*sin(A)];
			
			plot([Data.All_Vertices.X],[Data.All_Vertices.Y],'.','MarkerSize',50);
			hold on;
			plot(Vx,Vy,'LineWidth',3);
			%}
		case {'3-Way Junctions - Position','Tips - Position'}
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			
			switch GP.General.Active_Plot
				case '3-Way Junctions - Position'
					Vertex_Order = 3;
					Junction_Classes = [1,1,2 ; 2,3,3 ; 3,3,4]; % 234,344
				case 'Tips - Position'
					Vertex_Order = 1;
					Junction_Classes = 1:4;
			end
			
			Max_PVD_Orders = length(Junction_Classes);
			CM = lines(Max_PVD_Orders);
			
			for v=1:numel(Data.All_Vertices)
				if(Data.All_Vertices(v).Order == Vertex_Order && length(Data.All_Vertices(v).Class) == Vertex_Order)
					[I,i] = ismember(sort(Data.All_Vertices(v).Class),Junction_Classes,'rows');
					if(I) % If the class is a member of the Junction_Classes matrix, plot it.
						X = [Data.All_Vertices(v).X];
						Y = [Data.All_Vertices(v).Y];
						
						hold on;
						scatter(X,Y,40,CM(i,:),'filled');
					end
				end
			end
			
		case 'Curvature'
			Curvature_Min_Max = [0,0.3]; % 0.2
			CM_Lims = [1,1000];
			CM = jet(CM_Lims(2));
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold(Ax,'on');
			
			Ns =  numel(Data.Segments);
			for s=1:numel(Data.Segments)
				if(numel(Data.Segments(s).Rectangles))
					
					C = [Data.Segments(s).Rectangles.Curvature];
					f = find(~isnan(C));
					
					X = [Data.Segments(s).Rectangles(f).X];
					Y = [Data.Segments(s).Rectangles(f).Y];
					if(length(X) > 1)
						[X,Y] = Smooth_Points(X,Y,100);
					end
					
					C = C(f);
					C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))),:);
					% C = rescale(C,0,1,'InputMin',Curvature_Min_Max(1),'InputMax',Curvature_Min_Max(2))';
					
					X(end+1) = nan;
					Y(end+1) = nan;
					C(end+1,:) = nan(1,3);
					h = patch(Ax,X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
				end
				P.GUI_Handles.Waitbar.Value = s ./ Ns;
				
				XY = [Data.Vertices.Coordinate];
				scatter(Ax,XY(1:2:end-1),XY(2:2:end),5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
			end
		case 'PVD Orders - Points'
			
			Class_Num = max([Data.All_Points.Class]);
			
			C = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0 ; .5,.5,.5];
			
			% figure;
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold on;
			Midline_Distance = [Data.All_Points.X];
			Midline_Orientation = [Data.All_Points.Y];
			Classes = [Data.All_Points.Class]; % Classes = [Data.All_Points.Segment_Class];
			Classes(isnan(Classes)) = Class_Num + 1;
			
			scatter(Midline_Distance,Midline_Orientation,10,C(Classes,:),'filled');
			
			% assignin('base','All_Points',Data.All_Points);
			
		case 'PVD Orders - Segments'
			Class_Num = max([Data.Segments.Class]);
			
			% C = lines(Class_Num+1);
			Class_Indices = [1,2,3,4]; %  [1,2,3,3.5,4,5];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0]; % 3=0,0.8,0.8 ; 3.5=0,0,1 ; 5=0.5,0.5,0.5
			
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
			hold(Ax,'on');
			Ns = numel(Data.Segments);
			for s=1:Ns
				if(numel(Data.Segments(s).Rectangles))
					x = [Data.Segments(s).Rectangles.X];
					y = [Data.Segments(s).Rectangles.Y];
					
					if(length(x) > 1)
						[x,y] = Smooth_Points(x,y,100);
					end
					
					c = find(Class_Indices == Data.Segments(s).Class);
					if(isempty(c)) % isnan(c)
						plot(Ax,x,y,'Color',Class_Colors(end,:),'LineWidth',LineWidth_1);
					else
						plot(Ax,x,y,'Color',Class_Colors(c,:),'LineWidth',2); % Use 5 when zooming in. Otherwise 2.
					end
				end
				P.GUI_Handles.Waitbar.Value = s ./ Ns;
			end
			
			% Plot the vertices:
			%
			XY = [Data.Vertices.Coordinate];
			scatter(Ax,XY(1:2:end-1),XY(2:2:end),5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
			%}
			
			% Use when zooming in:
			% F = find([Data.All_Vertices.Order] >= 2);
			% R = [Data.All_Vertices.Radius] .* GP.Workspace(1).Workspace.User_Input.Scale_Factor ./ 10;
			% viscircles([X(F)',Y(F)'],R(F),'Color','k','LineWidth',5); % [0.6350 0.0780 0.1840]
		otherwise
			imshow(Data.Info.Files.Raw_Image{1},'Parent',Ax);
	end
	
	if(Undock)
		set(gca,'position',[0,0,1,1]);
		axis tight;
		H.InnerPosition = [50,50,ImCols./2.5,ImRows./2.5];
	end
	% set(gca,'YDir','normal');
	%{
	H.Position = [114,469,1692,498]; % [10,50,900,900];
	
	
	set(GP.Handles.Axes,'unit','normalize');
	set(GP.Handles.Axes,'position',[0,0,1,1]);
	axis tight;
	%}
	
	% axis(XY);
	
	%{
	hold on;
	Scale_Factor = GP.Workspace(1).Workspace.User_Input.Scale_Factor;
	plot([20,20+50*(1/Scale_Factor)],[20,20],'w','LineWidth',3);
	text(15+25,25,['50 \mum'],'FontSize',20,'Color','w');
	%}
	
	% hold on;
	% Compass1 = imread('Compass.tif');
	% imshow(Compass1);
	% imshow(imresize(Compass1,1)); % 0.1*GP.Workspace(1).Workspace.Parameters.General_Parameters.Im_Rows));
	
	function Set_Dynamic_Sliders_Values(Handles,Min_Value,Max_Value)
		set(Handles.Dynamic_Slider_Min,'Enable','on');
		set(Handles.Dynamic_Slider_Max,'Enable','on');
		if(Handles.Dynamic_Slider_Min.Min ~= Min_Value || Handles.Dynamic_Slider_Min.Max ~= Max_Value || ...
			Handles.Dynamic_Slider_Max.Min ~= Min_Value || Handles.Dynamic_Slider_Max.Max ~= Max_Value) % Update the slider only if the max or min have changed. Otherwise, keep the last chosen values.
			Handles.Dynamic_Slider_Min.Min = Min_Value; % Scale dynamic sliders.
			Handles.Dynamic_Slider_Min.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Max.Min = Min_Value;% ".
			Handles.Dynamic_Slider_Max.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Min.Value = Min_Value;
			Handles.Dynamic_Slider_Max.Value = Max_Value;
			Handles.Dynamic_Slider_Text_Min.String = [num2str(Handles.Dynamic_Slider_Min.Value),char(181),'m']; % Update sliders text.
			Handles.Dynamic_Slider_Text_Max.String = [num2str(Handles.Dynamic_Slider_Max.Value),char(181),'m']; % ".
		end
	end
	
	function [X,Y] = Smooth_Points(X,Y,Smoothing_Parameter) % X=[1,n]. Y=[1,n].
		% Eval_Points_Num = length(X); % TODO: normalize to the original number of points.
		
		u = smoothn(num2cell([X',Y'],1),Smoothing_Parameter);
		Suxy = horzcat(u{:});
		X = Suxy(:,1)'; % Smoothed x-coordinates.
		Y = Suxy(:,2)'; % Smoothed y-coordinates.
	end
	
end