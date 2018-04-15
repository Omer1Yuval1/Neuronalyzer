function NN_MAT_2_tif
	
	Target_Dir = 'D:\Omer\Neuronalizer\Resources\NN\Annotations\';	
	
	Dir1 = uigetdir; % Let the user choose a directory.
	
	Source_Files_List = dir(Dir1); % List of files names.
	Source_Files_List(find([Source_Files_List.isdir])) = []; % ".
	
	for i=1:length(Source_Files_List) % For each file.
		disp([num2str(i),'\',num2str(length(Source_Files_List))]);
		
        Im_Annotated = load(strcat(Dir1,filesep,Source_Files_List(i).name)); % Load the file.
		Im_Annotated.Workspace1.Image0 = Im_Annotated.Workspace1.Image0(:,:,1); % Taking the 1st channel in case it's a NxMx3 image.
		
		Im_Source = Im_Annotated.Workspace1.Image0;
		Im_Annotated = Reconstruct_TraceBW_NN_Old(Im_Annotated.Workspace1,0); % "0" = Do not show the image.
		
		imwrite(Im_Source,[Target_Dir,Source_Files_List(i).name(1:end-4),'_Source.tif']);
		imwrite(Im_Annotated,[Target_Dir,Source_Files_List(i).name(1:end-4),'_Annotated.tif']);
	end
	
	
	
end