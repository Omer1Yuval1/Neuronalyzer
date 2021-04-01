function [Data,Overwrite_Axes] = Add_Features_To_All_Workspaces(Data,P,Overwrite_Axes)
	
	Scale_Factor = Data.Info.Experiment(1).Scale_Factor;
	
	Data.Parameters = Parameters_Func(Scale_Factor);
	
	if(~isempty(Data.Vertices) && ~isempty(Data.Segments))
		for s=1:numel(Data.Segments) % For each segment.
			
			if(~isempty(Data.Segments(s).Rectangles))
				Data.Segments(s).Width = mean([Data.Segments(s).Rectangles.Width]);
				
				X = [Data.Segments(s).Rectangles.X];
				Y = [Data.Segments(s).Rectangles.Y];
				Step_Lengths = Scale_Factor .* Data.Parameters.Tracing.Rect_Length_Width_Func([Data.Segments(s).Rectangles.Width]);
				
				Li = (sum( [(X(2:end) - X(1:end-1)).^2 ; (Y(2:end) - Y(1:end-1)).^2] )).^0.5; % Arc length between successive points.
				L = sum(Li); % Arc length.
				Data.Segments(s).Length = L; % sum([Data.Segments(s).Rectangles.Length]);
				
				D = ((Data.Segments(s).Rectangles(1).X - Data.Segments(s).Rectangles(end).X)^2 + (Data.Segments(s).Rectangles(1).Y - Data.Segments(s).Rectangles(end).Y)^2)^.5; % end2end length.
				Data.Segments(s).End2End_Length = D.*Scale_Factor;
				
				if(length(X) > Data.Parameters.Analysis.Curvature.Min_Points_Num)
					[~,~,~,~,Cxy] = Get_Segment_Curvature(X,Y,Data.Parameters.Analysis.Curvature.Min_Points_Num_Smoothing);
					Cxy = Cxy .* (1./Scale_Factor); % Pixels to micrometers.
					
					Data.Segments(s).Curvature = dot(Step_Lengths,Cxy)./sum(Step_Lengths); % Integral of squared curvature.
					% Data.Segments(s).Curvature = dot(Step_Lengths,Cxy); % Integral of squared curvature, normalized to arc-length.
					Data.Segments(s).Max_Curvature = max(Cxy);
					
					% if(N == 1) % If only one workspace, add the curvature values for individual coordinates.
					if(~isempty(Cxy))
						for j=1:numel(Data.Segments(s).Rectangles) % For each coordinate. TODO: find a way to do this without a for loop.
							Data.Segments(s).Rectangles(j).Curvature = Cxy(j);
						end
					else
						[Data.Segments(s).Rectangles.Curvature] = deal(nan);
					end
					% end
				else
					[Data.Segments(s).Rectangles.Curvature] = deal(nan);
					Data.Segments(s).Curvature = nan;
					Data.Segments(s).Max_Curvature = nan;
				end
				
				% Find vertices:
				F1 = find([Data.Vertices.Vertex_Index] == Data.Segments(s).Vertices(1)); % Find the 1st vertex.
				F2 = find([Data.Vertices.Vertex_Index] == Data.Segments(s).Vertices(2)); % Find the 2nd vertex.
				
				if(length(F1) == 1 && length(F2) == 1)
					if(Data.Vertices(F1).Order == 1 || Data.Vertices(F2).Order == 1)
						Data.Segments(s).Terminal = 1;
					else
						Data.Segments(s).Terminal = 0;
					end
				else
					Data.Segments(s).Terminal = nan;
					disp(['Something is wrong with the vertices of segment index ',num2str(Data.Segments(s).Segment_Index)]);
				end
			else
				Data.Segments(s).Width = nan;
				Data.Segments(s).Length = nan;
				Data.Segments(s).Curvature = nan;
				Data.Segments(s).Terminal = nan;
			end
		end
	end
	
	% Compute vertices angles (angles between neighboring rectangles):
	if(isfield(Data,'Vertices'))
		for v=1:numel(Data.Vertices) % For each vertex.
			Data.Vertices(v).Angles = Calc_Junction_Angles([Data.Vertices(v).Rectangles.Angle]);
		end
	end
	
	% Map the neuron's axes:
	if(isfield(Data,'Segments'))
		
		if(~isfield(Data,'Axes') || ~isfield(Data.Axes,'Axis_0') || isempty(Data.Axes.Axis_0) || isempty(Data.Axes.Axis_1_Ventral)) % If the axes do not exist.
			Data.Axes = Find_Worm_Longitudinal_Axis(Data,0);
			Data = Map_Worm_Axes(Data,0,0);
		else	
			if(isempty(Overwrite_Axes))
				Overwrite_Axes = uiconfirm(P.GUI_Handles.Main_Figure,'Overwrite axes?','Warning','Icon','question','Options',{'Overwrite','Keep existing axes'});
			end
			
			if(isequal(Overwrite_Axes,'Overwrite'))
				% Compute the neuron axes only if they do not exist yet, to avoid overwriting user corrections.
				Data.Axes = Find_Worm_Longitudinal_Axis(Data,0);
				Data = Map_Worm_Axes(Data,0,0);
			end
		end
		
		% If the main and tertiary axes already exist, do not compute them and only get the neuron points.
		if(isfield(Data,'Axes') && isfield(Data.Axes,'Axis_0') && ~isempty(Data.Axes.Axis_0) && ~isempty(Data.Axes.Axis_1_Ventral))
			
			Data = Collect_All_Neuron_Points(Data); % [X, Y, Length, Angle, Curvature].
			Data.Points = Find_Distance_From_Midline(Data.Points,Data.Axes,Scale_Factor,1);
			Data.Vertices = Find_Distance_From_Midline(Data.Vertices,Data.Axes,Scale_Factor,1);
		end
		
		[D,A,L,phi,out] = Get_Corrected_Cylinder_Params([Data.Points.Midline_Distance],[Data.Points.Midline_Orientation],[Data.Points.Length],[Data.Points.Radius]);
		
		D = num2cell(D);
		A = num2cell(A);
		L = num2cell(L);
		phi = num2cell(phi);
		
		[Data.Points.Radial_Distance_Corrected] = D{:};
		[Data.Points.Midline_Orientation_Corrected] = A{:};
		[Data.Points.Length_Corrected] = L{:};
		[Data.Points.Angular_Coordinate] = phi{:};
		
		Clusters_Struct = load('Menorah_Class_Clusters.mat');
		Clusters_Struct = Clusters_Struct.Clusters_Struct;
		Data = Classify_PVD_Points(Data,Clusters_Struct);
	end
	% Data.Vertices = Find_Distance_From_Midline(Data,Data.Vertices,Data.Axes,Scale_Factor); % Add midline distance and orientation to the vertices struct.
	
	if(isfield(Data,'Vertices'))
		for v=1:numel(Data.Vertices) % For each vertex.
			if(numel(Data.Vertices(v).Rectangles) && abs(Data.Vertices(v).Midline_Distance) <= Data.Parameters.Angle_Correction.Worm_Radius_um && isfield(Data,'Axes') && isfield(Data.Axes,'Axis_0')) % Find the corrected angles only if the vertex is <= the length of the radius from the medial axis.
				
				Data.Vertices(v).Rectangles = Projection_Correction(Data,v);
				
				% Compute the corrected angles diffs:
				Data.Vertices(v).Corrected_Angles = Calc_Junction_Angles([Data.Vertices(v).Rectangles.Corrected_Angle]); % Data.Vertices(v).Corrected_Angles = Calc_Junction_Angles([Data.Vertices(v).Rectangles.Angle_Corrected]);
			else
				Data.Vertices(v).Corrected_Angles = nan;
			end
			%}
		end
	end
	
end