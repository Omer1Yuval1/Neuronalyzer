function Workspace1 = Add_Step_GUI(Workspace1)
	
	% Description:
		% This function lets the user choose an existing step and edit it.
		% By doing this, it doesn't actually add any step, it just marks an existing step,
		% as a step to be edited and that should be added to the queue.
	% Input:
		% Workspace1: contains the tracing database.
	% Output:
		% Workspace1: with the tracing database after marking the steps to be revised.
	
	[x1,y1] = ginput(1);
	
	N = numel(Workspace1.Path);
	MinD = Workspace1.Parameters.General_Parameters.Im_Rows;
	Row1 = 0;
	
	% Find the closest step:
		for i=1:N
			Xp = Workspace1.Path(i).Coordinates(1);
			Yp = Workspace1.Path(i).Coordinates(2);
			D = ((Xp-x1)^2+(Yp-y1)^2)^0.5;
			if( D < MinD )
				XY = Workspace1.Path(i).Coordinates;
				MinD = D;
				Row1 = i;
			end
		end
		F = find([Workspace1.Path.Step_Index] == Workspace1.Path(Row1).Step_Index);
		Workspace1.Path(F(1)).Is_Mapped = 0;
		
	% Create the new step:
		% Workspace1.Path(N+1).Rectangle_Index = max([Workspace1.Path.Rectangle_Index]) + 1;
		% Workspace1.Path(N+1).Step_Index = max([Workspace1.Path.Step_Index]) + 1;
		% Workspace1.Path(N+1).Coordinates = Workspace1.Path(Row1).Coordinates;
		% Workspace1.Path(N+1).Connection = Workspace1.Path(Row1).Connection;
		% Workspace1.Path(N+1).Width = Workspace1.Path(Row1).Width;
		% Workspace1.Path(N+1).Rect_Length = Workspace1.Path(Row1).Rect_Length;
		% Workspace1.Path(N+1).Angle = mod(Angle1,360);
		% Workspace1.Path(N+1).Score = Workspace1.Path(Row1).Score; % Use the score of another rect in the same step.
		% Workspace1.Path(N+1).Current_Branch_Step_Index = 1;
		% Workspace1.Path(N+1).Is_Mapped = 0;
	
	% Plot the Rectangle:
		% [XV,YV] = Get_Rect_Vector(Workspace1.Path(N+1).Coordinates,Angle1,Workspace1.Path(N+1).Width,Workspace1.Path(N+1).Rect_Length,Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Rotation_Origin);
		% hold on;
		% plot(XV,YV,'g','LineWidth',2);
		% plot([XV(2),XV(3)],[YV(2),YV(3)],'r','LineWidth',2);
end