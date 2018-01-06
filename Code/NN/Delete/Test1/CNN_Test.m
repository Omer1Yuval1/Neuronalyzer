function y = CNN_Test(Training_Frames,Training_Classes,Testing_Frames,Testing_Classes,Frame_Half_Size)
	
	% Display some of the training images
	% clf
	% for i = 1:20
		% subplot(4,5,i);
		% imshow(Training_Frames{i});
	% end
	
	rng('default');
	hiddenSize1 = 100;
	
	autoenc1 = trainAutoencoder(Training_Frames,hiddenSize1,'MaxEpochs',400,'L2WeightRegularization',0.004, ...
		'SparsityRegularization',4,'SparsityProportion',0.15,'ScaleData', false);
	% display(3);
	% view(autoenc1);
	
	% figure();
	% plotWeights(autoenc1);
	
	feat1 = encode(autoenc1,Training_Frames);
	hiddenSize2 = 50;
	autoenc2 = trainAutoencoder(feat1,hiddenSize2,'MaxEpochs',100,'L2WeightRegularization',0.002, ...
		'SparsityRegularization',4,'SparsityProportion',0.1,'ScaleData', false);
	% view(autoenc2);
	
	feat2 = encode(autoenc2,feat1);
	softnet = trainSoftmaxLayer(feat2,Training_Classes,'MaxEpochs',400);
	% view(softnet);
	
	% view(autoenc1);
	% view(autoenc2);
	% view(softnet);
	
	deepnet = stack(autoenc1,autoenc2,softnet);
	% view(deepnet);
	
	% Get the number of pixels in each image
	imageWidth = 2*Frame_Half_Size + 1;
	imageHeight = 2*Frame_Half_Size + 1;
	inputSize = imageWidth*imageHeight;
	
	% Turn the test images into vectors and put them in a matrix
	xTest = zeros(inputSize,numel(Testing_Frames));
	for i = 1:numel(Testing_Frames)
		xTest(:,i) = Testing_Frames{i}(:);
	end
	
	y = deepnet(xTest);
	plotconfusion(Testing_Classes,y);
	
	% Turn the training images into vectors and put them in a matrix
	xTrain = zeros(inputSize,numel(Training_Frames));
	for i = 1:numel(Training_Frames)
		xTrain(:,i) = Training_Frames{i}(:);
	end
	
	% Perform fine tuning
	deepnet = train(deepnet,xTrain,Training_Classes);
	
	y = deepnet(xTest);
	plotconfusion(Testing_Classes,y);
	
end