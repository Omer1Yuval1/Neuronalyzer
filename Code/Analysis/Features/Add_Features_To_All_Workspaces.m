function [W,Features] = Add_Features_To_All_Workspaces(W)
	
	% TODO: the step length in the Rectangles struct is currently in ***pixels***
	% This affects many things (e.g. curvature).
	
	Features = struct('Feature_Name',{},'Values',{},'Num_Of_Options',{});
	N = numel(W);
	
	for i=1:N % For each workspace.
		
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
				
				X = [W(i).Workspace.Segments(s).Rectangles.X];
				Y = [W(i).Workspace.Segments(s).Rectangles.Y];
				Step_Lengths = Scale_Factor.*Parameters.Tracing.Rect_Length_Width_Func([W(i).Workspace.Segments(s).Rectangles.Width]);
				
				Li = (sum( [(X(2:end) - X(1:end-1)).^2 ; (Y(2:end) - Y(1:end-1)).^2] )).^0.5; % Arc length between successive points.
				L = sum(Li); % Arc length.
				W(i).Workspace.Segments(s).Length = L; % sum([W(i).Workspace.Segments(s).Rectangles.Length]);
				
				D = ((W(i).Workspace.Segments(s).Rectangles(1).X - W(i).Workspace.Segments(s).Rectangles(end).X)^2 + ...
					(W(i).Workspace.Segments(s).Rectangles(1).Y - W(i).Workspace.Segments(s).Rectangles(end).Y)^2)^.5; % end2end length.
				W(i).Workspace.Segments(s).End2End_Length = D.*Scale_Factor;
				
				if(length(X) > 2)
					[~,~,~,Cxy] = Get_Segment_Curvature(X,Y);
					Squared_Curvature = ((Cxy .* (1./Scale_Factor)).^2); % Also converted to micrometers.
					W(i).Workspace.Segments(s).Curvature = dot(Step_Lengths,Squared_Curvature); % Integral of squared curvature.
				else
					W(i).Workspace.Segments(s).Curvature = -1;
				end
				
				if(N == 1) % If only one workspace, add the curvature values for individual coordinates.
					for j=1:numel(W(i).Workspace.Segments(s).Rectangles) % For each coordinate. TODO: find a way to do this without a for loop.
						W(i).Workspace.Segments(s).Rectangles(j).Curvature = Squared_Curvature(j);
					end
				end
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
		
		% Go over each feature *value* and add it if it doesn't exist yet (but the feature *names* cannot change anymore):
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
				c = numel(Features(j).Values);
			end
			W(i).(FN{j}) = c;
		end
	end
	
	for f=1:numel(Features) % Add number of values to each feature.
		Features(f).Num_Of_Options = length(Features(f).Values);
	end
	
end