function [ConvNet,B] = CNN_NoPooling(XTrain,YTrain,XTest,YTest,layers)
	
	% assignin('base','XTrain',XTrain);
	% assignin('base','YTrain',YTrain);
	% assignin('base','XTest',XTest);
	% assignin('base','YTest',YTest);
	% assignin('base','layers',layers);
	
	Num_of_Classes = 2;
	MaxEpochs = 30; % 15.
	MiniBatchSize = 512;
	% Filter_Size = 5; % = [5,5].
	
	[Sr,Sc] = size(XTrain(:,:,1,1));
	
	% Define the convolutional neural network architecture.
    if(nargin == 4)
		layers = [imageInputLayer([Sr,Sc,1]), ... % To left-right flip the inputs: 'DataAugmentation','randfliplr'
				convolution2dLayer(2,20),reluLayer,averagePooling2dLayer(2,'Stride',1), ...
				convolution2dLayer(2,20),reluLayer,averagePooling2dLayer(2,'Stride',1), ...
				fullyConnectedLayer(Num_of_Classes),softmaxLayer,classificationLayer()];
	end
			
			% Try a different number of BG frames.
			% Try to increase the number of neurons per layer.
			
			
			  % convolution2dLayer(2,20),reluLayer,convolution2dLayer(2,20),reluLayer,...
			  % convolution2dLayer(2,20),reluLayer,convolution2dLayer(2,20),reluLayer,...
			  % convolution2dLayer(2,20),reluLayer,convolution2dLayer(2,20),reluLayer,...
	% ***** Consider using a size=3 filter in the first later to detect edges of 1-pixel thick segments.
    
	% Specify the Training Options:
	options = trainingOptions('sgdm','MaxEpochs',MaxEpochs,'InitialLearnRate',0.0001,'ExecutionEnvironment','parallel', ...
								'MiniBatchSize',MiniBatchSize,'Plots','training-progress'); % 'ValidationData',{XTest,YTest},
	% The # of samples equals to the # of iterations per epoch X the minibacthsize (# of training samples per batch (default = 128)). 
	% The # of iterations per epoch is set implicitly such that 1 epoch covers all training samples.
	
	% Train the Network Using Training Data:
	ConvNet = trainNetwork(XTrain,YTrain,layers,options);
	% ConvNet.Training_Options = options;
	assignin('base','options',options);
	
	% Classify the Images in the Test Data and Compute Accuracy:
	B = grp2idx(classify(ConvNet,XTest))' - 1;
	A = (grp2idx(YTest))' - 1;
	plotconfusion(A,B);
    
    % assignin('base','A',A);
	% assignin('base','B',B);
	
end