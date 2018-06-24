function Input_Struct = Generate_Plot_Input(GUI_Parameters,DB_Name,Field_Name,Workspace_Operations,RowWise)
	
	% TODOs:
		% 1. seems like the numbers in the features (2) do not match the numbers here and that's why F is empty.
	
	% This function filters workspaces based on the chosen features and concentrates values from different workspaces
		% that belong to the same group.
	% assignin('base','Input_Struct',Input_Struct);
	switch length(Field_Name)
		case 1
			Input_Struct = struct('Group_Name',{},'Values',{},'Normalization',{},'Worms_Number',{},'Color',{},'Labels',{});
		case 2
			Input_Struct = struct('Group_Name',{},'XValues',{},'YValues',{},'Normalization',{},'Worms_Number',{},'Color',{},'Labels',{});
	end
	
	% Currently using only these two features:
	Grouping = find([GUI_Parameters.Features(7).Values.ON_OFF]); % Grouping. Indices of ON fields.
	Genotype = find([GUI_Parameters.Features(5).Values.ON_OFF]); % Genotype. Indices of ON fields.
	
	F1 = find(ismember([GUI_Parameters.Workspace.Grouping],Grouping)); % Find the workspaces that have a Grouping value that is ON.
	F2 = find(ismember([GUI_Parameters.Workspace.Genotype],Genotype)); % Find the workspaces that have a Genotype value that is ON.
	Selected_Workspaces = intersect(F1,F2); % Take the intersection of the workspaces indices.
	
	Selected_Groups = zeros(0,2); % A [n,2] matrix containing pairs of features indices [Grouping,Genotype].
	for i=1:length(Grouping) % TODO: this is temporary. Generating all possible pairs between these two features.
		Selected_Groups = [Selected_Groups ; combvec(Grouping(i),Genotype)'];
	end
	
	for i=1:size(Selected_Groups,1) % For each group (a unique combination of features).
		Input_Struct(i).Group_Name = [GUI_Parameters.Features(5).Values(Selected_Groups(i,2)).Name,'_',GUI_Parameters.Features(7).Values(Selected_Groups(i,1)).Name];
		Input_Struct(i).Normalization = 1;
		vi = 0;
		
		F = find([GUI_Parameters.Workspace.Grouping] == Selected_Groups(i,1) & [GUI_Parameters.Workspace.Genotype] == Selected_Groups(i,2)); % Find all the relevant workspaces.
		for j=1:length(F) % For each workspace within group i.
			switch length(Field_Name)
				case 1
					Input_Struct(i).Values = [Input_Struct(i).Values,Workspace_Operations([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Field_Name{1})])];
				case 2
					if(~RowWise) % Apply operation to the entire column at once.
						Input_Struct(i).XValues = [Input_Struct(i).XValues,Workspace_Operations([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Field_Name{1})])];
						Input_Struct(i).YValues = [Input_Struct(i).YValues,Workspace_Operations([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Field_Name{2})])];
					else % Perform the operation per row.
						for k=1:numel(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)) % For each row in the chosen DB_Name.
							% Note: not using (end+1) because the value may be an empty array.
							% Note: Each function performs a find-like operation and thus returns all values that match the rule.
								% ...*** thus, taking the 1st result for each in case there are duplicates.
							% disp(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Field_Name{1}));
							% disp([i,j,k]);
							X = GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Field_Name{1});
							Y = GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Field_Name{2});
							if(length(unique(X)) == length(X) && length(unique(Y)) == length(Y))
								X = Workspace_Operations{1}(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Field_Name{1}));
								Y = Workspace_Operations{2}(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Field_Name{2}));
								if(~isempty(X) && ~isempty(Y))
									vi = vi + 1;
									Input_Struct(i).XValues(vi) = X(1); % ***.
									Input_Struct(i).YValues(vi) = Y(1); % ***.
								end
							end
						end
					end
			end
		end
		Input_Struct(i).Worms_Number = length(F);
		Input_Struct(i).Color = GUI_Parameters.Visuals.Active_Colormap(i,:);
		Input_Struct(i).Labels = strrep(Input_Struct(i).Group_Name,'_','\newline');
	end
	
end