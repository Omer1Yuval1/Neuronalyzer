function [Training_Frames,Training_Classes] = Generate_Training_Set_XY(Frame_Half_Size,BG_Samples_Num)
	
	D = 2*Frame_Half_Size + 1;
	
	TrainingSet_MaxSize = 50*10^6;
	TrainingSet_MaxSize0 = 10^6;
	Min_Num_of_Neuron_Pixels = 0;
	
	Training_Frames = zeros(D,D,1,TrainingSet_MaxSize);
	Training_Classes = zeros(2,TrainingSet_MaxSize) = 0; %%%%%%%%%%%%%%%%%%
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Dir_Files_List = dir(Dir1); % List of files names.
	Dir_Files_List(find([Dir_Files_List.isdir])) = []; % ".
	
	T = 0;
	
	for i=1:length(Dir_Files_List) % For each file.
		
		Training_Frames0 = {};
		Training_Frames0(TrainingSet_MaxSize0) = {1};
		Training_Classes0 = [];
		Training_Classes0(2,TrainingSet_MaxSize0) = 0;
		T0 = 0;
		
		File1 = load(strcat(Dir1,filesep,Dir_Files_List(i).name)); % Load the file.
		% assignin('base','Workspace1',File1.Workspace1);
		
		Im_Trace = Reconstruct_Trace_Full(File1.Workspace1,0); % "0" = Do not show the image.
		[Rows1,Cols1] = size(Im_Trace);
		
		% % % Make sure the Frame_Half_Size is smaller than half the image min(dimensions).
		for r=1+Frame_Half_Size:Rows1-Frame_Half_Size % For each row (without the margins).
			for c=1+Frame_Half_Size:Cols1-Frame_Half_Size % For each col (without the margins).			
				
				Frame0 = double(File1.Workspace1.Image0(r-Frame_Half_Size:r+Frame_Half_Size,c-Frame_Half_Size:c+Frame_Half_Size));
				if(sum(Frame0(:))) % If the sum of all pixels in the frame is > 0.
				% if(length(find(Im_Trace(r-Frame_Half_Size:r+Frame_Half_Size,c-Frame_Half_Size:c+Frame_Half_Size) == 1)) ...
				% 	>= Min_Num_of_Neuron_Pixels) % At least one neuron pixel (=1) in the BW trace image.	
					T0 = T0 + 1;
					Training_Frames0{1,T0} = Frame0; % assignin('base','Frame0',Frame0);
					
					if(Im_Trace(r,c)) % If the central pixel is 1.
						Training_Classes0(:,T0) = [0 ; 1];
					else % If the central pixel is 0.
						Training_Classes0(:,T0) = [1 ; 0];
					end
				end
			end
		end
		Training_Frames0(T0+1:end) = [];
		Training_Classes0(:,T0+1:end) = [];
		
		F = find(Training_Classes0(1,:) == 1); % Find background samples.
		I = datasample(F,length(F) - min(length(F),BG_Samples_Num),'Replace',false);
		Training_Frames0(I) = [];
		Training_Classes0(:,I) = [];
		
		L = length(Training_Frames0);
		Training_Frames(T+1:T+L) = Training_Frames0;
		Training_Classes(:,T+1:T+L) = Training_Classes0;
		T = T + L;
	end
	
	Training_Frames(T+1:end) = [];
	Training_Classes(:,T+1:end) = [];
end