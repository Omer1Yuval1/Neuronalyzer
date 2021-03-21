function GUI_Params(P)
	
	P(1).GUI_Handles.Software_Name = 'Neuronalyzer';
	P(1).GUI_Handles.Software_Version = '2.0.0';
	
	P.GUI_Handles.UI = 1; % 0 = figure. 1 = uifigure.
	P.GUI_Handles.Multi_View = 0; % 0 = Single-view project. Multiple files are loaded as separate projects. 1 = Multi-view project. All files are loaded as one project.
	P.GUI_Handles.Save_Input_Data_Path = 0; % 0 = Save input data explicitly (e.g. image). 1 = Save only the path to the input data.
	
	P.GUI_Handles.Input_Data_Formats = {'*.tif;*.tiff;*.jpg;*.png'};
	
	P.GUI_Handles.Buttons_Names = {'Load Data','Load Project','Edit Parameters' ; 'Denoise Image','Trace Neuron','Extract Features' ; 'Apply Changes','Save Image','Save Project'};
	P.GUI_Handles.Step_Buttons_Names = {'Back','Start','Denoising','Vertex Detection','Neuron Tracing','Validation','Analysis','Next'};
	P.GUI_Handles.Info_Fields_List = {'Experiment','Analysis','Graphics'}; % Fields to include as tabs and tables in the info panel.
	P.GUI_Handles.Menu_Names = {'Project','Reconstructions','Plots'};
	
	P.GUI_Handles.Reconstruction_Menu_Entries = {'Project','Reconstruction','Plot'};
	
	
	P.GUI_Handles.Figure_Dims_Ratio = 2;
	
	P.GUI_Handles.Buttons_FontSize = 16;
	P.GUI_Handles.Step_Buttons_FontSize = 16;
	
	P.GUI_Handles.BG_Color_1 = [.25,.25,.25];
	P.GUI_Handles.BG_Color_2 = [1,1,1];
	
	P.GUI_Handles.Step_BG_Before = [.7,.2,.2];
	P.GUI_Handles.Step_BG_Active = [.8,.8,0];
	P.GUI_Handles.Step_BG_Done = [.1,.5,.1];
	
	P.GUI_Handles.Button_BG_Neurtral = [0.0980,0.0980,0.4392]; % [0,0,0.5]; [0.2549,0.4118,0.8824]; [.1,.1,.9];
	
	P.GUI_Handles.Plots.Axis_Title_FontSize = 20;
	P.GUI_Handles.Plots.Axis_Ticks_FontSize = 18;
	
	% P.GUI_Handles.Class_Colors = [0.6,0,0 ; 0,0.6,0 ; 0.12,0.56,1 ; 0.8,0.8,0];
	% P.GUI_Handles.Class_Colors = [0.9333,0.1333,0.1255 ; 0.0157,0.5961,0.1922 ; 0.0157,0.5804,0.8118 ; 0.9294,0.5961,0.0275];
	
	% P.GUI_Handles.Class_Colors = [0.9294,0.5961,0.0275 ; 0.0157,0.5961,0.1922 ; 0.0157,0.5804,0.8118 ; 0.9333,0.1333,0.1255];
	% P.GUI_Handles.Class_Colors = [0.9608,0.6314,0.0784 ; 0.0157,0.5961,0.1922 ; 0.0157,0.5804,0.8118 ; 0.9333,0.1333,0.1255];
	% P.GUI_Handles.Class_Colors = [0.0157,0.5961,0.1922 ; 0.9608,0.6314,0.0784 ; 0.0157,0.5804,0.8118 ; 0.9333,0.1333,0.1255];
	% P.GUI_Handles.Class_Colors = [0.9608,0.6314,0.0784 ; 0.0157,0.5961,0.1922 ; 0.9333,0.1333,0.1255 ; 0.0157,0.5804,0.8118];
	P.GUI_Handles.Class_Colors = [0.9333,0.1333,0.1255 ; 0.0157,0.5961,0.1922 ; 0.0157,0.5804,0.8118 ; 0.9608,0.6314,0.0784];
	% P.GUI_Handles.Class_Colors = [0.9333,0.1333,0.1255 ; 0.0157,0.5961,0.1922 ; 0.9608,0.6314,0.0784 ; 0.0157,0.5804,0.8118];
	% P.GUI_Handles.Class_Colors = [0.0157,0.5804,0.8118 ; 0.0157,0.5961,0.1922 ; 0.9608,0.6314,0.0784 ; 0.9333,0.1333,0.1255];
	
	
end