function Apply_And_Save()
	
	Dir1 = uigetdir; % Let the user choose a directory.
	Files_List = List_All_Files(Dir1,'mat');
	
	SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Midline\Midline_Detection_Results_Im2BW\';
	% SaveDir = uigetdir;
	
	for f=1:numel(Files_List) % For each file (image\neuron).
		
		File_Path = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		File1 = load(File_Path,'Workspace');
		Workspace = File1.Workspace;
		
		% assignin('base','Workspace',Workspace);
		% return;
		
		if(1) % Simple binarization.
			[V12,V21,BW,closeBW] = Find_Center_Line(Workspace.Workspace.Image0);
		else % NN.
			NN_Threshold = .65;
			[Im_Rows,Im_Cols] = size(Workspace.Workspace.Image0);
			BW = zeros(Im_Rows,Im_Cols);
			BW(find(Workspace.Workspace.NN_Probabilities >= NN_Threshold)) = 1;
			
			se = strel('disk',90);
			closeBW = imclose(BW,se);
			
			[V12,V21,~,~] = Find_Center_Line(Workspace.Workspace.Image0,closeBW);
		end
		
		figure(1);
		clf(1);
		subplot(1,3,1);
		imshow(Workspace.Workspace.Image0);
		if(~isempty(V12) && ~isempty(V21))
			hold on; scatter(V12(:,1),V12(:,2),10,jet(size(V12,1)),'filled'); % plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);
			hold on; scatter(V21(:,1),V21(:,2),10,jet(size(V21,1)),'filled'); % plot(V21(:,1),V21(:,2),'.g','MarkerSize',20);
		end
		
		subplot(1,3,2);
		imshow(BW);
		
		subplot(1,3,3);
		imshow(closeBW);
		if(~isempty(V12) && ~isempty(V21))
			hold on; scatter(V12(:,1),V12(:,2),10,jet(size(V12,1)),'filled'); % plot(V12(:,1),V12(:,2),'.g','MarkerSize',20);
			hold on; scatter(V21(:,1),V21(:,2),10,jet(size(V21,1)),'filled'); % plot(V21(:,1),V21(:,2),'.g','MarkerSize',20);
		end
		
		F = getframe(gcf);
		[Im_Save,Map] = frame2im(F);
		
		% assignin('base','Files_List',Files_List);
		% k = strfind(Files_List(f).folder,'\');
		% FileName = Files_List(f).folder(k(end)+1:end);
		% saveas(gcf,strcat(SaveDir,filesep,FileName),'tiffn'); % Save figure as image.
		
		imwrite(Im_Save,[SaveDir,num2str(f),'.tif']);
		
		disp(f);
		disp(File_Path);
	end
end