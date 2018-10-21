function [W,Features] = Add_Features_To_All_Workspaces(W)
	
	% TODO: the step length in the Rectangles struct is currently in ***pixels***
	% This affects many things (e.g. curvature).
	
	% TODO: move out and scale:
	Medial_Fit_Res = 1000;
	Worm_Radius_um = 40;
	
	Features = struct('Feature_Name',{},'Values',{},'Num_Of_Options',{});
	N = numel(W);
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	for i=1:N % For each workspace.
		
		Scale_Factor = W(i).Workspace.User_Input.Scale_Factor;
		Parameters = Parameters_Func(Scale_Factor);
		Worm_Radius_px = Worm_Radius_um ./ Scale_Factor; % Conversion to pixels.
		
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
			
			x0 = W(i).Workspace.Vertices(v).Coordinate(1);
			y0 = W(i).Workspace.Vertices(v).Coordinate(2);
			
			if(isfield(W(i).Workspace,'Medial_Axis') && ~isempty(W(i).Workspace.Medial_Axis) && numel(W(i).Workspace.Vertices(v).Rectangles))
				
				D = Distance_Func(x0,y0,W(i).Workspace.Medial_Axis(:,1),W(i).Workspace.Medial_Axis(:,2));
				W(i).Workspace.Vertices(v).Distance_From_Medial_Axis = min(D).*Scale_Factor;
				
				Xm = [W(i).Workspace.Medial_Axis(:,1)]';
				Ym = [W(i).Workspace.Medial_Axis(:,2)]';
				Medial_Fit_Object = cscvn([Xm ; Ym]);
				Medial_Der_Fit_Object = fnder(Medial_Fit_Object,1); % 1st derivative.
				Medial_Eval = linspace(Medial_Fit_Object.breaks(1),Medial_Fit_Object.breaks(end),Medial_Fit_Res);
				Fxy = fnval(Medial_Fit_Object,Medial_Eval);
				
				% Find the closest point along the medial axis to the vertex center:
				Cx = W(i).Workspace.Vertices(v).Coordinate(1); % x-coordinate of the vertex center.
				Cy = W(i).Workspace.Vertices(v).Coordinate(2); % y-coordinate of the vertex center.
				Dm = ( (Cx - Fxy(1,:)).^2 + (Cy - Fxy(2,:)).^2 ).^(.5);
				f1 = find(Dm == min(Dm));
				Dmin = Dm(f1(1)); % Minimal distance of the vertex center of the medial axis (= distance along the Y' axis).
				Medial_Tangent = [fnval(Medial_Der_Fit_Object,Medial_Eval(f1(1))) ; 0]'; % The medial tangent vector is already from the origin.
				
				W(i).Workspace.Vertices(v).Rectangles(end).Medial_Angles = -1;
				W(i).Workspace.Vertices(v).Rectangles(end).Medial_Angles_Corrected = -1;
				for r=1:numel(W(i).Workspace.Vertices(v).Rectangles) % For each vertex rectangle.
					a = W(i).Workspace.Vertices(v).Rectangles(r).Angle;
					Vr = [cos(a) - Cx , sin(a) - Cy , 0];
					W(i).Workspace.Vertices(v).Rectangles(r).Medial_Angles = atan2(norm(cross(Vr,Medial_Tangent)), dot(Vr,Medial_Tangent));
					
					% Projection Correction:
					Lz = (Worm_Radius_px.^2 - Dmin.^2).^(.5); % sin(b) = Dmin./ Worm_Radius_px.
					Vr_Corrected = Vr; % [Vr(1:2),Lz];
					W(i).Workspace.Vertices(v).Rectangles(r).Medial_Angles_Corrected = atan2(norm(cross(Vr_Corrected,Medial_Tangent)), dot(Vr_Corrected,Medial_Tangent));
				end
				% Compute the corrected angles diffs:
				W(i).Workspace.Vertices(v).Corrected_Angles = Calc_Junction_Angles([W(i).Workspace.Vertices(v).Rectangles.Medial_Angles_Corrected]);
				
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