function W = Collect_All_Workspaces()
	
	CurrentDir = pwd;
	[File1,Path1,Selection_Index] = uigetfile('*.mat','MultiSelect','on');
		
	if(Selection_Index == 0)
		return;
	elseif(~iscell(File1))
		File1 = {File1};
	end
		
	cd(CurrentDir); % Return to the main directory.
	
	W = struct('Workspace',{}); % 'Genotype',{},'Strain',{},'Crowding',{},'Age',{}
	
	for i=1:length(File1) % For each file.
		
		f = load([Path1,File1{i}],'Workspace');
		
		for j=1:numel(f.Workspace) % For each image (=worm).
			if(~isfield(f.Workspace(j).Workspace.User_Input,'IsGood') || ...
						( isfield(f.Workspace(j).Workspace.User_Input,'IsGood') && f.Workspace(j).Workspace.User_Input.IsGood) ) % Include workspace only if it is annotated as good.
				W(end+1).Workspace = f.Workspace(j).Workspace;
				
				 % W(end).Workspace = rmfield(W(end).Workspace,{'Image0'});
				% if(isfield(W(end).Workspace,'BW_Reconstruction'))
				% 	W(end).Workspace = rmfield(W(end).Workspace,'BW_Reconstruction');
				% end
			end
		end
	end
end