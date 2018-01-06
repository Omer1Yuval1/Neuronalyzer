function Update_All_MAT_Files_In_Dir()
		
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat'); % List all .mat files under this directory (including subdirectories).	
	
	N = length(Files_List);
	Multiple_NN_WaitBar = waitbar(0,'Please Wait');
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		disp(Files_List(f).name);
		
		% Create the new structure:
		Workspace = struct('Workspace',{});
		
		% Load Workspace.
		File1 = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		Workspace1 = load(File1,'Workspace');
		Workspace(1).Workspace = Workspace1.Workspace;
		
		% assignin('base','A',Workspace1.Workspace);
		
		% Save the updated Workspace:
		save(strcat(Files_List(f).folder,filesep,'Workspace.mat'),'Workspace');
		
		waitbar(f/N,Multiple_NN_WaitBar);
	end
	delete(Multiple_NN_WaitBar);
	
end