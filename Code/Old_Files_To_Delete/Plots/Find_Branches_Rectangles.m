function Rects_Coordinates = Find_Branches_Rectangles(Workspace1,Order1,Plot1)
	
	if(Plot1)
		figure(2);
		imshow(Workspace1.Image0);
		set(gca,'YDir','normal');
		Colormap = jet(64);
	end
	
	Vb = [];
	for o=1:length(Order1)
		Vb = [Vb,find([Workspace1.Branches.Order] == Order1(o))];
	end
	Rects_Coordinates = [];
	
	for b=Vb
		if(numel(Workspace1.Branches(b).Rectangles) > 1)
			P1 = [Workspace1.Branches(b).Rectangles(1).X,Workspace1.Branches(b).Rectangles(1).Y];
			P2 = [Workspace1.Branches(b).Rectangles(end).X,Workspace1.Branches(b).Rectangles(end).Y];
			
			A = Find_Angle360_2_Points(P1,P2);
			
			[Xv,Yv] = rotate_vector_origin([Workspace1.Branches(b).Rectangles.X], ...
						[Workspace1.Branches(b).Rectangles.Y],P1,90-A);
			
			Rect1X = [min(Xv) , max(Xv) , max(Xv) , min(Xv)]; % Bounding rectangle(x) - aligned with the grid.
			Rect1Y = [max(Yv) , max(Yv) , min(Yv) , min(Yv)]; % Bounding rectangle(y) - aligned with the grid.
			
			[Rect2X,Rect2Y] = rotate_vector_origin(Rect1X,Rect1Y,P1,A-90); % Bounding rectangle.
			
			Rect2X = [Rect2X,Rect2X(1)];
			Rect2Y = [Rect2Y,Rect2Y(1)];
			
			if(Plot1)
				hold on;
				plot(Rect2X,Rect2Y,'LineWidth',1.5,'Color',Colormap(randi([1,64],1,1),:));
			end
			
			Coordinates1 = InRect_Coordinates(Workspace1.Image0,[Rect2X',Rect2Y']);
			Rects_Coordinates = [Rects_Coordinates,Coordinates1];
		end
	end
	
	Rects_Coordinates = unique(Rects_Coordinates); % Do not count the same pixel more than once.
	
end