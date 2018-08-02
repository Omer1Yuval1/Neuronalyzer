function Generate_Orders_Result_Demo()
	
	% Run Example: Apply_To_AllFiles_SubDirs('tif');
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = dir([Dir1,filesep,'**',filesep,'*.','mat']); % List all .mat files under this directory (including subdirectories).
	Save_Dir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Branches_Orders_Test';
	
	N = length(Files_List);
	Multiple_NN_WaitBar = waitbar(0,'Please Wait');
	
	NN_Threshold = 0.6;
	Curvature_Threshold = 1;
	Length_Threshold = 3;
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		% Load File:
		disp(f);
		Wi = [Files_List(f).folder,filesep,Files_List(f).name] % Full path + name of the current file.
		Wi = load(Wi,'Workspace');
		Wi = Wi.Workspace.Workspace;
		% return;
		% Do Something:
		% assignin('base','Wi',Wi); % return;
		[Im_Rows,Im_Cols] = size(Wi.Image0);
		Wi.Im_BW = zeros(Im_Rows,Im_Cols);
		Wi.Im_BW(Wi.NN_Probabilities >= NN_Threshold) = 1;
		
		% assignin('base','Wi_0',Wi);
		Wi = Vertices_Analysis_Index(Wi);
		% assignin('base','Wi_1',Wi);
		Wi = Match_Vertex_Rects_To_Segments(Wi); % Note: this algorithm is included in 'Connect_Vertices.m'.
        
		Wi = add_length(Wi);
        
		% assignin('base','Wi_2',Wi);
		[Wi,Deleted_Segments] = Reduce_Connectivity(Wi,Length_Threshold);
		% assignin('base','Wi_3',Wi);
		Wi.Branches = construct_branches(Wi,Curvature_Threshold);
		% assignin('base','Wi_4',Wi);
		Wi = Classify_Branches(Wi);
		% assignin('base','Wi_5',Wi);
		
		figure(1);
		clf(1);
		Plot_Branches_Orders(Wi);
		%%%
		
		% Save Stuff:
		New_File_Name = [Files_List(f).name(1:end-4),'_',num2str(f),'.tif'];
		saveas(gcf,strcat(Save_Dir,filesep,New_File_Name),'tiffn'); % Save figure as image.
		
		waitbar(f/N,Multiple_NN_WaitBar); % Update the waitbar.
	end
	delete(Multiple_NN_WaitBar);
end