function Input_Struct = Generate_Plot_Input(GUI_Parameters,DB_Name,Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise)
	
	% assignin('base','GUI_Parameters3',GUI_Parameters);
	% TODOs:
		% 1. seems like the numbers in the features (2) do not match the numbers here and that's why F is empty.
	
	% This function filters workspaces based on the chosen features and concentrates values from different workspaces
		% that belong to the same group.
	% assignin('base','Input_Struct',Input_Struct);
	switch length(Var_Fields)
		case 1 % Using the name "XValues" allows to use more than one field for single-field plots to filter out data.
			Input_Struct = struct('Group_Name',{},'XValues',{},'Normalization',{},'Worms_Number',{},'Color',{},'Labels',{});
		case 2
			Input_Struct = struct('Group_Name',{},'XValues',{},'YValues',{},'Normalization',{},'Worms_Number',{},'Color',{},'Labels',{});
		case 3
			Input_Struct = struct('Group_Name',{},'XValues',{},'YValues',{},'ZValues',{},'Normalization',{},'Worms_Number',{},'Color',{},'Labels',{});
	end
	
	% Currently using only these two features:
	Grouping = find([GUI_Parameters.Features(7).Values.ON_OFF]); % Grouping. Indices of ON fields.
	Genotype = find([GUI_Parameters.Features(5).Values.ON_OFF]); % Genotype. Indices of ON fields.
	
	% F1 = find(ismember([GUI_Parameters.Workspace.Grouping],Grouping)); % Find the workspaces that have a non-zero Grouping value.
	% F2 = find(ismember([GUI_Parameters.Workspace.Genotype],Genotype)); % Find the workspaces that have a non-zero Genotype value.
	% Selected_Workspaces = intersect(F1,F2); % Take the intersection of the workspaces indices.
	
	Selected_Groups = zeros(0,2); % A [n,2] matrix containing pairs of features indices [Grouping,Genotype].
	for i=1:length(Grouping) % TODO: this is temporary. Generating all possible pairs between these two features (5 & 7).
		Selected_Groups = [Selected_Groups ; combvec(Grouping(i),Genotype)'];
	end
	
	Groups = struct('Name',{},'Features',{},'Workspaces',{},'Delete',{});
	for i=1:size(Selected_Groups,1)
		F = find([GUI_Parameters.Workspace.Grouping] == Selected_Groups(i,1) & [GUI_Parameters.Workspace.Genotype] == Selected_Groups(i,2));
		Groups(i).Workspaces = F; % Row numbers of workspaces.
		Groups(i).Name = [GUI_Parameters.Features(5).Values(Selected_Groups(i,2)).Name,'_',GUI_Parameters.Features(7).Values(Selected_Groups(i,1)).Name];
	end
	
	% Merge features for which the main button if OFF.
	F = [7,5];
	for i=1:length(F)
		User_Data = get(GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles(i),'UserData');
		if(User_Data(3) == 0) % If it's switched OFF.
			Selected_Groups(:,i) = 0;
		end
	end
	[~,~,ic] = unique(Selected_Groups,'rows'); % ic gives a uniqe index to each set of identical rows [N,1].
	% disp(ic);
	for i=1:max(ic) % For each new group (after merging indices).
		F = find(ic == i);
		Groups(F(1)).Features = Selected_Groups(F(1),:);
		Groups(F(1)).Delete = 0;
		for j=2:length(F)
			Groups(F(1)).Workspaces = [Groups(1).Workspaces,Groups(F(j)).Workspaces];
			Groups(F(j)).Delete = 1;
		end
	end
	Groups(find([Groups.Delete] == 1)) = [];
	Names = {'XValues','YValues','ZValues'};
	
	% assignin('base','Groups',Groups);
	for i=1:numel(Groups) % For each group (a unique combination of features).
		Input_Struct(i).Group_Name = Groups(i).Name;
		Input_Struct(i).Normalization = 1;
		
		F = Groups(i).Workspaces;
		% F = find([GUI_Parameters.Workspace.Grouping] == Selected_Groups(i,1) & [GUI_Parameters.Workspace.Genotype] == Selected_Groups(i,2)); % Find all the relevant workspaces.
		for j=1:length(F) % For each workspace within group i.
			if(~RowWise) % Apply operation to the entire column at once.
				for l=1:length(Var_Operations)
					% The result of each operation l is assigned to a different dimension (X, Y, Z in Names).
					V = Var_Operations{l}([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Var_Fields{l})]);
					Input_Struct(i).(Names{l}) = [Input_Struct(i).(Names{l}),V];
				end
			else % Perform the operation per row.
				for k=1:numel(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)) % For each row in the chosen DB_Name.
					% Note: not using (end+1) because the value may be an empty array.
					% Note: Each function performs a find-like operation and thus returns all values that match the rule.
						% ...*** thus, taking the 1st result for each, in case there are duplicates.
					% disp(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Var_Fields{1}));
					% disp([i,j,k]);
					
					% Use filtering fields:				
					Flag1 = 1;
					for l=1:length(Filter_Operations) % For each filter operation.
						IsValid = Filter_Operations{l}(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Filter_Fields{l}));
						if(~IsValid)
							Flag1 = 0;
						end
					end
					
					% Use the dynamic sliders to filter-out rows:
					Vi = GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Dynamic_Field);
					if(Vi >= GUI_Parameters.Handles.Analysis.Dynamic_Slider_Min.Value && Vi <= GUI_Parameters.Handles.Analysis.Dynamic_Slider_Max.Value)
						Dynamic_Slider_Flag = 1; % Include this row if the field value is within the dynamic sliders boundaries.
					else
						Dynamic_Slider_Flag = 0;
					end
					
					% Remove this (allow repeating value):
					Flag2 = 1;
					V = cell(1,length(Var_Fields));
					for l=1:length(Var_Operations) % For each variable.
						V{l} = GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Var_Fields{l});
						if(length(V{l}) ~= length(unique(V{l})))
							Flag2 = 0;
							disp('Repeating values detected.');
						end
					end
					
					if(Flag1 && Flag2 && Dynamic_Slider_Flag)
						% Note: the # of values in different fields may be different, which means values in corresponding positions don't correspond.
						% If any of the fields is empty (after applying the operation), the row will not be included.
							% This is also how the filtering-out of rows is implemented (implicitly).
						% disp(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).Order);
						for l=1:length(Var_Operations)
							Vi = Var_Operations{l}(GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name)(k).(Var_Fields{l}));
							N = length(Input_Struct(i).(Names{l})) + 1; % The current total number of values in field l (of group i).
							Ni = N : N + length(Vi) - 1; % The indices to put the new values.
							Input_Struct(i).(Names{l})(Ni) = Vi;
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