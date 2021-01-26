function P = PVD_CNN_Params()
    
	%% Modes
	% ******
	P.Im2Im = 3;
	
	%% Input, output and dataset
	% **************************
	P.Input_Size = [64,64]; % Pixels.
	P.Input_Half_Size = P.Input_Size ./ 2;
	P.Full_Image_Margin = P.Input_Size(1); % Pixels.
	P.Image_Format = '.tif';
	P.Ns = 50000; % Approximate number of samples for memory preallocation. 
	
	%% Paths
	% ******
	P.Main_Dir = ['.\Resources\CNN\'];
	P.Save_Dir_Input = [P.Main_Dir,'PVD_Dataset_In\'];
	P.Save_Dir_Output = [P.Main_Dir,'PVD_Dataset_Out\'];
	P.Train_Dir_Input = P.Save_Dir_Input;
	P.Train_Dir_Output = P.Save_Dir_Output;
	P.CheckpointPath = [P.Main_Dir,'Checkpoints\'];
	P.Projects_Path = [P.Main_Dir,'Projects\'];
	
	%% Functions
	% **********
	P.Input_Image_Func = @(x) im2double(x(:,:,1));
	P.Im_STD_Threshold = 0;
	P.BW_Min_Neuron_Pixels = round(0.1 * P.Input_Size(1) * P.Input_Size(2));
	P.Sample_In_Func = @(x) std(x(:)) > P.Im_STD_Threshold; % Function used to decide whether to include a sample based on the input image.
	P.Sample_Out_Func = @(x) sum(x(:)) > P.BW_Min_Neuron_Pixels; % Function used to decide whether to include a sample based on the output image.
	
	%% Augmentation
	% *************
	P.Samples_Per_Image = 10;
	% P.Rescale_Noise_Size = 0.2;
	P.Rotation_Vector = 0:90:360; % Degrees.
	P.Reflection_Vector = {@(x) x , @(x) fliplr(x) ,@(x) flipud(x)}; % [no reflection , x-reflection , y-reflection].
	
	%% Training + network parameters
	% ******************************
	P.Solver = 'adam';
	P.Test_Set_Ratio = 0.2;
	P.ExecutionEnvironment = 'parallel';
	P.Plots = 'none'; % 'training-progress';
	P.Verbose = true;
	P.miniBatchSize = 128;
	% P.miniBatchSize_Patch = 16;
	P.Max_Epochs = 400;
	P.InitialLearnRate = 0.001;
	P.LearnRateDropFactor = 0.5;
	P.LearnRateDropPeriod = 100; % # of epochs.
	P.ValidationFrequency = 200; % # of iterations.
	P.L2Regularization = 0.001; % Default = 0.0001.
	
	%% Network architecture
	% *********************
	P.Filters_num = 64; % *.
	P.Filters_num_Last = 2;
	P.Filter_Size_1 = 3;
	P.Filter_Size_2 = 3;
	P.Dropout_Probability = 0.9;
	P.Padding_Vector = 'same';
	P.Encoder_Depth = 4;
	
	if(0) % segnetLayers
		% P.Layers = unetLayers(P.Patch_Size,3,'encoderDepth',4); % https://ch.mathworks.com/help/vision/ref/unetlayers.html#namevaluepairarguments
		P.Layers = unetLayers([P.Input_Size,1],3,'encoderDepth',P.Encoder_Depth); % https://ch.mathworks.com/help/vision/ref/unetlayers.html#namevaluepairarguments
		
		% Convert from classification to image-to-image regression:
		P.Layers = P.Layers.removeLayers('Softmax-Layer');
		P.Layers = replaceLayer(P.Layers,'Final-ConvolutionLayer',convolution2dLayer(1,P.Filters_num_Last,'Name','Final-ConvolutionLayer')); % Change last convolution layer to have one channel.
		P.Layers = replaceLayer(P.Layers,'Segmentation-Layer',regressionLayer('name','regressionLayer'));
		P.Layers = P.Layers.connectLayers('Final-ConvolutionLayer','regressionLayer');
	elseif(1) % Used with pixelLabelImageDatastore.
		P.Layers = segnetLayers([P.Input_Size,1],2,P.Encoder_Depth);
		
		% Convert from classification to image-to-image regression:
		%{
		P.Layers = P.Layers.removeLayers('softmax');
		P.Layers = P.Layers.removeLayers('decoder1_bn_1');
		P.Layers = P.Layers.removeLayers('decoder1_relu_1');
		P.Layers = replaceLayer(P.Layers,'decoder1_conv1',convolution2dLayer(1,P.Filters_num_Last,'Name','Final-ConvolutionLayer')); % Change last convolution layer to have one channel.
		P.Layers = replaceLayer(P.Layers,'pixelLabels',regressionLayer('name','regressionLayer'));
		P.Layers = P.Layers.connectLayers('Final-ConvolutionLayer','regressionLayer');
		%}
	else
		P.Layers = [imageInputLayer([P.Input_Size,1]), ...
			convolution2dLayer(P.Filter_Size_1,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			convolution2dLayer(P.Filter_Size_2,P.Filters_num_Last,'Padding',P.Padding_Vector),batchNormalizationLayer,reluLayer, ...
			dropoutLayer(P.Dropout_Probability), ...
			regressionLayer];
	end
end