function index()
	
	% This is the root script for the GUI.
	% Project_H is a pointer to structure Project, defined as a class handle in Project_Class.m.
	
	close(findall(0,'type','figure')); % Close all figures.
	clear; % Clear workspace.
	
	cd(fileparts(which(mfilename))); % Change to the directory of this file.
	
	% Add all this directory (including all subdirectories) to the path, excluding the Resources directory:
	path1 = string(split(genpath(pwd),';'));
	path1(contains(path1,'Resources')) = [];
	path1 = join(path1,';'); % Join back to get a path format.
	addpath(path1); % Add to path.
	
	Project_H = Project_Class; % This creates an object of the Project_Class class.
	
	GUI_Params(Project_H);
	
	% Set_Objects(Project_H);
	Set_Objects_UI(Project_H);
	
	Set_Callbacks(Project_H);
	Project_H.GUI_Handles.Current_Step = 0;
	Project_H.GUI_Handles.Current_Project = 1;
	assignin('base','Project',Project_H);
	% close(Project_H.GUI_Handles.Waitbar);
	
	function Load_Data_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		end
		
		CurrentDir = pwd;
		
		if(~isempty(source)) % If a button is used to run this callback.
			[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats,'MultiSelect','on');
		elseif(isempty(source)) % If this callback is called from "Load_Project_Func" after loading a project file.
			Selection_Index = 1;
		else
			Selection_Index = 0;
		end
		
		if(Selection_Index == 0)
			disp('Files not found.');
			close(P.GUI_Handles.Waitbar);
			return;
		elseif(~isempty(source))
			if(~iscell(File1))
				File1 = {File1};
			end
		end
		
		cd(CurrentDir); % Return to the main directory.
		
		if(~P.GUI_Handles.Multi_View) % single-view project. Create a project for each loaded file.
			P.GUI_Handles.View_Axes = gobjects(1);
			if(~isempty(source)) % If data was loaded.
				pp = numel(P.Data);
				for ff=1:length(File1) % For each file.
					
					pp = pp + 1;
					
					P.Data(pp) = project_init(P); % Initialize project struct;
					
					file_info = imfinfo([Path1,filesep,File1{ff}]); % Get file meta-data.
					[filepath,filename,ext] = fileparts([Path1,filesep,File1{ff}]);
					P.Data(pp).Info.Experiment(1).Identifier = filename;
					
					if(P.GUI_Handles.Save_Input_Data_Path || numel(file_info) > 1) % If the user specified to save the path, or it is a multi-stack image file,
						P.Data(pp).Info.Files(1).Raw_Image = [Path1,filesep,File1{ff}]; % Save only the path to the input file.
					else % Save input data explicitly.
						P.Data(pp).Info.Files(1).Raw_Image = imread([Path1,filesep,File1{ff}]);
						P.Data(pp).Info.Files(1).Raw_Image = P.Data(pp).Info.Files(1).Raw_Image(:,:,1); % If there are multiple channels, take only the first (they contain identical information).
					end
					
					% Temporary:
					% if(~isfield(P.Data(pp).Parameters.Image_Parameters,'Pixel_Limits'))
					% 	P.Data(pp).Parameters.Image_Parameters.Pixel_Limits = [0,255];
					% end
					
					P.Data(pp).Info.Files(1).Stacks_Num = numel(file_info);
					
					Label_pp = ['Project_',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = ff ./ length(File1);
				end
			else % If a project file(s) was loaded.
				delete(P.GUI_Handles.Menus(1).Children); % Empty the Project menu.
				
				for pp=1:numel(P.Data) % For each project.
					
					if(P.GUI_Handles.Save_Input_Data_Path || ischar(P.Data(pp).Info.Files(1).Raw_Image)) % Validate image path. If it is not found, ask the user to specify a new path and save it.
					
						P.GUI_Handles.Save_Input_Data_Path = 1; % Update this flag in stack projects, in case the user haven't specified it in GUI_Params.
						
						[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files(1).Raw_Image);
						
						if(~(exist(filepath,'dir') == 7) || ~isfile(P.Data(pp).Info.Files(1).Raw_Image)) % If the path or file don't exist.
							[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats); % Ask the user to select the file.
						else
							Selection_Index = 0;
						end
						
						if(Selection_Index) % If the path should be updated.
							[~,filename1,~] = fileparts(File1);
							if(~isequal(filename,filename1))
								warning('File name does not match the original file name.');
							end
							P.Data(pp).Info.Experiment(1).Identifier = filename1;
							P.Data(pp).Info.Files(1).Raw_Image = [Path1,File1]; % A single file for project pp.
                            
                            if(~isnumeric(P.Data(pp).Info.Files(1).Raw_Image) && P.Data(pp).Info.Files(1).Stacks_Num > 0) % If multi-stack.
                                P.Data(pp).Info.Files(1).Binary_Image = [Path1,File1(1:end-4),filesep,'Binary_Image.tif'];
                                P.Data(pp).Info.Files(1).Denoised_Image = [Path1,File1(1:end-4),filesep,'Denoised_Image.tif'];
                            end
						end
						
					end
					
					% Temporary:
					% if(~isfield(P.Data(pp).Parameters.Image_Parameters,'Pixel_Limits'))
					% 	P.Data(pp).Parameters.Image_Parameters.Pixel_Limits = [0,255];
					% end
					
					if(isnumeric(P.Data(pp).Info.Files(1).Raw_Image))
						P.Data(pp).Info.Files(1).Stacks_Num = 1;
                    elseif(~isfield(P.Data(pp).Info.Files(1),'Stacks_Num') || isempty(P.Data(pp).Info.Files(1).Stacks_Num)) % If the path is saved.
						file_info = imfinfo(P.Data(pp).Info.Files(1).Raw_Image); % Get file meta-data.
						P.Data(pp).Info.Files(1).Stacks_Num = numel(file_info);
					end
					
					Label_pp = ['Project_',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = pp ./ numel(P.Data);
				end
			end
			
			Reset_Main_Axes(P);
			
			if(isnumeric(P.Data(1).Info.Files(1).Raw_Image)) % If the image is stored explicitly in the project class.
				Menus_Func(findall(P.GUI_Handles.Menus(2),'Label','Raw Image - Grayscale'),[],P);
				% Display_Reconstruction(P,P.Data(1),'Raw Image - Grayscale');
				% imshow(P.Data(1).Info.Files(1).Raw_Image,'Parent',P.GUI_Handles.View_Axes(1));
			else % If the path to the image is saved.
				
				if(P.Data(1).Info.Files(1).Stacks_Num > 1) % If it is a multi-stack image file.
					P.GUI_Handles.Current_Stack = 1;
					
					Menus_Func(findall(P.GUI_Handles.Menus(2),'Label','Raw Image - Grayscale'),[],P);
					% Display_Reconstruction(P,P.Data(1),'Raw Image - Grayscale');
					% imshow(tiffreadVolume(P.Data(1).Info.Files(1).Raw_Image,'PixelRegion',{[1,1,inf],[1,1,inf],[P.GUI_Handles.Current_Stack,1,P.GUI_Handles.Current_Stack]}),'Parent',P.GUI_Handles.View_Axes(1)); % Display the first stack.
					
					set(P.GUI_Handles.Menus(4).Children(:),'Checked',false);
					set(P.GUI_Handles.Menus(4).Children(2),'Checked',true,'Enable','on');
				end
			end
			P.GUI_Handles.View_Axes.XLim = findall(P.GUI_Handles.View_Axes.Children,'Type','image').XData; % P.GUI_Handles.View_Axes.Children(1).XData;
			P.GUI_Handles.View_Axes.YLim = findall(P.GUI_Handles.View_Axes.Children,'Type','image').YData; % P.GUI_Handles.View_Axes.Children(1).YData;
			
		else % Multi-view project.
			if(~isempty(source)) % If data was loaded, create a single project.
				P.GUI_Handles.View_Axes = gobjects(1,length(File1));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,length(File1)));
				P.Data(1) = project_init(P);
				for vv=1:length(File1) % For each view.
					
					P.GUI_Handles.Waitbar.Value = vv ./ length(File1);
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Save only the file name.
						P.Data(1).Info.Files(vv).Raw_Image = File1{vv};
					else % Save input data explicitly.
						P.Data(1).Info.Files(vv).Raw_Image = imread([Path1,filesep,File1{vv}]);
					end
					P.Data(1).Info.Files(vv).Raw_Image = P.Data(1).Info.Files(vv).Raw_Image(:,:,1);
					
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
					
					imshow(P.Data(1).Info.Files(vv).Raw_Image,'Parent',P.GUI_Handles.View_Axes(vv));
				end
				[filepath,filename,ext] = fileparts(File1{1});
				P.Data(1).Info.Experiment(1).Identifier = filename;
				Label_1 = ['Project_1','_',P.Data(1).Info.Experiment(1).Identifier];
				uimenu(P.GUI_Handles.Menus(1),'Text',Label_1,'UserData',1,'Callback',{@Switch_Project_Func,P});
			else % If a project file(s) was loaded.
				P.GUI_Handles.View_Axes = gobjects(1,numel(P.Data(1).Info.Files));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,numel(P.Data(1).Files)));
				for pp=1:numel(P.Data) % For each project.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Validate path. If it is not found, ask the user to specify a new path and save it.
						[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files(1).Raw_Image);
						if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Info.Files(1).Raw_Image)) % If the path or file don't exist.
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
								P.Data(pp).Info.Files(vv).Raw_Image = File1{vv};
							end
						end
					end
					
					Label_pp = ['Project_',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
				end
				
				for vv=1:length(File1) % For each view.
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1); % P.GUI_Handles.View_Axes(v) = uiimage(P.GUI_Handles.Axes_Grid);
					P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					imshow(P.Data(1).Info.Files(vv).Raw_Image,'Parent',P.GUI_Handles.View_Axes(vv));
				end
			end
		end
		
		figure(P.GUI_Handles.Main_Figure);
		
		Display_Project_Info(P);
		
		set(P.GUI_Handles.Menus(1),'UserData',1);
		set(P.GUI_Handles.Menus(1).Children(end),'Checked','on');
		P.GUI_Handles.Current_Menu = nan;
		
		set(P.GUI_Handles.Buttons(1),'Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		
		if(P.GUI_Handles.Current_Step == 0)
			P.GUI_Handles.Current_Step = 1;
			set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step+1),'Backgroundcolor',P.GUI_Handles.Step_BG_Active);
		end
		
		% Set a key detection callback for shifting the axes and for changing stacks:
		set(P.GUI_Handles.Main_Figure,'KeyPressFcn',{@Key_Func,P});
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Load_Project_Func(source,~,P)
		
		[File,Path,Selection_Index] = uigetfile('*.mat','MultiSelect','on');
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		if(Selection_Index == 0)
			close(P.GUI_Handles.Waitbar);
			return;
		end
		
		if(~iscell(File))
			File = {File};
		end
		
		figure(P.GUI_Handles.Main_Figure);
		set(P.GUI_Handles.Waitbar,'Indeterminate','off','Value',0);
		
		pp = numel(P.Data); % This allows loading different projects separately (rather than loading all projects at once).
		for ii=1:length(File) % For each loaded project file (may contain one or more projects).
			
			Loaded_File = load([Path,File{ii}]);
			
			% *************************************************************************************************************
			% *************************************************************************************************************
			% *************************************************************************************************************
			
			% Temporary (convert old workspace format to project format):
			if(isfield(Loaded_File,'Workspace'))
				Loaded_File.Project = Workspace_To_Project(Loaded_File.Workspace);
			end
						
			% Temporary ("Neuron_Axes" changed to "Axes"):
            if(isfield(Loaded_File.Project,'Neuron_Axes'))
                for jj=1:numel(Loaded_File.Project)
                    Loaded_File.Project(jj).Axes = Loaded_File.Project(jj).Neuron_Axes;

                end
                Loaded_File.Project = rmfield(Loaded_File.Project,'Neuron_Axes');
            end
            
            % Temporary (replace the "coordinate" field with X & Y to be consistent with the "Points" struct):
            for jj=1:numel(Loaded_File.Project)
                if(~isempty(Loaded_File.Project(jj).Vertices) && isfield(Loaded_File.Project(jj).Vertices,'Coordinate'))
                    if(~isfield(Loaded_File.Project(jj).Vertices,'X') && length(Loaded_File.Project(jj).Vertices(1).Coordinate) == 2)
                        for vv=1:numel(Loaded_File.Project(jj).Vertices)
                            Loaded_File.Project(jj).Vertices(vv).X = Loaded_File.Project(jj).Vertices(vv).Coordinate(1);
                            Loaded_File.Project(jj).Vertices(vv).Y = Loaded_File.Project(jj).Vertices(vv).Coordinate(2);
                        end
                    end
					Loaded_File.Project(jj).Vertices = rmfield(Loaded_File.Project(jj).Vertices,'Coordinate');
                end
            end
            
			% *************************************************************************************************************
			% *************************************************************************************************************
			% *************************************************************************************************************
			
			if(isfield(Loaded_File,'Project')) % If a project struct exists for the first loaded project.
				for jj=1:numel(Loaded_File.Project) % For each project within the ii project file.
					pp = pp + 1;
					P.Data(pp) = Loaded_File.Project(jj);
                    
                    % Temporary (update the parameters file):
                    P.Data(pp).Parameters = Parameters_Func(P.Data(pp).Info.Experiment(1).Scale_Factor);
                    % **********************************************************************************
                    
					P.GUI_Handles.Waitbar.Value = jj ./ numel(Loaded_File.Project);
				end
			end
		end
		
		Load_Data_Func([],[],P);
		
		set(source,'Enable','on','Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		
		set(allchild(P.GUI_Handles.Menus(1)),'Enable','on');
		
		close(P.GUI_Handles.Waitbar);
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
				% delete(allchild(P.GUI_Handles.View_Axes(1)));
				% set(P.GUI_Handles.View_Axes(1),'Position',[1,1,P.GUI_Handles.Main_Panel_1.InnerPosition(3:4)]);
				
				% Update the image display (for the selected project):
				P.GUI_Handles.Buttons(3,1).UserData = ''; % This will make sure that the axes are reset too.
				Menus_Func(findall(P.GUI_Handles.Menus(2),'Checked','on'),[],P);
			else % Multi-view project.
				% for vv=1:length(File1) % For each view.
				% 	imshow(P.Data(pp).Info.Files(vv).Raw_Image,'Parent',P.GUI_Handles.View_Axes(vv));
				% end
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
		
		% temporary fix: Data is copied and then copied back to the handle class to avoid repetitive reading of the class.
		
		pp = P.GUI_Handles.Current_Project;
		
		for tt=1:length(P.GUI_Handles.Info_Fields_List) % For each menu.
			if(isfield(P.Data(pp).Info,P.GUI_Handles.Info_Fields_List{tt}))
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
		
	end
	
	function Update_Info_Func(source,event,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Denoising images...','Indeterminate','on');
		
		pp = P.GUI_Handles.Current_Project;
		
		tt = source.UserData; % Table index.
		ff = P.GUI_Handles.Info_Fields_List{tt}; % Corresponding field name in P(pp).Data.Info.
		rr = event.Indices(1); % Table rows correspond to struct fields.
		cc = event.Indices(2); % Second column is the value and the third is the unit. First column is read-only (field name).
		FF = fields(P.Data(pp).Info.(ff));
		
		P.Data(pp).Info.(ff)(cc-1).(FF{rr}) = event.NewData;
		
		if(isequal(FF{rr},'Scale_Factor'))
			P.Data(pp).Parameters = Parameters_Func(event.NewData);
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Menus_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
		end
		pp = P.GUI_Handles.Current_Project;
		
		set(P.GUI_Handles.Control_Panel_Objects(:,2),'Enable','off'); % Disable the radio buttons.
		
		P.GUI_Handles.Current_Menu = source.UserData;
		
		% profile on;
		switch(source.UserData)
			case 2 % Reconstruction menu.
				set(P.GUI_Handles.Buttons(3,1),'ButtonPushedFcn',{@Apply_Changes_Func,P,2}); % Here it is set before running the function, because some options overwrite it.
				
				set(findall(P.GUI_Handles.Menus(2)),'Checked','off'); % set(P.GUI_Handles.Reconstruction_Menu_Handles(:),'Checked','off');
				set(source,'Checked','on');
				
				if(ishandle(P.GUI_Handles.View_Axes)) % If the axes exist, reset.
					% if(~isequal(source.Label,P.GUI_Handles.Buttons(3,1).UserData)) % If a different plot was chosen.
					if(isempty(P.GUI_Handles.Buttons(3,1).UserData)) % If a different project was chosen.
						Reset_Main_Axes(P);
					else % Otherwise only delete non-image and non-axes data, and save the zoom.
						XLim = P.GUI_Handles.View_Axes.XLim;
						YLim = P.GUI_Handles.View_Axes.YLim;
						delete(findobj(P.GUI_Handles.View_Axes,'-not','Type','image','-and','-not','Type','axes')); % Delete all graphical objects (except for the axes and the image).
					end
				else % If the axes do not exist.
					Reset_Main_Axes(P);
					P.GUI_Handles.Buttons(3,1).UserData = ''; % Used as a flag to reset the axes and axis limits.
				end
				
				Display_Reconstruction(P,P.Data(pp),source.Label);
				
				% if(~isequal(source.Label,P.GUI_Handles.Buttons(3,1).UserData)) % If a different plot was chosen, reset the limits.
				Fim = findall(P.GUI_Handles.View_Axes.Children,'Type','image');
				if(ishandle(P.GUI_Handles.View_Axes) && isempty(P.GUI_Handles.Buttons(3,1).UserData) && ~isempty(Fim)) % If a different project was chosen.
					P.GUI_Handles.View_Axes.XLim = findall(P.GUI_Handles.View_Axes.Children,'Type','image').XData; % P.GUI_Handles.View_Axes.Children(1).XData;
					P.GUI_Handles.View_Axes.YLim = findall(P.GUI_Handles.View_Axes.Children,'Type','image').YData; % P.GUI_Handles.View_Axes.Children(1).YData;
				elseif(ishandle(P.GUI_Handles.View_Axes) && ~isempty(Fim)) % Preserve the zoom.
					P.GUI_Handles.View_Axes.XLim = XLim;
					P.GUI_Handles.View_Axes.YLim = YLim;
				end
				
				set(P.GUI_Handles.Buttons(3,1),'UserData',source.Label); % Last used plot. Must be set after running the plot.
				
				% drawnow; drawnow;
				
				% set(P.GUI_Handles.Buttons(3,1),'ButtonPushedFcn','');
			case 3 % Plots menu.
				set(findall(P.GUI_Handles.Menus(3)),'Checked','off'); % set(P.GUI_Handles.Reconstruction_Menu_Handles(:),'Checked','off');
				set(source,'Checked','on');
				
				set(P.GUI_Handles.Buttons(3,1),'ButtonPushedFcn',{@Apply_Changes_Func,P,3});
				
				Display_Plot(P,P.Data,source.Label);
				
				set(P.GUI_Handles.Buttons(3,1),'UserData',source.Label); % Last used plot. Must be set after running the plot.
		end
		% profile off; profile viewer;
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Apply_Changes_Func(source,event,P,Option_Flag)
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
		
		switch(Option_Flag)
			case 2 % Reconstructions.
				Menus_Func(findall(P.GUI_Handles.Menus(2),'Checked','on'),[],P);
			case 3 % Plots.
				Menus_Func(findall(P.GUI_Handles.Menus(3),'Checked','on'),[],P);
			case 4 % Mode.
				set(findall(P.GUI_Handles.Menus(4)),'Checked','off');
				set(source,'Checked','on');
				if(P.GUI_Handles.Current_Menu == 2 || P.GUI_Handles.Current_Menu == 3)
					Menus_Func(findall(P.GUI_Handles.Menus(P.GUI_Handles.Current_Menu),'Checked','on'),[],P);
				end
		end
		close(P.GUI_Handles.Waitbar);
	end
	
	function Key_Func(source,event,P) % A key detection callback for shifting the axes and for changing stacks.
		
		if(1) % TODO: execute only if an image is displayed.
			pp = P.GUI_Handles.Current_Project;
			d = 10;
			
			switch(event.Key)
				case 'leftarrow'
					P.GUI_Handles.View_Axes.XLim = P.GUI_Handles.View_Axes.XLim - d;
				case 'rightarrow'
					P.GUI_Handles.View_Axes.XLim = P.GUI_Handles.View_Axes.XLim + d;
				case 'uparrow'
					P.GUI_Handles.View_Axes.YLim = P.GUI_Handles.View_Axes.YLim - d;
				case 'downarrow'
					P.GUI_Handles.View_Axes.YLim = P.GUI_Handles.View_Axes.YLim + d;
				case 'hyphen' % 45
					P.GUI_Handles.Current_Stack = max(1,P.GUI_Handles.Current_Stack - 1);
					Menus_Func(findall(P.GUI_Handles.Menus(2),'Checked','on'),[],P);
					disp(['Current stack = ',num2str(P.GUI_Handles.Current_Stack)]);
				case 'equal' % 61
					P.GUI_Handles.Current_Stack = min(P.Data(pp).Info.Files(1).Stacks_Num,P.GUI_Handles.Current_Stack + 1);
					Menus_Func(findall(P.GUI_Handles.Menus(2),'Checked','on'),[],P);
					disp(['Current stack = ',num2str(P.GUI_Handles.Current_Stack)]);
			end
			% disp(event.Key);
		end
	end
	
	function Denoise_Image_Func(source,event,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Denoising images...'); % ,'Indeterminate','on'
		
		CNN = load([findall(P.GUI_Handles.Menus(5).Children(end).Children,'Checked','on').Text,'.mat']);
		CNN = CNN.PVD_CNN;
		
		selection = uiconfirm(P.GUI_Handles.Main_Figure,'Overwrite existing binary images?','Warning','Icon','question','Options',{'Overwrite','Keep existing binary images'});
		switch(selection)
		case 'Overwrite'
			Overwrite = 1;
		case 'Keep existing binary images'
			Overwrite = 0;
		end
		
		for pp=1:numel(P.Data) % For each project.
			
			Pix_Lim = P.Data(pp).Parameters.Image_Parameters.Pixel_Limits;
			
			if(P.Data(pp).Info.Files(1).Stacks_Num == 1) % One image per project.
				
				P.GUI_Handles.Waitbar.Value = pp ./ numel(P.Data);
				
				Im = im2uint8(rescale(P.Data(pp).Info.Files(1).Raw_Image,0,1,'InputMin',Pix_Lim(1),'InputMax',Pix_Lim(2)));
				
				[Im_Rows,Im_Cols] = size(Im);
				P.Data(pp).Info.Files(1).Denoised_Image = Apply_CNN_Im2Im(CNN,Im); % Apply neural network to the raw image (after removing the cell-body).
				
				if( Overwrite || (~isfield(P.Data(pp).Info.Files,'Binary_Image') || isempty(P.Data(pp).Info.Files(1).Binary_Image)) ) % If a binary image is missing or if the user specified to overwrite existing images.
					P.Data(pp).Info.Files(1).Binary_Image = Update_Binary_Image(P.Data(pp).Info.Files(1).Denoised_Image,[],P.Data(pp).Parameters.Neural_Network.Min_CC_Size,1);
				else % Keep the existing binary image.
					% TODO: why is this needed?
					P.Data(pp).Info.Files(1).Binary_Image = Update_Binary_Image(P.Data(pp).Info.Files(1).Denoised_Image,P.Data(pp).Info.Files(1).Binary_Image,P.Data(pp).Parameters.Neural_Network.Min_CC_Size,0); % This only deletes sub-threshold objects.
				end
				
			else % Apply CNN to all stacks.
				
				% Memory pre-allocation:
				file_info = imfinfo(P.Data(pp).Info.Files(1).Raw_Image);
				Denoised_Image_Stack_0 = categorical(nan([file_info(1).Height,file_info(1).Width,P.Data(pp).Info.Files(1).Stacks_Num]));
				Binary_Image_Stack = nan([file_info(1).Height,file_info(1).Width,P.Data(pp).Info.Files(1).Stacks_Num]);
				
				% Create CNN and BW image files:
				if(isempty(P.Data(pp).Info.Files(1).Denoised_Image) && ~isnumeric(P.Data(pp).Info.Files(1).Raw_Image))
					[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files(1).Raw_Image);
					Dir1 = [filepath,filename(1:end-4)];
					mkdir(Dir1);
					
					% Create tiff files:
					t_cnn = Tiff([Dir1,filesep,'Denoised_Image.tif'],'w');
					t_bw = Tiff([Dir1,filesep,'Binary_Image.tif'],'w');
					
					Tags_Struct = TIF_Init([file_info(1).Width,file_info(1).Height]);
					
					% Save the absolute directory of the tiff files into the project file:
					P.Data(pp).Info.Files(1).Denoised_Image = [Dir1,filesep,'Denoised_Image.tif']; % Save the path to the image rather than the image itself.
					P.Data(pp).Info.Files(1).Binary_Image = [Dir1,filesep,'Binary_Image.tif']; % ".
					
					% P.Data(pp).Info.Files(1).Denoised_Image = [filepath,filesep,filename(1:end-4),filesep,'Denoised_Image.dcm']; % Save the path to the image rather than the image itself.
					% P.Data(pp).Info.Files(1).Binary_Image = [filepath,filesep,filename(1:end-4),filesep,'Binary_Image.dcm']; % ".
				end
				
				for ss=1:P.Data(pp).Info.Files(1).Stacks_Num % For each stack.
					
					P.GUI_Handles.Waitbar.Value = (pp * ss) ./ (numel(P.Data) * P.Data(pp).Info.Files(1).Stacks_Num);
					
					Im = im2uint8(tiffreadVolume(P.Data(pp).Info.Files(1).Raw_Image,'PixelRegion',{[1,1,inf],[1,1,inf],[ss,1,ss]}));
					
					Im = im2uint8(rescale(Im,0,1,'InputMin',Pix_Lim(1),'InputMax',Pix_Lim(2))); % Enahce image.
					
					Denoised_Image_Stack_0(:,:,ss) = Apply_CNN_Im2Im(CNN,Im);
					
					if( Overwrite || (~isfield(P.Data(pp).Info.Files,'Binary_Image') || isempty(P.Data(pp).Info.Files(1).Binary_Image)) ) % If a binary image is missing or if the user specified to overwrite existing images.
						Binary_Image_Stack(:,:,ss) = Update_Binary_Image(Denoised_Image_Stack_0(:,:,ss),[],P.Data(pp).Parameters.Neural_Network.Min_CC_Size,1);
					else % Keep the existing binary image.
						% TODO: why is this needed?
						Binary_Image_Stack(:,:,ss) = Update_Binary_Image(Denoised_Image_Stack_0(:,:,ss),Binary_Image_Stack(:,:,ss),P.Data(pp).Parameters.Neural_Network.Min_CC_Size,0); % This only deletes sub-threshold objects.
					end
					
					% Write slices to tiff files:
					Denoised_Image_Stack = im2uint8(zeros(size(Denoised_Image_Stack_0,[1,2])));
					Denoised_Image_Stack(Denoised_Image_Stack_0(:,:,ss) == "Neuron") = 255;
					
					setTag(t_cnn,Tags_Struct);
					setTag(t_bw,Tags_Struct);
					
					write(t_cnn,im2uint8(Denoised_Image_Stack));
					write(t_bw,im2uint8(Binary_Image_Stack(:,:,ss)));
					
					writeDirectory(t_cnn);
					writeDirectory(t_bw);
				end
				close(t_cnn);
				close(t_bw);
				%%% imwrite(Denoised_Image_Stack,P.Data(pp).Info.Files(1).Denoised_Image,'Compression','none'); % Save the denoised (CNN) image (all stacks) to a file (same dir as the raw image).
				% Denoised_Image_Stack = im2uint8(zeros(size(Denoised_Image_Stack_0)));
				% Denoised_Image_Stack(Denoised_Image_Stack_0 == "Neuron") = 255;
				% dicomwrite(permute(im2uint8(Denoised_Image_Stack),[1,2,4,3]),P.Data(pp).Info.Files(1).Denoised_Image);
				
				%%% imwrite(Binary_Image_Stack,P.Data(pp).Info.Files(1).Binary_Image,'Compression','none'); % Save the denoised (CNN) image (all stacks) to a file (same dir as the raw image).
				% dicomwrite(permute(im2uint8(Binary_Image_Stack),[1,2,4,3]),P.Data(pp).Info.Files(1).Binary_Image);
			end
		end
		
		% Update the image display (for the selected project):
		Menus_Func(findall(P.GUI_Handles.Menus(2),'Checked','on'),[],P); % Send the handle of the selected menu option to Menus_Func, to display it again.
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Trace_Neuron_Func(source,event,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message',''); % ,'Indeterminate','on'
		
		Np = numel(P.Data);
		for pp=1:Np
			P.GUI_Handles.Waitbar.Value = pp ./ Np;
			
			% Load and enhance the raw image:
			Pix_Lim = P.Data(pp).Parameters.Image_Parameters.Pixel_Limits;
			Im = im2uint8(rescale(P.Data(pp).Info.Files(1).Raw_Image,0,1,'InputMin',Pix_Lim(1),'InputMax',Pix_Lim(2)));
			
			Menus_Func(findall(P.GUI_Handles.Menus(2),'Label','Raw Image - Grayscale'),[],P); % set(P.GUI_Handles.Reconstruction_Menu_Handles(1),'Checked','on'); % Select the raw image in the reconstruction menu. It will be displayed through Switch_Project_Func -> Menus_Func.
			
			Switch_Project_Func(P.GUI_Handles.Menus(1).Children(Np - pp + 1),[],P); % Switch to project #pp.
			
			P.GUI_Handles.Waitbar.Message = ['Analyzing vertices (',num2str(pp),'\',num2str(Np),')...'];
			Data_pp = Vertices_Analysis_Index(Im,P.Data(pp));
			
			P.GUI_Handles.Waitbar.Message = ['Tracing neuron (',num2str(pp),'\',num2str(Np),')...'];
			Data_pp = Connect_Vertices(Im,Data_pp,P.GUI_Handles.View_Axes(1));
			
			P.Data(pp).Segments = Data_pp.Segments;
			P.Data(pp).Vertices = Data_pp.Vertices;
			P.Data(pp).Info.Files(1).Binary_Image = Data_pp.Info.Files(1).Binary_Image;
		end
		Menus_Func(findall(P.GUI_Handles.Menus(2),'Label','Trace - Lite'),[],P); % Menus_Func(P.GUI_Handles.Reconstruction_Menu_Handles(10),[],P); % Display the trace.
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Extract_Features_Func(source,event,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','');
		
		Overwrite_Axes = [];
		Np = numel(P.Data);
		for pp=1:Np
			
			P.GUI_Handles.Waitbar.Value = pp ./ Np;
			
			P.GUI_Handles.Waitbar.Message = ['Extracting Features (',num2str(pp),'\',num2str(Np),')...'];
			
			if(~isempty(P.Data(pp).Segments) && ~isempty(P.Data(pp).Vertices))
				[P.Data(pp),Overwrite_Axes] = Add_Features_To_All_Workspaces(P.Data(pp),P,Overwrite_Axes);
			else
				disp('The neuron must be traced before feature extraction.');
			end
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Save_Image_Func(~,~,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		Filename = sprintf('Screenshot_%s.svg', datestr(now,'mm-dd-yyyy HH-MM'));
		[File1,Path1] = uiputfile(Filename);
		
		if(Path1)
			disp('TODO: image saving not implemented');
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Save_Figure_Func(~,~)
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Save_Project_Func(~,~,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Saving...');
		
		if(P.GUI_Handles.Control_Panel_Objects(1,1).Value) % Selected project only.
			pp = P.GUI_Handles.Current_Project;
			
			if(isempty(P.Data(pp).Info) || isempty(P.Data(pp).Info.Experiment(1).Identifier))
				P.Data(pp).Info.Experiment(1).Identifier = '';
			end
			
			A = ['Project_X_',P.Data(pp).Info.Experiment(1).Identifier,'.mat'];
			A = strrep(A,':','-');
			A = strrep(A,' ','_');
			A = strrep(A,'?','_');
			
			Project = P.Data(pp);
		else
			Project = P.Data;
			A = 'Project_X.mat';
		end
		
		
		uisave('Project',A);
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Advanced_Menu_Func(source,~,P)
		
		switch(source.Position)
			case 2 % Train a denoising CNN.
				
				P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','');
				
				cnn_gui.cnn_panel = uipanel(P.GUI_Handles.Main_Grid,'Title','Train a denoising CNN','Scrollable','on','ForegroundColor',[1,1,1],'BackgroundColor',P.GUI_Handles.BG_Color_1,'AutoResizeChildren','off');
				cnn_gui.cnn_panel.Layout.Row = [1,18];
				cnn_gui.cnn_panel.Layout.Column = [1,10];
				% cnn_gui.cnn_panel.Position(1) = 0.1 * P.GUI_Handles.Main_Panel_1.Position(3);
				% cnn_gui.cnn_panel.Position(3) = 0.8 * P.GUI_Handles.Main_Panel_1.Position(3);
				% cnn_gui.cnn_panel.Position(4) = 0.9 * P.GUI_Handles.Main_Panel_1.Position(4);
				
				CNN_Grid_Dims = [15,6];
				
				cnn_gui.cnn_grid = uigridlayout(cnn_gui.cnn_panel,CNN_Grid_Dims,'RowHeight',repmat({'0.8x','1x','0.2x'},1,CNN_Grid_Dims(1)/3),'ColumnWidth',repmat({'1x','0.2x'},1,CNN_Grid_Dims(2)/2),'Scrollable','on','BackgroundColor',P.GUI_Handles.BG_Color_1);
				
				Training_Params = PVD_CNN_Params();
				Field_Names = {'Name','Solver','Input_Size','Samples_Per_Image','Max_Epochs','miniBatchSize','Encoder_Depth','Conv_Num','InitialLearnRate','Randomize_By_Image','Test_Set_Ratio','ExecutionEnvironment'};
				Default_Values = {['My_CNN_',datestr(datetime,'yyyymmdd_HH-MM-SS')],{'adam','sgdm','rmsprop'},Training_Params.Input_Size(1),Training_Params.Samples_Per_Image, ...
													Training_Params.Max_Epochs,Training_Params.miniBatchSize,Training_Params.Encoder_Depth,Training_Params.Conv_Num, ...
													Training_Params.InitialLearnRate,{'Randomize source images','Radnomize input samples'},Training_Params.Test_Set_Ratio,{'CPU (no parallel computing)','Parallel'}};
				Param_Names = {'Name','Solver','Sample size (px^2)','Number of samples per image','Number of epochs','Mini batch size', ...
								'Encoder Depth','Number of convolution layers (per encoder)','Initial learning rate','Sample randomization method','Test set ratio','Parallel computing'};
				
				for ii=1:length(Param_Names) % For each input field.
					
					[row,col] = ind2sub([CNN_Grid_Dims(1)/3,CNN_Grid_Dims(2)/2],ii);
					
					Name_label = uilabel(cnn_gui.cnn_grid,'Text',Param_Names{ii},'FontSize',16,'FontColor',[1,1,1]);
					Name_label.Layout.Row = 1 + 3*(row-1);
					Name_label.Layout.Column = 1 + 2*(col-1);
					
					if(ii == 2) % Solver.
						cnn_gui.(Field_Names{ii}) = uidropdown(cnn_gui.cnn_grid,'Items',Default_Values{ii},'Value',Default_Values{ii}{1});
					elseif(ii == 10) % Randomization method.
						cnn_gui.(Field_Names{ii}) = uidropdown(cnn_gui.cnn_grid,'Items',Default_Values{ii},'ItemsData',[1,0],'Value',1);
					elseif(ii == 12) % Parallelization.
						cnn_gui.(Field_Names{ii}) = uidropdown(cnn_gui.cnn_grid,'Items',Default_Values{ii},'ItemsData',{'cpu','parallel'},'Value','cpu');
					elseif(isnumeric(Default_Values{ii}))
						cnn_gui.(Field_Names{ii}) = uieditfield(cnn_gui.cnn_grid,'numeric','Value',Default_Values{ii},'HorizontalAlignment','center');
					else
						cnn_gui.(Field_Names{ii}) = uieditfield(cnn_gui.cnn_grid,'Value',Default_Values{ii});
					end
					
					cnn_gui.(Field_Names{ii}).Layout.Row = 2 + 3*(row-1);
					cnn_gui.(Field_Names{ii}).Layout.Column = 1 + 2*(col-1);
				end
				% uilabel(cnn_gui.cnn_grid,'Text','Number of samples per image');
				% uieditfield(cnn_gui.cnn_grid,'numeric','Limits', [-5 10],'Value',5);
				
				cnn_gui.submit = uibutton(cnn_gui.cnn_grid,'Text','Go!','ButtonPushedFcn',{@train_cnn_func,P,cnn_gui,Field_Names,Training_Params},'FontSize',P.GUI_Handles.Buttons_FontSize);
				cnn_gui.submit.Layout.Row = CNN_Grid_Dims(1)-1;
				cnn_gui.submit.Layout.Column = CNN_Grid_Dims(2)-1;
				
				cnn_gui.cancel = uibutton(cnn_gui.cnn_grid,'Text','Cancel','ButtonPushedFcn',{@cancel_cnn_func,cnn_gui},'FontSize',P.GUI_Handles.Buttons_FontSize);
				cnn_gui.cancel.Layout.Row = CNN_Grid_Dims(1)-1;
				cnn_gui.cancel.Layout.Column = CNN_Grid_Dims(2);
				
				close(P.GUI_Handles.Waitbar);
		end
		
		function cancel_cnn_func(~,~,cnn_gui)
			delete(cnn_gui.cnn_panel);
		end
		
		function train_cnn_func(~,~,P,cnn_gui,Field_Names,Training_Params)
			
			if(numel(P.Data) == 0)
				msgbox('You must first load a dataset in order to be able to train a denoising CNN.','Error','warn');
				delete(cnn_gui.cnn_panel);
				return;
			end
			
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Trainig...'); % ,'Indeterminate','on'
			
			% Make sure that the necessary directories exist:
			cd(fileparts(which('index.m'))); % Change the path to the main repository folder.
			if(~isfolder('./Resources/CNN/PVD_Dataset_In'))
				mkdir('./Resources/CNN/PVD_Dataset_In');
			else % Delete all files in that folder.
				delete('./Resources/CNN/PVD_Dataset_In/*');
			end
			if(~isfolder('./Resources/CNN/PVD_Dataset_Out'))
				mkdir('./Resources/CNN/PVD_Dataset_Out');
			else % Delete all files in that folder.
				delete('./Resources/CNN/PVD_Dataset_Out/*');

			end
			if(~isfolder('./Resources/CNN/Checkpoints'))
				mkdir('./Resources/CNN/Checkpoints');
			end
			
			for iii=1:length(Field_Names)
				if(isfield(Training_Params,Field_Names{iii})) % If the form field exists in the default CNN parameters struct.
					if(any(isletter(cnn_gui.(Field_Names{iii}).Value))) % If the value contains letter, treat it as a string.
						Training_Params.(Field_Names{iii}) = cnn_gui.(Field_Names{iii}).Value;
					elseif(isnumeric(cnn_gui.(Field_Names{iii}).Value)) % Treat as number.
						Training_Params.(Field_Names{iii}) = cnn_gui.(Field_Names{iii}).Value;
					else % A string that actually contains a numeric value.
						Training_Params.(Field_Names{iii}) = str2double(cnn_gui.(Field_Names{iii}).Value);
					end
				end
			end
			% assignin('base','Training_Params',Training_Params);
			
			% Prepare input and output images:
			for iii=1:numel(P.Data)
				Im_In{iii} = P.Data(iii).Info.Files.Raw_Image;
				Im_Out{iii} = P.Data(iii).Info.Files.Binary_Image;
			end
			
			% Save training and test set to .\Resources\CNN\:
			PVD_Generate_Dataset(Im_In,Im_Out,Training_Params);
			
			PVD_CNN = PVD_CNN_Train(1,Training_Params);
			save(['./Inputs/pretrained_cnn/',cnn_gui.Name.Value,'.mat'],'PVD_CNN');
			% [Im_Out,Im_Label] = Segment_Neuron(net,Im_In_4);
			
			uimenu(P.GUI_Handles.Menus(5).Children(end),'Label',cnn_gui.Name.Value,'Callback',{@select_cnn_func,P}); % ,'Checked','on'.
			
			delete(cnn_gui.cnn_panel);
			
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function select_cnn_func(source,~,P)
		set(allchild(P.GUI_Handles.Menus(5).Children(end)),'Checked','off');
		set(source,'Checked','on');
	end
	
	function Reset_Main_Axes(P)
		
		delete(allchild(P.GUI_Handles.Main_Panel_1));
		set(P.GUI_Handles.Main_Panel_1,'BackgroundColor',P.GUI_Handles.BG_Color_1);
		
		% Create axes and display the image of the first project:
		P.GUI_Handles.View_Axes(1) = uiaxes(P.GUI_Handles.Main_Panel_1,'Position',[1,1,P.GUI_Handles.Main_Panel_1.InnerPosition(3:4)],'BackgroundColor',P.GUI_Handles.BG_Color_1);
		title(P.GUI_Handles.View_Axes(1),[]);
		xlabel(P.GUI_Handles.View_Axes(1),[]);
		ylabel(P.GUI_Handles.View_Axes(1),[]);
		P.GUI_Handles.View_Axes(1).XAxis.TickLabels = {};
		P.GUI_Handles.View_Axes(1).YAxis.TickLabels = {};
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
		set(P.GUI_Handles.Buttons(2,3),Func_Button,{@Extract_Features_Func,P}); % Feature extraction.
		set(P.GUI_Handles.Buttons(3,1),Func_Button,{@Apply_Changes_Func,P});
		set(P.GUI_Handles.Buttons(3,2),Func_Button,@Save_Image_Func);
		set(P.GUI_Handles.Buttons(3,3),Func_Button,{@Save_Project_Func,P});
		
		% set(P.GUI_Handles.Control_Panel_Objects(1,1),Func_checkbox,{@Checkbox_1_Func,P});
		
		set(P.GUI_Handles.Step_Buttons(:),Func_Button,{@Step_Buttons_Func,P});
		
		for tt=1:length(P.GUI_Handles.Info_Tables) % For each info table.
			set(P.GUI_Handles.Info_Tables(tt),'CellEditCallback',{@Update_Info_Func,P});
		end
		
		% Menus:
		set(findall(P.GUI_Handles.Menus(2),'UserData',2),'Callback',{@Menus_Func,P}); % Reconstruction menu.
		set(findall(P.GUI_Handles.Menus(3),'UserData',3),'Callback',{@Menus_Func,P}); % Plot menu.
		set(allchild(P.GUI_Handles.Menus(4)),'Callback',{@Apply_Changes_Func,P,4}); % Mode menu.
		
		set(allchild(P.GUI_Handles.Menus(5)),'Callback',{@Advanced_Menu_Func,P}); % Advanced menu.
		set(allchild(P.GUI_Handles.Menus(5).Children(end)),'Callback',{@select_cnn_func,P}); % Advanced menu.
		
		close(P.GUI_Handles.Waitbar);
	end
end