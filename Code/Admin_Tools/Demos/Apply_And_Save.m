function Apply_And_Save()
	
	p = 1;
	
	% Input_Dir = uigetdir; % Let the user choose a directory.
	Input_Dir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\DEG_for_Menorah_analyser_Filtered_Format_Names';
    Files_List = List_All_Files(Input_Dir,'mat');
	
	% SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Midline\Midline_Detection_Results_Im2BW\';
	% SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\Midline\Midline_Detection_Results_NN\';
	
	SaveDir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\PVD Images\Sharon\Results_Demos\';
	% SaveDir = uigetdir;
	
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	Curvature_Min_Max = [0,0.4];
	Medial_Dist_Range = [0,60];
	
	for f=114:numel(Files_List) % For each file (image\neuron).
		
		File_Path = [Files_List(f).folder,filesep,Files_List(f).name]; % Full path + name of the current file.
		File1 = load(File_Path,'Workspace');
		W = File1.Workspace;
		
		disp(f);
		disp(File_Path);
		
		% assignin('base','W.Workspace',W.Workspace);
		% return;
		
		switch p
			case 1
				% Midline Detection:
				[W,Features] = Add_Features_To_All_Workspaces(W);
				NN_Threshold = .65;
				[Im_Rows,Im_Cols] = size(W.Workspace.Image0);
				BW = zeros(Im_Rows,Im_Cols);
				BW(find(W.Workspace.NN_Probabilities >= NN_Threshold)) = 1;
				[Final_Curve,Approved] = Find_Center_Line(W.Workspace.Image0,BW); % [V12,V21] = Hough_Midline_Detection(closeBW);
				
				Medial_Distances = [];
				Medial_Positions = [];
				
				if(~isempty(W.Workspace.Medial_Axis))
					for s=1:numel(W.Workspace.Segments)
						for r=1:numel(W.Workspace.Segments(s).Rectangles)
							Dm = Distance_Func(W.Workspace.Medial_Axis(:,1),W.Workspace.Medial_Axis(:,2),W.Workspace.Segments(s).Rectangles(r).X,W.Workspace.Segments(s).Rectangles(r).Y);
							f1 = find(Dm == min(Dm)); % The index of the midline point closest to the current coordinate.
							Medial_Distances(end+1) = Dm(f1(1)); % Minimal distance (in pixels) of the vertex center of the medial axis (= distance along the Y' axis).
							Medial_Positions(end+1) = f1(1); % The index of the closest midline point.
						end
					end
					
					subplot(2,3,4);
						imshow(W.Workspace.Image0);
						hold on;
						Reconstruct_Curvature(W.Workspace,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),1);
					subplot(2,3,5);
						histogram(Medial_Distances);
						title('Medial Distance');
						hold on;
						[yy,edges] = histcounts(Medial_Distances); % ,'Normalization','pdf'
						xx = (edges(1:end-1) + edges(2:end)) ./ 2;
						findpeaks(yy,xx,'SortStr','descend','NPeaks',2);
						
					subplot(2,3,6);
						histogram(Medial_Positions);
						title('Medial Position');
				end
					
				% waitforbuttonpress;
				set(gcf,'WindowState','maximized'); F = getframe(gcf); [Im_Save,~] = frame2im(F);
				SaveDir_f = [SaveDir,'Midline\Midline_Detection_Results_NN',filesep,num2str(f),'.tif'];
				imwrite(Im_Save,SaveDir_f);
				%}
				
				% Save to workspace:
				%{
				W.Workspace.Medial_Axis = Final_Curve;
				save(File_Path,'Workspace');
				%}
			case 2 % Vertices Angles.
				[W.Workspace,~] = Add_Features_To_All_Workspaces(W.Workspace);
				HF = figure(1); clf(1); % set(HF,'WindowState','maximized');
				imshow(W.Workspace.Image0);
				set(HF,'WindowState','maximized');
				hold on;
				Reconstruct_Vertices(W.Workspace,1);
			case 3 % Curvature Heatmap.
				figure(1); clf(1);
                imshow(W.Workspace.Image0);
				hold on;
				Reconstruct_Curvature(W.Workspace,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),1);
				
				set(gcf,'WindowState','maximized');
				F = getframe(gca);
				[Im_Save,~] = frame2im(F);
				
				s1 = strfind(Files_List(f).folder,'_Names\');
                s2 = strfind(Files_List(f).folder,'\My_Neuronalizer_Projects');
				S = File_Path(s1+7:s2-1);
				s3 = strfind(S,filesep);
				Genotype = S(1:s3(1)-1);
				Grouping = S(s3(end)+1:end);
				
				SaveDir_f = [SaveDir,'Curvature',filesep,Genotype,filesep,Grouping,filesep,num2str(f),'.tif'];
				imwrite(Im_Save,SaveDir_f);
				% imwrite(Im_Save,[SaveDir,num2str(f),'.bmp'],'bmp'); % ,Files_List(f).name(1:end-4)
		end
		
		% Annotate images either as good or bad:
		%{
		w = waitforbuttonpress;
		switch w
			case 1 % Keyboard click.
				W.Workspace.User_Input.IsGood = 0;
				title('Not Good');
			case 0 % Mouse Click
				W.Workspace.User_Input.IsGood = 1;
				title('Good');
		end
		
		% save(strcat(Files_List(f).folder,filesep,'Workspace.mat'),'Workspace');
		
		%}
		
		%{
		set(gcf,'WindowState','maximized');
		F = getframe(gcf);
		[Im_Save,Map] = frame2im(F);
		savefig(gcf,[SaveDir,num2str(f),'.fig']);
		% imwrite(Im_Save,[SaveDir,num2str(f),'.bmp'],'bmp'); % ,Files_List(f).name(1:end-4)
		pause(1);
		%}
		
		% assignin('base','Files_List',Files_List);
		% k = strfind(Files_List(f).folder,'\');
		% FileName = Files_List(f).folder(k(end)+1:end);
		% saveas(gcf,strcat(SaveDir,filesep,FileName),'tiffn'); % Save figure as image.
	end
end