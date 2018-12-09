function W = Collect_All_Workspaces()
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat');
	
	W = struct('Workspace',{}); % 'Genotype',{},'Strain',{},'Crowding',{},'Age',{}
	% W(numel(Files_List)).Workspace = -1;
	
	% [Genotype,Strain,Crowding] = Define_Groups_Categories(); % TODO: replace with an automatic feature extraction & numbering.
	
	% Features = struct('Feature_Name',{},'Values',{},'Num_Of_Options',{});
	
	for i=1:numel(Files_List) % For each workspace (=worm).
		
		File1 = [Files_List(i).folder,filesep,Files_List(i).name]; % Full path + name of the current file.
		f = load(File1,'Workspace');
		
		for j=1:numel(f.Workspace)
			if(~isfield(f.Workspace(j).Workspace.User_Input,'IsGood') || ...
						( isfield(f.Workspace(j).Workspace.User_Input,'IsGood') && f.Workspace(j).Workspace.User_Input.IsGood) ) % Include workspace only if it is annotated as good.
				W(end+1).Workspace = f.Workspace(j).Workspace;
				
				W(end).Workspace = rmfield(W(end).Workspace,{'Image0','Parameters'});
				if(isfield(W(end).Workspace,'BW_Reconstruction'))
					W(end).Workspace = rmfield(W(end).Workspace,'BW_Reconstruction');
				end
			end
		end
	end
end