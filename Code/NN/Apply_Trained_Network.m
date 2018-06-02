function NN_Probabilities = Apply_Trained_Network(Net,Im0)
	
	% This function gets a trained neural network and a grayscale image and produces a matrix of probabilities.
	% Each pixel in the output matrix contains the probability of the corresponding pixel in the grayscale image of being
	% a neuron pixel or a non-neuron pixel.
	
	% profile on;
	
	Im0 = Im0(:,:,1);
	[R0,C0] = size(Im0);
	NN_Probabilities = zeros(R0,C0);
	
	% Frame_Half_Size = 10; % 10=21X21 ; 12=25X25.
	switch(class(Net)) % Number of pixels in each frame.
		case 'SeriesNetwork' % 'XY'.
			InputSize = (Net.Layers(1,1).InputSize(1))^2;
		case 'network' % 'Cell'.
			InputSize = Net.inputs{1,1}.size;
	end
	
	% Convert the image to a format that is readable by the classification function:
	[New_DataSet,Pixels_To_Classify,Pre_Classified_Pixels] = Generate_New_DataSet(Im0,sqrt(InputSize),class(Net));
	
	switch(class(Net))
		case 'SeriesNetwork' % 'XY'.
			% New_DataSet_Cols = reshape(New_DataSet,2*Frame_Half_Size+1,[]);
			[Ypred,Probabilities] = classify(Net,New_DataSet);
			Probabilities = Probabilities';
		case 'network' % 'Cell'. Turn the test images into vectors and put them in a matrix.
			New_DataSet_Cols = zeros(InputSize,numel(New_DataSet));
			for i = 1:numel(New_DataSet)
				New_DataSet_Cols(:,i) = New_DataSet{i}(:);
			end
			Probabilities = Net(New_DataSet_Cols);
		% otherwise % cols
	end
	
	NN_Probabilities(Pixels_To_Classify) = Probabilities(2,:); % Second row represents the probability of a pixel being a neuron-pixel.
	
	NN_Probabilities(Pre_Classified_Pixels) = 0; % Set the probability of pixels for which std=0 (in their frame) to 0.
	
	% figure; imshow(NN_Probabilities);
	
	% profile off;
	% A = profile('info');
	% profview(0,A);
end