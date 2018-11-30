function [W,Features] = Add_Features_To_All_Workspaces(W)
	
	% TODO: the step length in the Rectangles struct is currently in ***pixels***
	% This affects many things (e.g. curvature).
	
	Rx = @(a) [1,0,0 ; 0,cos(a),-sin(a) ; 0,sin(a),cos(a)]; % Rotation matrix around the x-axis (angle should be given in radians).
	Rz = @(a) [cos(a),-sin(a),0 ; sin(a),cos(a),0 ; 0,0,1]; % Rotation matrix around the z-axis (angle should be given in radians).
	
	% TODO: move out and scale:
	Medial_Fit_Res = 1000;
	Worm_Radius_um = 45;
	SmoothingParameter = 3;
	Corrected_Plane_Angle_Func = @(d) asin(d./Worm_Radius_um); % Input: distance (in um) from the medial axis.
	
	Features = struct('Feature_Name',{},'Values',{},'Num_Of_Options',{});
	N = numel(W);
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	for i=1:N % For each workspace.
		
		Scale_Factor = W(i).Workspace.User_Input.Scale_Factor;
		Parameters = Parameters_Func(Scale_Factor);
		Worm_Radius_px = Worm_Radius_um ./ Scale_Factor; % Conversion to pixels.
		
		[W(i).Workspace.Vertices.Angles_Medial] = deal(-1);
		[W(i).Workspace.Vertices.Angles_Corrected_Medial] = deal(-1);		
		
		if(isfield(W(i).Workspace,'Medial_Axis') && ~isempty(W(i).Workspace.Medial_Axis))
			Xm = [W(i).Workspace.Medial_Axis(:,1)]';
			Ym = [W(i).Workspace.Medial_Axis(:,2)]';
			
			Medial_Fit_Object = cscvn([Xm ; Ym]); % Medial_Fit_Object = csaps(Xm,Ym,0.5);
			Medial_Der_Fit_Object = fnder(Medial_Fit_Object,1); % 1st derivative.
			Medial_Eval = linspace(Medial_Fit_Object.breaks(1),Medial_Fit_Object.breaks(end),Medial_Fit_Res);
			XY_Eval = fnval(Medial_Fit_Object,Medial_Eval);
			Use_Medial_Axis = 1;
		else
			Use_Medial_Axis = 0;
		end
		
		for v=1:numel(W(i).Workspace.Vertices) % For each vertex.
			% disp(i); disp(v);
			W(i).Workspace.Vertices(v).Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Angle]);
			Symmetry_A3_Linearity = Vertices_Symmetry_Linearity(W(i).Workspace.Vertices(v).Angles);
			if(length(Symmetry_A3_Linearity) == 3)
				W(i).Workspace.Vertices(v).Symmetry = Symmetry_A3_Linearity(1);
				W(i).Workspace.Vertices(v).Linearity = Symmetry_A3_Linearity(3);
			end
			W(i).Workspace.Vertices(v).Num_of_Branches = numel(W(i).Workspace.Vertices(v).Rectangles);
			
			% Find the distance from the CB:
			D = ( (W(i).Workspace.Vertices(v).Coordinate(1) - W(i).Workspace.CB.Center(1))^2 + ...
				(W(i).Workspace.Vertices(v).Coordinate(2) - W(i).Workspace.CB.Center(2))^2 )^.5;
			W(i).Workspace.Vertices(v).Distance_From_CB = D.*Scale_Factor;
			
			if(Use_Medial_Axis && numel(W(i).Workspace.Vertices(v).Rectangles)) % Find the corrected angles only if the vertex is <= the length of the radius from the medial axis.
				% Find the closest point along the medial axis to the vertex center:
				Cxy = W(i).Workspace.Vertices(v).Coordinate; % Just for readability.
				Dm = Distance_Func(XY_Eval(1,:),XY_Eval(2,:),Cxy(1),Cxy(2));
				f1 = find(Dm == min(Dm));
				Medial_Distance = Dm(f1(1)); % Minimal distance of the vertex center of the medial axis (= distance along the Y' axis).
				W(i).Workspace.Vertices(v).Distance_From_Medial_Axis = Medial_Distance.*Scale_Factor;
                if(Medial_Distance <= Worm_Radius_px)
					Medial_Tangent = [fnval(Medial_Der_Fit_Object,Medial_Eval(f1(1))) ; 0]'; % The medial tangent vector (from the origin).
					Rects = W(i).Workspace.Vertices(v).Rectangles; % ".
					Ap = Corrected_Plane_Angle_Func(Medial_Distance .* Scale_Factor); % Using the worm radius and the distance of the vertex from the medial axis to find the tilting angle of the vertex plane.
					W(i).Workspace.Vertices(v).Rectangles = Projection_Correction(i,v,W(i).Workspace.NN_Probabilities,XY_Eval,Cxy,Rects,Ap,Medial_Tangent,Rx,Rz,Scale_Factor,Corrected_Plane_Angle_Func);
					
					W(i).Workspace.Vertices(v).Angles_Medial = [W(i).Workspace.Vertices(v).Rectangles.Angle_Medial];
					W(i).Workspace.Vertices(v).Angles_Corrected_Medial = [W(i).Workspace.Vertices(v).Rectangles.Angle_Corrected_Medial];
					
					% Compute the corrected angles diffs:
					% W(i).Workspace.Vertices(v).Corrected_Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Angle_Corrected]);
					W(i).Workspace.Vertices(v).Corrected_Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Angle_Corrected_Medial]);
				else
					W(i).Workspace.Vertices(v).Distance_From_Medial_Axis = -1;
					W(i).Workspace.Vertices(v).Corrected_Angles = -1;
				end
			else
				W(i).Workspace.Vertices(v).Distance_From_Medial_Axis = -1;
				W(i).Workspace.Vertices(v).Corrected_Angles = -1;
			end
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
				
				Squared_Curvature = [];
				if(length(X) > 2)
					[~,~,~,Cxy] = Get_Segment_Curvature(X,Y);
					Squared_Curvature = ((Cxy .* (1./Scale_Factor)).^2); % Also converted to micrometers.
					W(i).Workspace.Segments(s).Curvature = dot(Step_Lengths,Squared_Curvature); % Integral of squared curvature.
				else
					W(i).Workspace.Segments(s).Curvature = -1;
				end
				
				if(N == 1) % If only one workspace, add the curvature values for individual coordinates.
					if(~isempty(Squared_Curvature))
						for j=1:numel(W(i).Workspace.Segments(s).Rectangles) % For each coordinate. TODO: find a way to do this without a for loop.
							W(i).Workspace.Segments(s).Rectangles(j).Curvature = Squared_Curvature(j);
						end
					else
						[W(i).Workspace.Segments(s).Rectangles.Curvature] = deal(-1);
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