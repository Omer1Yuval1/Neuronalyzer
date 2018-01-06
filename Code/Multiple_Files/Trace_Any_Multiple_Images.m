function Trace_Any_Multiple_Images(NN_Object,NN_Threshold)
	
	% Main Goal: Update existing .mat files using updated code.
	% Steps:
		% The user chooses a directory.
		% The code extracts all the existing .mat files in this directory (including sub-directories).
		% Then, it applies the updated analysis on each project.
	
	% assignin('base','NN_Object',NN_Object);
	% assignin('base','NN_Threshold',NN_Threshold);
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat'); % List all .mat files under this directory (including subdirectories).	
	
	% assignin('base','Files_List',Files_List);
	
	% mkdir([PathName,'My_Neuronalizer_Projects']);
	N = length(Files_List);
	Multiple_NN_WaitBar = waitbar(0,'Please Wait');
	
	for f=1:numel(Files_List) % For each file (image\neuron). TODO: check 84.
		
		% disp(Files_List(f).name);
		
		% 0. Load Workspace.
		File_Dir = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		disp(File_Dir);
		disp(f);
		File1 = load(File_Dir,'Workspace');
		Workspace = File1.Workspace;
		
		Workspace(1).Workspace.Parameters = Parameters_Func(Workspace(1).Workspace.User_Input(1).Scale_Factor);
		Workspace(1).Workspace.Parameters.Neural_Network.Default_Pixel_Classification_Threshold = NN_Threshold;
		
		% 1. Perorm pre-processing (using a trained neural network, but only if it wasn't manually edited):
		if(Workspace(1).Workspace.User_Input.BW_Edited == 0) % If the BW was NOT manually edited, overwrite.
			
			% If this code is commented, then the previous result of a neural network is used:
			% Workspace(1).Workspace.NN_Probabilities = Apply_Trained_Network(NN_Object,Workspace(1).Workspace.Image0);
			
			[Im_Rows,Im_Cols] = size(Workspace(1).Workspace.Image0);
			Workspace(1).Workspace.Im_BW = zeros(Im_Rows,Im_Cols);
			Workspace(1).Workspace.Im_BW(find(Workspace(1).Workspace.NN_Probabilities >= NN_Threshold)) = 1;
			% disp('Overwriting On Top of the Existing BW Image');
		end
		
		% 2. Skeletonize and segment skeleton:
		Workspace(1).Workspace = Vertices_Analysis_Index(Workspace(1).Workspace);
		
		% 3. Trace:
		Workspace(1).Workspace = Connect_Vertices(Workspace(1).Workspace);
		Workspace(1).Workspace = rmfield(Workspace(1).Workspace,'Im_BW'); % The probabilities matrix is saved instead.
		
		% 4. Save the updated Workspace:
		save(strcat(Files_List(f).folder,filesep,'Workspace.mat'),'Workspace');
		% saveas(gcf,strcat(Files_List(f).folder,filesep,'Trace'),'tiffn');
		
		waitbar(f/N,Multiple_NN_WaitBar);
	end
	delete(Multiple_NN_WaitBar);
	
end