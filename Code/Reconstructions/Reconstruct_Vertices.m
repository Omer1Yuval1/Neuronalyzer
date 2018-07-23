function Reconstruct_Vertices(W)
	
	Scale_Factor = W.User_Input(1).Scale_Factor;
	
	for v=1:numel(W.Vertices)
		Av = [W.Vertices(v).Rectangles.Angle];
		if(length(unique(Av)) < length(Av))
			C = [0,.6,0];
		else
			C = [.8,0,0];
		end
		
		for r=1:numel(W.Vertices(v).Rectangles)
			O = W.Vertices(v).Rectangles(r).Origin;
			A = W.Vertices(v).Rectangles(r).Angle .* 180 ./ pi;
			Rect_Width = W.Vertices(v).Rectangles(r).Width ./ Scale_Factor;
			Rect_Length = W.Vertices(v).Rectangles(r).Length ./ Scale_Factor;
			
			[XV,YV] = Get_Rect_Vector(O,A,Rect_Width,Rect_Length,14);
			
			plot(W.Vertices(v).Coordinate(1),W.Vertices(v).Coordinate(2),'.','Color',[1,.65,0],'MarkerSize',15); % Orange.
			hold on;
			plot(XV,YV,'Color',C,'LineWidth',2); % ,'Color',[.9,0,.4].
		end
	end
	
	% hold on;
	% for s=1:numel(W.Segments)
		% plot(W.Segments(s).Skel_X,W.Segments(s).Skel_Y,'k');
	% end
end