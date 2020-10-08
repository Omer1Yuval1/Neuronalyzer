function index()
	
	% This is the root script for the GUI.
	% Project_H is a pointer to structure Project, defined as a class handle in Project_Class.m.
	
	close all;
	clear;
	
	folder = fileparts(which(mfilename)); % Determine where the m-file's folder is.
	cd(folder);
	addpath(genpath(pwd)); % Add to path.
	
	Project_H = Project_Class; % This creates an object of the Project_Class class.
	
	GUI_Params(Project_H);
	
	% Set_Objects(Project_H);
	Set_Objects_UI(Project_H);
	
	Set_Callbacks(Project_H);
	Project_H.GUI_Handles.Current_Step = 0;
	Project_H.GUI_Handles.Current_Project = 1;
	assignin('base','Project',Project_H);
	close(Project_H.GUI_Handles.Waitbar);
	
	function Load_Data_Func(source,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...'); % 'Indeterminate','on'. P.GUI_Handles.Waitbar = waitbar(0,'Loading...');
		
		CurrentDir = pwd;
		
		if(~isempty(source)) % If a button is used to run this callback.
			[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats,'MultiSelect','on');
		elseif(isempty(source)) % If this callback is called from "Load_Project_Func" after loading a project file.
			Selection_Index = 1;
		else
			Selection_Index = 0;
		end
		
		if(Selection_Index == 0)
			set(All_Enabled_Objects,'Enable','on');
			disp('Files not found.');
		elseif(~isempty(source))
			if(~iscell(File1))
				File1 = {File1};
			end
			P.Data(1).Info.Experiment(1).Identifier = File1{1}(1:end-4);
		end
		
		cd(CurrentDir); % Return to the main directory.
		
		if(~P.GUI_Handles.Multi_View) % single-view project. Create a project for each loaded file.
			P.GUI_Handles.View_Axes = gobjects(1);
			% P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,1]);
			if(~isempty(source)) % If data was loaded.
				for ff=1:length(File1) % For each file.
					
					P.Data(ff) = project_init(P); % Initialize project struct;
					
					[filepath,filename,ext] = fileparts(File1{ff});
					P.Data(ff).Info.Experiment(1).Identifier = filename;
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Save path to input files.
						P.Data(ff).Info.Files(1).Raw_Image{1} = [Path1,filesep,File1{ff}];
					else % Save input data explicitly.
						P.Data(ff).Info.Files(1).Raw_Image{1} = imread([Path1,filesep,File1{ff}]);
					end
					
					Label_ff = ['Project_',num2str(ff),'_',P.Data(ff).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_ff,'UserData',ff,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = ff ./ length(File1);
				end
			else % If a project file(s) was loaded.
				for pp=1:numel(P.Data) % For each project.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Validate path. If it is not found, ask the user to specify a new path and save it.
						[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files.Raw_Image{1});
						
						if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Info.Files.Raw_Image{1})) % If the path or file don't exist.
							[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats); % Ask the user to select the file.
						else
							Selection_Index = 0;
						end
						
						if(Selection_Index) % If the path should be updated.
							[filepath1,filename1,ext1] = fileparts(File1);
							if(~isequal(filename,filename1))
								warning('File name does not match the original file name.');
							end
							P.Data(pp).Info.Experiment(1).Identifier = filename1;
							P.Data(pp).Info.Files.Raw_Image{1} = [Path1,filesep,File1{1}]; % A single file for project pp.
						end
					end
					
					Label_pp = ['Project_',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = pp ./ numel(P.Data);
				end
			end
			
			% Create axes and display the image of the first project:
			% P.GUI_Handles.View_Axes(1) = axes(P.GUI_Handles.Main_Panel_1); % ,'BackgroundColor',P.GUI_Handles.BG_Color_1
			P.GUI_Handles.View_Axes(1) = uiaxes(P.GUI_Handles.Main_Panel_1,'Position',[1,1,P.GUI_Handles.Main_Panel_1.InnerPosition(3:4)],'BackgroundColor',P.GUI_Handles.BG_Color_1);
			title(P.GUI_Handles.View_Axes(1),[]);
			xlabel(P.GUI_Handles.View_Axes(1),[]);
			ylabel(P.GUI_Handles.View_Axes(1),[]);
			P.GUI_Handles.View_Axes(1).XAxis.TickLabels = {};
			P.GUI_Handles.View_Axes(1).YAxis.TickLabels = {};
			
			imshow(P.Data(1).Info.Files.Raw_Image{1},'Parent',P.GUI_Handles.View_Axes(1));
			
		else % Multi-view project.
			if(~isempty(source)) % If data was loaded, create a single project.
				P.GUI_Handles.View_Axes = gobjects(1,length(File1));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,length(File1)));
				P.Data(1) = project_init(P);
				for vv=1:length(File1) % For each view.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Save only the path of the input files.
						P.Data(1).Info.Files{vv}.Raw_Image{vv} = [Path1,filesep,File1{vv}];
					else % Save input data explicitly.
						P.Data(1).Info.Files{vv}.Raw_Image{vv} = imread([Path1,filesep,File1{vv}]);
					end
					
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
					% P.GUI_Handles.View_Axes(vv) = uiimage(P.GUI_Handles.Axes_Grid);
					
					P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					
					% continue;
					title(P.GUI_Handles.View_Axes(vv),[]);
					xlabel(P.GUI_Handles.View_Axes(vv),[]);
					ylabel(P.GUI_Handles.View_Axes(vv),[]);
					P.GUI_Handles.View_Axes(vv).XAxis.TickLabels = {};
					P.GUI_Handles.View_Axes(vv).YAxis.TickLabels = {};
					
					imshow(P.Data(1).Info.Files.Raw_Image{vv},'Parent',P.GUI_Handles.View_Axes(vv));
				end
				[filepath,filename,ext] = fileparts(File1{1});
				P.Data(1).Info.Experiment(1).Identifier = filename;
				Label_1 = ['Project_1','_',P.Data(1).Info.Experiment(1).Identifier];
				uimenu(P.GUI_Handles.Menus(1),'Text',Label_1,'UserData',1,'Callback',{@Switch_Project_Func,P});
			else % If a project file(s) was loaded.
				P.GUI_Handles.View_Axes = gobjects(1,length(P.Data(1).Info.Files.Raw_Image));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,length(P.Data(1).Files.Raw_Image)));
				for pp=1:numel(P.Data) % For each project.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Validate path. If it is not found, ask the user to specify a new path and save it.
						[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files.Raw_Image{1});
						if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Info.Files.Raw_Image{1})) % If the path or file don't exist.
							[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats,'MultiSelect','on'); % Ask the user to select the file.
						else
							Selection_Index = 0;
						end
						
						if(Selection_Index)
							[filepath1,filename1,ext1] = fileparts(File1{1});
							if(~isequal(filename,filename1))
								warning('File name does not match the original file name.');
							end
							P.Data(pp).Info.Experiment(1).Identifier = filename1;
							
							for vv=1:length(File1) % For each view.
								P.Data(pp).Info.Files{vv}.Raw_Image{vv} = [Path1,filesep,File1{vv}];
							end
						end
					end
					
					Label_pp = ['Project_',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
				end
				
				for vv=1:length(File1) % For each view.
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1); % P.GUI_Handles.View_Axes(v) = uiimage(P.GUI_Handles.Axes_Grid);
					% P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					% P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					imshow(P.Data(1).Info.Files.Raw_Image{vv},'Parent',P.GUI_Handles.View_Axes(vv));
				end
			end
		end
		
		figure(P.GUI_Handles.Main_Figure);
		
		Display_Project_Info(P);
		
		set(P.GUI_Handles.Menus(1),'UserData',1);
		set(P.GUI_Handles.Menus(1).Children(end),'Checked','on');
		
		set(P.GUI_Handles.Buttons(1),'Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		set(All_Enabled_Objects,'Enable','on');
		
		if(P.GUI_Handles.Current_Step == 0)
			P.GUI_Handles.Current_Step = 1;
			set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step+1),'Backgroundcolor',P.GUI_Handles.Step_BG_Active);
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Load_Project_Func(source,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		[File,Path,Selection_Index] = uigetfile('*.mat','MultiSelect','on');
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		if(Selection_Index == 0)
			set(All_Enabled_Objects,'Enable','on');
			return;
		end
		
		if(~iscell(File))
			File = {File};
		end
		
		figure(P.GUI_Handles.Main_Figure);
		set(P.GUI_Handles.Waitbar,'Indeterminate','off','Value',0);
		
		pp = 0;
		for ii=1:length(File) % For each loaded project file (may contain one or more projects).
			
			Loaded_File = load([Path,File{ii}]);
			
			if(isfield(Loaded_File,'Project')) % If a project struct exists for the first loaded project.
				for jj=1:numel(Loaded_File.Project) % For each project within the ii project file.
					pp = pp + 1;
					P.Data(pp) = Loaded_File.Project(pp);
					P.GUI_Handles.Waitbar.Value = jj ./ numel(Loaded_File.Project);
				end
			end
		end
		
		close(P.GUI_Handles.Waitbar);
		
		Load_Data_Func([],[],P);
		
		set(source,'Enable','on','Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		
		set(All_Enabled_Objects,'Enable','on');
		set(allchild(P.GUI_Handles.Menus(1)),'Enable','on');
	end
	
	function Step_Buttons_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		end
		
		if(~isempty(source)) % If source is [], then the function is called from somewhere else (such as "Switch_Project_Func").
			if(source.UserData > 0 && source.UserData < 7) % If not the "Back" (0) or "Next" (7) button.
				P.GUI_Handles.Current_Step = source.UserData;
			elseif(source.UserData == 0 && P.GUI_Handles.Current_Step > 1) % Go one step back.
				P.GUI_Handles.Current_Step = P.GUI_Handles.Current_Step - 1;
			elseif(source.UserData == 7 && P.GUI_Handles.Current_Step < 7) % Go one step forward.
				P.GUI_Handles.Current_Step = P.GUI_Handles.Current_Step + 1;
				
				if(P(1).GUI_Handles.Current_Step > 1)
					set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step),'Backgroundcolor',P.GUI_Handles.Step_BG_Done);
				end
				
				if(P(1).GUI_Handles.Current_Step < 7)
					set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step+1),'Backgroundcolor',P.GUI_Handles.Step_BG_Active);
				end
			end
		end
		
		switch P.GUI_Handles.Current_Step % Load step.
			case 1 % Start.
			case 2
				GUI_1_Denoise(P);
			case 3
				% Screen_3(P);
			case 4
				% Screen_4(P);
			case 5
				% Screen_5(P);
		end
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Switch_Project_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		end
		
		% profile on;
		if(~isempty(source))
			P.GUI_Handles.Current_Project = source.UserData;
			pp = P.GUI_Handles.Current_Project;
			
			set(P.GUI_Handles.Menus(1),'UserData',source.UserData);
			set(allchild(P.GUI_Handles.Menus(1)),'Checked','off');
			set(source,'Checked','on');
			
			% Display project data:
			if(~P.GUI_Handles.Multi_View) % single-view project.
				delete(allchild(P.GUI_Handles.View_Axes(1)));
				set(P.GUI_Handles.View_Axes(1),'Position',[1,1,P.GUI_Handles.Main_Panel_1.InnerPosition(3:4)]);
				
				% Update the image display (for the selected project):
				ff = find([P.GUI_Handles.Reconstruction_Menu_Handles(:).Checked] == 1,1); % Find the selected menu entry.
				Menus_Func(P.GUI_Handles.Reconstruction_Menu_Handles(ff),[],P); % Send the menu entry handle to Menus_Func, to display it again.
				% imshow(P.Data(pp).Info.Files.Raw_Image{1},'Parent',P.GUI_Handles.View_Axes(1));
				
				% TODO: just get rid of the grid and make the panel the parent.
				%{
				dx = P.GUI_Handles.Main_Panel_1.InnerPosition(3) ./ P.GUI_Handles.View_Axes.OuterPosition(3);
				dy = P.GUI_Handles.Main_Panel_1.InnerPosition(4) ./ P.GUI_Handles.View_Axes.OuterPosition(4);
				
				P.GUI_Handles.View_Axes.OuterPosition(1:2) = [1,1];
				
				if(dx < dy)
					P.GUI_Handles.View_Axes.OuterPosition(3) = dx .* P.GUI_Handles.View_Axes.OuterPosition(3);
				else
					P.GUI_Handles.View_Axes.OuterPosition(4) = dy .* P.GUI_Handles.View_Axes.OuterPosition(4);
				end
                %}
			else % Multi-view project.
				for vv=1:length(File1) % For each view.
					imshow(P.Data(pp).Info.Files.Raw_Image{vv},'Parent',P.GUI_Handles.View_Axes(vv));
				end
			end
			
			Display_Project_Info(P);
		end
		
		Step_Buttons_Func([],[],P);
		
		drawnow;
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
		
		% profile off; profile viewer;
	end
	
	function Display_Project_Info(P)
		
		% temporary fix: Data is copied and than copied back to the handle class to avoid repetitive reading of the class.
		
		pp = P.GUI_Handles.Current_Project;
		
		for tt=1:length(P.GUI_Handles.Info_Fields_List) % For each menu.
			FF = fields(P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt}));
			Data = P.GUI_Handles.Info_Tables(tt).Data;
			Info_tt = P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt});
			for ii=1:length(FF) % For each field in the experiment struct.
				Data{ii,1} = FF{ii}; % Field name.
				Data{ii,2} = Info_tt(1).(FF{ii}); % Value.
				Data{ii,3} = Info_tt(2).(FF{ii}); % Unit.
				
				% P.GUI_Handles.Info_Tables(tt).Data{ii,1} = FF{ii}; % Field name.
				% P.GUI_Handles.Info_Tables(tt).Data{ii,2} = P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt})(1).(FF{ii}); % Value.
				% P.GUI_Handles.Info_Tables(tt).Data{ii,3} = P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt})(2).(FF{ii}); % Unit.
			end
			P.GUI_Handles.Info_Tables(tt).Data = Data;
		end
		
	end
	
	function Update_Info_Func(source,event,P)
		pp = P.GUI_Handles.Current_Project;
		
		tt = source.UserData; % Table index.
		ff = P.GUI_Handles.Info_Fields_List{tt}; % Corresponding field name in P(pp).Data.Info.
		rr = event.Indices(1); % Table rows correspond to struct fields.
		cc = event.Indices(2); % Second column is the value and the third is the unit. First column is read-only (field name).
		FF = fields(P.Data(pp).Info.(ff));
		
		P.Data(pp).Info.(ff)(cc-1).(FF{rr}) = event.NewData;
	end
	
	function Menus_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
		end
		pp = P.GUI_Handles.Current_Project;
		
		% profile on;
		switch(source.UserData)
		case 2
			set(P.GUI_Handles.Reconstruction_Menu_Handles(:),'Checked','off');
			set(source,'Checked','on');
			Display_Reconstruction(P,P.Data(pp),source.Label);
		case 3
		
		end
		% profile off; profile viewer;
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Denoise_Image_Func(source,event,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Denoising images...'); % ,'Indeterminate','on'
		
		CNN = load('My_CNN_13.mat');
		CNN = CNN.My_CNN;
		
		selection = uiconfirm(P.GUI_Handles.Main_Figure,'Overwrite existing binary images?','Warning','Icon','question','Options',{'Overwrite','Keep existing binary images'});
		switch(selection)
		case 'Overwrite'
			Overwrite = 1;
		case 'Keep existing binary images'
			Overwrite = 0;
		end
		
		for pp=1:numel(P.Data)
			
			P.GUI_Handles.Waitbar.Value = pp ./ numel(P.Data);
			
			if(Overwrite || (~isfield(P.Data(pp).Info.Files,'Binary_Image') || isempty(P.Data(pp).Info.Files.Binary_Image{1})) ) % If a binary image is missing or if the user specified to overwrite existing images.
				[Im_Rows,Im_Cols] = size(P.Data(pp).Info.Files.Raw_Image{1});
				
				CB_BW_Threshold = P.Data(pp).Parameters.Cell_Body.BW_Threshold;
				Scale_Factor = P.Data(pp).Info.Experiment(1).Scale_Factor;
				CNN_Threshold = P.Data(pp).Parameters.Neural_Network.Threshold;
				BW_Min_Object_Size = P.Data(pp).Parameters.Neural_Network.Min_CC_Size;
				
				[CB_Pixels,~] = Detect_Cell_Body(P.Data(pp).Info.Files.Raw_Image{1},CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
				Im_Input = P.Data(pp).Info.Files.Raw_Image{1};
				Im_Input(CB_Pixels) = 0;
				
				P.Data(pp).Info.Files.Denoised_Image{1} = Apply_CNN_Im2Im(CNN,Im_Input); % Apply neural network to the raw image (after removing the cell-body).
				
				% Threshold the result to get a binary image:
				P.Data(pp).Info.Files.Binary_Image{1} = zeros(Im_Rows,Im_Cols);
				P.Data(pp).Info.Files.Binary_Image{1}(P.Data(pp).Info.Files.Denoised_Image{1} >= CNN_Threshold) = 1; % Set to 1 pixels that are above the preset threshold.
				
				% Delete sub-threshold objects from the binary image:
				CC = bwconncomp(P.Data(pp).Info.Files.Binary_Image{1}); % Find connected components in the binary image.
				Nc = cellfun(@length,CC.PixelIdxList); % Number of connected objects.
				Fc = find(Nc <= BW_Min_Object_Size); % Find sub-threshold object sizes.
				for c=Fc % For each sub-threshold object.
					P.Data(pp).Info.Files.Binary_Image{1}(CC.PixelIdxList{1,c}) = 0; % Set the object's pixels to 0.
				end
			end
		end
		
		% Update the image display (for the selected project):
		ff = find([P.GUI_Handles.Reconstruction_Menu_Handles(:).Checked] == 1,1); % Find the selected menu entry.
		Menus_Func(P.GUI_Handles.Reconstruction_Menu_Handles(ff),[],P); % Send the menu entry handle to Menus_Func, to display it again.
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Trace_Neuron_Func(source,event,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message',''); % ,'Indeterminate','on'
		
		Np = numel(P.Data);
		for pp=1:Np
			P.GUI_Handles.Waitbar.Value = pp ./ Np;
			
			set(P.GUI_Handles.Reconstruction_Menu_Handles(:),'Checked','off');
			set(P.GUI_Handles.Reconstruction_Menu_Handles(1),'Checked','on'); % Select the raw image in the reconstruction menu. It will be displayed through Switch_Project_Func -> Menus_Func.
			
			Switch_Project_Func(P.GUI_Handles.Menus(1).Children(Np - pp + 1),[],P); % Switch to project #pp.
			
			P.GUI_Handles.Waitbar.Message = 'Analyzing vertices...';
			Data_pp = Vertices_Analysis_Index(P.Data(pp));
			
			P.GUI_Handles.Waitbar.Message = 'Tracing neuron...';
			Data_pp = Connect_Vertices(Data_pp,P.GUI_Handles.View_Axes(1));
			
			P.Data(pp).Segments = Data_pp.Segments;
			P.Data(pp).Vertices = Data_pp.Vertices;
			P.Data(pp).Info.Files.Binary_Image{1} = Data_pp.Info.Files.Binary_Image{1};
		end
		Menus_Func(P.GUI_Handles.Reconstruction_Menu_Handles(10),[],P); % Display the trace.
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Save_Image_Func(~,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		Filename = sprintf('Screenshot_%s.svg', datestr(now,'mm-dd-yyyy HH-MM'));
		[File1,Path1] = uiputfile(Filename);
		
		if(Path1)
			disp('TODO: image saving not implemented');
		end
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Save_Figure_Func(~,~)
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Save_Project_Func(~,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		pp = P.GUI_Handles.Current_Project;
		
		if(isempty(P.Data(pp).Info) || isempty(P.Data(pp).Info.Experiment(1).Identifier))
			P.Data(pp).Info.Experiment(1).Identifier = '';
		end
		
		A = ['Project_X_',P.Data(pp).Info.Experiment(1).Identifier,'.mat'];
		A = strrep(A,':','-');
		A = strrep(A,' ','_');
		A = strrep(A,'?','_');
		
		Project = P.Data(pp);
		uisave('Project',A);
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Set_Callbacks(P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		switch(P.GUI_Handles.UI)
		case 0
			Func_Button = 'Callback';
			Func_checkbox = 'Callback';
		case 1
			Func_Button = 'ButtonPushedFcn';
			Func_checkbox = 'ValueChangedFcn';
		end
		
		set(P.GUI_Handles.Buttons(1,1),Func_Button,{@Load_Data_Func,P}); % UI: ButtonPushedFcn
		set(P.GUI_Handles.Buttons(1,2),Func_Button,{@Load_Project_Func,P});
		set(P.GUI_Handles.Buttons(2,1),Func_Button,{@Denoise_Image_Func,P}); % Denoising.
		set(P.GUI_Handles.Buttons(2,2),Func_Button,{@Trace_Neuron_Func,P}); % Tracing.
		set(P.GUI_Handles.Buttons(3,1),Func_Button,{@Save_Image_Func,P});
		set(P.GUI_Handles.Buttons(3,2),Func_Button,@Save_Figure_Func);
		set(P.GUI_Handles.Buttons(3,3),Func_Button,{@Save_Project_Func,P});
		
		set(P.GUI_Handles.Control_Panel_Objects(1,1),Func_checkbox,{@Checkbox_1_Func,P});
		
		set(P.GUI_Handles.Step_Buttons(:),Func_Button,{@Step_Buttons_Func,P});
		
		for tt=1:length(P.GUI_Handles.Info_Tables) % For each info table.
			set(P.GUI_Handles.Info_Tables(tt),'CellEditCallback',{@Update_Info_Func,P});
		end
		
		% Menus:
		set(P.GUI_Handles.Reconstruction_Menu_Handles(:),'UserData',2,'Callback',{@Menus_Func,P}); % P.GUI_Handles.Menus(2)
		set(P.GUI_Handles.Plots_Menu_Handles(:),'UserData',3,'Callback',{@Menus_Func,P}); % P.GUI_Handles.Menus(3)
		
		close(P.GUI_Handles.Waitbar);
	end
end