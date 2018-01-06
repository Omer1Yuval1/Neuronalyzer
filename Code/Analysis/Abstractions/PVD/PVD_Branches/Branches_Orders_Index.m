function Workspace1 = Branches_Orders_Index(Workspace1)
	
	Workspace1.Branches = struct('Branch_Index',{},'Order',{},'Rectangles',{},'Length',0,'Straight_Length',{},'Curviness',{},'Persistence_Length',{},'Line_Angle',{},'Vertices',{},'Segments',{},'Menorah',{});
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	% Workspace1.Parameters.Branch_Parameters.Auto_Tracing_Parameters.Segment_Smoothing_Parameter = 0.01;
	
	[Workspace1.Segments.Menorah] = deal(-1);
	[Workspace1.Vertices.Order] = deal(-1); % Segments orders are set to 0 by default in 'Steps_Vertices_Segments'.
	[Workspace1.Branches.Order] = deal(-1);
	
	if(~isfield(Workspace1.User_Input,'Manual_Menorah_Orders') || ... % If the array does not exist or does not have the same # of segments, create\reset it.
										length(Workspace1.User_Input.Manual_Menorah_Orders) ~= numel(Workspace1.Segments))
		Workspace1.User_Input(1).Manual_Menorah_Orders = zeros(1,numel(Workspace1.Segments));
	end
	
	for i=1:numel(Workspace1.Segments) % Update the orders from the user manual array.
		Workspace1.Segments(i).Order = Workspace1.User_Input.Manual_Menorah_Orders(i);
	end
	
	Workspace1 = Identify_Order1(Workspace1);
	
	Workspace1 = Calc_Distances(Workspace1);
	Workspace1 = Segments_Orientation(Workspace1);
	
	Workspace1 = Identify_Order15(Workspace1);
	Workspace1 = Identify_Order2(Workspace1);
	Workspace1 = Map_Branches(Workspace1,2.5);
	Workspace1 = Identify_Order3(Workspace1);
	Workspace1 = Map_Branches(Workspace1,3.5);
	Workspace1 = Identify_Order4(Workspace1);
	Workspace1 = Map_Branches(Workspace1,4.5);
	Workspace1 = Identify_Order567(Workspace1,5);
	Workspace1 = Identify_Order567(Workspace1,6);
	Workspace1 = Identify_Order567(Workspace1,7);
	
	Workspace1 = Assign_Verex_Order(Workspace1);
	
	Workspace1 = Menorahs_DB(Workspace1);
	
	Branches = Workspace1.Branches;
	
	% Assigning additional properties to all branches:
	for i=1:numel(Branches)
		if(numel(Branches(i).Rectangles) == 1) % Only one rectangle. This means that two vertices have a mutual rectangle;
			Branches(i).Length = 0;
			Branches(i).Straight_Length = 0;
			Branches(i).Curviness = 0;
			Branches(i).Line_Angle = Branches(i).Rectangles(1).Angle;
		else
			% Branches(i).Length = sum([Branches(i).Rectangles(1:end-1).Step_Length]);
			Branches(i).Length = sum([Branches(i).Rectangles(1:end).Step_Length]);
			% Branches(i).Straight_Length = ( ((Branches(i).Rectangles(end).Y-Branches(i).Rectangles(1).Y)^2 + (Branches(i).Rectangles(end).X-Branches(i).Rectangles(1).X)^2)^0.5)*Scale_Factor; % The coodinates of the last point (rectangle origin (14)) is the point where the n-1 step ends.
			F1 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Branches(i).Vertices(1));
			F2 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Branches(i).Vertices(end));
			Branches(i).Straight_Length = ( ((Workspace1.Vertices(F1).Coordinates(2)-Workspace1.Vertices(F2).Coordinates(2))^2 + (Workspace1.Vertices(F1).Coordinates(1)-Workspace1.Vertices(F2).Coordinates(1))^2)^0.5)*Scale_Factor;
			Branches(i).Curviness = 1 - (Branches(i).Straight_Length/Branches(i).Length);
			Branches(i).Line_Angle = mod(atan2d(Branches(i).Rectangles(end).Y-Branches(i).Rectangles(1).Y,Branches(i).Rectangles(end).X-Branches(i).Rectangles(1).X),360);
		end
		Branches(i).Width = mean([Branches(i).Rectangles(:).Width]);
		
		[Branches(i).Rectangles,Branches(i).Curvature,Branches(i).Curvature2,Branches(i).Persistence_Length] = ...
		Curvature_And_Persistence_Length(Branches(i).Rectangles,Scale_Factor,Workspace1.Parameters);
		
	end
	
	Workspace1.Branches = Branches;
	% assignin('base','Branches',Branches);
	% imshow(Workspace1.Image0);
	% hold on;
	% Reconstruction_Index(Workspace1,4);
end