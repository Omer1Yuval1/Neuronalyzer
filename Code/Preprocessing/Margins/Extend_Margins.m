function ImP = Extend_Margins(Im,R)
	
	% 1. Find the background peak:
	h = histogram(Im(:));
	v = h.Values; % Values;
	e = (h.BinEdges(1:end-1) + h.BinEdges(2:end))/2; % Bins centers (locations. Mean of each consecutive edges pair).	
	[Peaks1,Locs1] = findpeaks(v,e,'SortStr','descend');
	
	if(length(Peaks1))
		[Rows,Cols] = size(Im);
		Pr = ceil(R*Rows); % Rows padding.
		Pc = ceil(R*Cols); % Cols padding.
		ImP = padarray(Im,[Pr,Pc],Locs1(1));
	else
		ImP = Im;
	end
	
	% imshow(ImP);
end