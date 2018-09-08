function [Nr,Nc] = Find_Blank_Boundaries(Im)
	
	[Sr,Sc,Sz] = size(Im);
	
	Cols_STD = std(double(Im),0,1); % A row of coulmns std
	Rows_STD = std(double(Im),0,2); % A column of rows std.
	
	Fc = find(Cols_STD > 0); % Find non-zero std columns.
	Nc = [max(1,Fc(1)) , min(Sc,Fc(end))]; % The first columns (from left and right) that contain non-std-zero content.
	
	Fr = find(Rows_STD > 0); % Find non-zero std rows.
	Nr = [max(1,Fr(1)) , min(Sr,Fr(end))]; % The first rows (from bottom and top) that contain non-std-zero content.
	
end