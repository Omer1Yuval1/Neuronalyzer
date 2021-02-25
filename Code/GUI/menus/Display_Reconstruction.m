function Display_Reconstruction(P,Data,p,Label)
	
	% P is the handle class containing all project and gui data.
	% Data = P.Data(p), where p is the current selected project. It is passed separately as a struct for faster reading (reading a handle class property in a loop is very slow).
	
	Undock = P.GUI_Handles.Control_Panel_Objects(4,1).Value;
	LineWidth_1 = 2; % [2,6].
	DotSize_1 = 10; % 80;
	DotSize_2 = 15; % 80;
	
	if(~Undock)
		Ax = P.GUI_Handles.View_Axes;
		delete(allchild(Ax));
	else
		H = figure;
		Ax = gca;
		[ImRows,ImCols] = size(Data.Info.Files(1).Raw_Image);
		hold on;
	end
	
	% Set_Dynamic_Sliders_Values(GP.Handles.Analysis,0,50);
	
	p = P.GUI_Handles.Current_Project;
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	
	set(P.GUI_Handles.View_Axes,'ButtonDownFcn',''); % set(P.GUI_Handles.View_Axes,'ButtonDownFcn',{@Show_Image_Func,P});
	set(P.GUI_Handles.Control_Panel_Objects(1,5),'ValueChangedFcn','');
	
	set(P.GUI_Handles.Radio_Group_1,'SelectionChangedFcn',{@Radio_Buttons_Func,P});
	% Radio_Buttons_Func([],[],P,Label);
	
	switch(Label)
		case 'Raw Image - Grayscale'
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
		case 'Raw Image - RGB'
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			colormap(Ax,'hot');
		case 'Cell Body' % Detect and display CB and the outsets of the branches connected to it:
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			CB_BW_Threshold = Data.Parameters.Cell_Body.BW_Threshold;
			
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Data.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			% set(gca,'YDir','normal','Position',[0,0,1,1]);
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(Data.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
			
			% plot(CB_Perimeter(:,1),CB_Perimeter(:,2),'LineWidth',4);
		case 'CNN Image'
			
			CM = lines;
			Im_Label = labeloverlay(Data.Info.Files(1).Raw_Image,Data.Info.Files(1).Denoised_Image,'Colormap',CM([1,7],:),'Transparency',0.1,'IncludedLabels',["Neuron"]);
			
			imshow(Im_Label,'Parent',Ax);
			
			set(P.GUI_Handles.Control_Panel_Objects(1,[4,5]),'Enable','off'); % 'Limits',[0,0.99],'Step',0.01,'Value',Data.Parameters.Neural_Network.Threshold,'Tooltip','Threshold for the binarization of the denoised image.'); % CNN threshold.
			
			set(P.GUI_Handles.Buttons(3,1),'ButtonPushedFcn',{@Apply_Changes_Func,P,p,Label});
		case {'Binary Image','Binary Image - RGB'}
			
			switch(Label)
				case 'Binary Image'
					imshow(Data.Info.Files(1).Binary_Image,'Parent',Ax);
				case 'Binary Image - RGB'
					Im_RGB = repmat(Data.Info.Files(1).Raw_Image(:,:,1),[1,1,3]);
					Im_RGB(:,:,1) = Im_RGB(:,:,1) .* uint8(~Data.Info.Files(1).Binary_Image);
					Im_RGB(:,:,2) = Im_RGB(:,:,2) .* uint8(Data.Info.Files(1).Binary_Image);
					imshow(Im_RGB,'Parent',Ax);
			end
			
			set(P.GUI_Handles.Control_Panel_Objects(1,3),'Text','Marker size:');
			set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[0,20],'Step',1,'Value',2,'Tooltip','Marker size (in pixels) for adding (left mouse click) and removing (left mouse click) pixels.'); % Set the spinner.
			set(P.GUI_Handles.Control_Panel_Objects(1,5),'Limits',[1,1000],'Step',1,'Value',Data.Parameters.Neural_Network.Min_CC_Size,'ValueChangedFcn',{@Update_Binary_Threshold_Func,P,p},'Tooltip','Minimum object size (in pixels) in the binarized image.'); % Minimum object size.
			
			set(P.GUI_Handles.Control_Panel_Objects([1,2,3],2),'Enable','on'); % Enable the radio buttons.
			set(P.GUI_Handles.Control_Panel_Objects(1,[4,5]),'Enable','on'); % Enable the spinners.
			
			set(allchild(Ax),'HitTest','off');
			set(Ax,'PickableParts','all');
		
		case 'CNN + Binary'
			CM = lines;
			
			Im = Data.Info.Files(1).Denoised_Image;
			Im(Data.Info.Files(1).Binary_Image == 1 & Im == "BG") = "Added"; % Added pixels.
			Im(Data.Info.Files(1).Binary_Image == 0 & Im == "Neuron") = "Removed"; % Removed pixels.
			
			Im_Label = labeloverlay(Data.Info.Files(1).Raw_Image,Im,'Colormap',CM([1,7,1,3],:),'Transparency',0.1,'IncludedLabels',["Neuron","Added","Removed"]);
			
			imshow(Im_Label,'Parent',Ax);
		case 'Skeleton'
			[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Pixel_Trace_Post_Proccessing(Data.Info.Files(1).Binary_Image,Scale_Factor);
			imshow(Im1_NoiseReduction,'Parent',Ax);
			
			skel_method = 2;
			
			switch(skel_method)
				case 1 % Display segments.
					for s=1:numel(Data.Segments)
						if(numel(Data.Segments(s).Rectangles))
							x = [Data.Segments(s).Rectangles.X];
							y = [Data.Segments(s).Rectangles.Y];
							hold(Ax,'on');
							plot(Ax,x,y,'LineWidth',1); % plot(x,y,'.','MarkerSize',30,'Color',rand(1,3));
						end
					end
					% [Y,X] = find(Im1_branchpoints); hold on; plot(X,Y,'.k','MarkerSize',30);
					% [Y,X] = find(Im1_endpoints); hold on; plot(X,Y,'.r','MarkerSize',30);
				case 2 % Display connected components.
					CM = lines(1000);
					
					CC = bwconncomp(Im1_NoiseReduction);
					for c=1:length(CC.PixelIdxList)
						[y,x] = ind2sub(size(Im1_NoiseReduction),CC.PixelIdxList{c});
						hold(Ax,'on');
						plot(Ax,x,y,'.','MarkerSize',7,'Color',CM(c,:));
					end
			end
		case 'Blob'
			[ImB,XYper] = Neuron_To_Blob(Data.Info.Files(1).Binary_Image);
			
			imshow(ImB,'Parent',Ax);
			hold(Ax,'on');
			
			plot(Ax,XYper(:,1),XYper(:,2),'LineWidth',2);
			
			% look in "Find_Worm_Longitudinal_Axis" to check the midline finding process.
			
		case {'Trace - Lite','Trace','Segmentation'}
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			
			Ns =  numel(Data.Segments);
			if(isfield(Data,'Segments'))
				for s=1:Ns
					if(numel(Data.Segments(s).Rectangles))
						x = [Data.Segments(s).Rectangles.X];
						y = [Data.Segments(s).Rectangles.Y];
						W = [Data.Segments(s).Rectangles.Width];
						if(length(x) > 1)
							[x,y] = Smooth_Points(x,y,10);
						end
						
						switch(Label)
							case 'Trace - Lite'
								plot(Ax,x,y,'LineWidth',LineWidth_1,'Color',[0,0.8,0]); % [0.12,0.56,1]
							case 'Trace'
								plot_line_edge(Ax,x,y,W);
							case 'Segmentation'
								plot(Ax,x,y,'LineWidth',LineWidth_1);
						end
					end
					% P.GUI_Handles.Waitbar.Value = s ./ Ns;
				end
			end
			
			% Plot the vertices:
			switch(Label)
				case {'Trace - Lite','Segmentation'}
					Fj = find([Data.Vertices.Order] == 3); % Find junctions.
					Xj = [Data.Vertices(Fj).X];
					Yj = [Data.Vertices(Fj).Y];
					scatter(Ax,Xj,Yj,5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
					% scatter(Ax,[Data.Vertices.X],[Data.Vertices.Y],5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
				case 'Trace'
					for j=1:numel(Data.Vertices)
						if(Data.Vertices(j).Order >= 3 && numel(Data.Vertices(j).Rectangles) == Data.Vertices(j).Order)
							plot_junction(Ax,Data.Vertices(j).X,Data.Vertices(j).Y,[Data.Vertices(j).Rectangles.Angle]);
						end
					end
			end
		case 'Segments by Length'
			
			Max_Length = 50; % [um].
			CM = jet(1000);
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
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
			
			scatter(Ax,[Data.Vertices.X],[Data.Vertices.Y],5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
		case 'Axes'
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			
			% look in "Find_Worm_Longitudinal_Axis" to check the midline finding process.
			
			set(P.GUI_Handles.Control_Panel_Objects([1,3],2),'Enable','on'); % Enable the radio buttons.
			set(P.GUI_Handles.Control_Panel_Objects(1,5),'Enable','off');
			set(P.GUI_Handles.Control_Panel_Objects(1,3),'Text','Points:');
			set(P.GUI_Handles.Control_Panel_Objects(1,4),'Limits',[5,100],'Step',1,'Enable','on','Tooltip','Number of interactive points.'); % Set the spinner.
			
			CM1 = lines(7);
			CM1 = CM1([7,1,1,3,3],:);
			
			F = fields(Data.Axes);
			
			if(P.GUI_Handles.Control_Panel_Objects(3,2).Value == 1) % Annotation mode.
				Np_Waypoints = P.GUI_Handles.Control_Panel_Objects(1,4).Value; % Number of interactive points.
				
				% disableDefaultInteractivity(Ax);
				% set(allchild(Ax),'HitTest','off'); set(Ax,'HitTest','off');
				% set(Ax,'PickableParts','all'); % set(allchild(Ax),'PickableParts','none');
				set(P.GUI_Handles.View_Axes.Children(end),'ButtonDownFcn',{@Lock_Image_Func,P}); % Used to fix the image.
			end
			
			for f=1:length(F)
				XY = [Data.Axes.(F{f}).X ; Data.Axes.(F{f}).Y]; % Midline coordinates.
				
				Np_Total = size(XY,2);
				Np_Waypoints = P.GUI_Handles.Control_Panel_Objects(1,4).Value; % Number of interactive points.
				
				if(P.GUI_Handles.Control_Panel_Objects(3,2).Value == 1) % Annotation mode.
					
					Waypoints = false(Np_Total,1);
					Waypoints(1:round(Np_Total / Np_Waypoints):Np_Total) = true;
					
					roi = images.roi.Freehand(Ax,'Position',[XY(1,:)',XY(2,:)'],'Waypoints',Waypoints,'UserData',{p,F{f}},'Closed',false,'Color',CM1(f,:),'FaceAlpha',0,'FaceSelectable',false); % roi = images.roi.Polyline(Ax,'Position',[XY(1,:)',XY(2,:)'],'UserData',{p,F{f}});
					addlistener(roi,'ROIMoved',@(src,evnt) Draggable_Point_Func(src,evnt,P));
				else
					plot(Ax,XY(1,:),XY(2,:),'Color',CM1(f,:),'LineWidth',3);
				end
			end
			% hold(Ax,'off');
			
			if(0) % Plot the normals to the midline.
				for i=1:numel(P.Data.Axes.Axis_0)
					x = P.Data.Axes.Axis_0(i).X;
					y = P.Data.Axes.Axis_0(i).Y;
					a = P.Data.Axes.Axis_0(i).Tangent_Angle + (pi/2);
					plot(Ax,x + 40.*[0,cos(a)] , y + 40.*[0,sin(a)]);
				end
			end
		case 'Axes Mapping Process'
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			Map_Worm_Axes(Data,Data.Axes,1,0,Ax);
		case {'Radial Distance','Angular Coordinate'}
			
			Min_Max = [0,pi./2];
			CM_Lims = [1,1000];
			CM = hsv(CM_Lims(2));
			
			switch(Label)
				case 'Radial Distance'
					Field_1 = 'Radial_Distance_Corrected';
				case 'Angular Coordinate'
					Field_1 = 'Angular_Coordinate';
			end
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			
			for s=1:numel(Data.Segments)
				
				Fs = find([[Data.Points.Segment_Index]] == Data.Segments(s).Segment_Index & ~isnan([Data.Points.(Field_1)]) );
				
				X = [Data.Points(Fs).X];
				Y = [Data.Points(Fs).Y];
				if(length(X) > 1)
					[X,Y] = Smooth_Points(X,Y,100);
				end
				
				C = abs([Data.Points(Fs).(Field_1)]);
				C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Min_Max(1),'InputMax',Min_Max(2))),:);
				
				X(end+1) = nan;
				Y(end+1) = nan;
				C(end+1,:) = nan(1,3);
				h = patch(Ax,X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
			end
		case 'Midline Orientation'
			
			Min_Max = [0,pi./2];
			CM_Lims = [1,1000];
			c = linspace(0,1,CM_Lims(2))';
			CM = [1-c,c,0.*c+0.1]; % CM = jet(CM_Lims(2));
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			
			for s=1:numel(Data.Segments)

				Fs = find([[Data.Points.Segment_Index]] == Data.Segments(s).Segment_Index);
			
				X = [Data.Points(Fs).X];
				Y = [Data.Points(Fs).Y];
				if(length(X) > 1)
					[X,Y] = Smooth_Points(X,Y,100);
				end
				
				C = [Data.Points(Fs).Midline_Orientation];
				C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Min_Max(1),'InputMax',Min_Max(2))),:);
				
				X(end+1) = nan;
				Y(end+1) = nan;
				C(end+1,:) = nan(1,3);
				h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
			end
		case 'Longitudinal Gradient'
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			
			Min_Max = [0,800]; % um.
			CM_Lims = [1,1000];
			CM = jet(CM_Lims(2));
			
			for s=1:numel(Data.Segments)

				Fs = find([[Data.Points.Segment_Index]] == Data.Segments(s).Segment_Index);
			
				X = [Data.Points(Fs).X];
				Y = [Data.Points(Fs).Y];
				if(length(X) > 1)
					[X,Y] = Smooth_Points(X,Y,100);
				end
				
				C = [Data.Points(Fs).Axis_0_Position];
				C = CM(round(rescale(C,CM_Lims(1),CM_Lims(2),'InputMin',Min_Max(1),'InputMax',Min_Max(2))),:);
				
				X(end+1) = nan;
				Y(end+1) = nan;
				C(end+1,:) = nan(1,3);
				h = patch(X',Y',1,'FaceVertexCData',C,'EdgeColor','interp','MarkerFaceColor','flat','LineWidth',2); % 8.
			end
		case 'Dorsal-Ventral'
			
			Field_1 = 'Radial_Distance_Corrected';
			
			CM = lines(2);
			
			X = [Data.Points.X];
			Y = [Data.Points.Y];
			Dist = [Data.Points.(Field_1)];
			
			D = find(Dist <= 0);
			V = find(Dist > 0);
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			scatter(Ax,X(D),Y(D),DotSize_1,CM(1,:),'filled');
			scatter(Ax,X(V),Y(V),DotSize_1,CM(end,:),'filled');
		
		case {'Junction Angles'}
			
			a = 5;
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			
			Reconstruct_Vertices(Data);
			
			%{
			F1 = find([Data.Points.Vertex_Order] >= 3); % Find rectangles of junctions.
			X = [Data.Points(F1).X];
			Y = [Data.Points(F1).Y];
			A = [Data.Points(F1).Angle];
			Vx = [X ; X + a.*cos(A)];
			Vy = [Y ; Y + a.*sin(A)];
			
			plot([Data.All_Vertices.X],[Data.All_Vertices.Y],'.','MarkerSize',50);
			hold on;
			plot(Vx,Vy,'LineWidth',3);
			%}
		case 'Vertex Positions'
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			
			Fv = find([Data.Vertices.Order] >= 3); % Junctions.
			Ft = find([Data.Vertices.Order] == 1); % Tips.
			
			X = [Data.Vertices.X];
			Y = [Data.Vertices.Y];
			
			hold(Ax,'on');
			scatter(Ax,X(Fv),Y(Fv),20,[0.8,0,0],'filled');
			scatter(Ax,X(Ft),Y(Ft),20,[0,0.8,0],'filled');
			
			%{
			switch(Label)
				case '3-Way Junctions - Position'
					Vertex_Order = 3;
					Junction_Classes = [1,1,2 ; 2,3,3 ; 3,3,4]; % 234,344
				case 'Tips - Position'
					Vertex_Order = 1;
					Junction_Classes = 1:4;
			end
			
			Max_PVD_Orders = length(Junction_Classes);
			CM = lines(Max_PVD_Orders);
			
			for v=1:numel(Data.Vertices)
				if(Data.Vertices(v).Order == Vertex_Order && length(Data.Vertices(v).Class) == Vertex_Order)
					[I,i] = ismember(sort(Data.Vertices(v).Class),Junction_Classes,'rows');
					if(I) % If the class is a member of the Junction_Classes matrix, plot it.
						X = [Data.Vertices(v).X];
						Y = [Data.Vertices(v).Y];
						
						hold on;
						scatter(X,Y,40,CM(i,:),'filled');
					end
				end
			end
			%}
		case 'Curvature'
			Curvature_Min_Max = [0,0.3]; % 0.2
			CM_Lims = [1,1000];
			CM = turbo(CM_Lims(2));
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
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
				% P.GUI_Handles.Waitbar.Value = s ./ Ns;
				
				scatter(Ax,[Data.Vertices.X],[Data.Vertices.Y],5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
			end
		case 'PVD Orders - Points'
			
			Class_Num = max([Data.Points.Class]);
			
			C = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0 ; .5,.5,.5];
			
			% figure;
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
			hold(Ax,'on');
			
			Midline_Distance = [Data.Points.X];
			Midline_Orientation = [Data.Points.Y];
			Classes = [Data.Points.Class]; % Classes = [Data.Points.Segment_Class];
			Classes(isnan(Classes)) = Class_Num + 1;
			
			scatter(Ax,Midline_Distance,Midline_Orientation,5,C(Classes,:),'filled');
			
			% assignin('base','Points',Data.Points);
			
		case 'PVD Orders - Segments'
			Class_Num = max([Data.Segments.Class]);
			
			% C = lines(Class_Num+1);
			Class_Indices = [1,2,3,4]; %  [1,2,3,3.5,4,5];
			Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0]; % 3=0,0.8,0.8 ; 3.5=0,0,1 ; 5=0.5,0.5,0.5
			
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
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
				% P.GUI_Handles.Waitbar.Value = s ./ Ns;
			end
			
			% Plot the vertices:
			%
			scatter(Ax,[Data.Vertices.X],[Data.Vertices.Y],5,'k','filled'); % Use 100 when zooming in. Otherwise 10.
			%}
			
			% Use when zooming in:
			% F = find([Data.All_Vertices.Order] >= 2);
			% R = [Data.All_Vertices.Radius] .* GP.Workspace(1).Workspace.User_Input.Scale_Factor ./ 10;
			% viscircles([X(F)',Y(F)'],R(F),'Color','k','LineWidth',5); % [0.6350 0.0780 0.1840]
		otherwise
			imshow(Data.Info.Files(1).Raw_Image,'Parent',Ax);
	end
	
	if(Undock)
		set(gca,'position',[0,0,1,1]);
		axis tight;
		H.InnerPosition = [50,50,ImCols./2.5,ImRows./2.5];
	else
		set(P.GUI_Handles.View_Axes.Children(1),'Visible','off','Visible','on');
	end
	
	function [X,Y] = Smooth_Points(X,Y,Smoothing_Parameter) % X=[1,n]. Y=[1,n].
		% Eval_Points_Num = length(X); % TODO: normalize to the original number of points.
		
		u = smoothn(num2cell([X',Y'],1),Smoothing_Parameter);
		Suxy = horzcat(u{:});
		X = Suxy(:,1)'; % Smoothed x-coordinates.
		Y = Suxy(:,2)'; % Smoothed y-coordinates.
	end
	
	function Update_Binary_Threshold_Func(~,~,P,pp)
		switch(Label)
			case {'Binary Image','Binary Image - RGB'}
				
				P.Data(pp).Parameters.Neural_Network.Min_CC_Size = P.GUI_Handles.Control_Panel_Objects(1,5).Value;
				disp(['Minimum object size changed to: ',num2str(P.Data(pp).Parameters.Neural_Network.Min_CC_Size)]);
				
				P.Data(pp).Info.Files(1).Binary_Image = Update_Binary_Image(P.Data(pp).Info.Files(1).Denoised_Image,P.Data(pp).Parameters.Neural_Network.Min_CC_Size);		end
	end
	
	function Annotate_Image(~,event,P,pp,RGB_Flag)
		
		Mode = find([P.GUI_Handles.Radio_Group_1.Children.Value] == 1);
		switch(Mode)
			case 1 % Default.
				disp('Default mode. User interaction is ignored.');
				set(findall(P.GUI_Handles.View_Axes.Children,'Type','image'),'HitTest','on');
			case {2,3} % Annotation & Drawing modes.
				
				set(findall(P.GUI_Handles.View_Axes.Children,'Type','image'),'HitTest','off');
				
				Mouse_Button = event.Button;
				Marker_Size = P.GUI_Handles.Control_Panel_Objects(1,4).Value;
				
				if(mod(Marker_Size,2) == 1) % If odd number.
					dd = [-round((Marker_Size-1)/2) : round((Marker_Size-1)/2)]; % dd = round((Marker_Size-1)/2);
				else % If even number.
					dd = [(-round((Marker_Size-1)/2)+1) : round((Marker_Size-1)/2)];
				end
				% disp(dd);
				
				switch(Mode)
					case 2 % Drawing mode.
						hold(P.GUI_Handles.View_Axes,'on');
						roi_i = drawfreehand(P.GUI_Handles.View_Axes,'Closed',0,'LineWidth',Marker_Size,'FaceAlpha',0,'FaceSelectable',0);
						% roi_i = images.roi.AssistedFreehand(P.GUI_Handles.View_Axes.Children(end)); draw(roi_i);
						
						% [~,ia,~] = unique(roi_i.Position,'rows'); % Remove duplicated points.
						% roi_i.Position = roi_i.Position(sort(ia),:);
						
						Npp = size(roi_i.Position,1);
						Cxy = zeros(2,0);
						
						if(Npp > 1)
							% Upsample:
							tt = 1:Npp;
							fit_ppform = spline(tt,[roi_i.Position']); % Alternative: use cscvn(roi_i.Position');
							xy = ppval(fit_ppform,linspace(tt(1),tt(end),Npp*100));
							xx = xy(1,:);
							yy = xy(2,:);
							
							% xx = roi_i.Position(:,1);
							% yy = roi_i.Position(:,2);
							
							Cx = round(xx(:)) + dd; % (-dd:dd)
							Cy = round(yy(:)) + dd;
							% Cxy = combvec(Cx',Cy');
							% Cxy = [reshape(Cxy(1:5,:),1,[]) ; reshape(Cxy(6:10,:),1,[])];
							
							for ii=1:length(xx) % For each point.
								Cxy = [Cxy , combvec(Cx(ii,:) , Cy(ii,:))]; % [2 x Np].
							end
							delete(roi_i); % delete(findobj(P.GUI_Handles.View_Axes,'-not','Type','image','-and','-not','Type','axes'));
						end
					case 3 % Annotation mode.
						CCi = event.IntersectionPoint;
						CCi = [round(CCi(1)),round(CCi(2))];
						Cxy = combvec(CCi(1) + dd , CCi(2) + dd); % [2 x Np].
				end
				
				Ci = (size(P.Data(pp).Info.Files(1).Binary_Image,1) .* (Cxy(1,:) - 1) + Cxy(2,:)); % Linear indices.
				
				switch(Mouse_Button)
					case 1 % Left mouse click - add pixels.
						P.Data(pp).Info.Files(1).Binary_Image(Ci) = 1;
						disp('Pixels added.');
					case 3 % Right mouse click - delete pixels.
						P.Data(pp).Info.Files(1).Binary_Image(Ci) = 0;
						disp('Pixels removed.');
				end
				
				% delete(allchild(P.GUI_Handles.View_Axes));
				
				if(RGB_Flag)
					Im_RGB_i = repmat(P.Data(pp).Info.Files(1).Raw_Image(:,:,1),[1,1,3]); % Replicate the full image in all channels.
					Im_RGB_i(:,:,1) = Im_RGB_i(:,:,1) .* uint8(~P.Data(pp).Info.Files(1).Binary_Image); % BG of BW is red.
					Im_RGB_i(:,:,2) = Im_RGB_i(:,:,2) .* uint8(P.Data(pp).Info.Files(1).Binary_Image); % Signal of BW is green.
					
					% imshow(Im_RGB_i,'Parent',P.GUI_Handles.View_Axes);
					set(P.GUI_Handles.View_Axes.Children(1),'CData',Im_RGB_i);
				else
					set(P.GUI_Handles.View_Axes.Children(1),'CData',P.Data(pp).Info.Files(1).Binary_Image);
					% imshow(P.Data(pp).Info.Files(1).Binary_Image,'Parent',P.GUI_Handles.View_Axes);
				end
				
				%{
				drawnow;
				drawnow;
				set(P.GUI_Handles.View_Axes,'Visible','on');
				drawnow;
				set(P.GUI_Handles.View_Axes.Children(1),'Visible','off','Visible','on');
				%}
				set(findall(P.GUI_Handles.View_Axes.Children,'Type','image'),'HitTest','off'); % set(P.GUI_Handles.View_Axes,'PickableParts','all');
				
			case 4 % Deletion.
				%{
				xy0 = event.IntersectionPoint; % Clicked point.
				CCi = bwconncomp(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW);
				Vc = nan(1,length(CCi.PixelIdxList)); % Vector of minimal distance from the connected objects.
				for ii=1:length(CCi.PixelIdxList)
					[y,x] = ind2sub([Im_Rows,Im_Cols],CCi.PixelIdxList{ii});
					Vc(ii) = min( ((xy0(1) - x).^2 + (xy0(2) - y).^2).^(0.5) );
				end
				GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW(CCi.PixelIdxList{find(Vc == min(Vc),1)}) = 0;
				%}
		end
	end
	
	function Draggable_Point_Func(source,~,P) % Update the position of annotated points.
		
		ppp = source.UserData{1}; % Project number.
		FF = source.UserData{2}; % Field name.
		
		xx = source.Position(:,1)';
		yy = source.Position(:,2)';
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
		
		xxc = num2cell(xx);
		yyc = num2cell(yy);
		[P.Data(ppp).Axes.(FF).X] = xxc{:};
		[P.Data(ppp).Axes.(FF).Y] = yyc{:};
		
		if(isequal(FF,'Axis_0')) % If it's the midline, also update arc-lengths and tangents.
			dxy = sum(([xx(2:end) ; yy(2:end)] - [xx(1:end-1) ; yy(1:end-1)]).^2,1).^(0.5); % sum([2 x Np],1). Summing up Xi+Yi and then taking the sqrt.
			Arc_Length = num2cell(cumsum([0 , dxy]) .* P.Data(ppp).Info.Experiment(1).Scale_Factor); % Convert pixels to real length units (um).
			
			dr = [gradient(xx(:)) , gradient(yy(:))]; % First derivative.
			ddr = [gradient(dr(:,1)) , gradient(dr(:,2))];
			Tangent_Angles = atan2(ddr(:,2),ddr(:,1));
			Tangent_Angles = num2cell(Tangent_Angles);
			
			[P.Data(ppp).Axes.(FF).Arc_Length] = Arc_Length{:};
			[P.Data(ppp).Axes.(FF).Tangent_Angles] = Tangent_Angles{:};
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Radio_Buttons_Func(~,~,P)
		switch(find([P.GUI_Handles.Radio_Group_1.Children.Value] == 1)) % Mode.
			case {2,3} % Annotation & Drawing modes.
				zoom(P.GUI_Handles.View_Axes,'off'); % Switch off the zoom function.
				
				switch(Label)
					case 'Binary Image'
						set(P.GUI_Handles.View_Axes,'ButtonDownFcn',{@Annotate_Image,P,P.GUI_Handles.Current_Project,0});
					case 'Binary Image - RGB'
						set(P.GUI_Handles.View_Axes,'ButtonDownFcn',{@Annotate_Image,P,P.GUI_Handles.Current_Project,1});
				end
				
			otherwise
				set(P.GUI_Handles.View_Axes,'ButtonDownFcn','');
		end
    end
    
    function Lock_Image_Func(~,~,P)
        
    end
	
end