function Reconstruct_Menorah_Orders(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	
	% % Reconstruction of segments with branches orders:
	% hold on;
	% for i=1:numel(Workspace1.Segments) % Go over each segment.
		% order = Workspace1.Segments(i).Order; % Save the order of this branch (and also of this segment).
		% if(order > 0)
			% color1 = order_colormap(order);		
			% plot([Workspace1.Segments(i).Rectangles(:).X],[Workspace1.Segments(i).Rectangles(:).Y],'color',color1,'LineWidth',2*Workspace1.Segments(i).Width);
		% end
	% end
	
	hold on;
	for i=1:numel(Workspace1.Branches) % Go over each branch.
		
		order = Workspace1.Branches(i).Order; % Take the order of this branch.
		if(order > 0)
			color1 = order_colormap(order);		
			plot([Workspace1.Branches(i).Rectangles(:).X],[Workspace1.Branches(i).Rectangles(:).Y],'color',color1,'LineWidth',2*Workspace1.Branches(i).Width);
		end
		
		F0 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Branches(i).Vertices(end));
		plot(Workspace1.Vertices(F0).Coordinates(1),Workspace1.Vertices(F0).Coordinates(2),'.','Color',[1,1,1],'MarkerSize',5);
	
	end
end