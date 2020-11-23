function Tracer_UI()
	
	tmp = matlab.desktop.editor.getActive;
	cd(fileparts(tmp.Filename));
	addpath(genpath(pwd));
	
	GUI_Parameters = Load_GUI_Parameters;
		close all;
		GUI_Parameters(1).Handles(1).Figure = figure('WindowState','maximized');
		set(GUI_Parameters(1).Handles.Figure,'Name',['Neuronalyzer ',GUI_Parameters.General.Version],'NumberTitle','off')
		Screen_Size = get(groot,'Screensize');
		% Screen_Size(2) = 0.03*Screen_Size(4);
		% Screen_Size(4) = Screen_Size(4) - Screen_Size(2)
		set(GUI_Parameters.Handles.Figure,'WindowStyle','normal'); % ,'Position',Screen_Size);
		% Figure_Window = get(GUI_Parameters.Handles.Figure,'JavaFrame');
		% set(Figure_Window,'Maximized',1);
		clf(GUI_Parameters.Handles.Figure);
		GUI_Parameters.Handles.Main_Panel = uipanel('FontSize',12,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.2 0 0.8 1]);
		GUI_Parameters.Handles.Axes = axes('Parent',GUI_Parameters.Handles.Main_Panel,'Units','normalized','Position',GUI_Parameters.Visuals.Main_Axes_Size_1);
		GUI_Parameters.Handles.Current_Image_Handle = [];
		GUI_Parameters.Handles.Edit_Panel = uipanel('FontSize',12,'Position',[0 0 0.2 0.5]); % [0.7,1,0.3].
		GUI_Parameters.Handles.Analysis_Panel = uipanel('FontSize',12,'Position',[0 0.5 0.2 0.5]);
		GUI_Parameters.Handles.Analysis_Tabs = uitabgroup('Parent',GUI_Parameters.Handles.Analysis_Panel,'Position',[0 0 1 1]);
		
		GUI_Parameters.Handles.Figure.Units = 'normalized';
		GUI_Parameters.Handles.Figure.Visible = 'off';
		GUI_Parameters.Handles.Axes.Visible = 'off';
		
		GUI_Parameters.Workspace = struct('Group_Name',{},'Handles',{},'Values',{});
		
		GUI_Parameters.Handles.Analysis.Analysis_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Analysis','BackgroundColor',[0.5,0.6,1]);
			GUI_Parameters.Handles.Workspace_Mode = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','popup','String',{'Use All Workspaces','Use Current Workspace Only'},'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
			GUI_Parameters.Handles.Significance_Bars_List = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','popup','String',{'No Statistical Test','T-TEST & U-TEST'},'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.8 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
			GUI_Parameters.Handles.Error_Bars_List = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','popup','String',{'No Error Bars','Standard Deviation','Standard Error of the Mean'},'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
			% GUI_Parameters.Handles.Analysis.Slider = uicontrol('Parent',GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','slider','Min',0,'Max',1,'Value',GUI_Parameters.General.Slider_Value,'Units','Normalized','Position',[0 0.01 1 GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@Slider_Func);
			GUI_Parameters.Handles.Normalization_List = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','popup','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.6 1 GUI_Parameters.Visuals.Button1_Height],'String',{'Not Normalized'},'Callback',@Rerun_Plot_Func);
			GUI_Parameters.Handles.Plot_Type_List = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','popup','String',{'Default'},'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.5 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
			GUI_Parameters.Handles.Projection_Correction_Checkbox = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','checkbox','Value',1,'String','Apply Projection Correction','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.4 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
			
			GUI_Parameters.Handles.Analysis.Slider = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','slider','Min',0,'Max',1,'Value',GUI_Parameters.General.Slider_Value,'Units','Normalized','UserData',0,'Position',[0 0.01 .8 GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@Slider_Func);
			GUI_Parameters.Handles.Analysis.Slider_Text = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','edit','String',num2str(GUI_Parameters.General.Slider_Value),'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.8,.01,.2,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
			GUI_Parameters.Handles.Analysis.Dynamic_Slider_Min = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','slider','Min',0,'Max',1,'Value',0,'Units','Normalized','Position',[.15 0.02+GUI_Parameters.Visuals.Button1_Height .35 GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@Dynamic_Slider_Min_Func,'Enable','off');
			GUI_Parameters.Handles.Analysis.Dynamic_Slider_Text_Min = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','edit','String',num2str(0),'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0,.02+GUI_Parameters.Visuals.Button1_Height,.15,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
			GUI_Parameters.Handles.Analysis.Dynamic_Slider_Max = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','slider','Min',0,'Max',1,'Value',1,'Units','Normalized','Position',[.5 0.02+GUI_Parameters.Visuals.Button1_Height .35 GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@Dynamic_Slider_Max_Func,'Enable','off');
			GUI_Parameters.Handles.Analysis.Dynamic_Slider_Text_Max = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','edit','String',num2str(1),'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.85,.02+GUI_Parameters.Visuals.Button1_Height,.15,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
			
			% Display_Original_Image_CheckBox = uicontrol(GUI_Parameters.Handles.Display_Tab,'Style','checkbox','Value',0,'String','Display Original Image','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.2 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Display_Original_Image);
			% Tree_Center_CheckBox = uicontrol(GUI_Parameters.Handles.Display_Tab,'Style','checkbox','Value',0,'String','Display Tree Center','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.1 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Tree_Center_CheckBox_Func);
			% Display_Loops_CheckBox = uicontrol(GUI_Parameters.Handles.Display_Tab,'Style','checkbox','Value',0,'String','Display Loops','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Tree_Center_CheckBox_Func);
			% GUI_Parameters.Handles.Clusters_Data_List = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','popup','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.4 0.48 GUI_Parameters.Visuals.Button1_Height], ...
				% 'String',{'Not Clustered','k-means','Gaussian Mixture','Linkage'},'Callback',@Rerun_Plot_Func);
			% GUI_Parameters.Handles.Clusters_Evaluation_Algorithm_List = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','popup','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0.52 0.4 0.48 GUI_Parameters.Visuals.Button1_Height], ...
				% 'String',{'Eval. Method','Silhouette','Gap','DaviesBouldin','CalinskiHarabasz'},'Callback',@Rerun_Plot_Func);
			% GUI_Parameters.Handles.Merge_Dorsal_Ventral_CheckBox = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','checkbox','Value',0,'String','Merge Dorsal-Ventral','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
			% GUI_Parameters.Handles.Find_Peaks_CheckBox = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','checkbox','Value',0,'String','Find Peaks','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.6 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
		GUI_Parameters.Handles.Analysis.Filters_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Filters','BackgroundColor',[0.5,0.6,1]);
		GUI_Parameters.Handles.Analysis.Display_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Format','BackgroundColor',[0.5,0.6,1]);
			Flip_Contrast_CheckBox = uicontrol(GUI_Parameters.Handles.Analysis.Display_Tab,'Style','checkbox','Value',0,'String','Flip Contrast','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Rerun_Plot_Func);
		GUI_Parameters.Handles.Analysis.Details_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Details','BackgroundColor',[0.5,0.6,1]);
		% GUI_Parameters.Handles.Analysis.Virtual_Keyboard_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Virtual Keyboard','BackgroundColor',[0.5,0.6,1]);
		% GUI_Parameters.Handles.Groups_Filter_Panel = uipanel('Parent',GUI_Parameters.Handles.Filters_Tab,'Units','Normalized','Position',[0 0.86 1 .1],'BackgroundColor','w');
		% GUI_Parameters.Handles.Categories_Filter_Panel = uipanel('Parent',GUI_Parameters.Handles.Filters_Tab,'FontSize',12,'Units','Normalized','Position',[0 0.63 1 .2],'BackgroundColor','w');
		
		GUI_Parameters.Handles.Tracing_Tabs_Group = uitabgroup('Parent',GUI_Parameters.Handles.Edit_Panel,'Position',[0 0 1 1]);
		GUI_Parameters.Handles.Tracing.Project_Panel = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Project');
		GUI_Parameters.Handles.Tracing.Machine_Learning_Panel = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Pre-Processing');
		GUI_Parameters.Handles.Tracing.Tracing_Tab = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Tracing','BackgroundColor',[0.8,0.4,0.4]);
		GUI_Parameters.Handles.Tracing.Analysis_Tab = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Analysis');
	% assignin('base','GUI_Parameters',GUI_Parameters);
	
	% Machine Learning Panel:
	GUI_Parameters.Handles.Machine_Learning.Train_NN_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Train Neural Network','Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Multiple_Save_Plot_Func);
	GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Apply Neural Network To All Images','Units','Normalized','Position',[0 0.8 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Apply_NN_Func);
	set(GUI_Parameters.Handles.Machine_Learning.Train_NN_Button,'Enable','off');
	set(GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button,'Enable','off');
	
	% assignin('base','GUI_Parameters',GUI_Parameters);
	
	% Project Tab:
	GUI_Parameters.Single.Handles.Tracing(1).New_Trace_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Start a New Project',...
		'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Start_A_New_Project_Func,'TooltipString','Load a New Image to Trace and Analyze It');
	GUI_Parameters.Single.Handles.Tracing.Edit_Trace_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Load an Existing Project',...
			'Units','Normalized','Position',[0 0.8 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Load_An_Existing_Project_File,'TooltipString','Load a .mat File Containing One or More Projects of Previously Analyzed Image.');	
	GUI_Parameters.Single.Handles.Tracing.Create_Multiple_DB = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Create a Multiple Neurons DB',...
			'Units','Normalized','Position',[0 0.6 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Collect_Multiple_Workspaces,'TooltipString','Choose a directory that contains multiple workspaces of single neurons (also in subfolders) and create a new workspace that contains all of them.');	
	GUI_Parameters.Single.Handles.Tracing.Update_Multiple_DB = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Update Multiple Workspaces',...
			'Units','Normalized','Position',[0 0.5 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Update_Multiple_Workspaces,'TooltipString','Choose a directory that contains multiple workspaces of single neurons (also in subfolders) and run the current version of the code using the same parameters.');	
	
	Edit_Properties_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Export Image',...
		'Units','Normalized','Position',[0 0.31 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Export_Image_Func,'TooltipString','Save current axis as image.');
	Edit_Properties_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Change Project Properties',...
		'Units','Normalized','Position',[0 0.21 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@User_Input_Single_Func,'TooltipString','Click Here to Display and Change The Current Parameters Values of Your Project');
	Save_Project_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save Current Project',...
		'Units','Normalized','Position',[0 0.11 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_Tracing_Func,'UserData',1,'TooltipString','Save a .mat file of your project so you can load and revise it later');
	Save_Project_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save All Projects',...
		'Units','Normalized','Position',[0 0.01 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_Tracing_Func,'UserData',2,'TooltipString','Save a .mat file of your project so you can load and revise it later');
	
	% Tracing Tab:
	GUI_Parameters.Single.Handles.Tracing.Start_Tracing_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Tracing_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Start Tracing',...
			'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Start_Tracing_Func);
	% Get_Object_Details_Button = uicontrol(GUI_Parameters.Handles.Analysis.Details_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Get Details','Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Get_Object_Details_Func);
	
	GUI_Parameters.Handles.Im_Menu = uimenu(GUI_Parameters.Handles.Figure,'Label','Image','UserData',0);
	set(GUI_Parameters.Handles.Im_Menu,'Enable','off');
	
	Reconstructions_Menu_Handle = uimenu(GUI_Parameters.Handles.Figure,'Label','Reconstructions');
		H_Raw_Image = uimenu(Reconstructions_Menu_Handle,'Label','Raw Image');
			H_Recon_Original_Image = uimenu(H_Raw_Image,'Label','Raw Image - Grayscale','UserData',0,'Callback',@Reconstruction_Func);
			H_Recon_Original_Image_RGB = uimenu(H_Raw_Image,'Label','Raw Image - RGB','UserData',0,'Callback',@Reconstruction_Func);
		
		H_CNN = uimenu(Reconstructions_Menu_Handle,'Label','CNN');
			H_Recon_Probability_Image = uimenu(H_CNN,'Label','CNN Image - Grayscale','UserData',0,'Callback',@Reconstruction_Func);
			H_Recon_Probability_Image_RGB = uimenu(H_CNN,'Label','CNN Image - RGB','UserData',0,'Callback',@Reconstruction_Func);
		
		H_Binary = uimenu(Reconstructions_Menu_Handle,'Label','Binary Image');
			H_Recon_Binary_Image = uimenu(H_Binary,'Label','Binary Image','UserData',0,'Callback',@Reconstruction_Func);
			H_Recon_Binary_Image = uimenu(H_Binary,'Label','Raw + Binary Image - RGB','UserData',0,'Callback',@Reconstruction_Func);
		
		H_Recon_Skeleton_Image = uimenu(Reconstructions_Menu_Handle,'Label','Skeleton','UserData',0,'Callback',@Reconstruction_Func);
		
		H_Recon_CB = uimenu(Reconstructions_Menu_Handle,'Label','Cell Body','UserData',0,'Callback',@Reconstruction_Func);
		H_Recon_CB = uimenu(Reconstructions_Menu_Handle,'Label','Blob','UserData',0,'Callback',@Reconstruction_Func);
		
		uimenu(Reconstructions_Menu_Handle,'Label','Trace','UserData',0,'Callback',@Reconstruction_Func);
		
		H_Segments = uimenu(Reconstructions_Menu_Handle,'Label','Segments');
			uimenu(H_Segments,'Label','Segmentation','UserData',0,'Callback',@Reconstruction_Func);
			uimenu(H_Segments,'Label','Segments by Length','UserData',0,'Callback',@Reconstruction_Func);
		
		uimenu(Reconstructions_Menu_Handle,'Label','Individual Menorahs','UserData',0,'Callback',@Reconstruction_Func,'Enable','off');
		
		H_Vertices = uimenu(Reconstructions_Menu_Handle,'Label','Vertices');
			H1_Vertices_Angles = uimenu(H_Vertices,'Label','Angles');
				uimenu(H1_Vertices_Angles,'Label','Vertices Angles','UserData',2,'Callback',@Reconstruction_Func);
				uimenu(H1_Vertices_Angles,'Label','Vertices Angles - Corrected','UserData',2,'Callback',@Reconstruction_Func);
			H2_Vertices_Positions = uimenu(H_Vertices,'Label','Positions');
				uimenu(H2_Vertices_Positions,'Label','3-Way Junctions - Position','UserData',2,'Callback',@Reconstruction_Func);
				uimenu(H2_Vertices_Positions,'Label','Tips - Position','UserData',2,'Callback',@Reconstruction_Func);
		H0_1_8 = uimenu(Reconstructions_Menu_Handle,'Label','Axes');
			uimenu(H0_1_8,'Label','Axes','UserData',0,'Callback',@Display_Neuron_Axes);
			uimenu(H0_1_8,'Label','Axes Mapping Process','UserData',0,'Callback',@Reconstruction_Func);
		uimenu(Reconstructions_Menu_Handle,'Label','Radial Distance','UserData',0,'Callback',@Reconstruction_Func);
		uimenu(Reconstructions_Menu_Handle,'Label','Angular Coordinate','UserData',0,'Callback',@Reconstruction_Func);
		uimenu(Reconstructions_Menu_Handle,'Label','Midline Orientation','UserData',0,'Callback',@Reconstruction_Func);
		uimenu(Reconstructions_Menu_Handle,'Label','Longitudinal Gradient','UserData',0,'Callback',@Reconstruction_Func,'Enable','off');
		uimenu(Reconstructions_Menu_Handle,'Label','Curvature','UserData',0,'Callback',@Reconstruction_Func);
		uimenu(Reconstructions_Menu_Handle,'Label','Dorsal-Ventral','UserData',0,'Callback',@Reconstruction_Func);
		H0_1_7 = uimenu(Reconstructions_Menu_Handle,'Label','PVD Orders');
			uimenu(H0_1_7,'Label','PVD Orders - Points','UserData',0,'Callback',@Reconstruction_Func);
			uimenu(H0_1_7,'Label','PVD Orders - Segments','UserData',0,'Callback',@Reconstruction_Func);
	set(allchild(Reconstructions_Menu_Handle),'Enable','off');
	% set(H0_1_2_4,'Enable','off');
	
	Graphs_Menu_Handle = uimenu(GUI_Parameters.Handles.Figure,'Label','Analysis Plots');
		
		H_Menu1_Length = uimenu(Graphs_Menu_Handle,'Label','Length');
				uimenu(H_Menu1_Length,'Label','Neuronal Length per Menorah Order','UserData',1,'Callback',@Menu1_Plots_Func);
				uimenu(H_Menu1_Length,'Label','Mean Segment Length','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
				uimenu(H_Menu1_Length,'Label','Distribution of Segment Lengths Per Order','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
				uimenu(H_Menu1_Length,'Label','Segment Linearity','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
				uimenu(H_Menu1_Length,'Label','End2End Length Of Segments','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','off');
		
		H_Menu2_Counts = uimenu(Graphs_Menu_Handle,'Label','Count / Density');
			uimenu(H_Menu2_Counts,'Label','Junction Number/Density','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
			uimenu(H_Menu2_Counts,'Label','Tip Number/Density','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
			uimenu(H_Menu2_Counts,'Label','Number of Segments','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
			uimenu(H_Menu2_Counts,'Label','Number of Menorahs','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
			
		H_Menu3_Curvature = uimenu(Graphs_Menu_Handle,'Label','Curvature');
			uimenu(H_Menu3_Curvature,'Label','Curvature Per Menorah Order','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
			uimenu(H_Menu3_Curvature,'Label','Curvature Distribution','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
			uimenu(H_Menu3_Curvature,'Label','Max Segment Curvature per Menorah Order','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','on');
		
		H_Menu2_CB = uimenu(Graphs_Menu_Handle,'Label','Cell Body','Callback','');
			H_Menu21_CB = uimenu(H_Menu2_CB,'Label','CB Intensity','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','off');
			H_Menu22_CB = uimenu(H_Menu2_CB,'Label','CB Area','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','off');
		
		H_Menu3_Vertices = uimenu(Graphs_Menu_Handle,'Label','Vertices','Callback','');
			H_Menu31_Angles = uimenu(H_Menu3_Vertices,'Label','Angles','Callback','');
				H_Menu311 = uimenu(H_Menu31_Angles,'Label','Histograms','Callback','');
					uimenu(H_Menu311,'Label','Histogram of all Angles','UserData',2,'Callback',@Menu1_Plots_Func);
					uimenu(H_Menu311,'Label','Angles of Menorah Orders','UserData',2,'Callback',@Menu1_Plots_Func);
					uimenu(H_Menu311,'Label','Midline Distance of Tips','UserData',2,'Callback',@Menu1_Plots_Func);
					uimenu(H_Menu311,'Label','Histogram of Symmetry Indices','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','on');
					uimenu(H_Menu311,'Label','Histogram of the Largest Angle','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','on');
					uimenu(H_Menu311,'Label','Signed Midline Orientation of Junction Rectangles','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','on');
					uimenu(H_Menu311,'Label','Distribution of Vertices Angles Relative To The Medial Axis','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					uimenu(H_Menu311,'Label','Distribution of Vertices Angles Relative To The Medial Axis - Corrected','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					uimenu(H_Menu311,'Label','Histogram of Smallest, Mid & Largest Angles','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','on');
					uimenu(H_Menu31_Angles,'Label','Distribution of the Difference between Vertex and End2End Angles','UserData',1,'Callback',@Menu1_Plots_Func,'Enable','off');
				H_Menu312 = uimenu(H_Menu31_Angles,'Label','Two Angles Plots','Callback','');
					H_Menu3120 = uimenu(H_Menu312,'Label','Menorah Orders of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3121 = uimenu(H_Menu312,'Label','All Angles VS Midline Distance','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3122 = uimenu(H_Menu312,'Label','Minimal and Maximal Angles of 3-Way junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3123 = uimenu(H_Menu312,'Label','The Two Minimal Angles of each 3-Way junction','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					H_Menu3124 = uimenu(H_Menu312,'Label','Linearity-Symmetry of 3-Way junctions','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','on');
					H_Menu3125 = uimenu(H_Menu312,'Label','Sum of 2 Smallest VS Product of 2 Smallest','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					H_Menu3126 = uimenu(H_Menu312,'Label','Smallest Angle VS Diff between 2 Smallest','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
				H_Menu313 = uimenu(H_Menu31_Angles,'Label','Three Angles Plots','Callback','');
					H_Menu3131 = uimenu(H_Menu313,'Label','2D Histogram Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					H_Menu3132 = uimenu(H_Menu313,'Label','2D Histogram of Corrected Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					H_Menu3133 = uimenu(H_Menu313,'Label','2D Histogram of Invariant Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
					H_Menu3134 = uimenu(H_Menu313,'Label','2D Histogram of Invariant Corrected Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
				
			H_Menu32_Angles = uimenu(H_Menu3_Vertices,'Label','Distances','Callback','');
				uimenu(H_Menu32_Angles,'Label','Inter-Tip Distance','UserData',2,'Callback',@Menu1_Plots_Func);
				uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The Medial Axis - Means','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
				uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The Medial Axis - Histogram','UserData',2,'Callback',@Menu1_Plots_Func);
				uimenu(H_Menu32_Angles,'Label','Distances Of 3-Way Junctions From The Medial Axis - Histogram','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
				uimenu(H_Menu32_Angles,'Label','Distances Of Tips From The Medial Axis - Histogram','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
				uimenu(H_Menu32_Angles,'Label','Smallest Angle VS Distance From Medial Axis','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
				uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The CB','UserData',2,'Callback',@Menu1_Plots_Func,'Enable','off');
			uimenu(H_Menu3_Vertices,'Label','Angles VS Midline Distance','UserData',2,'Callback',@Menu1_Plots_Func);
		H_Menu4_Orientation = uimenu(Graphs_Menu_Handle,'Label','Midline Orientation','Callback','');
			H_Menu41_Orientation_Distribution = uimenu(H_Menu4_Orientation,'Label','Distribution of Midline Orientation','Callback',@Menu1_Plots_Func);
			H_Menu42_Orientation_VS_Arclength_2D_Hist = uimenu(H_Menu4_Orientation,'Label','Distribution of Midline Orientation Along the Midline','Callback',@Menu1_Plots_Func);
			H_Menu43_Orientation_VS_Arclength_2D_Hist = uimenu(H_Menu4_Orientation,'Label','Distribution of Midline Orientation Along the Midline - Vertices Only','Callback',@Menu1_Plots_Func);
				% H_Menu1321_Primary_Vertices_Mean_Distance = uimenu(H_Menu132_Distances,'Label','Primary_Vertices_Mean_Distance','UserData',1,'Callback',@Menu1_Plots_Func);
			% H_Menu133_Vertices_Density = uimenu(H_Menu13_Vertices,'Label','Density of Vertices','UserData',1,'Callback',@Menu1_Plots_Func);			
		
		H_Menu6_Distance = uimenu(Graphs_Menu_Handle,'Label','Radial Distance','Callback','');
			uimenu(H_Menu6_Distance,'Label','Radial Distance of All Points','Callback',@Menu1_Plots_Func);
			uimenu(H_Menu6_Distance,'Label','Radial Distance of All Points - Second Moment','Callback',@Menu1_Plots_Func);
			uimenu(H_Menu6_Distance,'Label','Radial Distance of 3-Way Junctions','Callback',@Menu1_Plots_Func);
			uimenu(H_Menu6_Distance,'Label','Radial Distance of Tips','Callback',@Menu1_Plots_Func);
			
		H_Menu8_Angular = uimenu(Graphs_Menu_Handle,'Label','Angular Coordinate','Callback','');
			uimenu(H_Menu8_Angular,'Label','Angular Coordinate of All Points','Callback',@Menu1_Plots_Func);
			uimenu(H_Menu8_Angular,'Label','Angular Coordinate of Junctions','Callback',@Menu1_Plots_Func);
			uimenu(H_Menu8_Angular,'Label','Angular Coordinate of Tips','Callback',@Menu1_Plots_Func);
			uimenu(H_Menu8_Angular,'Label','Angular Coordinate of All Points - Second Moment','Callback',@Menu1_Plots_Func);
		
		H_Menu7_Midline_Density = uimenu(Graphs_Menu_Handle,'Label','Menorah Orders','Callback','');
			uimenu(H_Menu7_Midline_Density,'Label','Menorah Orders Classification','UserData',2,'Callback',@Menu1_Plots_Func);
			uimenu(H_Menu7_Midline_Density,'Label','Midline Density - Neuronal Length','UserData',2,'Callback',@Menu1_Plots_Func);
			uimenu(H_Menu7_Midline_Density,'Label','Density of Points per Menorah order','UserData',2,'Callback',@Menu1_Plots_Func);
		H_Menu5_2D_Plots = uimenu(Graphs_Menu_Handle,'Label','2D Plots','Callback','');
			uimenu(H_Menu5_2D_Plots,'Label','Midline Distance VS Midline Orientation','UserData',2,'Callback',@Menu1_Plots_Func);
			uimenu(H_Menu5_2D_Plots,'Label','Midline Distance VS Curvature','UserData',2,'Callback',@Menu1_Plots_Func);
			uimenu(H_Menu5_2D_Plots,'Label','Midline Orientation VS Curvature','UserData',2,'Callback',@Menu1_Plots_Func);
			uimenu(H_Menu5_2D_Plots,'Label','Midline Orientation VS Curvature VS Midlines Distance','UserData',2,'Callback',@Menu1_Plots_Func);
            
	set(allchild(Graphs_Menu_Handle),'Enable','off');
	
	GUI_Parameters.Handles.Figure.Visible = 'on'; % Make figure visible after adding all components.
	
	function Apply_NN_Func(source,callbackdata)
		
		if(nargin == 2)
			File1 = load('My_CNN_13.mat'); % My_CNN_8
			NN1 = File1.My_CNN; % TODO: choose the only variable from the file without specifying the name.
			clear File1;
			% GUI_Parameters(1).Neural_Network(1).Directory = strcat(PathName,FileName);
		end
		
		NN_Threshold_0 = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Threshold;
		NN_Min_Object_Size_0 = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Min_CC_Size;
			
		GUI_Parameters.Handles.Machine_Learning.Probability_Slider = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','slider','Min',0,'Max',1,'Value',NN_Threshold_0,'SliderStep',[0.05,0.05],'Units','Normalized','Position',[0,.6,.8,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@NN_Probability_Slider_Func);
		GUI_Parameters.Handles.Machine_Learning.Probability_Slider_Text = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','edit','String',num2str(NN_Threshold_0),'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.8,.6,.2,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
		
		GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Slider = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','slider','Min',0,'Max',5000,'Value',NN_Min_Object_Size_0,'SliderStep',[.01,.01],'Units','Normalized','Position',[0,.4,.8,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@NN_Min_Obejct_Size_Slider_Func);
		GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Text = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','edit','String',num2str(NN_Min_Object_Size_0),'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.8,.4,.2,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
			
		% GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Undo','Units','Normalized','Position',[0 0.11 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Undo_Func);
		GUI_Parameters.Handles.Machine_Learning.Save_Training_Sample = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save As Training Sample','Units','Normalized','Position',[0 .01 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_Training_Sample_Func); % ,'Enable','off');
		
		% [Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(end).Workspace.Image0);
		
		% Apply NN to all images:
		All_Enabled_Objects_0 = findobj(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Enable','on');
		set(All_Enabled_Objects_0,'Enable','off');
		WB_H_NN = waitbar(0,'Applying Neural Network to all Images. Please wait...');
		waitbar(0,WB_H_NN);
		
		for fi=1:numel(GUI_Parameters.Workspace)
			waitbar(fi/numel(GUI_Parameters.Workspace),WB_H_NN);
			
			if(~isfield(GUI_Parameters.Workspace(fi).Workspace,'Im_BW') || isempty(GUI_Parameters.Workspace(fi).Workspace.Im_BW))
				[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(fi).Workspace.Image0);
				
				CB_BW_Threshold = GUI_Parameters.Workspace(fi).Workspace.Parameters.Cell_Body.BW_Threshold;
				Scale_Factor = GUI_Parameters.Workspace(fi).Workspace.User_Input.Scale_Factor;

				[CB_Pixels,~] = Detect_Cell_Body(GUI_Parameters.Workspace(fi).Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
				GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities = GUI_Parameters.Workspace(fi).Workspace.Image0;
				GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities(CB_Pixels) = 0;
				
				
				GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities = Apply_CNN_Im2Im(NN1,GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities); % GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities = Apply_Trained_Network(NN1,GUI_Parameters.Workspace(fi).Workspace.Image0);
				
				
				GUI_Parameters.Workspace(fi).Workspace.Im_BW = zeros(Im_Rows,Im_Cols);
				GUI_Parameters.Workspace(fi).Workspace.Im_BW(find(GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities >= NN_Threshold_0)) = 1;
				% [GUI_Parameters.Workspace(fi).Workspace.NN_Probabilities,GUI_Parameters.Workspace(fi).Workspace.Im_BW] = Apply_NN(GUI_Parameters.Workspace(fi).Workspace.Image0,NN1,GUI_Parameters.Handles.Machine_Learning.Probability_Slider.Value,Im_Rows,Im_Cols,0);
				% Update NN threshold:
				GUI_Parameters.Workspace(fi).Workspace.Parameters.Neural_Network.Threshold = NN_Threshold_0;
				GUI_Parameters.Workspace(fi).Workspace.Parameters.Neural_Network.Min_CC_Size = NN_Min_Object_Size_0; % Min object size for the BW image.
			end
		end
		delete(WB_H_NN);
		
		% Create buttons for editing the BW reconstruction (before tracing):
		GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group = uibuttongroup(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Position',[.05,0.2,1,0.1],'BorderType','none');
		Marker_Sizes = [0,1,2,3,5,10];
		for ii=1:length(Marker_Sizes)
			GUI_Parameters.Handles.BW_Editing.MarkerSize1{ii} = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String',num2str(Marker_Sizes(ii)),'UserData',Marker_Sizes(ii),'Units','normalized','FontSize',18,'Position',[0.15*(ii-1),0.4,.5,.5]);
		end
		
		set(All_Enabled_Objects_0,'Enable','on');
		set(H_Raw_Image,'Enable','on');
		set(H_CNN,'Enable','on');
		set(H_Binary,'Enable','on');
		set(H_Recon_Skeleton_Image,'Enable','on');
		
		GUI_Parameters.General.Active_Plot = 'Binary Image';
		GUI_Parameters.General.Active_View = 1; % Reconstruction mode.
		% Reconstruction_Func(); % Display the BW of the current chosen image (in the image menu).
		
		function NN_Probability_Slider_Func(source,event) % Slider for controlling the threshold of the probability matrix.
			All_Enabled_Objects_1 = findobj(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Enable','on');
			set(All_Enabled_Objects_1,'Enable','off');
			set(GUI_Parameters.Handles.Machine_Learning.Probability_Slider_Text,'String',source.Value); % Update the NN threshold in the text box.
			
			if(isfield(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace,'NN_Probabilities') || ~isempty(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.NN_Probabilities))
				GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW = imbinarize(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.NN_Probabilities,source.Value);
			end
			
			% Apply the CC size thresholding to the updated BW image:
			CC = bwconncomp(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW);
			Nc = cellfun(@length,CC.PixelIdxList);
			Fc = find(Nc <= GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Min_CC_Size);
			for c=Fc
				GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW(CC.PixelIdxList{1,c}) = 0;
			end
			
			% GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW = Im_BW0; % Update the BW image to the workspace.
			GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Threshold = source.Value; % Update the new threshold value to the workspace.
			
			Reconstruction_Func(0);
			
			set(All_Enabled_Objects_1,'Enable','on');
		end
		
		function NN_Min_Obejct_Size_Slider_Func(source,event) % Slider for controlling minimum object size.
			All_Enabled_Objects_1 = findobj(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Enable','on');
			set(All_Enabled_Objects_1,'Enable','off');
			set(GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Text,'String',source.Value);
			
			CC = bwconncomp(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW);
			Nc = cellfun(@length,CC.PixelIdxList);
			Fc = find(Nc <= GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Min_CC_Size);
			for c=Fc
				GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW(CC.PixelIdxList{1,c}) = 0;
			end
			
			GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Min_CC_Size = source.Value; % Update the minimum object size.
			
			Reconstruction_Func(0);
			
			set(All_Enabled_Objects_1,'Enable','on');
		end
		
		%{
		function Save_BW_Func(source,callbackdata)
			imwrite(GUI_Parameters.Workspace(end).Workspace.Image0,[uigetdir,filesep,GUI_Parameters.Handles.FileName,'Source.tif']);
			imwrite(GUI_Parameters.Workspace(end).Workspace.Im_BW,[uigetdir,filesep,GUI_Parameters.Handles.FileName,'_Annotated.tif']);
		end
		%}
		% GUI_Parameters.Workspace(end).Workspace.User_Input.BW_Edited = 1;		
		
		function Save_Training_Sample_Func(source,event)
			Dir1 = uigetdir; % Let the user choose a directory.
			Files_List = dir(Dir1); % List of files.
			F1_Im = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Image0;
            F2_BW = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW;
			if(~isempty(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW))
				uisave({'F1_Im','F2_BW'},[GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.User_Input.File_Name(1:end-4),'_Anotated']);
			end
		end
	end
	
	function Mouse_Edit_BW_Func(source,event)
		MarkerSize_1 = GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group.SelectedObject.UserData;
		
		if(strcmp(GUI_Parameters.General.Active_Plot,'Binary Image') || strcmp(GUI_Parameters.General.Active_Plot,'Raw + Binary Image - RGB'))
			
			Im_Rows = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.General_Parameters.Im_Rows;
			Im_Cols = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.General_Parameters.Im_Cols;
			
			if(MarkerSize_1 == 0)
				xy0 = event.IntersectionPoint; % Clicked point.
				CC = bwconncomp(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW);
				Vc = nan(1,length(CC.PixelIdxList)); % Vector of minimal distance from the connected objects.
				for ii=1:length(CC.PixelIdxList)
					[y,x] = ind2sub([Im_Rows,Im_Cols],CC.PixelIdxList{ii});
					Vc(ii) = min( ((xy0(1) - x).^2 + (xy0(2) - y).^2).^(0.5) );
				end
				GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW(CC.PixelIdxList{find(Vc == min(Vc),1)}) = 0;
			else
				D = round((MarkerSize_1-1)/2);
				C = event.IntersectionPoint;
				C = [round(C(1)),round(C(2))];
				Cxy = combvec(C(1)-D:C(1)+D , C(2)-D:C(2)+D);
				
				Ci = (Im_Rows*(Cxy(1,:)-1)+Cxy(2,:)); % Linear indices.
				
				switch event.Button
					case 1 % Left mouse click - add pixels.
						GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW(Ci) = 1;
					case 3 % Right mouse click - delete pixels.
						GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Im_BW(Ci) = 0;
				end
			end
			Reconstruction_Func();
		end
	end
	
	function Start_A_New_Project_Func(source,callbackdata)
		% {['..',filesep,'*.tif'];['..',filesep,'*.jpg'],'Image Files'}
		[FileNames,PathName,~] = uigetfile(fullfile(pwd,'..',filesep,'*.tif;*.jpg'),'Please Choose an Image File.',cd,'MultiSelect','on'); % Lets the user choose a file.
		if(~length(FileNames))
			return;
		elseif(iscell(FileNames))
			GUI_Parameters.Handles.FileNames = FileNames;
		else
			GUI_Parameters.Handles.FileNames = {FileNames};
		end
		Current_Dir = cd(PathName);
		
		H1 = uipanel(GUI_Parameters.Handles.Main_Panel,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.3 0.1 0.4 0.8]);
			uicontrol(H1,'Style','text','FontSize',20,'BackgroundColor',[0.7,0.7,0.7],'String','Project Properties','Units','Normalized','Position',[0 0.93 1 0.07],'FontSize',28);
			Continue_Button = uicontrol(H1,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button2_Font_Size,'String','Continue','Units','Normalized','Position',[0 0 1 0.1],'Callback',@Continue_Func);
			
			% uicontrol(H1,'Style','text','units','Normalized','Position',[0,0.7,0.35,0.05],'String','Tracing Method:','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
			% Tracing_Method_Buttons = uibuttongroup(H1,'Position',[0.35,0.7,0.6,0.05],'BorderType','none');
			% uicontrol(Tracing_Method_Buttons,'Style','radiobutton','String','Manual','UserData',2,'Units','normalized','FontSize',18,'Position',[0,0,0.5,1],'BackgroundColor',[0.5,0.5,0.5]);
			% uicontrol(Tracing_Method_Buttons,'Style','radiobutton','String','Automatic','UserData',1,'Units','normalized','FontSize',18,'Position',[0.5,0,0.5,1],'BackgroundColor',[0.5,0.5,0.5]);
			
			uicontrol(H1,'Style','text','units','Normalized','Position',[0,.8,0.3,0.05],'String','Scale-Bar:','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
			
			uicontrol(H1,'Style','text','units','Normalized','Position',[0.35,0.85,0.2,0.05],'String','Pixels','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
			uicontrol(H1,'Style','text','units','Normalized','Position',[0.6,0.85,0.2,0.05],'String','Length','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
			uicontrol(H1,'Style','text','units','Normalized','Position',[0.81,0.85,0.15,0.05],'String','Unit','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
			
			User_Input.Scale_Bar.Pixels = uicontrol(H1,'style','edit','units','Normalized','position',[0.36,.8,0.2,0.05],'String','140','UserData','','FontSize',24); % 4.5.
			User_Input.Scale_Bar.Length = uicontrol(H1,'style','edit','units','Normalized','position',[0.6,.8,0.2,0.05],'String','50','UserData','','FontSize',24); % 1.
			User_Input.Scale_Bar.Unit = uicontrol(H1,'Style','popup','Units','Normalized','Position',[0.81,.8,0.15,0.05], ...
					'FontSize',16,'String',{[char(181),'m'],'nm','mm','km'});
			User_Input.BW_Edited = 0;
		
		Properties_Handles = struct('Property_Name',{},'Property_Value',{});
		
		p = 1; % A GUI parameter.
		Y0 = 0.65; % A GUI parameter.
		
		Properties_Handles(1).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06,0.45,0.05],'String','Creator Name','UserData','','FontSize',20);
			Properties_Handles(1).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06,0.45,0.05],'String','','UserData','','FontSize',20);
			
			Properties_Handles(2).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*2,0.45,0.05],'String','Neuron Name','UserData','','FontSize',20);
			Properties_Handles(2).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*2,0.45,0.05],'String','PVDL','UserData','','FontSize',20);
			
			Properties_Handles(3).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*3,0.45,0.05],'String','Age','UserData','','FontSize',20);
			Properties_Handles(3).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*3,0.45,0.05],'String','Young Adult','UserData','','FontSize',20);
			
			Properties_Handles(4).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*4,0.45,0.05],'String','Sex','UserData','','FontSize',20);
			Properties_Handles(4).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*4,0.45,0.05],'String','Hermaphrodite','UserData','','FontSize',20);
					
			Properties_Handles(5).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*5,0.45,0.05],'String','Genotype','UserData','','FontSize',20);
			Properties_Handles(5).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*5,0.45,0.05],'String','asic-1;degt-1','UserData','','FontSize',20);
			
			Properties_Handles(6).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*6,0.45,0.05],'String','Strain','UserData','','FontSize',20);
			Properties_Handles(6).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*6,0.45,0.05],'String','BP1028','UserData','','FontSize',20);
			
			Properties_Handles(7).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*7,0.45,0.05],'String','Grouping','UserData','','FontSize',20);
			Properties_Handles(7).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*7,0.45,0.05],'String','Crowded','UserData','','FontSize',20);
			
			Add_Property_Button = uicontrol(H1,'style','pushbutton','units','Normalized','position',[0.04,Y0-0.06*8.1,0.2,0.05],'String','+','FontSize',20,'Callback',@Add_Property_Func);
		
		p = 7;
		function Add_Property_Func(source1,callbackdata1)
			p = p + 1;
			set(Add_Property_Button,'Position',[0.04,Y0-0.06*(p+1.1),0.2,0.05]);
			Properties_Handles(p).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*p,0.45,0.05],'String','Property Name','UserData','','FontSize',20);
			Properties_Handles(p).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*p,0.45,0.05],'String','Property Value','UserData','','FontSize',20);
		end
		
		function Continue_Func(source1,callbackdata1)
			
			GUI_Parameters.Workspace = struct('Workspace',{}); % Reset the Workspace.
			
			Lf = length(GUI_Parameters.Handles.FileNames);
			for fi=1:Lf % For each loaded image.
				GUI_Parameters.Workspace(fi).Workspace.Im_BW = [];
				
				% Set the scale-bar:
				GUI_Parameters.Workspace(fi).Workspace.User_Input(1).Scale_Factor = str2num(User_Input.Scale_Bar.Length.String) / str2num(User_Input.Scale_Bar.Pixels.String);
				GUI_Parameters.Workspace(fi).Workspace.User_Input(1).Scale_Unit = User_Input.Scale_Bar.Unit.String(User_Input.Scale_Bar.Unit.Value);
				
				for i=1:numel(Properties_Handles)
					GUI_Parameters.Workspace(fi).Workspace.User_Input.Features.(strrep(Properties_Handles(i).Property_Name.String,' ','_')) = ...
						strrep(Properties_Handles(i).Property_Value.String,' ','_');
				end
				
				GUI_Parameters.Workspace(fi).Workspace.Parameters = Parameters_Func(GUI_Parameters.Workspace(fi).Workspace.User_Input.Scale_Factor);
				
				GUI_Parameters.Workspace(fi).Workspace.Image0 = imread(strcat(PathName,GUI_Parameters.Handles.FileNames{fi}));
				GUI_Parameters.Workspace(fi).Workspace.User_Input.File_Name = GUI_Parameters.Handles.FileNames{fi};
				
				% Convert the loaded image to the default format (uint8, [0,255]):
				GUI_Parameters.Workspace(fi).Workspace.Image0 = GUI_Parameters.Workspace(fi).Workspace.Parameters.General_Parameters.Image_Format(GUI_Parameters.Workspace(fi).Workspace.Image0);
				
				[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(fi).Workspace.Image0);
				GUI_Parameters.Workspace(fi).Workspace.Parameters.General_Parameters.Im_Rows = Im_Rows;
				GUI_Parameters.Workspace(fi).Workspace.Parameters.General_Parameters.Im_Cols = Im_Cols;
				
				uimenu(GUI_Parameters.Handles.Im_Menu,'Label',GUI_Parameters.Workspace(fi).Workspace.User_Input.File_Name,'UserData',fi,'Callback',@Image_Menu_Func);
			end
			delete(H1);
			
			% Activate the Image menu and specific reconstruction options:
			set(GUI_Parameters.Handles.Im_Menu,'Enable','on','UserData',1); % Set the Image menu to display the last image (appears first in the menu).
			set(allchild(GUI_Parameters.Handles.Im_Menu),'Checked','off');
			set(GUI_Parameters.Handles.Im_Menu.Children(end),'Checked','on'); % The objects are stored in GUI_Parameters.Handles.Im_Menu in reverse order.
			GUI_Parameters.General.Active_Plot = 'Cell Body';
			GUI_Parameters.General.Active_View = 1; % Reconstruction mode.
			% imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes); % Display the image just to initialize the axes.
			Reconstruction_Func(1);
			set(H_Recon_Original_Image,'Enable','on');
			set(H_Recon_CB,'Enable','on');
			
			% Enable the tracing list:
			% set(H0_1_2,'Enable','on');
			% set(allchild(H0_1_2),'Enable','on');
			% set(Display_List,'Enable','off');
		end
		
		set(GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button,'Enable','on');
	end
	
	function Load_An_Existing_Project_File(source,callbackdata)
		if(nargin == 2) % Default: user loads a file with 1+ neurons.
			if isunix
				filetypestr = '../../*.mat';
			else
				filetypestr = '..\..\*.mat';
			end
			[FileName,PathName] = uigetfile(filetypestr,'Please Choose a .mat File.',cd); % Lets the user choose a file.
			if(FileName == 0)
				return;
			end
			Current_Dir = cd(PathName);
			
			WB_H = waitbar(0,'Please wait...');
			waitbar(0,WB_H);
			File1 = load(strcat(PathName,FileName));
			waitbar(1/3,WB_H);
			
			GUI_Parameters.Workspace = File1.Workspace;
		else %  A workspace at the end of the tracing OR after generating an All_Workspaces file.
			WB_H = waitbar(0,'Please wait...');
			waitbar(0,WB_H);
		end
		
		[GUI_Parameters.Workspace,GUI_Parameters.Features] = Add_Features_To_All_Workspaces(GUI_Parameters.Workspace); % TODO: replace with automatic detection of features.
		waitbar(2/3,WB_H);
		
		% Activate Menus:
		for wi=1:numel(GUI_Parameters.Workspace)
			if(isfield(GUI_Parameters.Workspace(wi).Workspace.User_Input,'File_Name'))
				uimenu(GUI_Parameters.Handles.Im_Menu,'Label',GUI_Parameters.Workspace(wi).Workspace.User_Input.File_Name,'UserData',wi,'Callback',@Image_Menu_Func);
			else
				uimenu(GUI_Parameters.Handles.Im_Menu,'Label',['Image ',num2str(wi)],'UserData',wi,'Callback',@Image_Menu_Func);
			end
		end
		
		set(GUI_Parameters.Handles.Im_Menu,'UserData',1); % Set the Image menu to display the last image (appears first in the menu).
		set(allchild(GUI_Parameters.Handles.Im_Menu),'Checked','off');
		set(GUI_Parameters.Handles.Im_Menu.Children(end),'Checked','on'); % The objects are stored in GUI_Parameters.Handles.Im_Menu in reverse order.
		GUI_Parameters.General.Active_View = 1;
		GUI_Parameters.General.Active_Plot = 'Segmentation';
		
		if(numel(GUI_Parameters.Workspace) == 1 && isfield(GUI_Parameters.Workspace.Workspace,'Image0')) % If only one file that contains the original image (right after tracing).
			[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(1).Workspace.Image0);
			GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Im_Rows = Im_Rows;
			GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Im_Cols = Im_Cols;
			
			% Load the features of this file:
			Fields_Names = fieldnames(GUI_Parameters.Workspace(1).Workspace.User_Input.Features);
			for i=1:numel(Fields_Names)
				S1 = char(Fields_Names(i));
				GUI_Parameters.Workspace(1).Values(1).(S1) = GUI_Parameters.Workspace(1).Workspace.User_Input.Features.(S1);
			end
			
			% GUI_Parameters.General.Active_Plot = 'Original Image';
			GUI_Parameters.General.Groups_OnOff = 1;
			
			Reconstruction_Func();
			
			% Detect and display CB and the outsets of the branches connected to it:
			CB_BW_Threshold = GUI_Parameters.Workspace.Workspace.Parameters.Cell_Body.BW_Threshold;
			Scale_Factor = GUI_Parameters.Workspace.Workspace.User_Input.Scale_Factor;
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(GUI_Parameters.Workspace.Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(GUI_Parameters.Workspace.Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
			% set(Reconstructions_Menu_Handle,'Enable','on');
		else
			Reconstruction_Func();
		end
		
		set(GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button,'Enable','on');
		
		Features_Buttons_Handles = [];
		GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles = [];
		% Remove_Feature_Buttons_Handles = [];
		Generate_Filter_Buttons();
		waitbar(1,WB_H);
		delete(WB_H);
		
		% GUI_Parameters.General.Single_Multiple = 1; % Single Image Analysis.
		% set(Groups_Buttons(1),'Enable','on');
		% set(H0_1_2,'Enable','on');
		% set(allchild(H0_1_2),'Enable','on');
		
		set(GUI_Parameters.Handles.Im_Menu,'Enable','on');
		set(Reconstructions_Menu_Handle,'Enable','on');
		set(allchild(Reconstructions_Menu_Handle),'Enable','on');
		
		set(Graphs_Menu_Handle,'Enable','on');
		set(allchild(Graphs_Menu_Handle),'Enable','on');
		
		% assignin('base','GUI_Parameters',GUI_Parameters);
		% assignin('base','Features_Buttons_Handles',Features_Buttons_Handles);
		function Generate_Filter_Buttons
			% Field_Names = fieldnames(GUI_Parameters.Workspace); % Extract feature fields names.
			
			Field_Names = {GUI_Parameters.Features.Feature_Name}; % Extract feature fields names.
			F1 = 1:length(Field_Names); % [7,5]; % TODO: temporarily choosing these features only. find([GUI_Parameters.Features.Num_Of_Options] > 1);
			
			Features_Buttons_Handles = zeros(10,length(Field_Names)); % Features buttons. 10 is the maximum number of buttons per feature (1st row is an ON\OFF button).
			GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles = zeros(1,length(Field_Names)); % ON\OFF title buttons. 10 is the maximal number of buttons per feature (1st row is an ON\OFF button).
			
			ff = 0;
			bb = 0;
			
			for f=1:length(F1) % For each field (=feature) (except the 1st field which is the workspace).
				V = unique([GUI_Parameters.Workspace.(Field_Names{f})]);
				N = length(V); % Number of values in a specific field.
				if(N > 1) % If the field contains more than one value.
					
					ff = ff + 1;
					for b=1:min(N,numel(GUI_Parameters.Features(F1(f)).Values)) % Generate N buttons.
						Features_Buttons_Handles(b,f) = uicontrol(GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','pushbutton',...
							'String',GUI_Parameters.Features(F1(f)).Values(b).Name, ...
							'UserData',[F1(f),b],'Callback',@Categories_Filter_Func,'Units','normalized','Position',[.03+(ff-1)*(.44),(.92-.08*b),0.42,0.07], ...
							'FontSize',GUI_Parameters.Visuals.Button3_Font_Size,'BackgroundColor',[.9,.9,.9],'Callback',@Features_Buttons_Func);
					end
					GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles(f) = uicontrol(GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,...
					'UserData',[f,F1(f),1],'Units','Normalized','Position',[.03+(ff-1)*(.44),0.92,0.42,0.07],... % UserData=[f,F(f),ON\OFF].
					'BackgroundColor',[.2,.8,.4],'String',Field_Names{f},'Callback',@Features_OnOff_Buttons_Func);
				
					% Remove_Feature_Buttons_Handles(f) = uicontrol(GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'UserData',[f,F1(f)], ...
					% 		'Units','Normalized','Position',[.03+(f-1)*(.44),0.1,0.42,0.09],'BackgroundColor',[.2,.8,.4],'String','Remove','Callback',@Remove_Feature_Buttons_Func);
					% set(Remove_Feature_Buttons_Handles,'Enable','off');
				end
			end
			% % set(allchild(GUI_Parameters.Handles.Groups_Filter_Panel),'Enable','off');
			% assignin('base','GUI_Parameters1',GUI_Parameters);
		end
		
		function Features_Buttons_Func(source,callbackdata)
			if(GUI_Parameters.Features(source.UserData(1)).Values(source.UserData(2)).ON_OFF) % Feature is ON ->  Switch OFF.
				set(source,'BackgroundColor',[.3,.3,.3]);
				GUI_Parameters.Features(source.UserData(1)).Values(source.UserData(2)).ON_OFF = 0;
			else % Feature is OFF -> Switch ON.
				set(source,'BackgroundColor',[.9,.9,.9]);
				GUI_Parameters.Features(source.UserData(1)).Values(source.UserData(2)).ON_OFF = 1;
			end
			Reset_Axes();
			hold on;
			Multiple_Choose_Plot(GUI_Parameters);
			% assignin('base','Features',GUI_Parameters.Features);
		end
		
		function Features_OnOff_Buttons_Func(source,callbackdata)
			if(source.UserData(3)) % If ON ->  Switch OFF.
				source.UserData(3) = 0; % Switch OFF (meaning all features under this category will be merged and treated as one).
				set(source,'BackgroundColor',[.3,.3,.3]);
			else % If OFF -> Switch ON.
				source.UserData(3) = 1; % Switch ON.
				set(source,'BackgroundColor',[.2,.8,.4]);
			end
			Reset_Axes();
			hold on;
			Multiple_Choose_Plot(GUI_Parameters);
		end
		
		function Remove_Feature_Buttons_Func(source,callbackdata)
			GUI_Parameters.Features(source.UserData(2)) = []; % Delete the chosen feature from the features struct.
			delete(Features_Buttons_Handles); % Clear the features panel.
			delete(GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles); % Clear the features panel.
			% delete(Remove_Feature_Buttons_Handles); % Clear the features panel.
			Generate_Filter_Buttons; % Recreate the features panel.
		end
	end
	
	function Image_Menu_Func(source,callbackdata)
		
		set(allchild(GUI_Parameters.Handles.Im_Menu),'Checked','off');
		set(source,'Checked','on');
		set(GUI_Parameters.Handles.Im_Menu,'UserData',source.UserData); % This must come before the following "if" because this value is used there.
		
		if(GUI_Parameters.General.Active_View == 1) % If the current active plot is a reconstruction.
			Reconstruction_Func(1);
		elseif(GUI_Parameters.General.Active_View == 2) % If the current active plot is a graph.
			Reset_Axes();
			hold on;
			Multiple_Choose_Plot(GUI_Parameters);
		end
		
		if(isfield(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace,'NN_Probabilities') && isfield(GUI_Parameters.Handles.Machine_Learning,'Probability_Slider')) % If the probability image menu is ON (an indication that a NN has been loaded and applied to all images) - update the sliders values.
			set(GUI_Parameters.Handles.Machine_Learning.Probability_Slider,'Value',GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Threshold); % Update the NN threshold slider.
			set(GUI_Parameters.Handles.Machine_Learning.Probability_Slider_Text,'String',GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Threshold); % Update the NN threshold text box.
			
			set(GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Slider,'Value',GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Min_CC_Size); % Update the NN MinObjectSize slider.
			set(GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Text,'String',GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.Neural_Network.Min_CC_Size); % Update the NN MinObjectSize text box.
		end
	end
	
	function Collect_Multiple_Workspaces(source,callbackdata)
		Workspace = Collect_All_Workspaces();
		GUI_Parameters.Workspace = Workspace;
		uisave('Workspace',['All_Workspaces_',datestr(datetime,30),'.mat']);
		% Load_An_Existing_Project_File();
	end
	
	function Update_Multiple_Workspaces(source,callbackdata)
		An = inputdlg('Please enter a probability matrix threshold:','Threshold Input',1,{'0.65'});
		NN_Threshold = str2num(An{1,1});
		Trace_Any_Multiple_Images(0,NN_Threshold); % Currently running without applying the CNN again.
	end
	
	function Display_Neuron_Axes(~,~) % This function is run either if the user chooses to display the midline from the uimenu, or if the number of midline points changes.
		
		All_Enabled_Objects = findobj(GUI_Parameters(1).Handles(1).Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		% uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','text','String','Number of Midline Points:','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.05,.8,.7,GUI_Parameters.Visuals.Button1_Height]); % ,'backgroundcolor',[0.6 0.6 0.6]			% GUI_Parameters.Handles.Tracing.Analysis_Tab.Midline_Points_Num = 
		GUI_Parameters.Handles.Tracing.Midline_Points_OnOff = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','radio','String','# of Midline Points:','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Callback',@Draggable_Points_OnOff_Func,'Position',[.05,.8,.7,GUI_Parameters.Visuals.Button1_Height]); % ,'backgroundcolor',[0.6 0.6 0.6]			% GUI_Parameters.Handles.Tracing.Analysis_Tab.Midline_Points_Num = 
		GUI_Parameters.Handles.Tracing.Midline_Points_Num = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','edit','String','50','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.75,.8,.20,GUI_Parameters.Visuals.Button1_Height],'Callback',@Plot_Draggable_Points); % ,'backgroundcolor',[0.6 0.6 0.6]);
		GUI_Parameters.Handles.Tracing.Apply_Axes_Button = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','String','Apply Changes','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0,.01,1,GUI_Parameters.Visuals.Button1_Height],'Callback',@Apply_Axes_Changes_Func); % ,'backgroundcolor',[0.6 0.6 0.6]);
		
		GUI_Parameters(1).General.Active_Plot = 'Axes';
		Reconstruction_Func();
		Plot_Draggable_Points();
		
		set(All_Enabled_Objects,'Enable','on');
		
		function Plot_Draggable_Points(~,~)
			
			%{
			if(isempty(source)) % If this function is initiated from the text box (for the number of points).
				delete(findobj(GUI_Parameters.Handles.Axes,'Type','images.roi.point')); % Delete only the draggable points.
			else
				delete(findobj(GUI_Parameters.Handles.Axes,'-not','Type','image','-or','-not','Type','axes')); % Delete all graphical objects (except for the axes and the image).
			end
			%}
			
			delete(findobj(GUI_Parameters.Handles.Axes,'-not','Type','image','-and','-not','Type','axes')); % Delete all graphical objects (except for the axes and the image).
			
			Np0 = numel(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_0);
			Np = str2num(GUI_Parameters.Handles.Tracing.Midline_Points_Num.String);
			
			%
			XY_All = zeros(2,Np0,5);
			XY_All_Fit = zeros(2,Np,5);
			XY_All(:,:,1) = [GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_0.X ; GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_0.Y];
			XY_All(:,:,2) = [GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_1_Dorsal.X ; GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_1_Dorsal.Y];
			XY_All(:,:,3) = [GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_1_Ventral.X ; GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_1_Ventral.Y];
			XY_All(:,:,4) = [GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_2_Dorsal.X ; GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_2_Dorsal.Y];
			XY_All(:,:,5) = [GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_2_Ventral.X ; GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_2_Ventral.Y];
			%}
			
			% XY = [GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_0.X ; GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.Axis_0.Y];
			Curve_Handles = gobjects(1,5);
			DPoint_Handles = gobjects(5,Np);
			
			set(GUI_Parameters.Handles.Figure,'CurrentAxes',GUI_Parameters.Handles.Axes);
			hold on;
			
			CM = lines(7);
			CM = CM([1,7,7,3,3],:);
			for ii=1:5
				pp = cscvn(XY_All(:,:,ii)); % Fit a cubic spline.
				Vb = linspace(pp.breaks(1),pp.breaks(end),Np);
				XY_All_Fit(:,:,ii) = fnval(pp,Vb); % XY = fnval(pp,Vb);
				Curve_Handles(ii) = plot(GUI_Parameters.Handles.Axes,XY_All_Fit(1,:,ii),XY_All_Fit(2,:,ii),'Color',CM(ii,:),'LineWidth',3);
			end
			
			if(GUI_Parameters.Handles.Tracing.Midline_Points_OnOff.Value)
				CM = jet(Np);
				User_Data_Struct = struct('Axis_Field_Name',{},'Point_Index',{});
				for ii=1:Np
					User_Data_Struct(1).Axis_Field_Name = 'Axis_0'; User_Data_Struct(1).Curve_Index = 1; User_Data_Struct(1).Point_Index = ii;
					DPoint_Handles(1,ii) = drawpoint(GUI_Parameters.Handles.Axes,'Position',[XY_All_Fit(1,ii,1),XY_All_Fit(2,ii,1)],'Color',CM(ii,:),'UserData',User_Data_Struct,'StripeColor','w','LineWidth',10); % ,'SelectedColor','r'
					addlistener(DPoint_Handles(1,ii),'ROIMoved',@Draggable_Point_Func);
					
					%
					User_Data_Struct(1).Axis_Field_Name = 'Axis_1_Dorsal'; User_Data_Struct(1).Curve_Index = 2; User_Data_Struct(1).Point_Index = ii;
					DPoint_Handles(2,ii) = drawpoint(GUI_Parameters.Handles.Axes,'Position',[XY_All_Fit(1,ii,2),XY_All_Fit(2,ii,2)],'Color',CM(ii,:),'UserData',User_Data_Struct,'StripeColor','w','LineWidth',10); % ,'SelectedColor','r'
					addlistener(DPoint_Handles(2,ii),'ROIMoved',@Draggable_Point_Func);
					
					User_Data_Struct(1).Axis_Field_Name = 'Axis_1_Ventral'; User_Data_Struct(1).Curve_Index = 3; User_Data_Struct(1).Point_Index = ii;
					DPoint_Handles(3,ii) = drawpoint(GUI_Parameters.Handles.Axes,'Position',[XY_All_Fit(1,ii,3),XY_All_Fit(2,ii,3)],'Color',CM(ii,:),'UserData',User_Data_Struct,'StripeColor','w','LineWidth',10); % ,'SelectedColor','r'
					addlistener(DPoint_Handles(3,ii),'ROIMoved',@Draggable_Point_Func);
					
					User_Data_Struct(1).Axis_Field_Name = 'Axis_2_Dorsal'; User_Data_Struct(1).Curve_Index = 4; User_Data_Struct(1).Point_Index = ii;
					DPoint_Handles(4,ii) = drawpoint(GUI_Parameters.Handles.Axes,'Position',[XY_All_Fit(1,ii,4),XY_All_Fit(2,ii,4)],'Color',CM(ii,:),'UserData',User_Data_Struct,'StripeColor','w','LineWidth',10); % ,'SelectedColor','r'
					addlistener(DPoint_Handles(4,ii),'ROIMoved',@Draggable_Point_Func);
					
					User_Data_Struct(1).Axis_Field_Name = 'Axis_2_Ventral'; User_Data_Struct(1).Curve_Index = 5; User_Data_Struct(1).Point_Index = ii;
					DPoint_Handles(5,ii) = drawpoint(GUI_Parameters.Handles.Axes,'Position',[XY_All_Fit(1,ii,5),XY_All_Fit(2,ii,5)],'Color',CM(ii,:),'UserData',User_Data_Struct,'StripeColor','w','LineWidth',10); % ,'SelectedColor','r'
					addlistener(DPoint_Handles(5,ii),'ROIMoved',@Draggable_Point_Func);
					%}
					
					drawnow;
				end
			end			
			function Draggable_Point_Func(source,~) % Update the position of annotated points.
				
				Np0 = numel(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name)); % Original number of points.
				
				% XY(1,source.UserData.Point_Index) = source.Position(1);
				% XY(2,source.UserData.Point_Index) = source.Position(2);
				XY_All_Fit(1,source.UserData.Point_Index,source.UserData.Curve_Index) = source.Position(1);
				XY_All_Fit(2,source.UserData.Point_Index,source.UserData.Curve_Index) = source.Position(2);
				
				
				pp = cscvn(XY_All_Fit(:,:,source.UserData.Curve_Index)); % Fit a cubic spline.
				% pp = cscvn(XY); % Fit a cubic spline.
				Vb = linspace(pp.breaks(1),pp.breaks(end),Np0);
				XY_All(:,:,source.UserData.Curve_Index) = fnval(pp,Vb);
				
				if(strcmp(source.UserData.Axis_Field_Name,'Axis_0'))
					% Find arc-lengths and tangents:
					dxy = sum((XY_All(:,2:end,1) - XY_All(:,1:end-1,1)).^2,1).^(0.5); % sum([2 x Np],1). Summing up Xi+Yi and then taking the sqrt.
					Arc_Length = cumsum([0 , dxy]) .* GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.User_Input.Scale_Factor; % pixels to real length units (um).
					
					pp_Der1 = fnder(pp,1); % 1st derivative.
					XY_Der = fnval(pp_Der1,Vb); % [2 x Np].
					Tangent_Angles = atan2(XY_Der(2,:),XY_Der(1,:));
				end
				
				% Update points:
				xxyy = num2cell(XY_All(:,:,source.UserData.Curve_Index));
				[GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name).X] = xxyy{1,:};
				[GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name).Y] = xxyy{2,:};
				
				if(strcmp(source.UserData.Axis_Field_Name,'Axis_0'))
					Arc_Length = num2cell(Arc_Length);
					Tangent_Angles = num2cell(Tangent_Angles);
					[GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name).Arc_Length] = Arc_Length{:};
					[GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name).Tangent_Angle] = Tangent_Angles{:};
				end
				
				%{
				for iii=1:Np0
					GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name)(iii).X = XY_All(1,iii,source.UserData.Curve_Index);
					GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name)(iii).Y = XY_All(2,iii,source.UserData.Curve_Index);
					if(strcmp(source.UserData.Axis_Field_Name,'Axis_0'))
						GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name)(iii).Arc_Length = Arc_Length(iii);
						GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes.(source.UserData.Axis_Field_Name)(iii).Tangent_Angle = Tangent_Angles(iii);
					end
				end
				%}
				
				Curve_Handles(source.UserData.Curve_Index).XData(source.UserData.Point_Index) = source.Position(1);
				Curve_Handles(source.UserData.Curve_Index).YData(source.UserData.Point_Index) = source.Position(2);
				
				% assignin('base','Workspace',GUI_Parameters.Workspace);
			end
		end
		
		function Apply_Axes_Changes_Func(~,~)
			
			[GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.All_Points,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.All_Vertices] = Collect_All_Neuron_Points(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace); % [X, Y, Length, Angle, Curvature].
			GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.All_Points = Find_Distance_From_Midline(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.All_Points,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.User_Input.Scale_Factor,1);
			GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.All_Vertices = Find_Distance_From_Midline(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.All_Vertices,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Neuron_Axes,GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.User_Input.Scale_Factor,1);
		end
		
		function Draggable_Points_OnOff_Func(~,~)
			All_Enabled_Objects = findobj(GUI_Parameters(1).Handles(1).Figure,'Enable','on');
			set(All_Enabled_Objects,'Enable','off');
			Plot_Draggable_Points();
			set(All_Enabled_Objects,'Enable','on');
		end
	end
	
	function Start_Tracing_Func(source,callbackdata)
		% assignin('base','GUI_Parameters',GUI_Parameters);
		% set(GUI_Parameters.Handles.Display_Panel,'Enable','off');
		% set(GUI_Parameters.Handles.Edit_Panel,'Enable','off');
		set(Reconstructions_Menu_Handle,'Enable','off');
		set(Graphs_Menu_Handle,'Enable','off');
		
		Nw = numel(GUI_Parameters.Workspace);
		
		WB_H_Tracing = waitbar(0,'Please wait...');
		waitbar(0,WB_H_Tracing);
		% for fi=1:Nw
		for fi=1:Nw
			waitbar(fi/Nw,WB_H_Tracing,[num2str(fi),'/',num2str(Nw)]);
			
			Reset_Axes;
			imshow(GUI_Parameters.Workspace(fi).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
			% set(GUI_Parameters.Handles.Axes,'YDir','normal');
            
			% Skeletonize, detect vertices and segments and find vertices angles:
			GUI_Parameters.Workspace(fi).Workspace = Vertices_Analysis_Index(GUI_Parameters.Workspace(fi).Workspace);
			
			% Trace using skeleton vertices and Im_BW:
			GUI_Parameters.Workspace(fi).Workspace = Connect_Vertices(GUI_Parameters.Workspace(fi).Workspace,GUI_Parameters.Handles.Axes);
			
			% GUI_Parameters.Workspace(fi).Workspace = rmfield(GUI_Parameters.Workspace(fi).Workspace,'Im_BW'); % The probabilities matrix is saved instead.
			% waitfor(msgbox('The Tracing Completed Successully.'));
		end
		delete(WB_H_Tracing);
		
		if(Nw >= 1)
			Load_An_Existing_Project_File(); % TODO: what's the purpose of this?
			set(Graphs_Menu_Handle,'Enable','on');
			set(Reconstructions_Menu_Handle,'Enable','on');
			
			GUI_Parameters.General.Active_Plot = 'Segmentation';
			Reconstruction_Func();
		end
		assignin('base','GUI_Parameters',GUI_Parameters);
		
	end
	
	function Save_Tracing_Func(source,callbackdata) % Save project into a .mat file.
		
		switch source.UserData
			case 1 % Save only the current chosen workspace to a .mat file.
				Workspace = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData);
				Version_Num = GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Parameters.General_Parameters.Version_Num;
			case 2 % Save all loaded workspaces into a single .mat file.
				Workspace = GUI_Parameters.Workspace;
				Version_Num = GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Version_Num;
		end
		
		New_File_Name = strcat('MyTrace-V',Version_Num,'-',datestr(datetime,30),'.mat');
		cd(GUI_Parameters.General.Current_Dir);
		uisave('Workspace',New_File_Name);
	end
	
	function Reconstruction_Func(source,callbackdata)
		
		XL = xlim; % Save the current axis limits.
		YL = ylim;
		
		if(nargin == 1 && source) % Image changed - reseting the axis limits.
			[Rows_1,Cols_1] = size(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace.Image0);
			XL = [1,Cols_1];
            YL = [1,Rows_1];
			Reset_Axes();
		elseif(GUI_Parameters.General.Active_View == 2)
			GUI_Parameters.General.Active_Plot = source.Label;
			GUI_Parameters.General.View_Category_Type = source.UserData;
			GUI_Parameters.General.Active_View = 1;
			Reset_Axes();
		elseif(nargin == 2)
			GUI_Parameters.General.Active_Plot = source.Label;
			GUI_Parameters.General.View_Category_Type = source.UserData;
			GUI_Parameters.General.Active_View = 1;
			delete(findobj(GUI_Parameters.Handles.Axes,'-not','Type','axes'));
		else
			delete(findobj(GUI_Parameters.Handles.Axes,'-not','Type','axes'));
		end
		
		Reconstruction_Index(GUI_Parameters,GUI_Parameters.Handles.Im_Menu.UserData);
		
		if(isfield(GUI_Parameters.Workspace(GUI_Parameters.Handles.Im_Menu.UserData).Workspace,'Im_BW') && strcmp(GUI_Parameters.General.Active_Plot,'Binary Image') || strcmp(GUI_Parameters.General.Active_Plot,'Raw + Binary Image - RGB'))
			set(allchild(GUI_Parameters.Handles.Axes),'HitTest','off');
			set(GUI_Parameters.Handles.Axes,'PickableParts','all','ButtonDownFcn',@Mouse_Edit_BW_Func);
			
			% if(nargin == 2 || (nargin == 1 && source))
			% 	Apply_NN_Func();
			% end
		end
		
		if(XL(2) > 1 && YL(2) > 1)
			xlim(XL);
			ylim(YL);
		end
		
		% [jObj,hjObj,hContainer] = Display_Wait_Animation(1);
		% set(GUI_Parameters.Handles.Axes,'YDir','normal');
		% Display_Wait_Animation(0,jObj,hjObj,hContainer);
		% delete(Loading_Animation_Handle.h1);
		
		% if(GUI_Parameters.General.View_Category_Type > 0)
			% Categories_Filter_Lables(GUI_Parameters);
			% GUI_Parameters.General = Update_Categories_Filter_Values(GUI_Parameters.General,GUI_Parameters.Visuals.Active_Colormap);
		% end
		
		% Loading_Animation_Handle = gifplayer('Loading_Animation.gif',0.05);
	end
	
	function Slider_Func(source,callbackdata)
		set(source,'Enable','off','UserData',1);
		set(GUI_Parameters.Handles.Analysis.Slider_Text,'String',num2str(source.Value));
		Reset_Axes();
		hold on;
		Multiple_Choose_Plot(GUI_Parameters);
		set(source,'Enable','on');
	end
	
	function Dynamic_Slider_Min_Func(source,callbackdata)
		set(source,'Enable','off');
		set(GUI_Parameters.Handles.Analysis.Dynamic_Slider_Text_Min,'String',num2str(source.Value));
		Reset_Axes();
		hold on;
		switch GUI_Parameters.General.Active_View
			case 1
				Reconstruction_Func();
			case 2
				Multiple_Choose_Plot(GUI_Parameters);
		end
		set(source,'Enable','on');
	end
	
	function Dynamic_Slider_Max_Func(source,callbackdata)
		set(source,'Enable','off');
		set(GUI_Parameters.Handles.Analysis.Dynamic_Slider_Text_Max,'String',num2str(source.Value));
		Reset_Axes();
		hold on;
		switch GUI_Parameters.General.Active_View
			case 1
				Reconstruction_Func();
			case 2
				Multiple_Choose_Plot(GUI_Parameters);
		end
		set(source,'Enable','on');
	end
	
	function User_Input_Single_Func(source,callbackdata)
		
		H1 = uipanel(GUI_Parameters.Handles.Main_Panel,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.3 0.1 0.4 0.8]);
		
		uicontrol(H1,'Style','text','FontSize',20,'BackgroundColor',[0.7,0.7,0.7],'String','Project Properties','Units','Normalized','Position',[0 0.93 1 0.07],'FontSize',28);
		Continue_Button = uicontrol(H1,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button2_Font_Size,'String','Continue','Units','Normalized','Position',[0 0 1 0.1],'Callback',@Continue_Func);
		
		uicontrol(H1,'Style','text','units','Normalized','Position',[0,0.7,0.35,0.05],'String','Tracing Method:','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
		Tracing_Method_Buttons_Edit = uibuttongroup(H1,'Position',[0.35,0.7,0.6,0.05],'BorderType','none');
		R2 = uicontrol(Tracing_Method_Buttons_Edit,'Style','radiobutton','String','Manual','Units','normalized','FontSize',18,'Position',[0.5,0,0.5,1],'BackgroundColor',[0.5,0.5,0.5]);
		R1 = uicontrol(Tracing_Method_Buttons_Edit,'Style','radiobutton','String','Automatic','Units','normalized','FontSize',18,'Position',[0,0,0.5,1],'BackgroundColor',[0.5,0.5,0.5]);
		% TODO: set(Tracing_Method_Buttons,'SelectedObject',)
		
		uicontrol(H1,'Style','text','units','Normalized','Position',[0,.8,0.3,0.05],'String','Scale-Bar:','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
		
		uicontrol(H1,'Style','text','units','Normalized','Position',[0.35,0.85,0.2,0.05],'String','Pixels','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
		uicontrol(H1,'Style','text','units','Normalized','Position',[0.6,0.85,0.2,0.05],'String','Length','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
		uicontrol(H1,'Style','text','units','Normalized','Position',[0.81,0.85,0.15,0.05],'String','Unit','FontSize',18,'BackgroundColor',[0.5,0.5,0.5]);
		
		User_Input.Scale_Bar.Pixels = uicontrol(H1,'style','edit','units','Normalized','position',[0.36,.8,0.2,0.05],'String','1','UserData','','FontSize',24);
		User_Input.Scale_Bar.Length = uicontrol(H1,'style','edit','units','Normalized','position',[0.6,.8,0.2,0.05],'String',GUI_Parameters.Workspace(1).Workspace.User_Input.Scale_Factor,'UserData','','FontSize',24);
		User_Input.Scale_Bar.Unit = uicontrol(H1,'Style','popup','Units','Normalized','Position',[0.81,.8,0.15,0.05], ...
				'FontSize',16,'String',{[char(181),'m'],'nm','mm','km'});
		
		f = find(ismember(User_Input.Scale_Bar.Unit.String,GUI_Parameters.Workspace(1).Workspace.User_Input.Scale_Unit));
		set(User_Input.Scale_Bar.Unit,'Value',f);
		
		Y0 = 0.65;
		p = 0;
		Features_Struct = fieldnames(GUI_Parameters.Workspace(1).Workspace.User_Input.Features);
		Properties_Handles = struct('Property_Name',{},'Property_Value',{});
		for i=1:length(Features_Struct)
			p = p + 1;
			Properties_Handles(p).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*p,0.45,0.05],'String',Features_Struct{i},'UserData','','FontSize',20);
			Properties_Handles(p).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*p,0.45,0.05],'String',GUI_Parameters.Workspace(1).Workspace.User_Input.Features.(Features_Struct{i}),'UserData','','FontSize',20);
		end
		Add_Property_Button = uicontrol(H1,'style','pushbutton','units','Normalized','position',[0.04,Y0-0.06*(p+1+0.1),0.2,0.05],'String','+','FontSize',20,'Callback',@Add_Property_Func);
		
		function Add_Property_Func(source1,callbackdata1)
			p = p + 1;
			set(Add_Property_Button,'Position',[0.04,Y0-0.06*(p+1.1),0.2,0.05]);
			Properties_Handles(p).Property_Name = uicontrol(H1,'style','edit','units','Normalized','position',[0.04,Y0-0.06*p,0.45,0.05],'String','Property Name','UserData','','FontSize',20);
			Properties_Handles(p).Property_Value = uicontrol(H1,'style','edit','units','Normalized','position',[0.51,Y0-0.06*p,0.45,0.05],'String','Property Value','UserData','','FontSize',20);
		end
		
		function Continue_Func(source1,callbackdata1)
			
			% Set the scale-bar:
			GUI_Parameters.Workspace(1).Workspace.User_Input(1).Scale_Factor = str2num(User_Input.Scale_Bar.Length.String) / ...
																			str2num(User_Input.Scale_Bar.Pixels.String);
			GUI_Parameters.Workspace(1).Workspace.User_Input(1).Scale_Unit = User_Input.Scale_Bar.Unit.String(User_Input.Scale_Bar.Unit.Value);
			
			% Update the features:
			% GUI_Parameters.Workspace(1).Workspace.User_Input.Features.Tracing_Method = Tracing_Method_Buttons.SelectedObject.String;
			for i=1:numel(Properties_Handles)
				GUI_Parameters.Workspace(1).Workspace.User_Input.Features.(strrep(Properties_Handles(i).Property_Name.String,' ','_')) = ...
					strrep(Properties_Handles(i).Property_Value.String,' ','_');
			end
			
			assignin('base','Workspace',GUI_Parameters.Workspace(1).Workspace);
			
			delete(H1);
		end
		
	end
	
	function Multiple_Save_Plot_Func(source,callbackdata)
		Multiple_Save_Plot_Path = uigetdir;
		P = getpixelposition(GUI_Parameters.Handles.Main_Panel);
		F = getframe(GUI_Parameters.Handles.Figure,[P(1) P(2) P(3) P(4)-30]);
		imwrite(F.cdata,strcat(Multiple_Save_Plot_Path,'\MyPlot - ',datestr(datetime,30),'.png'));
	end
	
	function Multiple_Save_Project_Func(source,callbackdata)
		% Save project into a .mat file:
		New_File_Name = strcat('My_Project','-',datestr(datetime,30),'.mat');
		cd(GUI_Parameters.General.Current_Dir);
		Workspace1 = GUI_Parameters.Workspace;
		uisave('Workspace1',New_File_Name);
		clearvars Workspace1;
	end
	
	function Rerun_Plot_Func(source,callbackdata)
		if(GUI_Parameters.General.Active_View > 1)
			Reset_Axes();
			hold on;
			Multiple_Choose_Plot(GUI_Parameters);
		end
	end
	
	function Menu1_Plots_Func(source,callbackdata)
		
		GUI_Parameters.General.Active_View = 2; % Creates smaller axes that leave space for labels.
		% GUI_Parameters.General.View_Category_Type = source.UserData;
		GUI_Parameters.General.Active_Plot = source.Label; % Name of plot.
		
		Reset_Axes();
		
		% set(GUI_Parameters.Handles.Merge_Dorsal_Ventral_CheckBox,'Value',1);
		hold on;
		Multiple_Choose_Plot(GUI_Parameters);
	end
	
	function Reset_Axes()
		% delete(findobj(GUI_Parameters.Handles.Axes,'-not','Type','axes'));
		delete(allchild(GUI_Parameters.Handles.Main_Panel));
		
		if(GUI_Parameters.General.Active_View == 1) % Image Display Mode.
			% set(GUI_Parameters.Handles.Axes,'Position',GUI_Parameters.Visuals.Main_Axes_Size_1);
			GUI_Parameters.Handles.Axes = axes('Units','normalized','Position',GUI_Parameters.Visuals.Main_Axes_Size_1,'Parent',GUI_Parameters.Handles.Main_Panel); % set(GUI_Parameters.Handles.Axes,'Position',[0,0,1,1]);
		else
			% set(GUI_Parameters.Handles.Axes,'Position',GUI_Parameters.Visuals.Main_Axes_Size_2);
			GUI_Parameters.Handles.Axes = axes('Units','normalized','Position',GUI_Parameters.Visuals.Main_Axes_Size_2,'Parent',GUI_Parameters.Handles.Main_Panel);
		end
		
		if(~Flip_Contrast_CheckBox.Value)
			GUI_Parameters.Visuals.Active_Colormap = GUI_Parameters.Visuals.Black_On_White_Colormap;
			set(GUI_Parameters.Handles.Main_Panel,'BackgroundColor',[1,1,1]);
			set(GUI_Parameters.Handles.Axes,'Color','w');
			GUI_Parameters.Handles.Axes.XAxis.Color = 'k';
			GUI_Parameters.Handles.Axes.YAxis.Color = 'k';
		else
			GUI_Parameters.Visuals.Active_Colormap = GUI_Parameters.Visuals.White_On_Black_Colormap;
			set(GUI_Parameters.Handles.Main_Panel,'BackgroundColor',[0,0,0]);
			set(GUI_Parameters.Handles.Axes,'Color','k');
			GUI_Parameters.Handles.Axes.XAxis.Color = 'w';
			GUI_Parameters.Handles.Axes.YAxis.Color = 'w';
		end
	end
	
	function Get_Object_Details_Func(source,callbackdata)
		if(GUI_Parameters.General.Single_Multiple == 1 && GUI_Parameters.General.Active_View == 1)			
			switch GUI_Parameters.General.Active_Plot
				case 'Segmentation'
					Get_Segments_Details(GUI_Parameters);
				case 'Menorah Orders'
					Get_Menorah_Branches_Details(GUI_Parameters);
				case 'Individual Menorahs'
					Get_Menorahs_Details(GUI_Parameters);
				case 'Vertices Angles'
					Get_Vertices_Details(GUI_Parameters);
            end
		end
	end
	
	function Get_Groups_Details_Func(source,callbackdata)
		
		H1 = uipanel(GUI_Parameters.Handles.Main_Panel,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.3 0.1 0.4 0.8]);
		
		uicontrol(H1,'Style','text','FontSize',20,'BackgroundColor',[0.7,0.7,0.7],'String','Project Properties','Units','Normalized','Position',[0 0.93 1 0.07],'FontSize',28);
		Continue_Button = uicontrol(H1,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button2_Font_Size,'String','Continue','Units','Normalized','Position',[0 0 1 0.1],'Callback',@Continue_Func);
		Th = uitable(H1,'units','Normalized','Position',[0 0.2 1 0.6],'FontSize',24,'FontUnits','Normalized');
		Th.ColumnName = {'<html><h1>Group Name</h1></html>','<html><h1>Sample Size</h1></html>'};
		Th.ColumnWidth = {200,200};
		
		A = {GUI_Parameters.Workspace.Group_Name}';
		B = num2cell(cellfun(@length,{GUI_Parameters.Workspace(:).Files})');
		
		Th.Data = [A,B];
		
		function Continue_Func(source1,callbackdata1)
			delete(H1);
		end
	end
	
	function Export_Image_Func(source,callbackdata)
		Output_Dir = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\Neuronalizer Paper\Figures\Figure 1 (Intro)\SVG\ToCrop'; % uigetdir;
		% pos = plotboxpos(GUI_Parameters.Handles.Axes);
		export_fig([Output_Dir,filesep,'Exported_Figure.svg'],GUI_Parameters.Handles.Axes,'-svg');
	end
end