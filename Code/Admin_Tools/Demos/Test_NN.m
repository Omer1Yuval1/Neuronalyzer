function Test_NN(NN_Object,NN_Threshold,NN_Name)
	
	% [Files_List,PathName] = uigetfile({'*.tif';'*.jpg'},'Please Choose a Set of Images.','MultiSelect','on');
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'tif'); % List all .mat files under this directory (including subdirectories).	
	
	Target_Dir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\NN\AveragePool_1 (Neurons=[40,30,20],TrainSet_1, BG=All)_97.6\';
	% mkdir([PathName,'Test_Result_',NN_Name]);
	% cd([PathName,'Test_Result_',NN_Name]);
	N = numel(Files_List);
	Multiple_NN_WaitBar = waitbar(0,['Tracing In Progress (0/',num2str(N),')']);
	% assignin('base','Files_List',Files_List);
	
	for f=21:numel(Files_List) % For each file (image\neuron).
		
		disp(f);
		File_Name = Files_List(f).name
		if(strcmp(File_Name(1:5),'Trace'))
			continue;
		end
		
		Image0 = flipud(imread(strcat(Files_List(f).folder,filesep,File_Name)));
		Image0 = Image0(:,:,1); % Choose the 1st channel in case it's a pseudo RGB.
		
		NN_Probabilities = Apply_Trained_Network(NN_Object,Image0);
		
		[Im_Rows,Im_Cols] = size(Image0);
		Im_BW = zeros(Im_Rows,Im_Cols);
		Im_BW(find(NN_Probabilities >= NN_Threshold)) = 1;
		
		
		imwrite(Image0,[Target_Dir,File_Name(1:end-4),'_0',File_Name(end-3:end)]);
		imwrite(NN_Probabilities,[Target_Dir,File_Name(1:end-4),'_1',File_Name(end-3:end)]);
		imwrite(Im_BW,[Target_Dir,File_Name(1:end-4),'_2',File_Name(end-3:end)]);
		
		waitbar(f/N,Multiple_NN_WaitBar,['Tracing In Progress (',num2str(f),'/',num2str(N),')']);
		
	end
	delete(Multiple_NN_WaitBar);
end