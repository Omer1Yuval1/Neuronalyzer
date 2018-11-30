function Tracer_UI()
	
	tmp = matlab.desktop.editor.getActive;
	cd(fileparts(tmp.Filename));
	addpath(genpath(pwd));
	
	GUI_Parameters = Load_GUI_Parameters;
		
		GUI_Parameters(1).Handles(1).Figure = figure(1);
		set(GUI_Parameters(1).Handles.Figure,'Name',['Neuronalizer ',GUI_Parameters.General.Version],'NumberTitle','off')
		Screen_Size = get(groot,'Screensize');
		% Screen_Size(2) = 0.03*Screen_Size(4);
		% Screen_Size(4) = Screen_Size(4) - Screen_Size(2)
		set(GUI_Parameters.Handles.Figure,'WindowStyle','normal'); % ,'Position',Screen_Size);
		% Figure_Window = get(GUI_Parameters.Handles.Figure,'JavaFrame');
		% set(Figure_Window,'Maximized',1); 
		clf(GUI_Parameters.Handles.Figure);
		GUI_Parameters.Handles.Main_Panel = uipanel('FontSize',12,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.2 0 0.8 1]);
		GUI_Parameters.Handles.Axes = axes('Parent',GUI_Parameters.Handles.Main_Panel,'Units','normalized','Position',GUI_Parameters.Visuals.Main_Axes_Size);
		GUI_Parameters.Handles.Edit_Panel = uipanel('FontSize',12,'Position',[0 0 0.2 0.5]); % [0.7,1,0.3].
		GUI_Parameters.Handles.Analysis_Panel = uipanel('FontSize',12,'Position',[0 0.5 0.2 0.5]);
		GUI_Parameters.Handles.Analysis_Tabs = uitabgroup('Parent',GUI_Parameters.Handles.Analysis_Panel,'Position',[0 0 1 1]);
		
		GUI_Parameters.Handles.Figure.Units = 'normalized';
		GUI_Parameters.Handles.Figure.Visible = 'off';
		GUI_Parameters.Handles.Axes.Visible = 'off';
		
		GUI_Parameters.Workspace = struct('Group_Name',{},'Handles',{},'Values',{});
		
		GUI_Parameters.Handles.Analysis.Filters_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Filters','BackgroundColor',[0.5,0.6,1]);
			GUI_Parameters.Handles.Analysis.Slider = uicontrol('Parent',GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','slider','Min',0,'Max',1,'Value',GUI_Parameters.General.Slider_Value,'Units','Normalized','Position',[0 0.01 1 GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@Slider_Func);
		GUI_Parameters.Handles.Analysis.Analysis_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Analysis','BackgroundColor',[0.5,0.6,1]);
			GUI_Parameters.Handles.Error_Bars_CheckBox = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','checkbox','Value',0,'String','Display Error Bars','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.8 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Merge_Dorsal_Ventral_Func);			
			GUI_Parameters.Handles.Significance_Bars_CheckBox = uicontrol(GUI_Parameters.Handles.Analysis.Analysis_Tab,'Style','checkbox','Value',0,'String','Display Significance Bars','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Display_Significance_Bars_Func);
			% GUI_Parameters.Handles.Analysis.Slider = uicontrol('Parent',GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','slider','Min',0,'Max',1,'Value',GUI_Parameters.General.Slider_Value,'Units','Normalized','Position',[0 0.01 1 GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@Slider_Func);
			% GUI_Parameters.Handles.Normalization_List = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','popup','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.5 1 GUI_Parameters.Visuals.Button1_Height], ...
				% 'String',{'Not Normalized'},'Callback',@Display_Normalized_Resutls_Func);
			% Display_Original_Image_CheckBox = uicontrol(GUI_Parameters.Handles.Display_Tab,'Style','checkbox','Value',0,'String','Display Original Image','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.2 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Display_Original_Image);
			% Tree_Center_CheckBox = uicontrol(GUI_Parameters.Handles.Display_Tab,'Style','checkbox','Value',0,'String','Display Tree Center','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.1 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Tree_Center_CheckBox_Func);
			% Display_Loops_CheckBox = uicontrol(GUI_Parameters.Handles.Display_Tab,'Style','checkbox','Value',0,'String','Display Loops','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Tree_Center_CheckBox_Func);
			% GUI_Parameters.Handles.Clusters_Data_List = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','popup','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.4 0.48 GUI_Parameters.Visuals.Button1_Height], ...
				% 'String',{'Not Clustered','k-means','Gaussian Mixture','Linkage'},'Callback',@Cluster_Data_Func);
			% GUI_Parameters.Handles.Clusters_Evaluation_Algorithm_List = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','popup','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0.52 0.4 0.48 GUI_Parameters.Visuals.Button1_Height], ...
				% 'String',{'Eval. Method','Silhouette','Gap','DaviesBouldin','CalinskiHarabasz'},'Callback',@Cluster_Data_Func);
			% GUI_Parameters.Handles.Merge_Dorsal_Ventral_CheckBox = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','checkbox','Value',0,'String','Merge Dorsal-Ventral','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Merge_Dorsal_Ventral_Func);
			% GUI_Parameters.Handles.Find_Peaks_CheckBox = uicontrol(GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','checkbox','Value',0,'String','Find Peaks','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.6 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Merge_Dorsal_Ventral_Func);
		GUI_Parameters.Handles.Analysis.Display_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Format','BackgroundColor',[0.5,0.6,1]);
			Flip_Contrast_CheckBox = uicontrol(GUI_Parameters.Handles.Analysis.Display_Tab,'Style','checkbox','Value',0,'String','Flip Contrast','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Flip_Contrast_Func);
		GUI_Parameters.Handles.Analysis.Details_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Details','BackgroundColor',[0.5,0.6,1]);
		GUI_Parameters.Handles.Analysis.Virtual_Keyboard_Tab = uitab('Parent',GUI_Parameters.Handles.Analysis_Tabs,'Title','Virtual Keyboard','BackgroundColor',[0.5,0.6,1]);
		% GUI_Parameters.Handles.Groups_Filter_Panel = uipanel('Parent',GUI_Parameters.Handles.Filters_Tab,'Units','Normalized','Position',[0 0.86 1 .1],'BackgroundColor','w');
		% GUI_Parameters.Handles.Categories_Filter_Panel = uipanel('Parent',GUI_Parameters.Handles.Filters_Tab,'FontSize',12,'Units','Normalized','Position',[0 0.63 1 .2],'BackgroundColor','w');
		
		GUI_Parameters.Handles.Tracing_Tabs_Group = uitabgroup('Parent',GUI_Parameters.Handles.Edit_Panel,'Position',[0 0 1 1]);
		GUI_Parameters.Handles.Tracing.Project_Panel = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Project');
		GUI_Parameters.Handles.Tracing.Machine_Learning_Panel = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Pre-Processing');
		GUI_Parameters.Handles.Tracing.Editing_Tab = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Editing');
		GUI_Parameters.Handles.Tracing.Tracing_Tab = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Tracing','BackgroundColor',[0.8,0.4,0.4]);
		GUI_Parameters.Handles.Tracing.Analysis_Tab = uitab('Parent',GUI_Parameters.Handles.Tracing_Tabs_Group,'Title','Analysis');
		% set(GUI_Parameters.Handles.Tracing.Editing_Tab,'Enable','off');
		
		GUI_Parameters.Handles.Start_Edit_BW = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Editing_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Edit BW Reconstruction','Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Edit_BW_Func);
		
	% assignin('base','GUI_Parameters',GUI_Parameters);
	
	% Machine Learning Panel:
	GUI_Parameters.Handles.Machine_Learning.Train_NN_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Train Neural Network','Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Multiple_Save_Plot_Func);
	GUI_Parameters.Handles.Machine_Learning.Load_Trained_NN_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Load A Trained Neural Network','Units','Normalized','Position',[0 0.8 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Apply_NN_Func);
	GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Apply Neural Network On Multiple Images','Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Enable','off');
	set(GUI_Parameters.Handles.Machine_Learning.Train_NN_Button,'Enable','off');
	set(GUI_Parameters.Handles.Machine_Learning.Load_Trained_NN_Button,'Enable','off');
	
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
	
	Edit_Properties_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Change Project Properties',...
		'Units','Normalized','Position',[0 0.21 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@User_Input_Single_Func,'TooltipString','Click Here to Display and Change The Current Parameters Values of Your Project');
	Save_Project_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Project_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save Project',...
		'Units','Normalized','Position',[0 0.01 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_Tracing_Func,'TooltipString','Save a .mat File of Your Project So You Can Load and Revise It Later');
	
	% Tracing Tab:
	GUI_Parameters.Single.Handles.Tracing.Start_Tracing_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Tracing_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Start Tracing',...
			'Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Start_Tracing_Func);
	GUI_Parameters.Single.Handles.Tracing.Trace_Multiple_Neurons = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Tracing_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Trace Multiple Neurons',...
			'Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Trace_Multiple_Neurons);
	% Get_Object_Details_Button = uicontrol(GUI_Parameters.Handles.Analysis.Details_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Get Details','Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Get_Object_Details_Func);
	
	% Multiple Images Analysis Panel:
	%{
	Multiple_Create_Project_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Create a New Project','Units','Normalized','Position',[0 0.9 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@New_Project_Multiple_Func);
	Load_Multiple_File_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Open Project','Units','Normalized','Position',[0 0.8 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Load_Multiple_File_Func);
	Get_Groups_Details_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Get Groups Details','Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Get_Groups_Details_Func);
	Analyze_Tracing_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Analyze',...
		'Units','Normalized','Position',[0 0.2 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Analyze_Func);
	Save_Plot_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save Plot','Units','Normalized','Position',[0 0.1 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Multiple_Save_Plot_Func);
	Save_Project_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Analysis_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save Project','Units','Normalized','Position',[0 0 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Multiple_Save_Project_Func);
	%}
	
	Reconstructions_Menu_Handle = uimenu(GUI_Parameters.Handles.Figure,'Label','Reconstructions');
		H0_0_1 = uimenu(Reconstructions_Menu_Handle,'Label','Original Image','UserData',0,'Callback',@Reconstruction_Func);
		% H0_1_1 = uimenu(Reconstructions_Menu_Handle,'Label','Initial Guess');
		% 	H0_1_1_1 = uimenu(H0_1_1,'Label','Volume - Initial Guess','UserData',0,'Callback',@Reconstruction_Func);
		% 	H0_1_1_2 = uimenu(H0_1_1,'Label','Skeleton - Initial Guess','UserData',0,'Callback',@Reconstruction_Func);
		% 	H0_1_1_3 = uimenu(H0_1_1,'Label','Segmentation - Initial Guess','UserData',0,'Callback',@Reconstruction_Func);
		% H0_1_2 = uimenu(Reconstructions_Menu_Handle,'Label','Trace');
		% 	H0_1_2_1 = uimenu(H0_1_2,'Label','Trace','UserData',0,'Callback',@Reconstruction_Func);
		% 	H0_1_2_2 = uimenu(H0_1_2,'Label','Full Trace','UserData',0,'Callback',@Reconstruction_Func);
		% 	H0_1_2_3 = uimenu(H0_1_2,'Label','Skeleton','UserData',0,'Callback',@Reconstruction_Func);
		H0_1_3 = uimenu(Reconstructions_Menu_Handle,'Label','Segmentation','UserData',0,'Callback',@Reconstruction_Func);
		% H0_1_4 = uimenu(Reconstructions_Menu_Handle,'Label','Menorah Orders','UserData',1,'Callback',@Reconstruction_Func);
		% H0_1_5 = uimenu(Reconstructions_Menu_Handle,'Label','Individual Menorahs','UserData',0,'Callback',@Reconstruction_Func);
		H0_1_6 = uimenu(Reconstructions_Menu_Handle,'Label','Vertices Angles');
			H0_1_6_1 = uimenu(H0_1_6,'Label','Vertices Angles','UserData',2,'Callback',@Reconstruction_Func);
		% 	H0_1_6_2 = uimenu(H0_1_6,'Label','Vertices Angles - Skeleton','UserData',2,'Callback',@Reconstruction_Func);
		% H0_1_7 = uimenu(Reconstructions_Menu_Handle,'Label','Dorsal-Ventral','UserData',0,'Callback',@Reconstruction_Func);
		% H0_1_8 = uimenu(Reconstructions_Menu_Handle,'Label','Longitudinal Gradient','UserData',0,'Callback',@Reconstruction_Func);		
		% H0_1_9 = uimenu(Reconstructions_Menu_Handle,'Label','Curvature','UserData',0,'Callback',@Reconstruction_Func);
		% H0_1_10 = uimenu(Reconstructions_Menu_Handle,'Label','Persistence Length','UserData',0,'Callback',@Reconstruction_Func);
		% H0_1_11 = uimenu(Reconstructions_Menu_Handle,'Label','Curviness Length','UserData',0,'Callback',@Reconstruction_Func);
	set(Reconstructions_Menu_Handle,'Enable','off');
	% set(H0_1_2_4,'Enable','off');
	Graphs_Menu_Handle = uimenu(GUI_Parameters.Handles.Figure,'Label','Analysis Plots');
		% H_Menu1_Length = uimenu(Graphs_Menu_Handle,'Label','Length');
			% H_Menu111_Total_Length = uimenu(H_Menu11_Length,'Label','Total Length','UserData',1,'Callback',@Menu1_Plots_Func);
		H_Menu1_Segments = uimenu(Graphs_Menu_Handle,'Label','Segments','Callback','');
			H_Menu11_Segments = uimenu(H_Menu1_Segments,'Label','Total Length','UserData',1,'Callback',@Menu1_Plots_Func);
			H_Menu12_Segments = uimenu(H_Menu1_Segments,'Label','Mean Segment Length','UserData',1,'Callback',@Menu1_Plots_Func);
			H_Menu13_Segments = uimenu(H_Menu1_Segments,'Label','End2End Length Of Segments','UserData',1,'Callback',@Menu1_Plots_Func);
			H_Menu14_Segments = uimenu(H_Menu1_Segments,'Label','Curvature Of Segments','UserData',1,'Callback',@Menu1_Plots_Func);
			% H_Menu1151_Segments = uimenu(H_Menu115_Segments,'Label','Segments Length Distribution','UserData',1,'Callback',@Menu1_Plots_Func);
		
		H_Menu2_CB = uimenu(Graphs_Menu_Handle,'Label','Cell Body','Callback','');
			H_Menu21_CB = uimenu(H_Menu2_CB,'Label','CB Intensity','UserData',1,'Callback',@Menu1_Plots_Func);
			H_Menu22_CB = uimenu(H_Menu2_CB,'Label','CB Area','UserData',1,'Callback',@Menu1_Plots_Func);
		
		H_Menu3_Vertices = uimenu(Graphs_Menu_Handle,'Label','Vertices','Callback','');
			H_Menu31_Angles = uimenu(H_Menu3_Vertices,'Label','Angles','Callback','');
				% H_Mene311 = uimenu(H_Menu31_Angles,'Label','Symmetry of 3-Way junctions','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu311 = uimenu(H_Menu31_Angles,'Label','Histograms','Callback','');
					H_Menu3111 = uimenu(H_Menu311,'Label','Histogram of all Angles','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3112 = uimenu(H_Menu311,'Label','Histogram of Symmetry Indices','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3113 = uimenu(H_Menu311,'Label','Distribution of Vertices Angles Relative To The Medial Axis','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3114 = uimenu(H_Menu311,'Label','Distribution of Vertices Angles Relative To The Medial Axis - Corrected','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu312 = uimenu(H_Menu31_Angles,'Label','Two Angles Plots','Callback','');
					H_Menu3121 = uimenu(H_Menu312,'Label','Minimal and Maximal Angles of 3-Way junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3122 = uimenu(H_Menu312,'Label','The Two Minimal Angles of each 3-Way junction','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3123 = uimenu(H_Menu312,'Label','Linearity-Symmetry of 3-Way junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3124 = uimenu(H_Menu312,'Label','Sum of 2 Smallest VS Product of 2 Smallest','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3126 = uimenu(H_Menu312,'Label','Smallest Angle VS Diff between 2 Smallest','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu313 = uimenu(H_Menu31_Angles,'Label','Three Angles Plots','Callback','');
					H_Menu3131 = uimenu(H_Menu313,'Label','2D Histogram Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3132 = uimenu(H_Menu313,'Label','2D Histogram of Corrected Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3133 = uimenu(H_Menu313,'Label','2D Histogram of Invariant Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					H_Menu3134 = uimenu(H_Menu313,'Label','2D Histogram of Invariant Corrected Angles of 3-Way Junctions','UserData',2,'Callback',@Menu1_Plots_Func);
					% H_Menu3131 = uimenu(H_Menu313,'Label','Smallest-Mid-largest','UserData',2,'Callback',@Menu1_Plots_Func);
			H_Menu32_Angles = uimenu(H_Menu3_Vertices,'Label','Distances','Callback','');
				H_Menu321 = uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The Medial Axis - Means','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu322 = uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The Medial Axis - Histogram','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu323 = uimenu(H_Menu32_Angles,'Label','Distances Of 3-Way Junctions From The Medial Axis - Histogram','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu324 = uimenu(H_Menu32_Angles,'Label','Distances Of Tips From The Medial Axis - Histogram','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu325 = uimenu(H_Menu32_Angles,'Label','Smallest Angle VS Distance From Medial Axis','UserData',2,'Callback',@Menu1_Plots_Func);
				H_Menu326 = uimenu(H_Menu32_Angles,'Label','Distances Of Vertices From The CB','UserData',2,'Callback',@Menu1_Plots_Func);				
			% H_Menu132_Distances = uimenu(H_Menu13_Vertices,'Label','Distances','Callback','');
				% H_Menu1321_Primary_Vertices_Mean_Distance = uimenu(H_Menu132_Distances,'Label','Primary_Vertices_Mean_Distance','UserData',1,'Callback',@Menu1_Plots_Func);
			% H_Menu133_Vertices_Density = uimenu(H_Menu13_Vertices,'Label','Density of Vertices','UserData',1,'Callback',@Menu1_Plots_Func);			
		%{
		H_Menu17_Curvature = uimenu(Graphs_Menu_Handle,'Label','Curvature','Callback','');
			H_Menu171_Persistence_Length = uimenu(H_Menu17_Curvature,'Label','Persistence Length','UserData',1,'Callback',@Menu1_Plots_Func);
			H_Menu172_Curvature = uimenu(H_Menu17_Curvature,'Label','Curvature','Callback','');
				H_Menu1721 = uimenu(H_Menu172_Curvature,'Label','Integral of Squared Curvature of Branches','UserData',1,'Callback',@Menu1_Plots_Func);
			H_Menu173_Straight_Arc_Ratio = uimenu(H_Menu17_Curvature,'Label','Straight-Arc Length Ratio','UserData',1,'Callback',@Menu1_Plots_Func);
		H_Menu19_Orientation = uimenu(Graphs_Menu_Handle,'Label','Orientation');
		H_Menu20_Clustering = uimenu(Graphs_Menu_Handle,'Label','Clustering');
		H_Menu21_Space_Filling = uimenu(Graphs_Menu_Handle,'Label','Space Filling');
			H_Menu211_Bounding_Rectangles = uimenu(H_Menu21_Space_Filling,'Label','Bounding Rectangles');
				H_Menu2111 = uimenu(H_Menu211_Bounding_Rectangles,'Label','Total Dendritic Field','UserData',1,'Callback',@Menu1_Plots_Func);
		%}
	set(allchild(Graphs_Menu_Handle),'Enable','off');
	
	GUI_Parameters.Handles.Figure.Visible = 'on'; % Make figure visible after adding all components.
	
	function Apply_NN_Func(source,callbackdata)
		
		Default_Pixel_Classification_Threshold = GUI_Parameters.Workspace(1).Workspace.Parameters.Neural_Network.Default_Pixel_Classification_Threshold;
		
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
		File1 = load(strcat(PathName,FileName));
		NN1 = File1.deepnet; % TODO: choose the only variable from the file without specifying the name.
		clear File1;
		
		GUI_Parameters(1).Neural_Network(1).Directory = strcat(PathName,FileName);
		
		GUI_Parameters.Handles.Machine_Learning.Probability_Slider = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','slider','Min',0,'Max',1,'Value',Default_Pixel_Classification_Threshold,'SliderStep',[0.05,0.05],'Units','Normalized','Position',[0,.6,.8,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@NN_Probability_Slider_Func);
		GUI_Parameters.Handles.Machine_Learning.Probability_Slider_Text = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','edit','String',Default_Pixel_Classification_Threshold,'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.8,.6,.2,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
		
		GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Slider = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','slider','Min',0,'Max',500,'Value',0,'SliderStep',[.01,.01],'Units','Normalized','Position',[0,.4,.8,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6],'Callback',@NN_Min_Obejct_Size_Slider_Func);
		GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Text = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','edit','String',1,'FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'Units','Normalized','Position',[.8,.4,.2,GUI_Parameters.Visuals.Button1_Height],'backgroundcolor',[0.6 0.6 0.6]);
		
		GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Apply Neural Network To Multiple Images','Units','Normalized','Position',[0 0.7 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Apply_NN_Multiple_Func);
		
		GUI_Parameters.Handles.Machine_Learning.Save_Training_Sample = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save As Training Sample','Units','Normalized','Position',[0 .21 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_Training_Sample_Func);
		GUI_Parameters.Handles.Machine_Learning.Update = uicontrol(GUI_Parameters.Handles.Tracing.Machine_Learning_Panel,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Update','Units','Normalized','Position',[0 .01 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_NN_View_To_Workspace);
		
		[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(1).Workspace.Image0);
		Im_BW = zeros(Im_Rows,Im_Cols);
		GUI_Parameters.Workspace(1).Workspace.Im_BW = [];
		Apply_NN();
		
		function Apply_NN()
			% assignin('base','NN1',NN1);
			% assignin('base','Image0',GUI_Parameters.Workspace(1).Workspace.Image0);
			% profile on;
			GUI_Parameters.Workspace(1).Workspace.NN_Probabilities = Apply_Trained_Network(NN1,GUI_Parameters.Workspace(1).Workspace.Image0);
			
			Im_BW(find(GUI_Parameters.Workspace(1).Workspace.NN_Probabilities >= Default_Pixel_Classification_Threshold)) = 1;
			% assignin('base','Im_BW',Im_BW);
			% profile off;
			% profile viewer;
			
			Reset_Axes();
			imshow(Im_BW,'Parent',GUI_Parameters.Handles.Axes);
			set(gca,'YDir','normal');
			set(GUI_Parameters.Handles.Machine_Learning.Apply_NN_Multiple_Button,'Enable','on');
			% assignin('base','GUI_Parameters.Workspace(1).Workspace.Im_BW',GUI_Parameters.Workspace(1).Workspace.Im_BW);
		end
		
		function Apply_NN_Multiple_Func(source,event)
			
			% Workspace_Temp = Set_Project_Properties(GUI_Parameters); % Set global properties for the images to be chosen\analyzed.
			
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
				
				Workspace_Temp = {}; % Reset the Workspace.
				Workspace_Temp.Im_BW = [];
				
				% Set the scale-bar:
				Workspace_Temp.User_Input(1).Scale_Factor = str2num(User_Input.Scale_Bar.Length.String) / str2num(User_Input.Scale_Bar.Pixels.String);
				Workspace_Temp.User_Input(1).Scale_Unit = User_Input.Scale_Bar.Unit.String(User_Input.Scale_Bar.Unit.Value);
				
				for i=1:numel(Properties_Handles)
					Workspace_Temp.User_Input.Features.(strrep(Properties_Handles(i).Property_Name.String,' ','_')) = ...
						strrep(Properties_Handles(i).Property_Value.String,' ','_');
				end
				
				Workspace_Temp.Parameters = Parameters_Func(Workspace_Temp.User_Input.Scale_Factor);
				
				delete(H1);
				
				[FileName,PathName] = uigetfile('*tif','Please Choose a Set of Images.','MultiSelect','on');
				mkdir([PathName,'My_Neuronalizer_Projects']); % assignin('base','PathName',PathName);
				N = length(FileName);
				Multiple_NN_WaitBar = waitbar(0,'Please Wait');
				for f=1:length(FileName) % For each animal\worm\neuron.
					
					Workspace_Temp.Image0 = flipud(imread(strcat(PathName,FileName{f}))); % The current image.
					[Im_Rows,Im_Cols] = size(Workspace_Temp.Image0);
					Workspace_Temp.Parameters.General_Parameters.Im_Rows = Im_Rows;
					Workspace_Temp.Parameters.General_Parameters.Im_Cols = Im_Cols;
					
					[~,BW_Reconstruction_Temp] = Apply_Trained_Network(NN1,Workspace_Temp.Image0,GUI_Parameters.Handles.Machine_Learning.Probability_Slider.Value);
					
					Workspace_Temp.Im_BW = BW_Reconstruction_Temp;
					
					save(strcat(PathName,filesep,'My_Neuronalizer_Projects',filesep,FileName{f}(1:end-3),'mat'),'Workspace_Temp');
					% save(strcat(PathName,filesep,'My_Neuronalizer_Projects',filesep,FileName{f}),'-struct','Workspace_Temp','Workspace');
					
					waitbar(f/N,Multiple_NN_WaitBar);
				end
				delete(Multiple_NN_WaitBar);
			end
		end
		
		%{
				if(w) % keyboard key.
					set(GUI_Parameters.Handles.Figure,'KeyPressFcn',' ');
					c1 = double(get(GUI_Parameters.Handles.Figure,'CurrentCharacter'));
					if(isscalar(c1))
						switch c1
							case {27,48} % Esc OR 0.
								set(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'SelectedObject',GUI_Parameters.Handles.Machine_Learning.BW);
								set(gcf,'Pointer','arrow');
								Edit_BW_Radio_View_Func();
								% break;
							case 61 % +. Zoom In.
								xlim([ mean(XL) - ((mean(XL) - XL(1)) / 1.5) , mean(XL) + ((XL(2) - mean(XL)) / 1.5) ]);
								ylim([ mean(YL) - ((mean(YL) - YL(1)) / 1.5) , mean(YL) + ((YL(2) - mean(YL)) / 1.5) ]);
								XL = xlim;
								YL = ylim;
							case 45 % -. Zoom Out.
								xlim([ mean(XL) - ((mean(XL) - XL(1)) * 1.5) , mean(XL) + ((XL(2) - mean(XL)) * 1.5) ]);
								ylim([ mean(YL) - ((mean(YL) - YL(1)) * 1.5) , mean(YL) + ((YL(2) - mean(YL)) * 1.5) ]);
								XL = xlim;
								YL = ylim;
							case 28 % <-
								xlim(XL + 10);
								XL = xlim;
							case 29 % ->
								xlim(XL - 10);
								XL = xlim;
							case 31 % \/
								ylim(YL + 10);
								YL = ylim;
							case 30 % ^
								ylim(YL - 10);
								YL = ylim;
							case 49 % #1. Show the original image.
								set(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'SelectedObject', ...
									GUI_Parameters.Handles.Machine_Learning.Grayscale);
								Edit_BW_Radio_View_Func();
								% break;
							case 50
								set(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'SelectedObject', ...
									GUI_Parameters.Handles.Machine_Learning.BW);
								Edit_BW_Radio_View_Func();
							case 51
								set(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'SelectedObject', ...
									GUI_Parameters.Handles.Machine_Learning.RGB);
								Edit_BW_Radio_View_Func();
						end
					end
		
		%}
		
		function NN_Probability_Slider_Func(source,event)
			% [Scores,GUI_Parameters.Workspace(1).Workspace.Im_BW] = Apply_Trained_Network(NN1,GUI_Parameters.Workspace(1).Workspace.Image0,source.Value,Input_Type);
			set(GUI_Parameters.Handles.Machine_Learning.Probability_Slider,'Enable','off');
			
			Im_BW(find(GUI_Parameters.Workspace(1).Workspace.NN_Probabilities >= source.Value)) = 1;
			Im_BW(find(GUI_Parameters.Workspace(1).Workspace.NN_Probabilities < source.Value)) = 0;
			
			Reset_Axes();
			imshow(Im_BW,'Parent',GUI_Parameters.Handles.Axes);
			set(gca,'YDir','normal');
			set(GUI_Parameters.Handles.Machine_Learning.Probability_Slider_Text,'String',source.Value);
			
			set(GUI_Parameters.Handles.Machine_Learning.Probability_Slider,'Enable','on');
			% disp(source.Value);
		end
		
		function NN_Min_Obejct_Size_Slider_Func(source,event)
			% [Scores,GUI_Parameters.Workspace(1).Workspace.Im_BW] = Apply_Trained_Network(NN1,GUI_Parameters.Workspace(1).Workspace.Image0,source.Value,Input_Type);
			set(GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Slider,'Enable','off');
			
			Im_BW(find(GUI_Parameters.Workspace(1).Workspace.NN_Probabilities >= GUI_Parameters.Handles.Machine_Learning.Probability_Slider.Value)) = 1;
			Im_BW(find(GUI_Parameters.Workspace(1).Workspace.NN_Probabilities < GUI_Parameters.Handles.Machine_Learning.Probability_Slider.Value)) = 0;
			
			CC = bwconncomp(Im_BW);
			for c=1:CC.NumObjects
				if(length(CC.PixelIdxList{1,c}) <= source.Value)
					Im_BW(CC.PixelIdxList{1,c}) = 0;
				end
			end
			
			Reset_Axes();
			imshow(Im_BW,'Parent',GUI_Parameters.Handles.Axes);
			set(gca,'YDir','normal');
			set(GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Text,'String',source.Value);
			
			set(GUI_Parameters.Handles.Machine_Learning.Min_Obejct_Size_Slider,'Enable','on');
		end
		
		function Save_Training_Sample_Func(source,event)
			Dir1 = uigetdir; % Let the user choose a directory.
			Files_List = dir(Dir1); % List of files.
			f = (length(find([Files_List.isdir] == 0)) / 2) + 1; % A unique integer for the new sample.
			if(~isempty(GUI_Parameters.Workspace(1).Workspace.Im_BW))
				imwrite(GUI_Parameters.Workspace(1).Workspace.Image0,[Dir1,filesep,num2str(f),'_GS_',GUI_Parameters.Handles.FileName]);
				imwrite(GUI_Parameters.Workspace(1).Workspace.Im_BW,[Dir1,filesep,num2str(f),'_BW_',GUI_Parameters.Handles.FileName]);
			end
		end
		
		function Save_NN_View_To_Workspace(source,event)
			if(isempty(Im_BW))
				display('Im_BW was not found');
			else % If the project does not have any BW reconstruction.
				GUI_Parameters.Workspace(1).Workspace.Im_BW = Im_BW;
				h = msgbox({'Binary Image Successully Updated as Initial Guess.'});
				ah = get(h,'CurrentAxes');
				ch = get(ah,'Children');
				set(ch,'FontSize',14);
				P = get(h,'Position');
				P(1) = P(1) - 0.8*P(3);
				P(3) = P(3) + 0.8*P(3);
				% P(4) = P(4) * 1.2;
				set(h,'Position',P);
				% set(GUI_Parameters.Handles.Tracing.Editing_Tab,'Enable','on');
				set(H0_1_1,'Enable','on');
				set(H0_1_1_1,'Enable','on');
				% TODO: Add popup explaining the next step in the pipeline...
			end
			
			% assignin('base','GUI_Parameters',GUI_Parameters);
			% assignin('base','Im_BW',Im_BW);
			
		end
	end
	
	function Edit_BW_Func(source,callbackdata)
		
		set(GUI_Parameters.Handles.Start_Edit_BW,'Enable','off');
		GUI_Parameters.Handles.Finish_Edit_BW = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Editing_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Apply Changes','Units','Normalized','Position',[0 0.01 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Finish_Edit_BW_Func);
		GUI_Parameters.Handles.Save_BW = uicontrol('Parent',GUI_Parameters.Handles.Tracing.Editing_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'String','Save Binary Image','Units','Normalized','Position',[0 0.11 1 GUI_Parameters.Visuals.Button1_Height],'Callback',@Save_BW_Func);
		
		% TODO: Add a check (if) to see if a BW exists...
		
		% Create the buttons for editing the BW reconstruction (before tracing):
		GUI_Parameters.Handles.Edit_BW_View_Radio_Group = uibuttongroup(GUI_Parameters.Handles.Tracing.Editing_Tab,'Position',[.05,0.2,1,0.2],'BorderType','none','SelectionChangedFcn',@Edit_BW_Radio_View_Func);
		GUI_Parameters.Handles.Machine_Learning.Grayscale = uicontrol(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'Style','radiobutton','String','Original','UserData',1,'Units','normalized','FontSize',18,'Position',[0,0.5,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.BW = uicontrol(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'Style','radiobutton','String','BW','UserData',2,'Units','normalized','FontSize',18,'Position',[0.4,0.5,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.RGB = uicontrol(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'Style','radiobutton','String','RGB','UserData',3,'Units','normalized','FontSize',18,'Position',[0.65,0.5,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.BW_Skel = uicontrol(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'Style','radiobutton','String','Skeleton','UserData',4,'Units','normalized','FontSize',18,'Position',[0,0,0.5,.5]);
		set(GUI_Parameters.Handles.Edit_BW_View_Radio_Group,'SelectedObject',GUI_Parameters.Handles.Machine_Learning.BW);
		% ":
		GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group = uibuttongroup(GUI_Parameters.Handles.Tracing.Editing_Tab,'Position',[.05,0.4,1,0.1],'BorderType','none','SelectionChangedFcn',@Edit_BW_Radio_MarkerSize_Func);
		GUI_Parameters.Handles.Machine_Learning.MarkerSize1 = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String','1','UserData',1,'Units','normalized','FontSize',18,'Position',[0,0.4,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.MarkerSize2 = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String','2','UserData',2,'Units','normalized','FontSize',18,'Position',[0.15,0.4,0.5,.5],'Enable','off');
		GUI_Parameters.Handles.Machine_Learning.MarkerSize3 = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String','3','UserData',3,'Units','normalized','FontSize',18,'Position',[0.3,0.4,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.MarkerSize5 = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String','5','UserData',5,'Units','normalized','FontSize',18,'Position',[0.45,0.4,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.MarkerSize11 = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String','11','UserData',11,'Units','normalized','FontSize',18,'Position',[0.6,0.4,0.5,.5]);
		GUI_Parameters.Handles.Machine_Learning.MarkerSize15 = uicontrol(GUI_Parameters.Handles.Edit_BW_MarkerSize_Radio_Group,'Style','radiobutton','String','15','UserData',15,'Units','normalized','FontSize',18,'Position',[0.75,0.4,0.5,.5]);
		
		[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(1).Workspace.Image0);
		Im_RGB = zeros(Im_Rows,Im_Cols,3);
		Im_RGB(:,:,1) = im2double(GUI_Parameters.Workspace(1).Workspace.Image0);
		Im_RGB(:,:,2) = GUI_Parameters.Workspace(1).Workspace.Im_BW .* Im_RGB(:,:,1);
		Im_RGB(:,:,1) = Im_RGB(:,:,1) .* (1-GUI_Parameters.Workspace(1).Workspace.Im_BW);
		
		XL = xlim;
		YL = ylim;
		% Pointer_Shape_Mat = ones(32,32);
		NN_MarkerSize = 1; % Default.
		
		Im_Handle = imshow(GUI_Parameters.Workspace(1).Workspace.Im_BW,'Parent',GUI_Parameters.Handles.Axes);
		set(Im_Handle,'HitTest','off');
		
		set(GUI_Parameters.Handles.Axes,'YDir','normal','PickableParts','all','ButtonDownFcn',@Mouse_Edit_BW_Func,'Position',[0,0,1,1]);
		
		function Edit_BW_Radio_View_Func(source,event)
			XL = xlim;
			YL = ylim;
			switch GUI_Parameters.Handles.Edit_BW_View_Radio_Group.SelectedObject.UserData
				case 1
					imshow(GUI_Parameters.Workspace(1).Workspace.Image0);
					xlim(XL);
					ylim(YL);
				case 2
					Im_Handle = imshow(GUI_Parameters.Workspace(1).Workspace.Im_BW);
					set(Im_Handle,'HitTest','off');
					xlim(XL);
					ylim(YL);
				case 3
					Im_Handle = imshow(Im_RGB);
					set(Im_Handle,'HitTest','off');
					xlim(XL);
					ylim(YL);
				case 4
					[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Pixel_Trace_Post_Proccessing(GUI_Parameters.Workspace(1).Workspace.Im_BW);
					imshow(Im1_NoiseReduction);
					assignin('base','Im1_NoiseReduction',Im1_NoiseReduction);
					xlim(XL);
					ylim(YL);
					
					% Color connected components:
					CC = bwconncomp(Im1_NoiseReduction);
					for c=1:length(CC.PixelIdxList)
						[y,x] = ind2sub(size(Im1_NoiseReduction),CC.PixelIdxList{c});
						hold on;
						plot(x,y,'.','MarkerSize',7);
					end
					
					% assignin('base','Ims',Im1_NoiseReduction);
					% assignin('base','Workspace',GUI_Parameters.Workspace(1).Workspace);
			end
			set(gca,'YDir','normal','PickableParts','all','ButtonDownFcn',@Mouse_Edit_BW_Func);
			% Mouse_Edit_BW_Func();
			XL = xlim;
			YL = ylim;
		end
		
		function Edit_BW_Radio_MarkerSize_Func(source,event)
			NN_MarkerSize = source.SelectedObject.UserData;
		end
		
		function Mouse_Edit_BW_Func(source,event)
			XL = xlim;
			YL = ylim;
			D = ((NN_MarkerSize-1)/2); % D = round((XL(2)-XL(1))/40); % *(YL(2)-YL(1));		
			
			C = event.IntersectionPoint; % C = get(GUI_Parameters.Handles.Axes,'CurrentPoint');
			C = [round(C(1)),round(C(2))]; % C = [round(C(1,1)),round(C(1,2))]
			C = [C(1)-D,C(1)+D,C(2)-D,C(2)+D];
			
			switch event.Button
				case 1 % Left mouse click - add pixels.
					% display(1);
					[Fy,Fx] = find(Im_RGB(C(3):C(4),C(1):C(2),2) == 0);
					Fx = Fx + C(1) - 1;
					Fy = Fy + C(3) - 1;
					F = (Im_Rows*(Fx-1)+Fy);
					Im_RGB(F + (Im_Rows*Im_Cols)) = Im_RGB(F); % Add point (change to green channel).
					Im_RGB(F) = 0; % Delete the red channel.
					GUI_Parameters.Workspace(1).Workspace.Im_BW(F) = 1;
				case 3 % Right mouse click - delete pixels.
					% display(3);
					[Fy,Fx] = find(Im_RGB(C(3):C(4),C(1):C(2),1) == 0);
					Fx = Fx + C(1) - 1;
					Fy = Fy + C(3) - 1;
					F = (Im_Rows*(Fx-1)+Fy);
					Im_RGB(F) = Im_RGB(F + (Im_Rows*Im_Cols)); % Delete point (change to red channel).
					Im_RGB(F + (Im_Rows*Im_Cols)) = 0; % Delete the green channel.
					GUI_Parameters.Workspace(1).Workspace.Im_BW(F) = 0;
			end
			Edit_BW_Radio_View_Func();
		end
		
		function Save_BW_Func(source,callbackdata)
			imwrite(GUI_Parameters.Workspace(1).Workspace.Image0,[uigetdir,filesep,GUI_Parameters.Handles.FileName,'Source.tif']);
			imwrite(GUI_Parameters.Workspace(1).Workspace.Im_BW,[uigetdir,filesep,GUI_Parameters.Handles.FileName,'_Annotated.tif']);
		end
		
		function Finish_Edit_BW_Func(source,callbackdata)
			
			% GUI_Parameters.Workspace(1).Workspace.Im_BW = ;
			% TODO: update BW in workspace. Currently it is updated directly during the user editing.
			GUI_Parameters.Workspace(1).Workspace.User_Input.BW_Edited = 1;
			
			set(GUI_Parameters.Handles.Start_Edit_BW,'Enable','on');
			set(GUI_Parameters.Handles.Finish_Edit_BW,'Enable','off');
		end
	end
	
	function Start_A_New_Project_Func(source,callbackdata)
		% {['..',filesep,'*.tif'];['..',filesep,'*.jpg'],'Image Files'}
		[FileName,PathName,FilterIndex] = uigetfile(fullfile(pwd,'..',filesep,'*.tif;*.jpg'),'Please Choose an Image File.',cd); % Lets the user choose a file.
		if(FileName == 0)
			return;
		end
		Current_Dir = cd(PathName);
		GUI_Parameters.Handles.FileName = FileName;
		
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
		
		p = 1;
		Y0 = 0.65;
		
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
			GUI_Parameters.Workspace(1).Workspace.Im_BW = [];
			
			GUI_Parameters.General.Active_View = 1;
			% Reset_Axes();
			
			% Set the scale-bar:
			GUI_Parameters.Workspace(1).Workspace.User_Input(1).Scale_Factor = str2num(User_Input.Scale_Bar.Length.String) / ...
																			str2num(User_Input.Scale_Bar.Pixels.String);
			GUI_Parameters.Workspace(1).Workspace.User_Input(1).Scale_Unit = User_Input.Scale_Bar.Unit.String(User_Input.Scale_Bar.Unit.Value);
			
			for i=1:numel(Properties_Handles)
				GUI_Parameters.Workspace(1).Workspace.User_Input.Features.(strrep(Properties_Handles(i).Property_Name.String,' ','_')) = ...
					strrep(Properties_Handles(i).Property_Value.String,' ','_');
			end
			
			delete(H1);
			
			GUI_Parameters.Workspace(1).Workspace.Parameters = Parameters_Func(GUI_Parameters.Workspace(1).Workspace.User_Input.Scale_Factor);
			
			GUI_Parameters.Workspace(1).Workspace.Image0 = imread(strcat(PathName,FileName));
			
			a = 0;
			% Convert the loaded image to the default format (uint8, [0,255]):
			GUI_Parameters.Workspace(1).Workspace.Image0 = ...
			GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Image_Format(GUI_Parameters.Workspace(1).Workspace.Image0);
			
			cla(GUI_Parameters.Handles.Axes,'reset');
			imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
			set(gca,'YDir','normal','Position',[0,0,1,1]);
			% set(Display_List,'Enable','off');
			
			% Detect and display CB and the outsets of the branches connected to it:
			CB_BW_Threshold = GUI_Parameters.Workspace.Workspace.Parameters.Cell_Body.BW_Threshold;
			Scale_Factor = GUI_Parameters.Workspace.Workspace.User_Input.Scale_Factor;
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(GUI_Parameters.Workspace.Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(GUI_Parameters.Workspace.Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
			
			[Im_Rows,Im_Cols] = size(GUI_Parameters.Workspace(1).Workspace.Image0);
			GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Im_Rows = Im_Rows;
			GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Im_Cols = Im_Cols;
			
			GUI_Parameters.Workspace(1).Workspace.Path = struct('Rectangle_Index',{});
			
			% Enable the tracing list:
			% set(H0_1_2,'Enable','on');
			% set(allchild(H0_1_2),'Enable','on');
		end
		
		set(GUI_Parameters.Handles.Machine_Learning.Load_Trained_NN_Button,'Enable','on');
	end
	
	function Load_An_Existing_Project_File(source,callbackdata)
		
		if(nargin == 2) % Default: user loads a file with 1+ neurons. else: A single neuron at the end of the tracing.
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
		end
		
		[GUI_Parameters.Workspace,GUI_Parameters.Features] = Add_Features_To_All_Workspaces(GUI_Parameters.Workspace); % TODO: replace with automatic detection of features.
		waitbar(2/3,WB_H);
		
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
			Reset_Axes();
			GUI_Parameters.General.Active_Plot = 'Original Image';
			GUI_Parameters.General.Groups_OnOff = 1;
			
			Reconstruction_Index(GUI_Parameters);
			set(GUI_Parameters.Handles.Axes,'YDir','normal');
			
			% Detect and display CB and the outsets of the branches connected to it:
			CB_BW_Threshold = GUI_Parameters.Workspace.Workspace.Parameters.Cell_Body.BW_Threshold;
			Scale_Factor = GUI_Parameters.Workspace.Workspace.User_Input.Scale_Factor;
			[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(GUI_Parameters.Workspace.Workspace.Image0,CB_BW_Threshold,Scale_Factor,0); % Detect cell-body.
			[CB_Vertices,Pixels0,Pixels1] = Find_CB_Vertices(GUI_Parameters.Workspace.Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_BW_Threshold,1);
			set(Reconstructions_Menu_Handle,'Enable','on');
		end
		
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
		set(Graphs_Menu_Handle,'Enable','on');
		set(allchild(Graphs_Menu_Handle),'Enable','on');
		
		% assignin('base','GUI_Parameters',GUI_Parameters);
		% assignin('base','Features_Buttons_Handles',Features_Buttons_Handles);
		function Generate_Filter_Buttons
			% Field_Names = fieldnames(GUI_Parameters.Workspace); % Extract feature fields names.
			F1 = [7,5]; % TODO: temporarily choosing these features only. find([GUI_Parameters.Features.Num_Of_Options] > 1);
			Field_Names = {GUI_Parameters.Features(F1).Feature_Name}; % Extract feature fields names.
			Features_Buttons_Handles = zeros(10,length(Field_Names)); % Features buttons. 10 is the maximal number of buttons per feature (1st row is an ON\OFF button).
			GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles = zeros(1,length(Field_Names)); % ON\OFF title buttons. 10 is the maximal number of buttons per feature (1st row is an ON\OFF button).
			for f=1:length(F1) % For each field (=feature) (except the 1st field which is the workspace).
				V = unique([GUI_Parameters.Workspace.(Field_Names{f})]);
				N = length(V); % Number of values in a specific field.
				for b=1:min(N,numel(GUI_Parameters.Features(F1(f)).Values)) % Generate N buttons.
					Features_Buttons_Handles(b,f) = uicontrol(GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','pushbutton',...
						'String',GUI_Parameters.Features(F1(f)).Values(b).Name, ...
						'UserData',[F1(f),b],'Callback',@Categories_Filter_Func,'Units','normalized','Position',[.03+(f-1)*(.44),(.9-.1*b),0.42,0.09], ...
						'FontSize',GUI_Parameters.Visuals.Button3_Font_Size,'BackgroundColor',[.9,.9,.9],'Callback',@Features_Buttons_Func);
				end
				GUI_Parameters.Handles.Analysis.Features_OnOff_Buttons_Handles(f) = uicontrol(GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,...
				'UserData',[f,F1(f),1],'Units','Normalized','Position',[.03+(f-1)*(.44),0.9,0.42,0.09],... % UserData=[,,ON\OFF].
				'BackgroundColor',[.2,.8,.4],'String',Field_Names{f},'Callback',@Features_OnOff_Buttons_Func);
				
				% Remove_Feature_Buttons_Handles(f) = uicontrol(GUI_Parameters.Handles.Analysis.Filters_Tab,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button1_Font_Size,'UserData',[f,F1(f)], ...
				% 		'Units','Normalized','Position',[.03+(f-1)*(.44),0.1,0.42,0.09],'BackgroundColor',[.2,.8,.4],'String','Remove','Callback',@Remove_Feature_Buttons_Func);
				% set(Remove_Feature_Buttons_Handles,'Enable','off');
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
	
	function Collect_Multiple_Workspaces(source,callbackdata)
		Workspace = Collect_All_Workspaces();
		uisave('Workspace',['All_Workspaces_',datestr(datetime,30),'.mat']);
		Load_An_Existing_Project_File();
	end
	
	function Update_Multiple_Workspaces(source,callbackdata)
		An = inputdlg('Please enter a probability matrix threshold:','Threshold Input',1,{'0.65'});
		NN_Threshold = str2num(An{1,1});
		Trace_Any_Multiple_Images(0,NN_Threshold); % Currently running without applying the CNN again.
	end
	
	function Delete_Segments_Func(source,callbackdata)
		GUI_Parameters.Workspace(1).Workspace = Delete_Segment(GUI_Parameters.Workspace(1).Workspace,0,1);
		Reset_Axes();
		imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
		set(GUI_Parameters.Handles.Axes,'YDir','normal');
		Reconstruct_Trace_Dots(GUI_Parameters.Workspace(1).Workspace);
	end
	
	function Edit_Orders_Func(source,callbackdata)
		if(strcmp(GUI_Parameters.General.Active_Plot,'Menorah Orders'))
			if(~isfield(GUI_Parameters.Workspace(1).Workspace.User_Input,'Manual_Menorah_Orders') || ... % If the array does not exist or does not have the same # of segments, create\reset it.
												length(GUI_Parameters.Workspace(1).Workspace.User_Input.Manual_Menorah_Orders) ~= numel(GUI_Parameters.Workspace(1).Workspace.Segments))
				GUI_Parameters.Workspace(1).Workspace.User_Input(1).Manual_Menorah_Orders = zeros(1,numel(GUI_Parameters.Workspace(1).Workspace.Segments));
			end
			
			S = Find_Closest_Segment(GUI_Parameters.Workspace(1).Workspace);
			plot([GUI_Parameters.Workspace(1).Workspace.Segments(S).Rectangles(:).X],[GUI_Parameters.Workspace(1).Workspace.Segments(S).Rectangles(:).Y],...
			'color',order_colormap(str2num(source.String)),'LineWidth',2*GUI_Parameters.Workspace(1).Workspace.Segments(S).Width);
			GUI_Parameters.Workspace(1).Workspace.User_Input(1).Manual_Menorah_Orders(S) = str2num(source.String); % Update the order in the manual user array.
			
			% assignin('base','GUI_Parameters',GUI_Parameters);
		end
	end
	
	function Detect_Start_Points_Func(source,callbackdata)
		[GUI_Parameters.Workspace(1).Workspace,I6,CB_Perimeter,Ellipse_Ind] = Find_Cell_Body(GUI_Parameters.Workspace(1).Workspace);
		
		D = 7/GUI_Parameters.Workspace(1).Workspace.User_Input.Scale_Factor;
		hold on;
		axis([ min([Ellipse_Ind(:,1)]) - D , max([Ellipse_Ind(:,1)]) + D , min([Ellipse_Ind(:,2)]) - D , max([Ellipse_Ind(:,2)]) + D ]);
		% assignin('base','GUI_Parameters',GUI_Parameters);
	end
	
	function Delete_All_Start_Points_Func(source,callbackdata)
		GUI_Parameters.Workspace(1).Workspace.Path = struct('Rectangle_Index',{});
		Reset_Axes;
		imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
		set(gca,'YDir','normal');
		% assignin('base','GUI_Parameters',GUI_Parameters);
	end
	
	function Add_CB_Branch_Func(source,callbackdata)
		set(gcf,'Pointer','arrow');
		% assignin('base','GUI_Parameters',GUI_Parameters);
		GUI_Parameters.Workspace(1).Workspace = Add_CB_Branch(GUI_Parameters.Workspace(1).Workspace,GUI_Parameters.Handles.Figure,GUI_Parameters.Handles.Axes);
		% assignin('base','GUI_Parameters',GUI_Parameters);
	end
	
	function Add_Rectangle_To_Step_Func(source,callbackdata)
		GUI_Parameters.Workspace(1).Workspace = Add_Rectangle_To_Step(GUI_Parameters.Workspace(1).Workspace);
	end
	
	function Add_Step_Func(source,callbackdata)
		GUI_Parameters.Workspace(1).Workspace = Add_Step_GUI(GUI_Parameters.Workspace(1).Workspace);
	end
	
	function Start_Tracing_Func(source,callbackdata)
		% assignin('base','GUI_Parameters',GUI_Parameters);
		% set(GUI_Parameters.Handles.Display_Panel,'Enable','off');
		% set(GUI_Parameters.Handles.Edit_Panel,'Enable','off');
		set(Reconstructions_Menu_Handle,'Enable','off');
		set(Graphs_Menu_Handle,'Enable','off');
		
		axes(GUI_Parameters.Handles.Axes);
		Reset_Axes;
		set(GUI_Parameters.Handles.Axes,'YDir','normal');
		
		% GUI_Parameters.Workspace(1).Workspace = Trace1(GUI_Parameters.Workspace(1).Workspace);
		
		% Skeletonize, detect vertices and segments and find vertices angles:
		GUI_Parameters.Workspace(1).Workspace = Vertices_Analysis_Index(GUI_Parameters.Workspace(1).Workspace);
		
		% assignin('base','Workspace',GUI_Parameters.Workspace(1).Workspace);
		
		% Trace using skeleton vertices and Im_BW:
		GUI_Parameters.Workspace(1).Workspace = Connect_Vertices(GUI_Parameters.Workspace(1).Workspace);
		GUI_Parameters.Workspace(1).Workspace = rmfield(GUI_Parameters.Workspace(1).Workspace,'Im_BW'); % The probabilities matrix is saved instead.
		waitfor(msgbox('The Tracing Completed Successully.'));
		
		Load_An_Existing_Project_File();
		
		imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
		Reconstruct_Segmented_Trace(GUI_Parameters.Workspace(1).Workspace);
		set(GUI_Parameters.Handles.Axes,'YDir','normal');
		
		% set(GUI_Parameters.Handles.Display_Panel,'Enable','on');
		% set(GUI_Parameters.Handles.Edit_Panel,'Enable','on');
		set(Reconstructions_Menu_Handle,'Enable','on');
		set(Graphs_Menu_Handle,'Enable','on');
		% set(allchild(GUI_Parameters.Handles.Tracing.Tracing_Tab),'Enable','on');
	end
	
	function Trace_Multiple_Neurons(source,callbackdata)
		
		User_Input = GUI_Parameters.Workspace(1).Workspace.User_Input;
		
		% Scale_Factor = GUI_Parameters.Workspace(1).Workspace.User_Input(1).Scale_Factor;
		File1 = load(GUI_Parameters(1).Neural_Network(1).Directory);
		NN_Threshold = GUI_Parameters.Workspace(1).Workspace.Parameters.Neural_Network.Default_Pixel_Classification_Threshold;
		
		Trace_Multiple_Images(User_Input,File1.deepnet,NN_Threshold,GUI_Parameters.Handles.Figure);
		clear File1;
	end
	
	function Analyze_Func(source,callbackdata)
		
		set(findall(GUI_Parameters.Handles.Tracing.Tracing_Tab,'-property','enable'),'enable','off');
		
		display('Started Analyzing...');
		GUI_Parameters.Workspace(1).Workspace = Analyze1(GUI_Parameters.Workspace(1).Workspace);
		display('Finished Analyzing !');
		
		set(findall(GUI_Parameters.Handles.Tracing.Tracing_Tab,'-property','enable'),'enable','on');
	end
	
	function Save_Tracing_Func(source,callbackdata)		
		% Save project in a .mat file:
		Version_Num = GUI_Parameters.Workspace(1).Workspace.Parameters.General_Parameters.Version_Num;
		New_File_Name = strcat('MyTrace-V',Version_Num,'-',datestr(datetime,30),'.mat');
		cd(GUI_Parameters.General.Current_Dir);
		% assignin('base','GUI_Parameters',GUI_Parameters);
		Workspace = GUI_Parameters.Workspace;
		uisave('Workspace',New_File_Name);
	end
	
	function Reconstruction_Func(source,callbackdata)
		
		GUI_Parameters.General.Active_Plot = source.Label;
		GUI_Parameters.General.View_Category_Type = source.UserData;
		GUI_Parameters.General.Active_View = 1;
		
		Reset_Axes();		
		
		% if(GUI_Parameters.General.View_Category_Type > 0)
			% Categories_Filter_Lables(GUI_Parameters);
			% GUI_Parameters.General = Update_Categories_Filter_Values(GUI_Parameters.General,GUI_Parameters.Visuals.Active_Colormap);
		% end
		
		% Loading_Animation_Handle = gifplayer('Loading_Animation.gif',0.05);
		imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
		% [jObj,hjObj,hContainer] = Display_Wait_Animation(1);
		Reconstruction_Index(GUI_Parameters);
		set(GUI_Parameters.Handles.Axes,'YDir','normal');
		% Display_Wait_Animation(0,jObj,hjObj,hContainer);
		% delete(Loading_Animation_Handle.h1);
	end
	
	function Slider_Func(source,callbackdata)
		%{
		set(GUI_Parameters.Handles.Analysis.Slider,'Enable','off');
		
		Reset_Axes();
		hold on;
		if(GUI_Parameters.General.Active_View == 1)
			imshow(GUI_Parameters.Workspace(1).Workspace.Image0,'Parent',GUI_Parameters.Handles.Axes);
			Reconstruction_Index(GUI_Parameters);
		else
			Multiple_Choose_Plot(GUI_Parameters);
		end
		
		set(GUI_Parameters.Handles.Analysis.Slider,'Enable','on');
		%}
		Reset_Axes();
		hold on;
		Multiple_Choose_Plot(GUI_Parameters);
	end
	
	function Tree_Center_CheckBox_Func(source,callbackdata)
		% Tree_Center_CheckBox_Value = source.Value;
		[Cxy_Num,Cxy_Length] = Find_Tree_Center(GUI_Parameters.Workspace(1).Workspace);
		axes(GUI_Parameters.Handles.Axes);
		hold on;
		plot(GUI_Parameters.Handles.Axes,Cxy_Length(1),Cxy_Length(2),'.g','MarkerSize',40);
		plot(GUI_Parameters.Handles.Axes,Cxy_Num(1),Cxy_Num(2),'.r','MarkerSize',20);
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
	
	function New_Project_Multiple_Func(source1,callbackdata1)
		
		Features_Struct = struct();
		Num_Of_Radio_Buttons = 10;
		Radio_Font_Size = 16;
		set(allchild(GUI_Parameters.Handles.Groups_Filter_Panel),'Enable','off');
		
		Dir1 = uigetdir; % Let the user choose a directory.
		
		% TODO: list files also from subfolders in any level.
		Dir_Files_List = dir(Dir1); % List of files names.
		Dir_Files_List(find([Dir_Files_List.isdir])) = []; % ".
		Delete_Array = [];
		
		h1 = waitbar(0,'Please wait...');
		for i=1:length(Dir_Files_List) % For each file.
			waitbar(i / length(Dir_Files_List));
			
			File1 = load(strcat(Dir1,filesep,Dir_Files_List(i).name)); % Load the file.
			if(isfield(File1.Workspace1.User_Input,'Features')) % If the features struct exists.
				Fields_Names = fieldnames(File1.Workspace1.User_Input.Features); % Find all field names.
				for j=1:length(Fields_Names) % For each field name.
					if(isfield(Features_Struct,Fields_Names{j})) % If the field already exists in 'Features_Struct',
						if(length(find(ismember(Features_Struct(1).(Fields_Names{j}), ...
							File1.Workspace1.User_Input.Features.(Fields_Names{j})))) == 0) % If the value doesn't exist.
							
							A = Features_Struct.(Fields_Names{j});
							A(end+1) = {File1.Workspace1.User_Input.Features.(Fields_Names{j})};
							Features_Struct.(Fields_Names{j}) = A; % Add it.
						end
					else % If the field does not exist,
						Features_Struct.(Fields_Names{j}) = {}; % Add this field (with an empty cell).
						
						A = Features_Struct.(Fields_Names{j});
						A(end+1) = {File1.Workspace1.User_Input.Features.(Fields_Names{j})};
						Features_Struct.(Fields_Names{j}) = A; % Add it.
					end
				end
			else % If the features struct does NOT exist.
				Delete_Array(end+1) = i;
			end
		end
		Dir_Files_List(Delete_Array) = []; % Delete this file entry from the list of files.
		close(h1);
		
		Fields_Names = vertcat('Choose a Property',fieldnames(Features_Struct));
		
		H1 = uipanel(GUI_Parameters.Handles.Main_Panel,'FontSize',12,'BackgroundColor',[0.5,0.5,0.5],'Position',[0.3 0.1 0.4 0.8]);
		Tabs_Group = uitabgroup(H1,'Position',[0 0.2 1 0.8]);
		Tabs_Handles = [];
		
		New_Group_Button = uicontrol(H1,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button2_Font_Size,'String','Add Another Group','Units','Normalized','Position',[0 0.1 1 0.1],'Callback',@New_Group_Func);
		Finish_Button = uicontrol(H1,'Style','pushbutton','FontSize',GUI_Parameters.Visuals.Button2_Font_Size,'String','Compare Groups','Units','Normalized','Position',[0 0 1 0.1],'Callback',@Finish_Func);
		
		New_Group_Func(source1,callbackdata1); % Run this function manually once in order to create the 1st group.
		
		function New_Group_Func(source,callbackdata)
			% Group_Num = Group_Num + 1;
			Group_Num = numel(GUI_Parameters.Workspace) + 1;
			
			Tabs_Handles(Group_Num) = uitab(Tabs_Group,'Title',['Group',' ',num2str(Group_Num)],'UserData',Group_Num,'BackgroundColor',[0.5,0.5,.5]);
			Tabs_Group.SelectedTab = Tabs_Handles(Group_Num);
			
			GUI_Parameters.Workspace(Group_Num).Handles(1).Group_Name_Panel = uipanel(Tabs_Handles(Group_Num),'FontSize',12,'BackgroundColor',[0.5,0.5,0.5],'Position',[0,0.9,1,0.1]);
			GUI_Parameters.Workspace(Group_Num).Handles(1).Group_Name_Textbox = uicontrol(GUI_Parameters.Workspace(Group_Num).Handles(1).Group_Name_Panel,'style','edit','units','Normalized','position',[0,0,1,1], ...
				'String',['Group',' ',num2str(Group_Num)],'UserData',Group_Num,'foregroundcolor','k','BackgroundColor','w','FontSize',24,'Callback',@Update_Group_Name_Func);
			
			GUI_Parameters.Workspace(Group_Num).Handles(1).Fields_Names = uicontrol(Tabs_Handles(Group_Num),'Style','popup','Units','Normalized', ...
				'Position',[0,0.78,1,0.1],'FontSize',GUI_Parameters.Visuals.Button1_Font_Size, ...
				'UserData',Group_Num,'String',Fields_Names,'Callback',@Update_Radio_Labels_Func);
			
			GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Group_Handle = uibuttongroup(Tabs_Handles(Group_Num),'Position',[0 0.2 1 0.61],'BackgroundColor',[0.5,0.5,0.5],'BorderType','none');
			GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Buttons_Handles = zeros(1,Num_Of_Radio_Buttons);
			
			GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Button_Any_Handle = uicontrol(GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Group_Handle, ... 
				'Style','radiobutton','UserData',[Group_Num,0],'Units','normalized','String','Any', ...
				'Position',[0.02,0.98-0.11,0.96,0.1],'FontSize',Radio_Font_Size,'Callback',@Update_Chosen_Radio);
			set(GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Button_Any_Handle,'Enable','off');
			set(GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Button_Any_Handle,'Visible','off');
			
			for i=1:Num_Of_Radio_Buttons
				GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Buttons_Handles(i) = uicontrol(GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Group_Handle,'Style','radiobutton', ...
					'UserData',[Group_Num,i],'Units','normalized','Position',[0.02,0.98-0.11*(i+1),0.96,0.1],'FontSize',Radio_Font_Size,'Callback',@Update_Chosen_Radio);
				set(GUI_Parameters.Workspace(Group_Num).Handles(1).Radio_Buttons_Handles(i),'Visible','off');
			end
			
			for i=2:numel(Fields_Names)
				S1 = char(Fields_Names(i));
				GUI_Parameters.Workspace(Group_Num).Values(1).(S1) = 'Any';
				GUI_Parameters.Workspace(Group_Num).Values(2).(S1) = 0;
			end
			
			% assignin('base','GUI_Parameters.Workspace',GUI_Parameters.Workspace);
		end
		
		function Update_Radio_Labels_Func(source,callbackdata)
			% assignin('base','Features_Struct',Features_Struct);
			
			if(source.Value > 1)
				S1 = source.String;
				S = Features_Struct.(char(S1(source.Value))); % Cell array of strings of the current feature.
				N = numel(S);
				
				n = GUI_Parameters.Workspace(source.UserData).Values(2).(char(S1(source.Value)));
				if(n > 0)
					set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Group_Handle,'SelectedObject', ...
						GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Buttons_Handles(n));
						% GUI_Parameters.Workspace(source.UserData).Values(2).(char(S1(source.Value)))+1);
				else
					set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Group_Handle,'SelectedObject', ...
						GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Button_Any_Handle);
				end
				
				for i=1:Num_Of_Radio_Buttons
					if(i > N)
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Buttons_Handles(i),'Enable','off');
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Buttons_Handles(i),'Visible','off');				
					else
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Button_Any_Handle,'Enable','on');
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Button_Any_Handle,'Visible','on');
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Buttons_Handles(i),'Visible','on');
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Buttons_Handles(i),'Enable','on');
						set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Buttons_Handles(i),'String',S(i));
					end
				end

			else
				set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Button_Any_Handle,'Enable','off');
				set(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Button_Any_Handle,'Visible','off');
				set(allchild(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Group_Handle),'Enable','off');
				set(allchild(GUI_Parameters.Workspace(source.UserData).Handles(1).Radio_Group_Handle),'Visible','off');
			end
			
		end
		
		function Update_Chosen_Radio(source,callbackdata)
			
			n = GUI_Parameters.Workspace(source.UserData(1)).Handles(1).Fields_Names.Value;
			S1 = char(Fields_Names(n));
			S2 = Features_Struct.(S1);
			if(source.UserData(2) > 0)
				GUI_Parameters.Workspace(source.UserData(1)).Values(1).(S1) = S2(source.UserData(2));
				GUI_Parameters.Workspace(source.UserData(1)).Values(2).(S1) = source.UserData(2);
			else
				GUI_Parameters.Workspace(source.UserData(1)).Values(1).(S1) = 'Any';
				GUI_Parameters.Workspace(source.UserData(1)).Values(2).(S1) = 0;
			end
			
			% assignin('base','GUI_Parameters.Workspace',GUI_Parameters.Workspace);
		end
		
		function Update_Group_Name_Func(source,callbackdata)
			set(Tabs_Handles(Tabs_Group.SelectedTab.UserData),'Title',source.String);
		end
		
		function Finish_Func(source,callbackdata)
			
			h1 = waitbar(0,'Please wait...');
			for i=1:numel(GUI_Parameters.Workspace) % For each group.
				GUI_Parameters.Workspace(i).Group_Name = strrep(GUI_Parameters.Workspace(i).Handles.Group_Name_Textbox.String,' ','_');
				GUI_Parameters.Workspace(i).Files = {};
				Delete_Array = [];
				
				for j=1:length(Dir_Files_List) % For each file.
					
					waitbar( ( ((i-1)*length(Dir_Files_List) + j) / length(Dir_Files_List)) / numel(GUI_Parameters.Workspace));
					
					% Check if the file belongs to this group:
					File1 = load(strcat(Dir1,filesep,Dir_Files_List(j).name)); % Load the file.
					Fields_Names = fieldnames(File1.Workspace1.User_Input.Features);
					t = 1; % A flag that says if the file belongs to the group or not.
					
					for f=1:length(Fields_Names) % For each field in the loaded file.
						if(GUI_Parameters.Workspace(i).Values(2).(Fields_Names{f}) > 0 && ... % If the value is not 0 (='Any').
							~strcmp(char(GUI_Parameters.Workspace(i).Values(1).(Fields_Names{f})), ... % and the field value is not the same as for the group.
								File1.Workspace1.User_Input.Features.(Fields_Names{f})))
							t = 0; % If at least one field has a different value, turn the flag off.
						end
					end
					
					if(t) % If this file belongs to this group.
						
						% delete unwanted fields\info:						
						% if(isfield(File1.Workspace1,'Image0'))
							% File1.Workspace1 = rmfield(File1.Workspace1,'Image0');
						% end
						if(isfield(File1.Workspace1,'Workspace0'))
							File1.Workspace1 = rmfield(File1.Workspace1,'Workspace0');
						end
						if(isfield(File1.Workspace1,'Path'))
							File1.Workspace1 = rmfield(File1.Workspace1,'Path');
						end
						if(isfield(File1.Workspace1,'Steps'))
							File1.Workspace1 = rmfield(File1.Workspace1,'Steps');
						end
						if(isfield(File1.Workspace1,'Statistics'))
							File1.Workspace1 = rmfield(File1.Workspace1,'Statistics');
						end
						
						GUI_Parameters.Workspace(i).Files{end+1} = File1.Workspace1; % add the j-file to group i.
						Delete_Array(end+1) = j; % Save its row number and delete it later.
					end
				end
				Dir_Files_List(Delete_Array) = []; % Delete entries that were already used.
			end
			close(h1);
			delete(H1); % Delete all graphics handles. delete(allchild(H1));
			GUI_Parameters.Workspace = rmfield(GUI_Parameters.Workspace,'Handles');
			
			% assignin('base','GUI_Parameters',GUI_Parameters);
			
			GUI_Parameters = Plot_Multiple(GUI_Parameters);
			GUI_Parameters.General.Single_Multiple = 2; % Multiple Images Analysis.
			set(Graphs_Menu_Handle,'Enable','on');
			GUI_Parameters.General.Current_Groups_Num = numel(GUI_Parameters.Workspace);
			set(Groups_Buttons(1:GUI_Parameters.General.Current_Groups_Num),'Enable','on');
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
	
	function Merge_Dorsal_Ventral_Func(source,callbackdata)
		if(GUI_Parameters.General.Active_View > 1)
			Reset_Axes();
			hold on;
			Multiple_Choose_Plot(GUI_Parameters);
		end
	end
	
	function Display_Significance_Bars_Func(source,callbackdata)
		if(GUI_Parameters.General.Active_View > 1)
			Reset_Axes();
			hold on;
			Multiple_Choose_Plot(GUI_Parameters);
		end
	end
	
	function Display_Normalized_Resutls_Func(source,callbackdata)
		Reset_Axes();
		% GUI_Parameters.Multiple.Normalization_OnOff = source.Value; % TODO: delete.
		hold on;
		Multiple_Choose_Plot(GUI_Parameters);
	end
	
	function Cluster_Data_Func(source,callbackdata)
		Reset_Axes();
		hold on;
		Multiple_Choose_Plot(GUI_Parameters);
	end
	
	function Flip_Contrast_Func(source,callbackdata)
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
		delete(allchild(GUI_Parameters.Handles.Main_Panel));
		GUI_Parameters.Handles.Axes = axes('Units','normalized','Position',GUI_Parameters.Visuals.Main_Axes_Size,'Parent',GUI_Parameters.Handles.Main_Panel);
		
		if(GUI_Parameters.General.Active_View == 1)
			set(GUI_Parameters.Handles.Axes,'Position',[0,0,1,1]);
		end
		
		if(Flip_Contrast_CheckBox.Value)
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

end