function Trace_Multiple_Images(User_Input,NN_Object,NN_Threshold)
	
	% This function has to be run on each group of animals separately.
	
	assignin('base','User_Input',User_Input);
	assignin('base','NN_Object',NN_Object);
	assignin('base','NN_Threshold',NN_Threshold);
	
	% Workspace0 = struct('Workspace0',{});
	% Workspace0(1).Parameters = Parameters_Func(User_Input(1).Scale_Factor);
	
	[Files_List,PathName] = uigetfile({'*.tif';'*.jpg'},'Please Choose a Set of Images.','MultiSelect','on');
	mkdir([PathName,'My_Neuronalizer_Projects']);
	N = length(Files_List);
	Multiple_NN_WaitBar = waitbar(0,'Please Wait');
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		disp(Files_List{f});
		
		Workspace0 = struct();
		Workspace0(1).Parameters = Parameters_Func(User_Input(1).Scale_Factor);
		
		% 0. Load image, create a sub-folder and generate a workspace.
		Dir1 = [PathName,'My_Neuronalizer_Projects',filesep,Files_List{f}(1:end-4)];
		% FileName = [Files_List{f}(1:end-4),'.mat'];
		mkdir(Dir1);
		Workspace0(1).Image0 = flipud(imread(strcat(PathName,Files_List{f})));
		Workspace0.User_Input = User_Input;
		[Workspace0.Parameters.General_Parameters.Im_Rows,Workspace0.Parameters.General_Parameters.Im_Cols] = size(Workspace0.Image0);
		
		% 1. Perorm pre-processing (using a trained neural network):
		if(0) % exist('Workspace0.mat','file')) % If a .mat file already exists,
			Workspace1 = load([Dir1,filesep,'Workspace0.mat'],'Workspace0'); % Check if the BW_Reconstruction was manually editted.
			Workspace1 = Workspace1.Workspace0;
			if(Workspace1.User_Input.BW_Edited) % If the BW was manually edited, override it.
				Workspace0.BW_Reconstruction = Workspace1.BW_Reconstruction;
				Workspace0.User_Input.BW_Edited = 1;
			else
				[~,BW_Reconstruction] = Apply_Trained_Network(NN_Object,Workspace0(1).Image0,NN_Threshold);
				Workspace0.BW_Reconstruction = BW_Reconstruction;
				Workspace0.User_Input.BW_Edited = 0;
				disp('Overwriting On Top of the Existing BW Image');
			end
			clear Workspace1; % Delete the old workspace file.
		else
			NN_Probabilities = Apply_Trained_Network(NN_Object,Workspace0(1).Image0);
			Workspace0.NN_Probabilities = NN_Probabilities;
			
			[Im_Rows,Im_Cols] = size(Workspace0.Image0);
			Workspace0.Im_BW = zeros(Im_Rows,Im_Cols);
			Workspace0.Im_BW(find(Workspace0.NN_Probabilities >= NN_Threshold)) = 1;
			
			Workspace0.User_Input.BW_Edited = 0;
		end
		% assignin('base','Workspace0',Workspace0);
		% return;
		
		% 2. Skeletonize and segment skeleton:
		Workspace0 = Vertices_Analysis_Index(Workspace0);
		
		% 3. Trace:
		Workspace0 = Connect_Vertices(Workspace0);
		
		Workspace.Workspace = Workspace0;
		
		% 4. Save .tif files for BW, skeleton, trace and segmentation:
		save(strcat(Dir1,filesep,'Workspace0.mat'),'Workspace0');
		% saveas(gcf,strcat(Dir1,filesep,'Trace'),'tiffn');
		% imwrite(Workspace0.Image0,'Raw_Image.tif');
		% imwrite(Im1_NoiseReduction,'Skeleton.tif');
		
		waitbar(f/N,Multiple_NN_WaitBar);
		% return;
	end
	delete(Multiple_NN_WaitBar);
	
end