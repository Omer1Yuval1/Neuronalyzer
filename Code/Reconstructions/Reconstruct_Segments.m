function Reconstruct_Segments(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	MarkerConstant = 10;
	LineWidthConstant = 1;
	
	figure(1);
	hold on;
	
	% Reconstuct Segments:
	Vs = zeros(1,numel(Workspace1.Segments));
	for i=1:numel(Workspace1.Segments) % Go over each segment.
		Vs(i) = plot([Workspace1.Segments(i).Rectangles.X],[Workspace1.Segments(i).Rectangles.Y], ...
			'LineWidth',Workspace1.Segments(i).Width);
	end
	
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