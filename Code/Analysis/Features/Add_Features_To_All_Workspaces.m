function [W,Features] = Add_Features_To_All_Workspaces(W)
	
	% TODO: the step length in the Rectangles struct is currently in ***pixels***
	% This affects many things (e.g. curvature).
	
	Features = struct('Feature_Name',{},'Values',{},'Num_Of_Options',{});
	
	for i=1:numel(W) % For each workspace.
		
		Scale_Factor = W(i).Workspace.User_Input.Scale_Factor;
		Parameters = Parameters_Func(Scale_Factor);
		
		for v=1:numel(W(i).Workspace.Vertices) % For each vertex.
			% disp(i); disp(v);
			W(i).Workspace.Vertices(v).Angles = Calc_Junction_Angles(W(i).Workspace.Vertices(v).Rectangles);
			Symmetry_A3_Linearity = Vertices_Symmetry_Linearity(W(i).Workspace.Vertices(v).Angles);
			if(length(Symmetry_A3_Linearity) == 3)
				W(i).Workspace.Vertices(v).Symmetry = Symmetry_A3_Linearity(1);
				W(i).Workspace.Vertices(v).Linearity = Symmetry_A3_Linearity(3);
			end
			W(i).Workspace.Vertices(v).Num_of_Branches = numel(W(i).Workspace.Vertices(v).Rectangles);
			
			D = ( (W(i).Workspace.Vertices(v).Coordinate(1) - W(i).Workspace.CB.Center(1))^2 + ...
				(W(i).Workspace.Vertices(v).Coordinate(2) - W(i).Workspace.CB.Center(2))^2 )^.5;
			W(i).Workspace.Vertices(v).Distance_From_CB = D;
			W(i).Workspace.Vertices(v).Distance_From_Longitudinal_Axis = -1;
		end
		
		% TODO: Calculate minimal distance from the CB.
		
		for s=1:numel(W(i).Workspace.Segments) % For each segment.
			if(~isempty(W(i).Workspace.Segments(s).Rectangles))
				W(i).Workspace.Segments(s).Width = mean([W(i).Workspace.Segments(s).Rectangles.Width]);
				W(i).Workspace.Segments(s).Length = sum([W(i).Workspace.Segments(s).Rectangles.Length]);
				
				D = ((W(i).Workspace.Segments(s).Rectangles(1).Coordinates(1) - W(i).Workspace.Segments(s).Rectangles(end).Coordinates(1))^2 + ...
					(W(i).Workspace.Segments(s).Rectangles(1).Coordinates(2) - W(i).Workspace.Segments(s).Rectangles(end).Coordinates(2))^2)^.5;
				W(i).Workspace.Segments(s).End2End_Length = D*Scale_Factor;
				
				XY = [W(i).Workspace.Segments(s).Rectangles.Coordinates];
				[Point_Curvature_Values,Mean_Curvature,Mean_Squared_Curvature] = Calc_Mean_Curvature(XY(1:2:end-1),XY(2:2:end),[W(i).Workspace.Segments(s).Rectangles.Length],Scale_Factor,Parameters);
				W(i).Workspace.Segments(s).Curvature = Mean_Squared_Curvature;
			else
				W(i).Workspace.Segments(s).Width = -1;
				W(i).Workspace.Segments(s).Length = -1;
				W(i).Workspace.Segments(s).End2End_Length = -1;
				W(i).Workspace.Segments(s).Curvature = -1;
			end
		end
		
		% Generate the Features struct.
		FN = fieldnames(W(i).Workspace.User_Input.Features);
		if(i == 1) % Use the 1st workspace to build the features struct.
			for j=1:length(FN)
				Features(end+1).Feature_Name = FN{j};
				Features(end).Values = struct('Name',{},'ON_OFF',{});
			end
		end
		
		% Go over each feature value and add it if it doesn't exist yet (but the feature names list cannot change anymore):
		for j=1:length(FN) % For each feature field.
			c = 0;
			for k=1:length(Features(j).Values) % For each existing value assigned to the j-feature field.
				if(strcmp(Features(j).Values(k).Name,W(i).Workspace.User_Input.Features.(FN{j})))
					c = k; % The value already exists.
					break;
				end
			end
			if(~c) % The value does not exist yet, add it.
				Features(j).Values(end+1).Name = W(i).Workspace.User_Input.Features.(FN{j});
				Features(j).Values(end).ON_OFF = 1;
				c = numel(Features(j).Values) + 1;
			end
			 W(i).(FN{j}) = c;
		end
	end
	
	for f=1:numel(Features) % Add number of values to each feature.
		Features(f).Num_Of_Options = length(Features(f).Values);
	end
	
end