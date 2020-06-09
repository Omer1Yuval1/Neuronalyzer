function [ImB,XY] = Neuron_To_Blob(Im)
	
	BW_Threshold = 0.5;
	
	% Im_BW = imbinarize(Im,BW_Threshold);
    Im_BW = Im;
    
	Im_BW = bwareafilt(Im_BW,[5,inf]);
	
	se = strel('disk',20);
	ImD1 = imdilate(Im_BW,se);
	ImB = imdilate(ImD1,se); % The Blob.
    ImB = imclose(ImB,strel('disk',20));
	
    Im_Perim = bwperim(ImB);
    Im_Perim(:,1) = 0;
	[Y,X] = find(Im_Perim);
    f = find(X == min(X));
    XY = Order_Connected_Pixels(Im_Perim,[X(f(1)),Y(f(1))]); % ,[X(f(2)),Y(f(2))]); % [Nx2].
	
	XY = cell2mat(smoothn(num2cell(XY,1),5.*10^6)); % Smoothing.
	% hold on; scatter(XY(:,1),XY(:,2),10,jet(size(XY,1)),'filled');
end