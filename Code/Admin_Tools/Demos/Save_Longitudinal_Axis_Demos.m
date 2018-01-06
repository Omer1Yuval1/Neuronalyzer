function Save_Longitudinal_Axis_Demos
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat');
	
	% SaveDir = 'D:\Omer\Dropbox (Technion)\Neuronalizer\PVD Images\Sharon\DEG_for_Menorah_analyser_Filtered_Format_Names\Results_Demos\Longitudinal_Axis';
	SaveDir = 'D:\Omer\Dropbox (Technion)\Neuronalizer\PVD Images\Sharon\DEG_for_Menorah_analyser_Filtered_Format_Names\Results_Demos\Longitudinal_Axis_Skel';
	% SaveDir = uigetdir;
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		File_Path = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		File1 = load(File_Path,'Workspace');
		Workspace = File1.Workspace;
		
		Find_Worm_Longitudinal_Axis(Workspace);
		
		% assignin('base','Files_List',Files_List);
		k = strfind(Files_List(f).folder,'\');
		FileName = Files_List(f).folder(k(end)+1:end);
		saveas(gcf,strcat(SaveDir,filesep,FileName),'tiffn'); % Save figure as image.
		
		disp(f);
		disp(File_Path);
	end
end