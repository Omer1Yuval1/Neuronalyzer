function Multiple_Choose_Plot(GUI_Parameters)
	
	% Single_Workspace_Operation is a function to operate on the values vector of each single workspace (= animal).
	
	assignin('base','GUI_Parameters',GUI_Parameters);
	
	switch GUI_Parameters.General.Active_Plot
		case 'Mean Segment Length'
			Single_Workspace_Operation = @(x) x(x>=0); % The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'Mean Length of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'Length'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Total Length'
			Single_Workspace_Operation = @(x) sum(x(x>=0)); % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'Total Length';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'Length'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'End2End Length Of Segments'
			Single_Workspace_Operation = @(x) x(x>=0); % The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'End2End Length Of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'End2End_Length'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Curvature Of Segments'
			Single_Workspace_Operation = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Y_Label = 'Mean Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature Of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'Curvature'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'CB Intensity'
			Single_Workspace_Operation = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Y_Label = 'Pixel Intensity';
			Title = 'Intensity of the Cell Body';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'CB',{'Mean_Intensity'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
		case 'CB Area'
			Single_Workspace_Operation = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Y_Label = 'Area (\mum^2)';
			Title = 'Area of the Cell Body';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'CB',{'Area'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Distances Of Vertices From The CB'
			Single_Workspace_Operation = @(x) x; % The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'Distances Of Vertices From The CB';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Distance_From_CB'},Single_Workspace_Operation);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Linearity-Symmetry of 3-Way junctions'
			Single_Workspace_Operation = @(x) x; % The length of a segment has to be positive.
			Y_Label = 'Linearity';
			X_Label = 'Symmetry';
			Title = 'Linearity-Symmetry of 3-Way junctions';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Symmetry','Linearity'},Single_Workspace_Operation);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
		
		%{
		case 'Segments Length Distribution'
			% Property_Func = str2func('Segments_Length_Struct');
			% XLable = 'Length (\mum)';
			% YLable = 'Number of Segments';
			% Title1 = 'Distribution of Segments Length';
			% Histogram_Plot(GUI_Parameters,Property_Func,[0,40],[1,10],0,XLable,YLable,Title1,'normal',1,1);
			Plot_Segments_Length(GUI_Parameters);
		case 'Length Distribution'
			Property_Func = str2func('Length_Gradient');
			XLable = 'Length (\mum)';
			YLable = 'Mean Length (\mum)';
			Title1 = 'Distribution of Neuronal Length Along the Primary Branches';
			Histogram_Plot(GUI_Parameters,Property_Func,[-500,500],[1,100],0,XLable,YLable,Title1,'reverse',1,1);
		case 'Symmetry of 3-Way junctions'
			Plot_Junctions_Symmetry(GUI_Parameters);

		case 'Smallest Angles of 3-Way Junctions'
			Smallest_Angles_2D_Menorah_Orders(GUI_Parameters);
		case 'Linearity VS Assymetry'
			Two_Angles_Closest_To_Source_Rect(GUI_Parameters);
		case 'Distribution of the "New" Angle in 3-way Junctions'
			Property_Func = str2func('New_Angle_Distribution');
			XLable = 'Angle (\^o)';
			YLable = 'Number of Junctions';
			Title1 = 'Distribution of the Branching Angle in 3-way Junctions';
			Histogram_Plot(GUI_Parameters,Property_Func,[0,210],[1,60],0,XLable,YLable,Title1,'normal',1,0);
		case 'Density of Vertices'
			Means_Plot(GUI_Parameters,'Vertices_Density','# of Branch-Points Per Branch Length (\mum)','Density of Vertices');
		%}
end