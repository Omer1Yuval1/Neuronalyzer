function PVD_CNN = PVD_CNN_Train(Training_Mode,S,net)
	
    % Run Examples:
        % PVD_CNN = PVD_CNN_Train(1,[]);
	
	switch(nargin)
		case 0
			Training_Mode = 1;
			S = PVD_CNN_Params();
			net = [];
		case 1
			S = PVD_CNN_Params();
			net = [];
		case 2
			net = [];
	end
	
	rng('default'); % Reset the random seed.
	
	if(Training_Mode == 1) % Training locally.
		Train_Dir_Input_Old = S.Train_Dir_Input;
		Train_Dir_Output_Old = S.Train_Dir_Output;
		
		Mat_File_Dir = S.Main_Dir;
		
	elseif(Training_Mode == 2)
		Mat_File_Dir = S.HPC_Path;
	end
	
	T_Set = load([Mat_File_Dir,'T_Set_1'],'T_Set');
	T_Set = T_Set.T_Set;
	
	if(Training_Mode == 1)
		T_Set.Input = strrep(T_Set.Input,Train_Dir_Input_Old,S.Save_Dir_Input);
		
		if(S.Im2Im)
			T_Set.Output = strrep(T_Set.Output,Train_Dir_Output_Old,S.Save_Dir_Output);
		end
	end
	
	if(S.Randomize_By_Image)
		N_Im = length(unique([T_Set.Source_Image_Index{:}])); % Total number of images.
		N_Test = ceil(S.Test_Set_Ratio * N_Im); % Number of test images.
		I_Set = randperm(N_Im); % Image indices with randomised order.
		
		I_Test = find(ismember([T_Set.Source_Image_Index{:}],I_Set(1:N_Test))); % Indices of samples from test images.
		I_Train = find(ismember([T_Set.Source_Image_Index{:}],I_Set(N_Test+1:end))); % Indices of samples from train images.
		
		disp(['Training set: ',num2str(I_Set(N_Test+1:end))]);
		disp(['Test set: ',num2str(I_Set(1:N_Test))]);
	else % Randomize samples.
		I_Set = randperm(size(T_Set,1)); % Random unique permutation of all rows in T_Set.
		I_Threshold = round(S.Test_Set_Ratio .* size(T_Set,1)); % Last index of test set (+1 is the first of the training set).
		
		I_Test = I_Set(1:I_Threshold); % Test set indices.
		I_Train = I_Set((I_Threshold+1):end); % Training set indices.
	end
	Test_Set = T_Set(I_Test,:);
	Train_Set = T_Set(I_Train,:);
	
	switch(S.Im2Im)
		case 1
			% Create datastores for input and output data (training and testing):
			Input_Train = imageDatastore(Train_Set{:,1},'FileExtensions','.tif');
			Output_Train = imageDatastore(Train_Set{:,2},'FileExtensions','.tif');
			Input_Test = imageDatastore(Test_Set{:,1},'FileExtensions','.tif');
			Output_Test = imageDatastore(Test_Set{:,2},'FileExtensions','.tif');
			
			% Combine datastores:
			% Train_Set = combine(Input_Train,Output_Train);
			% Test_Set = combine(Input_Test,Output_Test);
			
			Train_Set = randomPatchExtractionDatastore(Input_Train,Output_Train,S.Patch_Size,'PatchesPerImage',S.miniBatchSize_Patch,'DataAugmentation','none');
			Train_Set.MiniBatchSize = S.miniBatchSize_Patch;
			
			Test_Set = randomPatchExtractionDatastore(Input_Test,Output_Test,S.Patch_Size,'PatchesPerImage',S.miniBatchSize_Patch,'DataAugmentation','none');
			Test_Set.MiniBatchSize = S.miniBatchSize_Patch;
			
			clear Input_Train Input_Test Output_Train Output_Test;
		case 2 % Use tables with explicit images.
			for i=1:size(Train_Set,1)
				Train_Set.Input{i} = im2double(imread(Train_Set.Input{i}));
				Train_Set.Output{i} = im2double(imread(Train_Set.Output{i}));
			end
			
			for i=1:size(Test_Set,1)
				Test_Set.Input{i} = im2double(imread(Test_Set.Input{i}));
				Test_Set.Output{i} = im2double(imread(Test_Set.Output{i}));
			end
		case 3 % pixelLabelDatastore.
			
			% Create datastores for input data (training and testing):
			Input_Train = imageDatastore(Train_Set{:,1},'FileExtensions','.tif');
			Input_Test = imageDatastore(Test_Set{:,1},'FileExtensions','.tif');
			
			% Create pixelLabelDatastore for output data (training and testing):
			Output_Train = pixelLabelDatastore(Train_Set{:,2},["BG","Neuron"],[0,255],'FileExtensions','.tif');
			Output_Test = pixelLabelDatastore(Test_Set{:,2},["BG","Neuron"],[0,255],'FileExtensions','.tif');
			
			% Combine input and output data into a "pixelLabelImageDatastore":
			Train_Set = pixelLabelImageDatastore(Input_Train,Output_Train);
			Test_Set = pixelLabelImageDatastore(Input_Test,Output_Test); % ,'OutputSize',S.Input_Size
			
			clear Input_Train Input_Test Output_Train Output_Test;
	end
	
	if(S.Im2Im)
		Options = trainingOptions(S.Solver,'LearnRateSchedule','piecewise','InitialLearnRate',S.InitialLearnRate,'LearnRateDropFactor',S.LearnRateDropFactor,'LearnRateDropPeriod',S.LearnRateDropPeriod,...
				'L2Regularization',S.L2Regularization,'MiniBatchSize',S.miniBatchSize,'Shuffle','once','MaxEpochs',S.Max_Epochs,'ExecutionEnvironment',S.ExecutionEnvironment, ...
				'Plots',S.Plots,'Verbose',true,'ValidationData',Test_Set,'ValidationFrequency',S.ValidationFrequency,'CheckpointPath',S.CheckpointPath);
	else % Predict coordinates.
		Options = trainingOptions(S.Solver,'MiniBatchSize',S.miniBatchSize,'MaxEpochs',S.Max_Epochs, ...
			'InitialLearnRate',S.InitialLearnRate,'LearnRateSchedule','piecewise','LearnRateDropFactor',S.LearnRateDropFactor,'LearnRateDropPeriod',S.LearnRateDropPeriod,...
			'Shuffle','once',... % 'L2Regularization',S.L2Regularization, ...
			'ValidationData',Test_Set,'ValidationFrequency',S.validationFrequency,'CheckpointPath',S.CheckpointPath, ...
			'ExecutionEnvironment',S.ExecutionEnvironment,'Plots',S.Plots,'Verbose',S.Verbose);
	end
	
	if(~isempty(net))
		S.Layers = layerGraph(net); % net.Layers;
	end
	
	clear Test_Set T_Set net;
	
	PVD_CNN = trainNetwork(Train_Set,S.Layers,Options);
end