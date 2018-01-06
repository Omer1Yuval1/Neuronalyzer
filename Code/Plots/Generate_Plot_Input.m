function Input_Struct = Generate_Plot_Input(GUI_Parameters,DB_Name,Field_Name,Single_Workspace_Operation)
	
	% TODOs:
		% 1. why do I have a workspace(16) with Grouping value = 3.
	
	% This function filters workspaces based on the chosen features and concentrates values from different workspaces
		% that belong to the same group.
	
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
		
		F = find([GUI_Parameters.Workspace.Grouping] == Selected_Groups(i,1) & [GUI_Parameters.Workspace.Genotype] == Selected_Groups(i,2)); % Find all the relevant workspaces.
		for j=1:length(F) % For each workspace within group i.
			switch length(Field_Name)
				case 1
					Input_Struct(i).Values = [Input_Struct(i).Values,Single_Workspace_Operation([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Field_Name{1})])];
				case 2
					Input_Struct(i).XValues = [Input_Struct(i).XValues,Single_Workspace_Operation([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Field_Name{1})])];
					Input_Struct(i).YValues = [Input_Struct(i).YValues,Single_Workspace_Operation([GUI_Parameters.Workspace(F(j)).Workspace.(DB_Name).(Field_Name{2})])];
			end
		end
		Input_Struct(i).Worms_Number = length(F);
		Input_Struct(i).Color = GUI_Parameters.Visuals.Active_Colormap(i,:);
		Input_Struct(i).Labels = strrep(Input_Struct(i).Group_Name,'_','\newline');
	end
	
end