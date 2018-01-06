function [ConvNet,B] = Simple_CNN(XTrain,YTrain,XTest,YTest,Frame_Half_Size)
	
	Num_of_Classes = 2;
	Filter_Size = 5; % = [5,5].
	
	[Sr,Sc] = size(XTrain(:,:,1,1));
	
	% Define the convolutional neural network architecture.
	layers = [imageInputLayer([Sr Sc 1]) % To left-right flip the inputs: 'DataAugmentation','randfliplr'
			  convolution2dLayer(Filter_Size,20) % 20 = number of filters, which is the number of neurons that connect to the same region of the output.
			  reluLayer
			  maxPooling2dLayer(2,'Stride',2)
			  fullyConnectedLayer(Num_of_Classes)
			  softmaxLayer
			  classificationLayer()];
	
	% Specify the Training Options:
	options = trainingOptions('sgdm','MaxEpochs',15,'InitialLearnRate',0.0001);
	
	% Train the Network Using Training Data:
	ConvNet = trainNetwork(XTrain,YTrain,layers,options);
	
	assignin('base','ConvNet',ConvNet);
	
	% Classify the Images in the Test Data and Compute Accuracy:
	B = grp2idx(classify(ConvNet,XTest))' - 1;
	A = (grp2idx(YTest))' - 1;
	plotconfusion(A,B);
	
end