function Generate_Files_DataSet(Frame_Half_Size,Dir2)
	
	% The user chooses a directory containing MAT files containing grayscale image (under field "Image0".
	% For each pixel within each image it saves a frame as a .tif file and names it 1 or 0 (1 if it's a neuron pixel, 0 if it's a BG pixel).
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Dir_Files_List = dir(Dir1); % List of files names.
	Dir_Files_List(find([Dir_Files_List.isdir])) = []; % ".
	
	for i=1:length(Dir_Files_List) % For each file.
		File1 = load(strcat(Dir1,filesep,Dir_Files_List(i).name)); % Load the file.
		% assignin('base','Workspace1',File1.Workspace1);
		
		Im_Trace = Reconstruct_Trace_Full(File1.Workspace1,0); % "0" = Do not show the image.
		[Rows1,Cols1] = size(Im_Trace);
		
		% % % Make sure the Frame_Half_Size is smaller than half the image dimension.
		for r=1+Frame_Half_Size:Rows1-Frame_Half_Size % For each row (without the margins).
			for c=1+Frame_Half_Size:Cols1-Frame_Half_Size % For each col (without the margins).			
				
				Frame0 = double(File1.Workspace1.Image0(r-Frame_Half_Size:r+Frame_Half_Size,c-Frame_Half_Size:c+Frame_Half_Size));
				if(sum(Frame0(:))) % If the sum of all pixels in the frame is > 0.
					
					% Save the frame as .tif in folder 1 or 0:
					if(Im_Trace(r,c)) % If the central pixel is 1 (it's a neuron pixel).
						imwrite(Frame0,[Dir2,'1\Im','_',num2str(i),'_',num2str(r),'_',num2str(c),'.tif']);
					else % If the central pixel is 0 (it's a non-neuron pixel).
						imwrite(Frame0,[Dir2,'0\Im','_',num2str(i),'_',num2str(r),'_',num2str(c),'.tif']);
					end
					
				end
			end
		end
	end
	
end