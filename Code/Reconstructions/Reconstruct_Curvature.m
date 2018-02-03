function Reconstruct_Curvature(Workspace,Slider_Value)
	
	% Plot a heatmap of curvature.
	% Maximal value set by the slide bar.
	Slider_Value = 0.3;
	
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	ColorMap1 = jet(64);
	
	for s=1:numel(Workspace.Segments) % For each segment. 
		for p=1:numel(Workspace.Segments(s).Rectangles) % For each coordinate within segment s.
			C = Workspace.Segments(s).Rectangles(p).Curvature;
			if(C >= 0) % If the coordinate has a positive curvature value.
				if(C <= Slider_Value) % If the curvature value is below the maximum set by the Slider_Value.
					% MLS = min(M,Workspace.Segments(s).Rectangles(p).Curvature)/M;
					plot(Workspace.Segments(s).Rectangles(p).X,Workspace.Segments(s).Rectangles(p).Y,'.','Color',[C 0 1-C],'MarkerSize',Workspace.Segments(s).Width/Scale_Factor);
				else %  % If the curvature value is below the maximum set by the Slider_Value.
					% plot(Workspace.Segments(s).Rectangles(p).X,Workspace.Segments(s).Rectangles(p).Y,'*','Color','r','MarkerSize',Workspace.Segments(s).Width/Scale_Factor);
				end
			else
				plot(Workspace.Segments(s).Rectangles(p).X,Workspace.Segments(s).Rectangles(p).Y,'.','Color',[0,.8,0],'MarkerSize',Workspace.Segments(s).Width/Scale_Factor);
			end
		end
	end
end