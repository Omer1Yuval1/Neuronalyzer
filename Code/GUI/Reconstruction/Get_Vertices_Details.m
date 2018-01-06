function Get_Vertices_Details(GUI_Parameters)
	
	[x,y] = ginput(1);
	
	MinD = max(size(GUI_Parameters.Workspace(1).Files{1}.Image0,1),size(GUI_Parameters.Workspace(1).Files{1}.Image0,2));
	C = 0;
	for i=1:numel(GUI_Parameters.Workspace(1).Files{1}.Vertices)
		if(length(GUI_Parameters.Workspace(1).Files{1}.Vertices(i).Rects_Angles_Diffs) >= 3)
			D = ((GUI_Parameters.Workspace(1).Files{1}.Vertices(i).Coordinates(1) - x)^2+(GUI_Parameters.Workspace(1).Files{1}.Vertices(i).Coordinates(2) - y)^2)^.5;
			if(D < MinD)
				MinD = D;
				C = i;
			end
		end
	end
	
	if(exist('Details_Axes1'))
		cla(Details_Axes1);
		cla(Details_Axes2);
		% delete(Details_Axes);
		% Details_Axes = axes(GUI_Parameters.Handles.Details_Tab,'Units','normalized','Position',[0,0,1,.5]);
	else
		Details_Axes1 = axes(GUI_Parameters.Handles.Details_Tab,'Units','normalized','Position',[0,.55,1,.3]);
		Details_Axes2 = axes(GUI_Parameters.Handles.Details_Tab,'Units','normalized','Position',[0,0.1,1,.3]);
	end
	
	axes(Details_Axes1);
	% rose(GUI_Parameters.Workspace(1).Files{1}.Vertices(C).Rectangles_Angles*(pi/180));
	polarhistogram(GUI_Parameters.Workspace(1).Files{1}.Vertices(C).Rectangles_Angles*(pi/180),45);
	set(gca,'FontSize',14);
	
	axes(Details_Axes2);
	Labels1 = textscan(num2str(round(GUI_Parameters.Workspace(1).Files{1}.Vertices(C).Rects_Angles_Diffs)),'%s');
	p = pie(GUI_Parameters.Workspace(1).Files{1}.Vertices(C).Rects_Angles_Diffs,Labels1{1,1});
	p(2).FontSize = 18;
	p(4).FontSize = 18;
	p(6).FontSize = 18;
	
end