function Apply_And_Save()
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat');
	
	SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Longitudinal_Axis_NN\';
	% SaveDir = uigetdir;
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		File_Path = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		File1 = load(File_Path,'Workspace');
		Workspace = File1.Workspace;
		
		if(0) % Simple binarization.
			[ImP,BW,closeBW] = Find_Center_Line(Workspace);
		else % NN.
			NN_Threshold = .65;
			[Im_Rows,Im_Cols] = size(Workspace.Workspace.Image0);
			BW = zeros(Im_Rows,Im_Cols);
			BW(find(Workspace.Workspace.NN_Probabilities >= NN_Threshold)) = 1;
			
			se = strel('disk',90);
			closeBW = imclose(BW,se);
		end
		
		% assignin('base','Files_List',Files_List);
		% k = strfind(Files_List(f).folder,'\');
		% FileName = Files_List(f).folder(k(end)+1:end);
		% saveas(gcf,strcat(SaveDir,filesep,FileName),'tiffn'); % Save figure as image.
		
		imwrite(closeBW,[SaveDir,num2str(f),'.tif']);
		
		disp(f);
		disp(File_Path);
	end
end