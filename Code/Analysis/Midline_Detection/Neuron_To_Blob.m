function ImB = Neuron_To_Blob(Im)
	
	BW_Threshold = 0.5;
	
	Im_BW = imbinarize(Im,BW_Threshold);
	[R,C] = size(Im_BW);
	
	se = strel('disk',20);
	ImD1 = imdilate(Im_BW,se);
	ImB = imdilate(ImD1,se); % The Blob.
end