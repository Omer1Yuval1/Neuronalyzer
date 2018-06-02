function [ConvNet,B] = CNN_CCRCCRP_X3(XTrain,YTrain,XTest,YTest,Frame_Half_Size)
	
	Num_of_Classes = 2;
	Conv1_FilterSize = [2,2];
	Conv1_FiltersNum = 20;
	
	[Sr,Sc] = size(XTrain(:,:,1,1));
	
	% Define the convolutional neural network architecture.
	layers = [imageInputLayer([Sr,Sc,1]), ... % To left-right flip the inputs: 'DataAugmentation','randfliplr'
			  convolution2dLayer(Conv1_FilterSize,Conv1_FiltersNum),reluLayer, ...
			  convolution2dLayer(Conv1_FilterSize,Conv1_FiltersNum),reluLayer, ... % maxPooling2dLayer(2,'Stride',2), ...
			  convolution2dLayer(Conv1_FilterSize,Conv1_FiltersNum),reluLayer, ...
			  convolution2dLayer(Conv1_FilterSize,Conv1_FiltersNum),reluLayer, ... % maxPooling2dLayer(2,'Stride',2), ...
			  convolution2dLayer(Conv1_FilterSize,Conv1_FiltersNum),reluLayer, ...
			  convolution2dLayer(Conv1_FilterSize,Conv1_FiltersNum),reluLayer, ...
			  fullyConnectedLayer(Num_of_Classes),reluLayer, ...
              fullyConnectedLayer(Num_of_Classes),reluLayer, ...
              fullyConnectedLayer(Num_of_Classes), ...
              softmaxLayer,classificationLayer()];
	
    % maxPooling2dLayer(1,'Stride',1), ...
	% Specify the Training Options:
	options = trainingOptions('sgdm','MaxEpochs',15,'InitialLearnRate',0.0001,'ExecutionEnvironment','parallel');
	
	% Train the Network Using Training Data:
	ConvNet = trainNetwork(XTrain,YTrain,layers,options);
	
	% assignin('base','ConvNet',ConvNet);
	
	% Classify the Images in the Test Data and Compute Accuracy:
	B = grp2idx(classify(ConvNet,XTest))' - 1;
	A = (grp2idx(YTest))' - 1;
	plotconfusion(A,B);
	
end