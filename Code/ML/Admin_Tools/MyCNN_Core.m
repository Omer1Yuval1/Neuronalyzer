function [ConvNet,Accuracy] = MyCNN_Core(XTrain,YTrain,XTest,YTest,Params_Struct)
	
	[Sr,Sc] = size(XTrain(:,:,1,1));
	
	% Define the convolutional neural network architecture:
	layers = [	imageInputLayer([Sr Sc 1],'Normalization','none') % Flips and mirros are already included in the training set.
				convolution2dLayer(Params_Struct.Conv_Layer_FilterSize,Params_Struct.Conv_Layer_MapSize,'Stride',Params_Struct.Conv_Layer_Stride) % .
				reluLayer
				averagePooling2dLayer(Params_Struct.Pool_Size,'Stride',Params_Struct.Pool_Stride); % maxPooling2dLayer(2,'Stride',MaxPooling_Stride)
				fullyConnectedLayer(Params_Struct.Num_of_Classes)
				softmaxLayer
				classificationLayer()];
	
	% Specify the Training Options:
	options = trainingOptions('sgdm','MaxEpochs',15,'InitialLearnRate',0.0001,'ExecutionEnvironment','parallel');
	
	% Train the Network Using Training Data:
	ConvNet = trainNetwork(XTrain,YTrain,layers,options);
	
	% assignin('base','ConvNet',ConvNet);
	% assignin('base','XTest',XTest);
	% assignin('base','YTest',YTest);
	
	% Classify the Images in the Test Data and Compute Accuracy:
	B = grp2idx(classify(ConvNet,XTest))' - 1;
	A = (grp2idx(YTest))' - 1;
	plotconfusion(A,B);
	
	Accuracy = sum(B == A)/numel(A);
	
end