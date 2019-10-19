function [W,Features] = Add_Features_To_All_Workspaces(W)
	
	% TODO: the step length in the Rectangles struct is currently in ***pixels***
	% This affects many things (e.g. curvature).
	
	Rx = @(a) [1,0,0 ; 0,cos(a),-sin(a) ; 0,sin(a),cos(a)]; % Rotation matrix around the x-axis (angle is given in radians).
	Rz = @(a) [cos(a),-sin(a),0 ; sin(a),cos(a),0 ; 0,0,1]; % Rotation matrix around the z-axis (angle is given in radians).
	
	Features = struct('Feature_Name',{},'Values',{},'Num_Of_Options',{});
	N = numel(W);
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	for i=1:N % For each workspace.
		
		Scale_Factor = W(i).Workspace.User_Input.Scale_Factor;
		W(i).Workspace.Parameters = Parameters_Func(Scale_Factor,W(i).Workspace.Parameters);
		
		if(isfield(W(i).Workspace,'Vertices') && isfield(W(i).Workspace,'Segments'))
			for s=1:numel(W(i).Workspace.Segments) % For each segment.
				
				if(~isempty(W(i).Workspace.Segments(s).Rectangles))
					W(i).Workspace.Segments(s).Width = mean([W(i).Workspace.Segments(s).Rectangles.Width]);
					
					X = [W(i).Workspace.Segments(s).Rectangles.X];
					Y = [W(i).Workspace.Segments(s).Rectangles.Y];
					Step_Lengths = Scale_Factor.*W(i).Workspace.Parameters.Tracing.Rect_Length_Width_Func([W(i).Workspace.Segments(s).Rectangles.Width]);
					
					Li = (sum( [(X(2:end) - X(1:end-1)).^2 ; (Y(2:end) - Y(1:end-1)).^2] )).^0.5; % Arc length between successive points.
					L = sum(Li); % Arc length.
					W(i).Workspace.Segments(s).Length = L; % sum([W(i).Workspace.Segments(s).Rectangles.Length]);
					
					D = ((W(i).Workspace.Segments(s).Rectangles(1).X - W(i).Workspace.Segments(s).Rectangles(end).X)^2 + ...
						(W(i).Workspace.Segments(s).Rectangles(1).Y - W(i).Workspace.Segments(s).Rectangles(end).Y)^2)^.5; % end2end length.
					W(i).Workspace.Segments(s).End2End_Length = D.*Scale_Factor;
					
					if(length(X) > 3)
						[~,~,~,~,Cxy] = Get_Segment_Curvature(X,Y);
						Cxy = Cxy .* (1./Scale_Factor); % Pixels to micrometers.			
						
						W(i).Workspace.Segments(s).Curvature = dot(Step_Lengths,Cxy)./sum(Step_Lengths); % Integral of squared curvature.
						% W(i).Workspace.Segments(s).Curvature = dot(Step_Lengths,Cxy); % Integral of squared curvature, normalized to arc-length.
						W(i).Workspace.Segments(s).Max_Curvature = max(Cxy);
						
						% if(N == 1) % If only one workspace, add the curvature values for individual coordinates.
						if(~isempty(Cxy))
							for j=1:numel(W(i).Workspace.Segments(s).Rectangles) % For each coordinate. TODO: find a way to do this without a for loop.
								W(i).Workspace.Segments(s).Rectangles(j).Curvature = Cxy(j);
							end
						else
							[W(i).Workspace.Segments(s).Rectangles.Curvature] = deal(-1);
						end
						% end
					else
						[W(i).Workspace.Segments(s).Rectangles.Curvature] = deal(-1);
						W(i).Workspace.Segments(s).Curvature = -1;
						W(i).Workspace.Segments(s).Max_Curvature = -1;
					end
					
					% Find vertices:
					%{
					F1 = find([W(i).Workspace.Vertices.Vertex_Index] == W(i).Workspace.Segments(s).Vertices(1)); % Find the 1st vertex.
					F2 = find([W(i).Workspace.Vertices.Vertex_Index] == W(i).Workspace.Segments(s).Vertices(2)); % Find the 2nd vertex.
					
					if(isempty(F1))
						disp(['Error: Vertex index (',num2str(W(i).Workspace.Segments(s).Vertices(1)),') not found']);
					elseif(length(F1) > 1)
						disp(['Error: Vertex index (',W(i).Workspace.Segments(s).Vertices(1),') appears multiple times']);
					end
					if(isempty(F2))
						disp(['Error: Vertex index (',num2str(W(i).Workspace.Segments(s).Vertices(2)),') not found']);
					elseif(length(F2) > 1)
						disp(['Error: Vertex index (',W(i).Workspace.Segments(s).Vertices(2),') appears multiple times']);
					end
					%}
					%{
					if(length(F1) > 1 || length(F2) > 1)
						disp(['Error: Multiple vertex',num2str(,' rectangles are associated with the same segment']);
					end
					%}
					
				else
					W(i).Workspace.Segments(s).Width = -1;
					W(i).Workspace.Segments(s).Length = -1;
					W(i).Workspace.Segments(s).Curvature = -1;
				end
			end
		end
		
		% Map the neuron's axes:
        if(isfield(W(i).Workspace,'Segments'))
			% If the main and tertiary axes already exist, do not compute them and only get the neuron points.
			if(isfield(W(i).Workspace,'Neuron_Axes') && isfield(W(i).Workspace.Neuron_Axes,'Axis_0') && ~isempty(W(i).Workspace.Neuron_Axes.Axis_1_Ventral))
				
				[W(i).Workspace.All_Points,W(i).Workspace.All_Vertices] = Collect_All_Neuron_Points(W(i).Workspace); % [X, Y, Length, Angle, Curvature].
				W(i).Workspace.All_Points = Find_Distance_From_Midline(W(i).Workspace,W(i).Workspace.All_Points,W(i).Workspace.Neuron_Axes,Scale_Factor,1);
				W(i).Workspace.All_Vertices = Find_Distance_From_Midline(W(i).Workspace,W(i).Workspace.All_Vertices,W(i).Workspace.Neuron_Axes,Scale_Factor,1);
				
			else % Compute the neuron axes only if they do not exist yet, to avoid overwriting user corrections.
				W(i).Workspace.Neuron_Axes = Find_Worm_Longitudinal_Axis(W(i).Workspace,0);
				[W(i).Workspace.All_Points,W(i).Workspace.All_Vertices,W(i).Workspace.Neuron_Axes] = Map_Worm_Axes(W(i).Workspace,W(i).Workspace.Neuron_Axes,0,0);
			end
			Clusters_Struct = load('PVD_Orders.mat');
			Clusters_Struct = Clusters_Struct.Clusters_Struct;
			W(i).Workspace = Classify_PVD_Points(W(i).Workspace,Clusters_Struct);
		end
		% W(i).Workspace.Vertices = Find_Distance_From_Midline(W(i).Workspace,W(i).Workspace.Vertices,W(i).Workspace.Neuron_Axes,Scale_Factor); % Add midline distance and orientation to the vertices struct.
		
		if(isfield(W(i).Workspace,'Vertices'))
			for v=1:numel(W(i).Workspace.Vertices) % For each vertex.
				W(i).Workspace.Vertices(v).Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Angle]);
				
				if(numel(W(i).Workspace.Vertices(v).Rectangles) && W(i).Workspace.All_Vertices(v).Midline_Distance <= W(i).Workspace.Parameters.Angle_Correction.Worm_Radius_um && isfield(W(i).Workspace,'Neuron_Axes') && isfield(W(i).Workspace.Neuron_Axes,'Axis_0')) % Find the corrected angles only if the vertex is <= the length of the radius from the medial axis.
					
					if(v == 264)
						disp(1);
					end
					
					W(i).Workspace.Vertices(v).Rectangles = Projection_Correction(W(i).Workspace,v);
					% Projection_Correction(i,v,W(i).Workspace.NN_Probabilities,XY_Eval,Cxy,Rects,Ap,Medial_Tangent,Rx,Rz,Scale_Factor,Corrected_Plane_Angle_Func);						
					
					% Compute the corrected angles diffs:
					W(i).Workspace.Vertices(v).Corrected_Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Corrected_Angle]); % W(i).Workspace.Vertices(v).Corrected_Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Angle_Corrected]);
				else
					W(i).Workspace.Vertices(v).Corrected_Angles = -1;
				end
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