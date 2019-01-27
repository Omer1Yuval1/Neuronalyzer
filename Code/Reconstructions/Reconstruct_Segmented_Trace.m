function Reconstruct_Segmented_Trace(Workspace1,Dynamic_Sliders_Handles)
		
	% Scale_Factor = Workspace1.User_Input.Scale_Factor;
	MarkerConstant = 10;
	LineWidthConstant = 1;
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	
	figure(1);
	hold on;
	
	% assignin('base','Workspace1',Workspace1);
	
	% Reconstuct Segments:
	Vs = zeros(1,numel(Workspace1.Segments));
	for s=1:numel(Workspace1.Segments) % Go over each segment.
		if(~isempty(Workspace1.Segments(s).Distance_From_Medial_Axis))
			Vi = Workspace1.Segments(s).Distance_From_Medial_Axis;
			if(~isempty(Workspace1.Segments(s).Rectangles) && (Vi >= Dynamic_Sliders_Handles.Dynamic_Slider_Min.Value && Vi <= Dynamic_Sliders_Handles.Dynamic_Slider_Max.Value))
				Color1 = rand(1,3);
				Vs(s) = plot([Workspace1.Segments(s).Rectangles.X],[Workspace1.Segments(s).Rectangles.Y],'Color',Color1,'LineWidth',3); % ,'LineWidth',Workspace1.Segments(s).Width);
			end
		elseif(~isempty(Workspace1.Segments(s).Rectangles))
			Color1 = rand(1,3);
			Vs(s) = plot([Workspace1.Segments(s).Rectangles.X],[Workspace1.Segments(s).Rectangles.Y],'Color',Color1,'LineWidth',3);
		end
	end
	
	hold on; % Plot Vertices rectangles (branches outsets):
	Vi = [Workspace1.Vertices.Coordinate];
	Vi = [Vi(1:2:end-1)',Vi(2:2:end)'];
	viscircles(Vi,[Workspace1.Vertices.Center_Radius]');
	%{
	for v=1:numel(Workspace1.Vertices) % Go over each vertex.
		plot(Workspace1.Vertices(v).Coordinate(1),Workspace1.Vertices(v).Coordinate(2),'.r','MarkerSize',10);
		%{
		for r=1:numel(Workspace1.Vertices(v).Rectangles)
			Origin1 = Workspace1.Vertices(v).Rectangles(r).Origin;
			Angle1 = Workspace1.Vertices(v).Rectangles(r).Angle;
			Width1 = Workspace1.Vertices(v).Rectangles(r).Width / Scale_Factor; % Conversion to pixels.
			Length1 = Workspace1.Vertices(v).Rectangles(r).Length / Scale_Factor; % Conversion to pixels.
			[XV,YV] = Get_Rect_Vector(Origin1,Angle1*180/pi,Width1,Length1,14);
		
			plot(XV,YV,'LineWidth',2);
		end
		%}
	end
	%}
	return;
	
	Fj = find([Workspace1.Vertices.Vertex_Index] > 0);
	Ft = find([Workspace1.Vertices.Vertex_Index] < 0);
	Vj = [Workspace1.Vertices(Fj).Coordinates];
	Vt = [Workspace1.Vertices(Ft).Coordinates];
	Hj = scatter(Vj(1:2:end),Vj(2:2:end),'.g','SizeData',30);
	Ht = scatter(Vt(1:2:end),Vt(2:2:end),'.','SizeData',30,'MarkerEdgeColor',[.9,0,.4]);
	
	z = zoom;
	% set(z,'ActionPreCallback',@myprecallback);
	set(z,'ActionPostCallback',@mypostcallback);
	
	function mypostcallback(z,eventdata);
		currentunits = get(gca,'Units');
		set(gca,'Units','Points');
		axpos = get(gca,'Position');
		set(gca,'Units',currentunits);
		MarkerPoints = MarkerConstant/diff(xlim)*axpos(3); % Calculate Marker width in points.
		
		set(Hj,'SizeData',MarkerPoints^2);
		set(Ht,'SizeData',MarkerPoints^2);
		set(Vs,'LineWidth',LineWidthConstant^2);
	end
	
end