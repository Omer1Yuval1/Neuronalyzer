function Multiple_Choose_Plot(GUI_Parameters)
	
	% Workspace_Operations is a function to operate on the values vector of each single workspace (= animal).
	
	% assignin('base','GUI_Parameters2',GUI_Parameters);
	
	switch GUI_Parameters.General.Active_Plot
		case 'Mean Segment Length'
			Workspace_Operations = @(x) x(x>=0); % The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'Mean Length of Segments';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'Length'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Total Length'
			Workspace_Operations = @(x) sum(x(x>=0)); % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'Total Length';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'Length'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'End2End Length Of Segments'
			Workspace_Operations = @(x) x(x>=0); % The length of a segment has to be positive.
			Y_Label = 'Length (\mum)';
			Title = 'End2End Length Of Segments';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'End2End_Length'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Curvature Of Segments'
			Workspace_Operations = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Y_Label = 'Mean Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature Of Segments';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',{'Curvature'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'CB Intensity'
			Workspace_Operations = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Y_Label = 'Pixel Intensity';
			Title = 'Intensity of the Cell Body';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'CB',{'Mean_Intensity'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
		case 'CB Area'
			Workspace_Operations = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Y_Label = 'Area (\mum^2)';
			Title = 'Area of the Cell Body';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'CB',{'Area'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Distances Of Vertices From The CB'
			Workspace_Operations = @(x) x;
			Y_Label = 'Length (\mum)';
			Title = 'Distances Of Vertices From The CB';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Distance_From_CB'},Workspace_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Histogram of all Angles'
			Workspace_Operations = @(x) x(x>=0).*180./pi; % Exclude tips (appear as angle = -1) and convert to degrees.
			Y_Label = 'Probability';
			Title = 'Histogram of all Angles';
			X_Min_Max = [30,200];
			BinSize = 20 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles'},Workspace_Operations,RowWise);
			% assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,Y_Label,Title);
		case 'Histogram of Symmetry Indices'
			Workspace_Operations = @(x) x(x>=0);
			Y_Label = 'Probability';
			Title = 'Symmetry Indices';
			X_Min_Max = [0,1];
			BinSize = 0.1 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Symmetry'},Workspace_Operations,RowWise);
			% assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,Y_Label,Title);
		case 'Minimal and Maximal Angles of 3-Way junctions'
			Workspace_Operations{1} = @(x) x(x == min(x) & x>0);
			Workspace_Operations{2} = @(x) x(x == max(x) & x>0); % x(x ~= min(x) & x~=max(x) & x>0);
			X_Label = 'Minimal Angle';
			Y_Label = 'Maximal Angle';
			Title = 'Minimal and Maximal Angles of 3-Way junctions';
			RowWise = 1;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles'},Workspace_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
		case 'The Two Minimal Angles of each 3-Way junction'
			Workspace_Operations{1} = @(x) x(x == min(x) & x>0);
			Workspace_Operations{2} = @(x) x(x ~= min(x) & x~=max(x) & x>0);
			X_Label = 'Minimal Angle';
			Y_Label = 'Mid-size Angle';			
			Title = 'The Two Minimal Angles of each 3-Way junction';
			RowWise = 1;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles'},Workspace_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
		case 'Linearity-Symmetry of 3-Way junctions'
			Workspace_Operations = @(x) x;
			X_Label = 'Symmetry';
			Y_Label = 'Linearity';
			Title = 'Linearity-Symmetry of 3-Way junctions';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Symmetry','Linearity'},Workspace_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
		
		case 'Sum of 2 Smallest VS Product of 2 Smallest'
			Workspace_Operations{1} = @(x) (x(x == min(x) & x>0)) + x(x ~= min(x) & x~=max(x) & x>0);
			Workspace_Operations{2} = @(x) (x(x == min(x) & x>0)) .* x(x ~= min(x) & x~=max(x) & x>0);
			X_Label = 'Sum of 2 Smallest Angles';
			Y_Label = 'Product of 2 Smallest Angles';			
			Title = 'Sum of 2 Smallest VS Product of 2 Smallest';
			RowWise = 1;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles'},Workspace_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
			
		case 'Smallest Angle VS Diff between 2 Smallest'
			Workspace_Operations{1} = @(x) x(x == min(x) & x>0);
			Workspace_Operations{2} = @(x) abs((x(x == min(x) & x>0)) - x(x ~= min(x) & x~=max(x) & x>0));
			X_Label = 'Smallest Angle';
			Y_Label = 'Diff between 2 Smallest Angles';			
			Title = 'Smallest Angle VS Diff between 2 Smallest';
			RowWise = 1;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles'},Workspace_Operations,RowWise);
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
		assignin('base','Input_Struct',Input_Struct);
end