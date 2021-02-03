function [New_DataSet,Pixels_To_Classify,Pre_Classified_Pixels] = Generate_New_DataSet(Im0,Input_Rows_Num,Input_Class)
	
	[Rows1,Cols1] = size(Im0);
	Frames_Max_Num = Rows1*Cols1;
	Frame_Half_Size = (Input_Rows_Num - 1) / 2;
	
	switch(Input_Class) % Determine the type of the neural network object.
		case 'SeriesNetwork' % 'XY'
			New_DataSet = zeros(Input_Rows_Num,Input_Rows_Num,1,Frames_Max_Num);
		case 'network' % 'Cell'.
			New_DataSet = {};
			New_DataSet(Frames_Max_Num) = {1};
	end
	
	Pixels_To_Classify = [];
	Pixels_To_Classify(Frames_Max_Num) = 0;
	T = 0;
	
	Pre_Classified_Pixels = [];
	Pre_Classified_Pixels(Frames_Max_Num) = 0;
	ptc = 0;
	
	% Set the probability of pixels in the margins regions to 0:
	Cols_STD = std(double(Im0),0,1); % A row vector of coulmns std.
	Rows_STD = std(double(Im0),0,2); % A column vector of rows std;
	
	F_Cols_Left = find(cumsum(Cols_STD)); % Find non-zero values in the cumsum vector.
	F_Cols_Right = find(cumsum(fliplr(Cols_STD))); % Find non-zero values in the cumsum vector (from end to beginning).
	Cols_Margins = [F_Cols_Left(1),F_Cols_Right(1)-1]; % The margins columns. [left,right]. The 1st values in each "find" is the first non-BG col.
	
	F_Rows_Bottom = find(cumsum(Rows_STD)); % Find non-zero values in the cumsum vector.
	F_Rows_Top = find(cumsum(flipud(Rows_STD))); % Find non-zero values in the cumsum vector (from end to beginning).
	Rows_Margins = [F_Rows_Bottom(1),F_Rows_Top(1)-1]; % The margins rows. [left,right]. The 1st values in each "find" is the first non-BG row.
	
	% Fc = find(Cols_STD == 0);
	% Fr = find(Rows_STD == 0);
	% NN_Probabilities(:,Fc) = 0; % Delete pixels in the margins regions.
	% NN_Probabilities(Fr,:) = 0; % ".
		
	% % % Make sure the Frame_Half_Size is smaller than half the image min(dimensions).
	for r=Rows_Margins(1)+Frame_Half_Size:Rows1-Rows_Margins(2)-Frame_Half_Size % For each row (without the margins).
		for c=Cols_Margins(1)+Frame_Half_Size:Cols1-Cols_Margins(2)-Frame_Half_Size % For each col (without the margins).			
			
			Frame0 = double(Im0(r-Frame_Half_Size:r+Frame_Half_Size,c-Frame_Half_Size:c+Frame_Half_Size));
			if(std(Frame0(:))) % If the sum of all pixels in the frame is > 0.
				T = T + 1;
				switch(Input_Class)
					case 'SeriesNetwork' % 'XY'
						New_DataSet(:,:,1,T) = Frame0; % 4D array.
					case 'network' % 'Cell'.
						New_DataSet{1,T} = Frame0; % Cell.
				end
				Pixels_To_Classify(T) = Rows1*(c-1)+r; % Linear index of pixel [r,c].
			else
				ptc = ptc + 1;
				Pre_Classified_Pixels(ptc) = Rows1*(c-1)+r; % Linear index of pixel [r,c].
			end
		end
	end
	%  A = reshape(num2cell(squeeze(XTest),[1,2]),1,[]); % Convert 4D array to 1D cell array.
	switch(Input_Class)
		case 'SeriesNetwork' % 'XY'
			New_DataSet(:,:,:,T+1:end) = [];
		case 'network' % 'Cell'.
			New_DataSet(T+1:end) = [];
	end
	
	% Delete the empty tails of the linear coordinates arrays:
	Pixels_To_Classify(T+1:end) = [];
	Pre_Classified_Pixels(ptc+1:end) = [];
end