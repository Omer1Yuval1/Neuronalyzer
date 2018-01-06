function Reconstruct_Trace_Dots(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	MarkerConstant = 3;
	
	figure(1);
	hold on;
	
	F = find([Workspace1.Path.Is_Mapped] > -1);
	V = [Workspace1.Path(F).Coordinates];
	X = (V(1:2:end));
	Y = (V(2:2:end));
	h = scatter(X,Y,'.','MarkerEdgeColor',[.125,.564,1]); % [.9,0,.4]);
	
	z = zoom;
	set(z,'ActionPostCallback',@mypostcallback);
	
	function mypostcallback(z,eventdata);
		currentunits = get(gca,'Units');
		set(gca,'Units','Points');
		axpos = get(gca,'Position');
		set(gca,'Units',currentunits);
		MarkerPoints = MarkerConstant/diff(xlim)*axpos(3); % Calculate Marker width in points.
		
		set(h,'SizeData',MarkerPoints^2);
	end
	
end