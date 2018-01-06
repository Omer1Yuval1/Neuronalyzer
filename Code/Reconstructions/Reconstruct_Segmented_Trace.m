function Reconstruct_Segmented_Trace(Workspace1)
	
	% Scale_Factor = Workspace1.User_Input.Scale_Factor;
	MarkerConstant = 10;
	LineWidthConstant = 1;
	
	figure(1);
	hold on;
	
	% assignin('base','Workspace1',Workspace1);
	
	% Reconstuct Segments:
	Vs = zeros(1,numel(Workspace1.Segments));
	for s=1:numel(Workspace1.Segments) % Go over each segment.
		if(~isempty(Workspace1.Segments(s).Rectangles));
			Coordinates1 = reshape([Workspace1.Segments(s).Rectangles.Coordinates]',2,[])';
			if(length(Coordinates1))
				Vs(s) = plot(Coordinates1(:,1),Coordinates1(:,2),'.'); % ,'LineWidth',Workspace1.Segments(s).Width);
			end
		end
	end
	
	hold on; % Plot Vertices rectangles (branches outsets):
	for v=1:numel(Workspace1.Vertices) % Go over each vertex.
		for r=1:numel(Workspace1.Vertices(v).Rectangles)
			Origin1 = Workspace1.Vertices(v).Rectangles(r).Origin;
			Angle1 = Workspace1.Vertices(v).Rectangles(r).Angle;
			Width1 = Workspace1.Vertices(v).Rectangles(r).Width;
			Length1 = Workspace1.Vertices(v).Rectangles(r).Length;
			[XV,YV] = Get_Rect_Vector(Origin1,Angle1*180/pi,Width1,Length1,14);
		
			plot(XV,YV,'LineWidth',2);
		end
	end
	
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