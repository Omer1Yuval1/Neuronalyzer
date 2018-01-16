function Reconstruct_Dorsal_Ventral(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	Colors1 = [1,0,0 ; 0,1,0 ; 0,0,1];
	C = 1;
	
	% Reconstuct Segments & Vertices coordinates:
	for i=1:numel(Workspace1.Segments) % Go over each segment.
		
		if(Workspace1.Segments(i).Rectangles(end).Distance_From_Primary == 0)
			C = 3; % Primary Segments. Blue.
		elseif(Workspace1.Segments(i).Rectangles(end).Distance_From_Primary > 0)
			C = 2; % Dorsal.
		else % Ventral.
			C = 1;
		end
		
		if(numel(Workspace1.Segments(i).Rectangles) > 2)
			plot([Workspace1.Segments(i).Rectangles(:).X],[Workspace1.Segments(i).Rectangles(:).Y],'.','Color',Colors1(C,:),'MarkerSize',Workspace1.Segments(i).Width/Scale_Factor);
		else
			plot(Workspace1.Segments(i).Rectangles(:).X,Workspace1.Segments(i).Rectangles(:).Y,'Color',Colors1(C,:),'LineWidth',Workspace1.Segments(i).Width);
		end
	end
	
	% for i=1:numel(Workspace1.Vertices) % Go over all vertices.
		% switch (Workspace1.Vertices(i).Dorsal_Ventral)
		% case 0
			% plot(Workspace1.Vertices(i).Coordinates(1),Workspace1.Vertices(i).Coordinates(2),'.b','MarkerSize',15);
		% case 1 % Dorsal.
			% plot(Workspace1.Vertices(i).Coordinates(1),Workspace1.Vertices(i).Coordinates(2),'.g','MarkerSize',10);
		% case -1 % Ventral.
			% plot(Workspace1.Vertices(i).Coordinates(1),Workspace1.Vertices(i).Coordinates(2),'.r','MarkerSize',10);
	% end
	
end