function Extend_Margins_Multiple()
	
	R = 0.2; % Ratio of rows # and cols # for border extension.
	
	Path1 = uigetdir; % Let the user to manually choose a directory.
	
	Files_List = List_All_Files(Path1,'tif'); % List all .tif files in this directory (including sub-directories).
	
	for f=1:numel(Files_List)
		
		Im = imread([Files_List(f).folder,filesep,Files_List(f).name]); % Read image.
		
		% ImP = Im;
		ImP = Extend_Margins(Im,R); % Pad image (extend borders).
		
		
		% Add date and strain to the filename:
		%% Date1 = Files_List(f).folder(1:10);
		Strain1 = 'BP1028'; % Files_List(f).folder(end-5:end);
		imwrite(ImP,[Files_List(f).folder,filesep,Files_List(f).name(1:end-4),'_',Strain1,'.tif']); % Make sure the strain name is at the end of the folder name.
		
		delete([Files_List(f).folder,filesep,Files_List(f).name]);
		
		disp(f);
		
		
	end	
	
end