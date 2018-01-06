function [Data_Frames,Data_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols)
	
	DataSet_MaxSize = 10^6;
	DataSet_MaxSize0 = 10^5;
	% Min_Num_of_Neuron_Pixels = 0;
	
	switch(XY_Cell_Cols)
		case 1
			Data_Frames = zeros(2*Frame_Half_Size+1,2*Frame_Half_Size+1,1,DataSet_MaxSize);
		case 2
			Data_Frames = {};
			Data_Frames(DataSet_MaxSize) = {1};
	end
	Data_Classes = []; % tTrain.
	Data_Classes(2,DataSet_MaxSize) = 0;
	
	Dir1 = uigetdir; % Let the user choose a directory.
	if(Image_MAT == 1)
		Source_Files_List = dir([Dir1,'\Source']); % List of source files.
		Annotated_Files_List = dir([Dir1,'\Annotated']); % List of annotated files.
		Source_Files_List(find([Source_Files_List.isdir])) = []; % ".
		Annotated_Files_List(find([Annotated_Files_List.isdir])) = []; % ".
	elseif(Image_MAT == 2)
		Source_Files_List = dir(Dir1); % List of files names.
		Source_Files_List(find([Source_Files_List.isdir])) = []; % ".
	end
	
	T = 0;
	
	for i=1:length(Source_Files_List) % For each file.
		
		switch(XY_Cell_Cols)
			case 1
				Data_Frames0 = zeros(2*Frame_Half_Size+1,2*Frame_Half_Size+1,1,DataSet_MaxSize0);
			case 2
				Data_Frames0 = {};
				Data_Frames0(DataSet_MaxSize0) = {1};
		end
		Data_Classes0 = [];
		Data_Classes0(2,DataSet_MaxSize0) = 0;
		T0 = 0;
		
		if(Image_MAT == 1)
			Im_Source = imread([Dir1,filesep,'Source',filesep,Source_Files_List(i).name]);
			Im_Annotated = imread([Dir1,filesep,'Annotated',filesep,Annotated_Files_List(i).name]);
		elseif(Image_MAT == 2)
			Im_Annotated = load(strcat(Dir1,filesep,Source_Files_List(i).name)); % Load the file.
			Im_Source = Im_Annotated.Workspace1.Image0;
			Im_Annotated = Reconstruct_TraceBW_NN_Old(Im_Annotated.Workspace1,0); % "0" = Do not show the image.			
		end
		
		[Rows1,Cols1] = size(Im_Annotated);
		
		% % % Make sure the Frame_Half_Size is smaller than half the image min(dimensions).
		for r=1+Frame_Half_Size:Rows1-Frame_Half_Size % For each row (without the margins).
			for c=1+Frame_Half_Size:Cols1-Frame_Half_Size % For each col (without the margins).			
				
				Frame0 = double(Im_Source(r-Frame_Half_Size:r+Frame_Half_Size,c-Frame_Half_Size:c+Frame_Half_Size));
				FrameBW = (Im_Annotated(r-Frame_Half_Size:r+Frame_Half_Size,c-Frame_Half_Size:c+Frame_Half_Size));
				if(std(Frame0(:))) % If the std of all pixels in the frame > 0.
					if(Im_Annotated(r,c)) % If the central pixel is 1 (= neuron).
						for Roti=[0,90,180,270] % Rotate 3 times in 90 degrees (both the original and the mirror image).
							T0 = T0 + 1;
							switch(XY_Cell_Cols)
								case 1
									Data_Frames0(:,:,1,T0) = imrotate(Frame0,Roti); % 4D array.
								case 2
									Data_Frames0{1,T0} = imrotate(Frame0,Roti);
							end
							Data_Classes0(:,T0) = [0 ; 1];
							
							T0 = T0 + 1;
							switch(XY_Cell_Cols)
								case 1
									Data_Frames0(:,:,1,T0) = imrotate(fliplr(Frame0),Roti); % 4D array.
								case 2
									Data_Frames0{1,T0} = imrotate(fliplr(Frame0),Roti);
							end
							Data_Classes0(:,T0) = [0 ; 1];
						end
					elseif(length(find(FrameBW))) % If the central pixel is 0 (non-neuron pixel) && At least one neuron pixel.
						% assignin('base','FrameBW',FrameBW);
						T0 = T0 + 1;
						switch(XY_Cell_Cols)
							case 1
								Data_Frames0(:,:,1,T0) = Frame0; % 4D array.
							case 2
								Data_Frames0{1,T0} = Frame0; % assignin('base','Frame0',Frame0);
						end
						Data_Classes0(:,T0) = [1 ; 0];
					end
				end
			end
		end
		
		% assignin('base','Data_Classes0',Data_Classes0);
		% TODO: mark BG frames based on their neighborhood and use this to choose the subset.
		F = find(Data_Classes0(1,:) == 1); % Find background samples.
		I = datasample(F,length(F) - min(length(F),BG_Samples_Num),'Replace',false); % Choose BG_Samples_Num randomally.
		Data_Classes0(:,T0+1:end) = [];
		Data_Classes0(:,I) = [];
		
		L = size(Data_Classes0,2);
		switch(XY_Cell_Cols)
			case 1
				Data_Frames0(:,:,:,T0+1:end) = [];
				Data_Frames0(:,:,:,I) = [];
				Data_Frames(:,:,1,T+1:T+L) = Data_Frames0;
			case 2
				Data_Frames0(T0+1:end) = [];
				Data_Frames0(I) = [];
				Data_Frames(T+1:T+L) = Data_Frames0;
		end
		Data_Classes(:,T+1:T+L) = Data_Classes0;
		T = T + L;
	end
	
	Data_Classes(:,T+1:end) = [];
	switch(XY_Cell_Cols)
		case 1
			Data_Frames(:,:,:,T+1:end) = [];
			Data_Classes = categorical(Data_Classes(2,:)');
		case 2
			Data_Frames(T+1:end) = [];
	end
	% assignin('base','Data_Classes2',Data_Classes);
end