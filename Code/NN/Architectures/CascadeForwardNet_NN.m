function [deepnet,y] = CascadeForwardNet_NN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size)
	
	rng('default');
	
	Net = cascadeforwardnet([10,10,10]);
	
	% Get the number of pixels in each image
	imageWidth = 2*Frame_Half_Size + 1;
	imageHeight = 2*Frame_Half_Size + 1;
	inputSize = imageWidth*imageHeight;
	
	% Turn the test images into vectors and put them in a matrix
	xTest = zeros(inputSize,numel(Test_Frames));
	for i = 1:numel(Test_Frames)
		xTest(:,i) = Test_Frames{i}(:);
	end
	
	% Turn the training images into vectors and put them in a matrix
	xTrain = zeros(inputSize,numel(Training_Frames));
	for i = 1:numel(Training_Frames)
		xTrain(:,i) = Training_Frames{i}(:);
	end
	
	% Perform fine tuning
	Net = train(Net,xTrain,Training_Classes,'useParallel','yes','useGPU','yes','showResources','yes');
	
	y = Net(xTest);
	plotconfusion(Test_Classes,y);
	
end