function Apply_And_Save()
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat');
	
	% SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Midline\Midline_Detection_Results_Im2BW\';
	SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Midline\Midline_Detection_Results_NN\';
	
	% SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Vertices_Angles\20180911\';
	% SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Vertices_Angles\20180203_5eabe335\';
	% SaveDir = uigetdir;
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		File_Path = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		File1 = load(File_Path,'Workspace');
		Workspace = File1.Workspace;
		
		disp(f);
		disp(File_Path);
		
		% assignin('base','Workspace',Workspace);
		% return;
		
		%
		% Midline Detection:
		NN_Threshold = .65;
		[Im_Rows,Im_Cols] = size(Workspace.Workspace.Image0);
		BW = zeros(Im_Rows,Im_Cols);
		BW(find(Workspace.Workspace.NN_Probabilities >= NN_Threshold)) = 1;
		[Final_Curve,Approved] = Find_Center_Line(Workspace.Workspace.Image0,BW); % [V12,V21] = Hough_Midline_Detection(closeBW);
		
		% Save to workspace:
			Workspace.Workspace.Medial_Axis = Final_Curve;
			save(File_Path,'Workspace');
		%}
		
		%{
		% Vectices Angles:
		HF = figure(1); clf(1); set(HF,'WindowState','maximized');
		imshow(Workspace.Workspace.Image0);
		set(HF,'WindowState','maximized');
		hold on;
		Reconstruct_Vertices(Workspace.Workspace);
		
		w = waitforbuttonpress;
		switch w
			case 1 % Keyboard click.
				Workspace.Workspace.User_Input.IsGood = 0;
				title('Not Good');
			case 0 % Mouse Click
				Workspace.Workspace.User_Input.IsGood = 1;
				title('Good');
		end
		
		save(strcat(Files_List(f).folder,filesep,'Workspace.mat'),'Workspace');
		%}
		
		%
		set(gcf,'WindowState','maximized');
		F = getframe(gcf);
		[Im_Save,Map] = frame2im(F);
		imwrite(Im_Save,[SaveDir,num2str(f),'.tif']); % ,Files_List(f).name(1:end-4)
		pause(1);
		%}
		
		% assignin('base','Files_List',Files_List);
		% k = strfind(Files_List(f).folder,'\');
		% FileName = Files_List(f).folder(k(end)+1:end);
		% saveas(gcf,strcat(SaveDir,filesep,FileName),'tiffn'); % Save figure as image.
	end
end