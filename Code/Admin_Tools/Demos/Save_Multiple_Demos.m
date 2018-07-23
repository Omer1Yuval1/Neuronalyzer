function Save_Multiple_Demos
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat');
	
	SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\DEG_for_Menorah_analyser_Filtered_Format_Names\Results_Demos\0.65';
	% SaveDir = uigetdir;
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		File_Path = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		File1 = load(File_Path,'Workspace');
		Workspace = File1.Workspace;
		
		Generate_Result_Demo(Workspace(1).Workspace); % Plot segments, CB and primary branch in figure(1).
		
		% assignin('base','Files_List',Files_List);
		k = strfind(Files_List(f).folder,'\');
		FileName = Files_List(f).folder(k(end)+1:end);
		saveas(gcf,strcat(SaveDir,filesep,FileName),'tiffn'); % Save figure as image.
		
		disp(f);
		disp(File_Path);
	end
end