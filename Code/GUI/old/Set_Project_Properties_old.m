function Workspace1 = Set_Project_Properties(GUI_Parameters)
	
	Ter = 0;
	Workspace1 = [];
	
	H1 = uipanel(GUI_Parameters.Handles.Main_Panel,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.3 0.1 0.4 0.8]);
	
	uicontrol(H1,'Style','text','FontSize',20,'BackgroundColor',[0.7,0.7,0.7],'String','Project Properties','Units','Normalized','Position',[0 0.93 1 0.07],'FontSize',28);
	Continue_Button = uicontrol(H1,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button2_Font_Size,'String','Continue','Units','Normalized','Position',[0 0 1 0.1],'Callback',@Continue_Func);
	
	uicontrol(H1,'Style','text','units','Normalized','Position',[0,.8,0.3,0.05],'String','Scale-Bar:','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
	
	uicontrol(H1,'Style','text','units','Normalized','Position',[0.35,0.85,0.2,0.05],'String','Pixels','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
	uicontrol(H1,'Style','text','units','Normalized','Position',[0.6,0.85,0.2,0.05],'String','Length','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
	uicontrol(H1,'Style','text','units','Normalized','Position',[0.81,0.85,0.15,0.05],'String','Unit','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
	
	User_Input.Scale_Bar.Pixels = uicontrol(H1,'style','edit','units','Normalized','position',[0.36,.8,0.2,0.05],'String','140','UserData','','FontSize',24); % 4.5.
	User_Input.Scale_Bar.Length = uicontrol(H1,'style','edit','units','Normalized','position',[0.6,.8,0.2,0.05],'String','50','UserData','','FontSize',24); % 1.
	User_Input.Scale_Bar.Unit = uicontrol(H1,'Style','popup','Units','Normalized','Position',[0.81,.8,0.15,0.05], ...
			'FontSize',16,'String',{[char(181),'m'],'nm','mm','km'});
	
	Properties_Handles = struct('Property_Name',{},'Property_Value',{});
	
	p = 1;
	Y0 = 0.65;
	
	Properties_Handles(1).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06,0.45,0.05],'String','Creator Name','UserData','','FontSize',20);
	Properties_Handles(1).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06,0.45,0.05],'String','Anna','UserData','','FontSize',20);
	
	Properties_Handles(2).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*2,0.45,0.05],'String','Neuron Name','UserData','','FontSize',20);
	Properties_Handles(2).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*2,0.45,0.05],'String','PVDL','UserData','','FontSize',20);
	
	Properties_Handles(3).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*3,0.45,0.05],'String','Age','UserData','','FontSize',20);
	Properties_Handles(3).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*3,0.45,0.05],'String','Young Adult','UserData','','FontSize',20);
	
	Properties_Handles(4).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*4,0.45,0.05],'String','Sex','UserData','','FontSize',20);
	Properties_Handles(4).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*4,0.45,0.05],'String','Hermaphrodite','UserData','','FontSize',20);
			
	Properties_Handles(5).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*5,0.45,0.05],'String','Genotype','UserData','','FontSize',20);
	Properties_Handles(5).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*5,0.45,0.05],'String','WT','UserData','','FontSize',20);
	
	Properties_Handles(6).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*6,0.45,0.05],'String','Strain','UserData','','FontSize',20);
	Properties_Handles(6).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*6,0.45,0.05],'String','BP2117','UserData','','FontSize',20);
	
	Properties_Handles(7).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*7,0.45,0.05],'String','Grouping','UserData','','FontSize',20);
	Properties_Handles(7).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*7,0.45,0.05],'String','','UserData','','FontSize',20);
	
	Add_Property_Button = uicontrol(H1,'style','pushbutton','units','Normalized','position',[0.04,Y0-0.06*8.1,0.2,0.05],'String','+','FontSize',20,'Callback',@Add_Property_Func);
	
	p = 7;
	
	function Add_Property_Func(source1,callbackdata1)
		p = p + 1;
		set(Add_Property_Button,'Position',[0.04,Y0-0.06*(p+1.1),0.2,0.05]);
		Properties_Handles(p).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*p,0.45,0.05],'String','Property Name','UserData','','FontSize',20);
		Properties_Handles(p).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*p,0.45,0.05],'String','Property Value','UserData','','FontSize',20);
	end
	
	function Continue_Func(source1,callbackdata1)
		
		GUI_Parameters.Workspace(1).Files = {}; % Reset the Workspace.
		GUI_Parameters.Workspace(1).Files{1}.BW_Reconstruction = [];
		
		GUI_Parameters.General.Active_View = 1;
		% Reset_Axes();
		
		% Set the scale-bar:
		GUI_Parameters.Workspace(1).Files{1}.User_Input(1).Scale_Factor = str2num(User_Input.Scale_Bar.Length.String) / ...
																		str2num(User_Input.Scale_Bar.Pixels.String);
		GUI_Parameters.Workspace(1).Files{1}.User_Input(1).Scale_Unit = User_Input.Scale_Bar.Unit.String(User_Input.Scale_Bar.Unit.Value);
		
		for i=1:numel(Properties_Handles)
			GUI_Parameters.Workspace(1).Files{1}.User_Input.Features.(strrep(Properties_Handles(i).Property_Name.String,' ','_')) = ...
				strrep(Properties_Handles(i).Property_Value.String,' ','_');
		end
		
		GUI_Parameters.Workspace(1).Files{1}.Image0 = imread(strcat(PathName,FileName));
		GUI_Parameters.Workspace(1).Files{1}.Image0 = flipud(GUI_Parameters.Workspace(1).Files{1}.Image0(:,:,1));
		% % cla(GUI_Parameters.Handles.Axes,'reset');
		% % imshow(GUI_Parameters.Workspace(1).Files{1}.Image0,'Parent',GUI_Parameters.Handles.Axes);
		% % set(gca,'YDir','normal','Position',[0,0,1,1]);
		% set(Display_List,'Enable','off');
		
		GUI_Parameters.Workspace(1).Files{1}.Parameters = Parameters_Func(GUI_Parameters.Workspace(1).Files{1}.User_Input.Scale_Factor);
		
		[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(1).Files{1}.Image0);
		GUI_Parameters.Workspace(1).Files{1}.Parameters.General_Parameters.Im_Rows = Im_Rows;
		GUI_Parameters.Workspace(1).Files{1}.Parameters.General_Parameters.Im_Cols = Im_Cols;
		
		% GUI_Parameters.Workspace(1).Files{1}.Path = struct('Rectangle_Index',{});
		
		% Enable the tracing list:
		% % set(H0_1_2,'Enable','on');
		% % set(allchild(H0_1_2),'Enable','on');
		Workspace1 = GUI_Parameters.Workspace(1).Files{1};
		delete(H1);
		Ter = 1;
	end
	drawnow;
	
	while(1)
		if(Ter)
			break;
		end
	end
end