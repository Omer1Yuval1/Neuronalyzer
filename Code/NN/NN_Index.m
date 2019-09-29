function [My_CNN,X,Y] = NN_Index()
    
	% Architecture
		% https://uk.mathworks.com/help/images/ref/dncnnlayers.html
		% https://uk.mathworks.com/help/images/ref/denoisingnetwork.html
		
		% https://uk.mathworks.com/help/images/train-and-apply-denoising-neural-networks.html
		% https://uk.mathworks.com/help/images/ref/denoiseimage.html
		% https://uk.mathworks.com/help/deeplearning/examples/image-to-image-regression-using-deep-learning.html
		% https://uk.mathworks.com/help/deeplearning/examples/visualize-features-of-a-convolutional-neural-network.html
	
	% Visual
		% https://uk.mathworks.com/help/deeplearning/ref/deepdreamimage.html
		% https://uk.mathworks.com/help/deeplearning/examples/extract-image-features-using-pretrained-network.html
		% https://uk.mathworks.com/help/deeplearning/ref/analyzenetwork.html
		% https://uk.mathworks.com/help/deeplearning/ref/deepnetworkdesigner-app.html
		% https://uk.mathworks.com/help/deeplearning/ref/nnet.cnn.layergraph.html
		% https://uk.mathworks.com/help/deeplearning/ref/activations.html
	
	
    tmp = matlab.desktop.editor.getActive;
    cd(fileparts(tmp.Filename));
	
	addpath(genpath(pwd));
	
	Frame_Half_Size = 10; % 10 = 21X21 ; 12 = 25X25 ; 15 = 31X31 ; 7 = 15X15.
	Train_Set_Ratio = 0.8;
	% BG_Samples_Num = 2*10^5; % 10,000.
	
	[X,Y] = Generate_DataSet(Frame_Half_Size);
	
	% Divide the set randomly into train and test sets:
	Ns = size(X,4); % Total number of samples.
	idx = randperm(Ns);
	ID_Train = idx(1:round(Train_Set_Ratio*Ns));
	ID_Test = idx(round(Train_Set_Ratio*Ns)+1:end);
	X_Train = X(:,:,:,ID_Train);
	Y_Train = Y(:,:,:,ID_Train);
	X_Test = X(:,:,:,ID_Test);
	Y_Test = Y(:,:,:,ID_Test);
	
	Options = trainingOptions('sgdm','MaxEpochs',100,'InitialLearnRate',0.0001,'ValidationData',{X_Test,Y_Test},'ValidationFrequency',10000,'ExecutionEnvironment','parallel','Plots','training-progress','Verbose',false);
	
	Layers = CNN_CCRCCRP_X3(2.*Frame_Half_Size+1);
	% [Net,y] = CNN_NoPooling(Training_Frames,Training_Classes,Test_Frames,Test_Classes);
	% [Net,y] = Simple_CNN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
	% [Net,y] = HiddenX3_CNN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size,layers);
	% [Net,y] = CascadeForwardNet_NN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
	
	My_CNN = trainNetwork(X_Train,Y_Train,Layers,Options);
	
	%{
	% Classify the Images in the Test Data and Compute Accuracy:
	B = grp2idx(classify(ConvNet,XTest))' - 1;
	A = (grp2idx(YTest))' - 1;
	plotconfusion(A,B);
	%}
end