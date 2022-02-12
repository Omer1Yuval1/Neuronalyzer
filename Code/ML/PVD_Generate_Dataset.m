function PVD_Generate_Dataset(Im_In,Im_Out,S)
	
	% This function generates a training set made of input-output pairs of PVD patches from annotated grayscale images.
	
	% Note:
		% To generate samples with an even number of rows and columns, an asymmetric x-range and y-range are used around each pixel (-d:(d-1)).
		% Input and output images must be uint8.
			% This is because input images are grayscale, and will be saved as uint8 anyway.
			% If output images are logical (for example), they will be saved as logical and will have a different scale compared to the output.
		
	rng('default'); % Reset the random seed.
	
	if(nargin < 3 || isempty(S))
		S = PVD_CNN_Params();
	end
	
	if(nargin < 2)
		File_List = dir([S.Projects_Path,'Project_WT_x11.mat']);
		N_Files = numel(File_List);
	else
		N_Files = 1;
		N_Images = length(Im_In);
	end
	
	T_Set = table('Size',[S.Ns,2],'VariableTypes',{'cell','cell'},'VariableNames',{'Input','Output'});
	t = 0;
	Source_Image_Index = 0;
	
	for f=1:N_Files % For each image (or project file).
		
		if(nargin < 2)
			% Load file:
			P.Data = load([File_List(f).folder,filesep,File_List(f).name]);
			P.Data = P.Data.Project;
			N_Images = numel(P.Data);
		end
		
		for p=1:N_Images % For each project within file f.
			
			Source_Image_Index = Source_Image_Index + 1;
			
			% Get raw and annotated images:
			if(nargin < 2)
				Im = S.Input_Image_Func(P.Data(p).Info.Files.Raw_Image(:,:,1)); % Raw image.
				Im_BW = P.Data(p).Info.Files.Binary_Image(:,:,1); % Binary image.
				ID = P.Data(p).Info.Experiment(1).Identifier;
			else
				Im = Im_In{p}; % Raw image.
				Im_BW = Im_Out{p}; % Binary image.
				ID = p;
			end
			disp(ID);
			
			Im_Size = size(Im);
			
			% Force uint8 format for both the input and output:
			if(~isa(Im,'uint8')) % The input image is double and hence will be saved as uint8 anyway. Leaving it here as double to be able to use the std function later.
				Im = im2uint8(Im);
			end
			
			if(~isa(Im_BW,'uint8'))
				Im_BW = im2uint8(Im_BW);
			end
			
			% Get pixel indices and randomize their order:
			Xr = S.Full_Image_Margin:(Im_Size(2)-S.Full_Image_Margin); % X range.
			Yr = S.Full_Image_Margin:(Im_Size(1)-S.Full_Image_Margin); % Y range.
			XYr = combvec(Xr,Yr); % All pixel coordinates.
			XYr = XYr(:,randperm(size(XYr,2))); % Randomize pixels order.
			
			tt = 0; % Image-specific sample counter (counts the number of pixels used to generate samples).
			for i=1:size(XYr,2) % For each pixel.
				
				% Generate sample:
				Ixy = XYr(:,i) + (-S.Input_Half_Size:(S.Input_Half_Size-1)); % [2 x Np].
				In = Im(Ixy(2,:),Ixy(1,:));
				Out = Im_BW(Ixy(2,:),Ixy(1,:));
				
				if(S.Sample_In_Func(im2double(In)) && (S.Sample_Out_Func(Out) || all(randi([0,1],1,4)))) % Using randi to include some BG samples (no annotated neuron pixels).
					t = t + 1; % Global sample index.
					tt = tt + 1; % Image-specific sample index.
					
					% Apply random enhancement:
					% In = im2uint8(rescale(In,0,1,'InputMin',randi(S.Pixel_Limits(1,:)),'InputMax',randi(S.Pixel_Limits(2,:))));
					
					% Apply random rotation:
					Ri = randi(length(S.Rotation_Vector));
					In = imrotate(In,S.Rotation_Vector(Ri));
					Out = imrotate(Out,S.Rotation_Vector(Ri));
					
					% Apply random reflection
					Ri = randi(length(S.Reflection_Vector));
					In = S.Reflection_Vector{Ri}(In);
					Out = S.Reflection_Vector{Ri}(Out);
					
					% Save sample:
					File_Name = [num2str(ID),'-',num2str(XYr(1,i)),'-',num2str(XYr(2,i)),S.Image_Format]; % [image_identifier - x - y . tif].
					
					imwrite(In,[S.Save_Dir_Input,File_Name],'Compression','none'); % Save input image.
					imwrite(Out,[S.Save_Dir_Output,File_Name],'Compression','none'); % Save output image.
					
					T_Set.Input{t} = [S.Train_Dir_Input,File_Name];
					T_Set.Output{t} = [S.Train_Dir_Output,File_Name];
					T_Set.Source_Image_Index{t} = Source_Image_Index;
					
					% Validate:
					% H = figure; subplot(1,2,1); imshow(In); subplot(1,2,2); imshow(Out); waitforbuttonpress; close(H);
				end
				
				if(tt == S.Samples_Per_Image)
					break;
				end
			end
		end
	end
	
	T_Set = T_Set(1:t,:);
	save([S.Main_Dir,'T_Set_1'],'T_Set');
	
end