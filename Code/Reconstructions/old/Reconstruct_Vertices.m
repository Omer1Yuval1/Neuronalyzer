function Reconstruct_Vertices(GUI_Parameters)
	
	Vertices = GUI_Parameters.Workspace(1).Files{1}.Vertices;
	Rect_Width = 4;
	Rect_Length = 8;
	Parameters1 = struct();
	Parameters1.Auto_Tracing_Parameters.Rect_Rotation_Origin = 14;	
	
	% assignin('base','GUI_Parameters',GUI_Parameters);
	
	if(size(GUI_Parameters.General.Categories_Filter_Values,1) > 0)
		for i=1:numel(Vertices)
			O = [Vertices(i).Coordinates(1) Vertices(i).Coordinates(2)];
			if(length(Vertices(i).Order) == 3 && ismember(Vertices(i).Order,GUI_Parameters.General.Categories_Filter_Values,'rows'))
				for j=1:3
					% [XV,YV] = Get_Rect_Vector(O,Vertices(i).Fit_Angles_Diffs(j),Rect_Width,Rect_Length,Parameters1);
					[XV,YV] = Get_Rect_Vector(O,Vertices(i).Rectangles_Angles(j),Rect_Width,Rect_Length,14);
					plot(XV,YV,'Color',[.9,0,.4],'LineWidth',2);
					% fill(XV,YV,[.9,0,.4]);
				end
				plot(O(1),O(2),'.g','MarkerSize',10);
			else
				plot(O(1),O(2),'.','Color',[1,.65,0],'MarkerSize',10); % Orange.
			end
		end
	else
		for i=1:numel(Vertices)
			O = [Vertices(i).Coordinates(1) Vertices(i).Coordinates(2)];
			if(length(Vertices(i).Order) == 3)
				plot(O(1),O(2),'.g','MarkerSize',15);
			else
				plot(O(1),O(2),'.','Color',[1,.65,0],'MarkerSize',15);
		end
	end
	
end