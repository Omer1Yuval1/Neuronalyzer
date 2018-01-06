function Workspace1 = Delete_Segment(Workspace1,Rect_Row,C)
	
	if(C == 1) % First iteration.
		
		% Find a close coordinate to [x,y]:
		D = max(Workspace1.Parameters.General_Parameters.Im_Rows,Workspace1.Parameters.General_Parameters.Im_Cols); % Set a maximal distance.
		MinRow = 0; % S = 0; % Step index of the step closest to the clicked point.
		[x,y] = ginput(1);
		for i=1:numel(Workspace1.Path)
			D1 = ( (x-Workspace1.Path(i).Coordinates(1))^2 + (y-Workspace1.Path(i).Coordinates(2))^2 )^0.5;
			if(D1 < D)
				D = D1;
				MinRow = i;
			end
		end
		F0 = find([Workspace1.Path.Step_Index] == Workspace1.Path(MinRow).Step_Index); % Find all the entries (rectangles) with this step index.
		
		for i=F0 % 1:length(F0) % Set the Is_Mapped value of all rectangles (exept the 1st one) to -2 (=deleted).
			Workspace1.Path(i).Is_Mapped = -2;
		end
		Workspace1.Path(F0(1)).Is_Mapped = 0;
		
		Workspace1 = Delete_Segment(Workspace1,F0(1),2);
	else % 2+ interation.
		F1 = find([Workspace1.Path.Connection] == Rect_Row); % Find the rects connected to the 0 rect.
		% display(F1);
		for i=F1 % 1:length(F1)
			Workspace1.Path(i).Is_Mapped = -2;
			Workspace1 = Delete_Segment(Workspace1,i,2);
		end
	end
	
end