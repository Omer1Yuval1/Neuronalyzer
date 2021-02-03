function [ConvNet,B] = HiddenX3_CNN(XTrain,YTrain,XTest,YTest,layers)
	
	Num_of_Classes = 2;
	% Filter_Size = 5; % = [5,5].
	
	[Sr,Sc] = size(XTrain(:,:,1,1));
	
	% Define the convolutional neural network architecture.
	if(nargin == 4)
		disp('****************************');
		layers = [imageInputLayer([Sr,Sc,1]), ... % To left-right flip the inputs: 'DataAugmentation','randfliplr'
				  convolution2dLayer(2,20),reluLayer,maxPooling2dLayer(2,'Stride',1), ... % Default stride=[1,1].
				  convolution2dLayer(2,20),reluLayer,maxPooling2dLayer(2,'Stride',1), ... % Default padding=[0,0,0,0].
				  convolution2dLayer(2,20),reluLayer,maxPooling2dLayer(2,'Stride',1), ...
				  convolution2dLayer(2,20),reluLayer,maxPooling2dLayer(2,'Stride',1), ...
				  convolution2dLayer(2,20),reluLayer,maxPooling2dLayer(2,'Stride',1), ...
				  convolution2dLayer(2,20),reluLayer,maxPooling2dLayer(2,'Stride',1), ...
				  fullyConnectedLayer(Num_of_Classes),softmaxLayer,classificationLayer()];
	end
	
	% ***** Consider using a size=3 filter in the first later to detect edges of 1-pixel thick segments.
	% ***** try to get rid of maxPooling2dLayer layers.
	% ***** try to add more convolution2dLayer layers.
	
	% Specify the Training Options:
	options = trainingOptions('sgdm','MaxEpochs',15,'InitialLearnRate',0.0001,'ExecutionEnvironment','parallel', ...
								'Plots','training-progress');
	
	% Train the Network Using Training Data:
	ConvNet = trainNetwork(XTrain,YTrain,layers,options);
	
	% assignin('base','ConvNet',ConvNet);
	
	% Classify the Images in the Test Data and Compute Accuracy:
	B = grp2idx(classify(ConvNet,XTest))' - 1;
	A = (grp2idx(YTest))' - 1;
	plotconfusion(A,B);
    
    assignin('base','A',A);
    assignin('base','B',B);
	
end