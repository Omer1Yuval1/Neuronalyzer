function GUI_Parameters = Plot_Multiple(GUI_Parameters)
	
	% Description:
		% This function generates a structure containing integrated information from several animals
		% and several groups of animals.
		% This structure is used by various functions that generate a graphical representation of the data
		% in the form of different plots.
		% Calling functions: Tracer_UI.
	% Input:
		% GUI_Parameters: a structure containing general parameters and graphical handles, as well as a structure of each
		% animal from each group containing the tracing and post-processing data.
	% Output
		% GUI_Parameters: an updated structure containing also the new structure with the integrated information
		% regarding all the animals in each group.
	
	for i=1:numel(GUI_Parameters.Workspace) % For each group of worms (Images\PVDs).
		
		GUI_Parameters.Workspace(i).Statistics = struct();
			
			Group_Size = length(GUI_Parameters.Workspace(i).Files);
			
			GUI_Parameters.Workspace(i).Statistics.Group_Size = Group_Size;
			
			GUI_Parameters.Workspace(i).Statistics.Tips_Distances = zeros(1,Group_Size);
			
			% GUI_Parameters.Workspace(i).Statistics.Rectangles_Orientation.Array = zeros(Group_Size,90/GUI_Parameters.Visuals.Rectangles_Orientation_BinSize,GUI_Parameters.General.Num_Menorah_Order);
			% GUI_Parameters.Workspace(i).Statistics.Orientation.Segments = zeros(Group_Size,90/GUI_Parameters.Visuals.Rectangles_Orientation_BinSize,GUI_Parameters.General.Num_Menorah_Order);
			
			GUI_Parameters.Workspace(i).Statistics.Counts(1).Branches = zeros(Group_Size,GUI_Parameters.General.Num_Menorah_Order);
			
			GUI_Parameters.Workspace(i).Statistics.Vertices_Distribution = struct;
			GUI_Parameters.Workspace(i).Statistics.Menorah.Receptive_Field = struct([]);
		
		for Li=1:Group_Size % For each member in set i.
			Wc = GUI_Parameters.Workspace(i).Files{Li};
			
			for o=1:GUI_Parameters.General.Num_Menorah_Order
				O1 = Order_Index_Conversion(o,-1);
				if(O1 == GUI_Parameters.General.Max_Menorah_Order)
					% Fs = find([Wc.Segments.Order] >= O1);
					Fb = find([Wc.Branches.Order] >= O1);
				else
					% Fs = find([Wc.Segments.Order] == O1);
					Fb = find([Wc.Branches.Order] == O1);
				end
				
				% Means Per Category:
				GUI_Parameters.Workspace(i).Statistics.Total_Length(1).Values(Li,o) = sum([Wc.Branches(Fb).Length]);
				GUI_Parameters.Workspace(i).Statistics.Total_Length(1).Normalization(1).Name = 'Length of Primary Branches';
				GUI_Parameters.Workspace(i).Statistics.Total_Length(1).Normalization(1).Values(Li) = sum([Wc.Branches(find([Wc.Branches.Order] == 1)).Length]);
				GUI_Parameters.Workspace(i).Statistics.Total_Length(1).Normalization(2).Name = 'Total Length';
				GUI_Parameters.Workspace(i).Statistics.Total_Length(1).Normalization(2).Values(Li) = sum([Wc.Branches.Length]);
				
				GUI_Parameters.Workspace(i).Statistics.Mean_Length(1).Values(Li,o) = nanmean([Wc.Branches(Fb).Length]);
				GUI_Parameters.Workspace(i).Statistics.Mean_Length(1).Normalization = [];
				
				GUI_Parameters.Workspace(i).Statistics.Branches_Counts(1).Values(Li,o) = length(Fb);
				GUI_Parameters.Workspace(i).Statistics.Branches_Counts.Normalization(1).Name = 'Total Number of Branches';
				GUI_Parameters.Workspace(i).Statistics.Branches_Counts.Normalization(1).Values(Li) = numel([Wc.Branches]);
				GUI_Parameters.Workspace(i).Statistics.Branches_Counts.Normalization(2).Name = 'Length of Primary Branches';
				GUI_Parameters.Workspace(i).Statistics.Branches_Counts.Normalization(2).Values(Li) = sum([Wc.Branches(find([Wc.Branches.Order] == 1)).Length]);
				
				GUI_Parameters.Workspace(i).Statistics.Straight_Arc_Length_Ratio.Menorah_Orders(1).Total(Li,o) = nanmean([Wc.Branches(Fb).Straight_Length] ./ [Wc.Branches(Fb).Length]);
				
				VD = zeros(1,length(Fb));
				% VD = nan; % If animal 'Li' do not have any 'o'-category branches.
				for b=1:length(Fb) % For each branch of category O1.
					if(Wc.Branches(Fb(b)).Length > 0)
						V = find([Wc.Branches(Fb(b)).Vertices] > 0); % Don't count the tips.
						VD(b) = length(unique(V)) / Wc.Branches(Fb(b)).Length; % Number of junctions divided by the length of the branch.
					else
						VD(b) = [];
					end
				end
				GUI_Parameters.Workspace(i).Statistics.Vertices_Density(1).Values(Li,o) = mean(VD);
				GUI_Parameters.Workspace(i).Statistics.Vertices_Density(1).Normalization = [];
				
				FCb = find([Wc.Branches.Order] == O1 & [Wc.Branches.Curvature2] >= 0); % Exclude (-1) values (means that the curvature couldn't be calculated for that branch).
				GUI_Parameters.Workspace(i).Statistics.Curvature2(1).Values(Li,o) = nanmean([Wc.Branches(FCb).Curvature2]);
				GUI_Parameters.Workspace(i).Statistics.Curvature2(1).Normalization = [];
				
				FCb = find([Wc.Branches.Order] == O1 & [Wc.Branches.Persistence_Length] >= 0); % Exclude (-1) values (means that the Persistence Length couldn't be calculated for that branch).
				GUI_Parameters.Workspace(i).Statistics.Persistence_Length(1).Values(Li,o) = nanmean([Wc.Branches(FCb).Persistence_Length]);
				GUI_Parameters.Workspace(i).Statistics.Persistence_Length(1).Normalization = [];
				
				Rects_Coordinates = Find_Branches_Rectangles(Wc,O1,0);
				% if(O1 == 1)
				% 	GUI_Parameters.Workspace(i).Statistics.Space_Filling(1).Values(Li,o) = [];
				% else
					GUI_Parameters.Workspace(i).Statistics.Space_Filling(1).Values(Li,o) = length(Rects_Coordinates)*Wc.User_Input.Scale_Factor;
				% end
				GUI_Parameters.Workspace(i).Statistics.Space_Filling.Normalization(1).Name = 'Length of Primary Branches';
				GUI_Parameters.Workspace(i).Statistics.Space_Filling.Normalization(1).Values(Li) = sum([Wc.Branches(find([Wc.Branches.Order] == 1)).Length]);
			end
			
			% Menorahs Length Symmetry:
			Fm = find([Wc.Menorahs.Total_Length] > 0); % Take only Menorahs with positive total length.
			Vm = zeros(1,length(Fm)); % Symmetry vector.
			for m=1:length(Fm)
				Vm(m) = (Wc.Menorahs(Fm(m)).Anterior_Length - Wc.Menorahs(Fm(m)).Posterior_Length) / ...
					Wc.Menorahs(Fm(m)).Total_Length;
			end
			GUI_Parameters.Workspace(i).Statistics.Menorahs_Length_Symmetry(1).Values(Li,1) = mean(Vm);
			GUI_Parameters.Workspace(i).Statistics.Menorahs_Length_Symmetry(1).Normalization = [];
			
			GUI_Parameters.Workspace(i).Statistics.Menorahs_Overlap(1).Values(Li,1) = ...
				nanmean([Wc.Menorahs(find([Wc.Menorahs.IsMenorah] == 1)).Anterior_Overlap]);
			GUI_Parameters.Workspace(i).Statistics.Menorahs_Overlap(1).Normalization = [];
			
			Tips_Distances_Temp = [];
			for v=1:numel(Wc.Vertices)
				% if(length(Wc.Vertices(v).Rectangles_Angles) == 3) % If it's a 3-way junction.
				% end
				if(Wc.Vertices(v).Vertex_Index < 0) % If it's a tip.
					MinD = 10000;
					for c=1:numel(Wc.Vertices)
						if(Wc.Vertices(c).Vertex_Index < 0 && c ~= v) % If it's a tip AND not the v-tip.
							Xv = Wc.Vertices(v).Coordinates(1);
							Yv = Wc.Vertices(v).Coordinates(2);
							Xc = Wc.Vertices(c).Coordinates(1);
							Yc = Wc.Vertices(c).Coordinates(2);
							D1 = ((Xv-Xc)^2+(Yv-Yc)^2)^0.5;
							if(D1 < MinD)
								MinD = D1;
							end
						end
					end
					Tips_Distances_Temp(end+1) = MinD*Wc.User_Input.Scale_Factor; % Array of distances for a specific animal.
				end
			end
			GUI_Parameters.Workspace(i).Statistics.Tips_Distances(Li) = mean(Tips_Distances_Temp);
		end
	end
	
	% assignin('base','Statistics_Multiple',Statistics);
	
end