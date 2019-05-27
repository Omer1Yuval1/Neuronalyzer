function GUI_Parameters = Load_GUI_Parameters
	
	GUI_Parameters = struct();
	GUI_Parameters(1).General(1).Current_Dir = cd;
	GUI_Parameters.General.Single_Multiple = 1; % 1 = Single Image Analysis. 2 = Multiple Images Analysis.
	GUI_Parameters.General.Active_View = 1; % 1 = Reconstruction. 2 = Means Graph. 3 = Angles Graph. 4 = Bar Histogram.
	GUI_Parameters.General.View_Category_Type = 1; % 0 = No Category. 1 = Branches Orders. 2 = Angles Orders.
	GUI_Parameters.General.Active_Plot = ''; % Current Plot Name.
	% GUI_Parameters.General.Categories_OnOff = 1:.5:10;
	GUI_Parameters.General.Num_Of_Caterogories_Filter_Buttons = 16;
	GUI_Parameters.General.Num_Of_Menorah_Orders = 9;
	GUI_Parameters.General.Num_Of_Menorah_Angles_Orders = 15;
	GUI_Parameters.General.Menorah_Orders_Labels = strsplit(strjoin({num2str([1:.5:4.5]),[num2str(5),'+']}));
	GUI_Parameters.General.Categories_Filter_Handles = [];
	GUI_Parameters.General.Categories_Filter_Values = [];
	GUI_Parameters.General.Groups_OnOff = 1:10;
	GUI_Parameters.General.Slider_Value = 0.9;
	GUI_Parameters.General.Version = '2.0';
	
	GUI_Parameters.General.Max_Menorah_Order = 5; % [1,1.5,2,2.5,3,3.5,4,4.5,5].
	GUI_Parameters.General.Num_Menorah_Order = 2*GUI_Parameters.General.Max_Menorah_Order - 1;
	GUI_Parameters.General.Current_Groups_Num = [];
	
	GUI_Parameters(1).Neural_Network(1).Directory = '';		
	GUI_Parameters(1).Neural_Network(1).Threshold = -1;		
	
	GUI_Parameters(1).Visuals(1).Main_Axes_Size_1 = [0 0 1 1];
	GUI_Parameters(1).Visuals(1).Main_Axes_Size_2 = [0.12 0.15 0.85 0.75];
	GUI_Parameters.Visuals.Button1_Font_Size = 14;
	GUI_Parameters.Visuals.Button2_Font_Size = 20;
	GUI_Parameters.Visuals.Button3_Font_Size = 12;
	GUI_Parameters.Visuals.Button1_Height = 0.08;
	GUI_Parameters.Visuals.Main_Title_Font_Size = 32;
	GUI_Parameters.Visuals.Axes_Titles_Font_Size = 30;
	GUI_Parameters.Visuals.Axes_Lables_Font_Size = 24;
	GUI_Parameters.Visuals.Mean_Dot_Size = 60;
	GUI_Parameters.Visuals.Mean_Line_Width = 4;
	GUI_Parameters.Visuals.Axss_Lables_Orientation = 30; % Degrees.
	GUI_Parameters.Visuals.Statistics_Tests_Font_Size = 20;
	GUI_Parameters.Visuals.Scatter_Dot_Size1 = 2;
	GUI_Parameters.Visuals.Jitter1 = 0.2;
	GUI_Parameters.Visuals.Jitter2 = 0.075;
	GUI_Parameters.Visuals.Legend_Font_Size1 = 30;
	GUI_Parameters.Visuals.Legend_Font_Size2 = 14;
	GUI_Parameters.Visuals.Alpha1 = 0.4;
	GUI_Parameters.Visuals.ErrorBar_Width1 = 2.5;
	GUI_Parameters.Visuals.ErrorBar_Color1 = [.5,.5,.5]; % [0 0.5 1]; [.392,.392,.392].
	GUI_Parameters.Visuals.ErrorBar_Color2 = [0.9 0 0];
	% GUI_Parameters.Visuals.Rectangles_Orientation_BinSize = 5;
	GUI_Parameters.Visuals.Black_On_White_Colormap = [0,0,0 ; 1 0 0 ; .125,.564,1 ; .188,.533,.039 ; .5 .8 .98 ; 0 .6 0 ; 1 1 0 ; .5 .16 .7 ; .01 .38 .88 ; .07 .51 .83 ; .02 .64 .78 ; .19 .72 .63 ; .54 .74 .46 ; .82 .73 .34 ; .64,.08,.18];
	GUI_Parameters.Visuals.White_On_Black_Colormap = [1,1,1 ; 1 0 0 ; .125,.564,1 ; .188,.533,.039 ; 1 .54 0 ; 0 .6 0 ; 1 1 0 ; .5 .16 .3 ; .01 .38 .88 ; .07 .51 .83 ; .02 .64 .78 ; .19 .72 .63 ; .54 .74 .46 ; .82 .73 .34 ; .97 .98 .05];
	
	GUI_Parameters.Visuals.Active_Colormap = GUI_Parameters.Visuals.Black_On_White_Colormap; % Default.
	% GUI_Parameters.Visuals.Menorah_Branches_Colormap = [.7 .7 .7 ; .4 .4 .4 ; 1 0 0 ; .72,.47,.34 ; 0 .63 .9 ; .13,.7,.3 ; 1 1 0 ; 1 .5 .15 ; 1 0 1];
	% GUI_Parameters.Visuals.Menorah_Junctions_Colormap = [.7 .7 .7 ; .4 .4 .4 ; 1 0 0 ; .72,.47,.34 ; 0 .63 .9 ; .13,.7,.3 ; 1 1 0 ; 1 .5 .15 ; 1 0 1];
	% GUI_Parameters.Visuals.Active_Menorah_Colormap = GUI_Parameters.Visuals.Menorah_Branches_Colormap;
	
	% TODO: temporary. just to have enough colors for all the groups:
	GUI_Parameters.Visuals.Black_On_White_Colormap = [GUI_Parameters.Visuals.Black_On_White_Colormap ; GUI_Parameters.Visuals.Black_On_White_Colormap];
	GUI_Parameters.Visuals.White_On_Black_Colormap = [GUI_Parameters.Visuals.White_On_Black_Colormap ; GUI_Parameters.Visuals.White_On_Black_Colormap];
end