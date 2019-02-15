function Multiple_Choose_Plot(GUI_Parameters)
	
	% This function...
	% 
	% 
	% 
	% The flag RowWise tells the Generate_Plot_Input() function to perform the field operation in a row-wise manner.
		% For example, this is necessary in cases in which a second field is used to filter out rows (e.g. vertex order).
	
	
	% Note: When using a field to filter-out rows, the # of values in different fields can be different.
		% This means that values in corresponding positions don't correspond. But that's ok because the filtering field is not analyzed.
		% Example: using the "order" field to include only 3rd order junctions, and the "Angle" field which can contain any number (>0) of values.	
	
	% Var_Operations is a function to operate on the values vector of each single workspace (= animal).
	
	% Note: RowWise must be set to 1 if: one of the field is a vector AND thes values won't be simply combined with all the rest (other rows).
	
	% assignin('base','GUI_Parameters2',GUI_Parameters);
	
	% Impotrant TODO:
		% The Angles field now contains the angle for tips (instead of -1).
		% Some of the plots here rely on that -1 to filter out tips.
		% Instead, I should change it to use the order field as a filter.
	%
	
	set(GUI_Parameters.Handles.Analysis.Dynamic_Slider_Min,'Enable','off');
	set(GUI_Parameters.Handles.Analysis.Dynamic_Slider_Max,'Enable','off');
	
	switch GUI_Parameters.General.Active_Plot
		case 'Number of Segments'
			% TODO: this could be replaced by a sums plot (similar to Means_Plot) but currently Generate_Plot_Input does not differentiate betweern workspaces.
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			m = GUI_Parameters.Handles.Analysis.Dynamic_Slider_Min.Value;
			M = GUI_Parameters.Handles.Analysis.Dynamic_Slider_Max.Value;
			Var_Operations{1} = @(x) Fan(x,m,M); % Summing up the logical 1s (but only taking positive sums).
			Filter_Operations = [];
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = [];
			%
			RowWise = 0;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%
			Y_Label = 'Count';
			Title = 'Number of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Number of Terminal Segments'
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			m = GUI_Parameters.Handles.Analysis.Dynamic_Slider_Min.Value;
			M = GUI_Parameters.Handles.Analysis.Dynamic_Slider_Max.Value;
			Var_Operations{1} = @(x) sum(x >= m & x<= M); % Summing up the logical 1s.
			Var_Operations{2} = @(x) sum(x >= m & x<= M); % Summing up the logical 1s.
			Filter_Operations = [];
			Var_Fields = {'Distance_From_Medial_Axis','Terminal'};
			Filter_Fields = [];
			%
			RowWise = 0;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%
			Y_Label = 'Count';
			Title = 'Number of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);

			
		case 'Mean Segment Length'
			Var_Operations{1} = @(x) x(x>=0); % The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Length'};
			Filter_Fields = [];
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Length (\mum)';
			Title = 'Mean Length of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
		case 'Total Length'
			Var_Operations{1} = @(x) sum(x(x>=0)); % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Length'};
			Filter_Fields = [];
			%
			RowWise = 0;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Length (\mum)';
			Title = 'Total Length';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'End2End Length Of Segments'
			Var_Operations{1} = @(x) x(x>=0); % The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'End2End_Length'};
			Filter_Fields = [];
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Length (\mum)';
			Title = 'End2End Length of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Mean Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Curvature'};
			Filter_Fields = {};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Mean Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Max Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Max_Curvature'};
			Filter_Fields = {};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Max Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature of Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Mean Curvature Of Terminal Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations{1} = @(x) (x==1);
			Var_Fields = {'Curvature'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Squared Curvature (1/(\mum)^2)';
			Title = 'Mean Curvature Of Terminal Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Max Curvature Of Terminal Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.05); % The curvature of a segment has to be positive.
			Filter_Operations{1} = @(x) (x==1);
			Var_Fields = {'Max_Curvature'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Y_Label = 'Squared Curvature (1/(\mum)^2)';
			Title = 'Max Curvature Of Terminal Segments';
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Distribution of Mean Squared Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Curvature'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			X_Label = 'Squared Curvature (1/(\mum)^2)';
			Y_Label = 'Count';
			Title = 'Mean of Squared Curvature of Segments';
			%
			X_Min_Max = [0,0.1];
			BinSize = 0.005 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distribution of Max Squared Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Max_Curvature'};
			Filter_Fields = {};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			X_Label = 'Squared Curvature (1/(\mum)^2)';
			Y_Label = 'Count';
			Title = 'Max of Squared Curvature of Segments';
			%
			X_Min_Max = [0,0.1];
			BinSize = 0.005 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);		
			
		case 'Distribution of Min Medial Angle Diff'
			Var_Operations{1} = @(x) x(x>=0) .*180 ./ pi;
			Filter_Operations = {};
			Var_Fields = {'Min_Medial_Angle_Corrected_Diff'};
			Filter_Fields = [];
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			X_Label = ['Angle (',char(176),')'];
			Y_Label = 'Count';
			Title = 'Minimal Difference between Medial Angle and Vertex Angles';
			%
			X_Min_Max = [0,180];
			BinSize = 20 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distribution of the Difference between Vertex and End2End Angles'
			Var_Operations{1} = @(x) x(x>0).*180./pi; % Angle difference in degrees (this values is supposed to always be positive: max(a1,a2)-min(a1,a2) ; a1,a2=[0,2.*pi]).
			Filter_Operations{1} = @(x) (x >= 0); % Both terminals and non-terminals.
			Var_Fields = {'End2End_Vertex_Angle_Diffs'};
			Filter_Fields = {'Terminal'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			X_Label = ['Angle (',char(176),')'];
			Y_Label = 'Count';
			Title = 'Difference between Vertex and End2End Angles';
			%
			X_Min_Max = [0,180];
			BinSize = 5 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'CB Intensity'
			Var_Operations = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Mean_Intensity'};
			Filter_Fields = [];
			%
			Y_Label = 'Pixel Intensity';
			Title = 'Intensity of the Cell Body';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'CB',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
		case 'CB Area'
			Var_Operations = @(x) x; % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Area'};
			Filter_Fields = [];
			%
			Y_Label = 'Area (\mum^2)';
			Title = 'Area of the Cell Body';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'CB',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Distances Of Vertices From The CB'
			Var_Operations{1} = @(x) x;
			Filter_Operations{1} = [];
			Var_Fields = {'Distance_From_CB'};
			Filter_Fields = [];
			%
			Y_Label = 'Length (\mum)';
			Title = 'Distances Of Vertices From The CB';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%
		case 'Distances Of Vertices From The Medial Axis - Means'
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = [];
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = [];
			%
			Y_Label = 'Distance (\mum)';
			Title = 'Mean Distance Of Vertices From The Medial Axis';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Distances Of Vertices From The Medial Axis - Histogram'
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = [];
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = [];
			%
			RowWise = 0;
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of Vertices From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,[],Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distances Of 3-Way Junctions From The Medial Axis - Histogram'
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = @(x) (x == 3); % Choose third order vertices only (= 3-way junctions).
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of 3-Way Junctions From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distances Of Tips From The Medial Axis - Histogram'
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = @(x) (x == 1); % Choose first order vertices only (= tips).
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			Dynamic_Field = 'Distance_From_Medial_Axis';
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of Tips From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Smallest Angle VS Distance From Medial Axis'
			% TODO: what if there are two minimums???????????
			Var_Operations{1} = @(x) x(x == min(x)); % Smallest Angle.
			Var_Operations{2} = @(x) x; % Distance from Medial Axis.
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions (and specifically not tips)..
			Filter_Operations{2} = @(x) (x >= 0); % Only 3-way junctions (and specifically not tips)..
			Var_Fields = {'Angles','Distance_From_Medial_Axis'};
			Filter_Fields = {'Order','Distance_From_Medial_Axis'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Distance (\mum)';
			Title = 'Smallest Angle VS Distance From Medial Axis';
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,[],Var_Operations,Filter_Operations,RowWise);
			assignin('base','Input_Struct',Input_Struct);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
			
		case 'Histogram of all Angles'
			Var_Operations{1} = @(x) x.*180./pi; % Exclude tips (appear as angle = -1) and convert to degrees.
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions (and specifically not tips)..
			Filter_Operations{2} = @(x) (x>=25 & x<=35); % x(x>=25 & x<=35). Filter-out distances from medial axis (TODO: validate!).
			Var_Fields = {'Angles'};
			Filter_Fields = {'Order','Distance_From_Medial_Axis'};
			%
			RowWise = 1;
			%%%
			X_Label = ['Angle (',char(176),')'];
			Y_Label = 'Count';
			Title = 'Histogram of all Angles of 3-way Junctions';
			%%%
			X_Min_Max = [30,200];
			BinSize = 20 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,[],Var_Operations,Filter_Operations,RowWise);
			% assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
		case 'Histogram of Symmetry Indices'
			Var_Operations{1} = @(x) x;
			Filter_Operations{1} = @(x) (x >= 0); % x(x>=25 & x<=35). Filter-out distances from medial axis (TODO: validate!).
			Var_Fields = {'Symmetry'};
			Filter_Fields = {'Symmetry'};
			%
			RowWise = 0;
			%%%
			X_Label = '';
			Y_Label = 'Probability';
			Title = 'Symmetry Indices';
			X_Min_Max = [0,1];
			BinSize = 0.1 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
		case 'Minimal and Maximal Angles of 3-Way junctions'
			Var_Operations{1} = @(x) x(x == min(x));
			Var_Operations{2} = @(x) x(x == max(x)); % x(x ~= min(x) & x~=max(x) & x>0);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Minimal Angle';
			Y_Label = 'Maximal Angle';
			Title = 'Minimal and Maximal Angles of 3-Way junctions';
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,[],Var_Operations,Filter_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
		case 'The Two Minimal Angles of each 3-Way junction'
			Var_Operations{1} = @(x) x(x == min(x));
			Var_Operations{2} = @(x) x(x ~= min(x) & x~=max(x));
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Minimal Angle';
			Y_Label = 'Mid-size Angle';			
			Title = 'The Two Minimal Angles of each 3-Way junction';
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
		case 'Linearity-Symmetry of 3-Way junctions'
			%{
			Var_Operations = @(x) x;
			
			RowWise = 0;
			%%%
			X_Label = 'Symmetry';
			Y_Label = 'Linearity';
			Title = 'Linearity-Symmetry of 3-Way junctions';
			%%%
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Symmetry','Linearity'},Var_Operations,RowWise);
			% Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
			%}
		case 'Sum of 2 Smallest VS Product of 2 Smallest'
			%{
			Var_Operations{1} = @(x) (x(x == min(x) & x>0)) + x(x ~= min(x) & x~=max(x) & x>0);
			Var_Operations{2} = @(x) (x(x == min(x) & x>0)) .* x(x ~= min(x) & x~=max(x) & x>0);
			X_Label = 'Sum of 2 Smallest Angles';
			Y_Label = 'Product of 2 Smallest Angles';			
			Title = 'Sum of 2 Smallest VS Product of 2 Smallest';
			RowWise = 1;
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles'},Var_Operations,RowWise);
			% Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
			%}
		case 'Smallest Angle VS Diff between 2 Smallest'
			%{
			Var_Operations{1} = @(x) x(x == min(x) & x>0);
			Var_Operations{2} = @(x) abs((x(x == min(x) & x>0)) - x(x ~= min(x) & x~=max(x) & x>0));
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Diff between 2 Smallest Angles';			
			Title = 'Smallest Angle VS Diff between 2 Smallest';
			%%%
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles'},Var_Operations,RowWise);
			% Two_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Title);
			%}
		case 'Smallest-Mid-largest'
			%{
			Var_Operations{1} = @(x) x(x == min(x) & x>0);
			Var_Operations{2} = @(x) x(x ~= min(x) & x~=max(x) & x>0);
			Var_Operations{3} = @(x) x(x == max(x) & x>0);
			X_Label = 'Minimal Angle';
			Y_Label = 'Mid-size Angle';
			Z_Label = 'Maximal Angle';
			Title = 'Smallest-Mid-largest';
			RowWise = 1;
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles','Angles'},Var_Operations,RowWise);
			% Three_Vars_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Label,Y_Label,Z_Label,Title);
			%}
		case '2D Histogram Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) x(x == min(x)).*180./pi;
			Var_Operations{2} = @(x) x(x == max(x)).*180./pi;
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			Filter_Operations{2} = @(x) (x>=10 & x<=20);
			%
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Angles','Distance_From_Medial_Axis'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Largest Angle'; % 'Maximal Angle';	
			Title = 'Angles of 3-Way Junctions';
			%%%
			BinSize = 20 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			% disp(GUI_Parameters.Handles.Analysis.Slider.Value);
			X_Min_Max = [30,120];
			Y_Min_Max = [110,290];
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Angles','Angles','Distance_From_Medial_Axis'},Var_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
		%%%
		case '2D Histogram of Corrected Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) x(x == min(x)).*180./pi;
			Var_Operations{2} = @(x) x(x == max(x)).*180./pi;
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			% Filter_Operations{2} = @(x) (x>=25 & x<=35);
			%
			Var_Fields = {'Corrected_Angles','Corrected_Angles'};
			Filter_Fields = {'Corrected_Angles'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Smallest Angle';
			Y_Label = 'Largest Angle'; % 'Maximal Angle';	
			Title = 'Corrected Angles of 3-Way Junctions';
			%%%
			BinSize = 20 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			% disp(GUI_Parameters.Handles.Analysis.Slider.Value);
			X_Min_Max = [30,120];
			Y_Min_Max = [110,290];
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
		
		case '2D Histogram of Invariant Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) (x(1).*x(2) + x(1).*x(3) + x(2).*x(3));
			Var_Operations{2} = @(x) (x(1).*x(2).*x(3));
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			% Filter_Operations{2} = @(x) (x>=25 & x<=35);
			%
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Angles'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Invariant 1';
			Y_Label = 'Invariant 2'; % 'Maximal Angle';	
			Title = 'Invariants of Angles of 3-Way Junctions';
			%%%
			BinSize = GUI_Parameters.Handles.Analysis.Slider.Value;
			% disp(GUI_Parameters.Handles.Analysis.Slider.Value);
			X_Min_Max = [10,15];
			Y_Min_Max = [5,10];
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Corrected_Angles','Corrected_Angles','Distance_From_Medial_Axis'},Var_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case '2D Histogram of Invariant Corrected Angles of 3-Way Junctions'
			Var_Operations{1} = @(x) (x(1).*x(2) + x(1).*x(3) + x(2).*x(3));
			Var_Operations{2} = @(x) (x(1).*x(2).*x(3));
			Filter_Operations{1} = @(x) (length(x) == 3); % Only 3-way junctions.
			% Filter_Operations{2} = @(x) (x>=25 & x<=35);
			%
			Var_Fields = {'Corrected_Angles','Corrected_Angles'};
			Filter_Fields = {'Corrected_Angles'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Invariant 1';
			Y_Label = 'Invariant 2'; % 'Maximal Angle';	
			Title = 'Invariants of Corrected Angles of 3-Way Junctions';
			%%%
			BinSize = GUI_Parameters.Handles.Analysis.Slider.Value;
			% disp(GUI_Parameters.Handles.Analysis.Slider.Value);
			X_Min_Max = [10,15];
			Y_Min_Max = [5,10];
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			% Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',{'Corrected_Angles','Corrected_Angles','Distance_From_Medial_Axis'},Var_Operations,RowWise);
			Histogram_2D_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,Y_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distribution of Vertices Angles Relative To The Medial Axis'
			Var_Operations{1} = @(x) mod(x.*180./pi,90);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles_Medial'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = '';
			Y_Label = 'Count';
			Title = 'Distribution of Vertices Angles Relative To The Medial Axis';
			X_Min_Max = [0,90];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise); % assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distribution of Vertices Angles Relative To The Medial Axis - Corrected'
			Var_Operations = @(x) mod(x.*180./pi,90);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles_Corrected_Medial'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = '';
			Y_Label = 'Count';
			Title = 'Distribution of Vertices Angles Relative To The Medial Axis - Corrected';
			X_Min_Max = [0,90];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise); % assignin('base','Input_Struct',Input_Struct);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
		case 'Histogram of Smallest, Mid & Largest Angles'
			Var_Operations{1} = @(x) x(x == min(x));
			Var_Operations{2} = @(x) x(x == max(x)); % x(x ~= min(x) & x~=max(x) & x>0);
			Filter_Operations{1} = @(x) (x == 3); % Only 3-way junctions.
			Var_Fields = {'Angles','Angles'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			BinSize = 1 + (30 .* GUI_Parameters.Handles.Analysis.Slider.Value);
			%
			Dynamic_Field = 'Distance_From_Medial_Axis';
			Set_Dynamic_Sliders_Values(GUI_Parameters.Handles.Analysis,0,50);
			%
			Title = 'Histogram of Smallest, Mid & Largest Angles';
			%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Dynamic_Field,Var_Operations,Filter_Operations,RowWise);
			Plot_3Angles_Junction_Histogram(Input_Struct,GUI_Parameters,BinSize,GUI_Parameters.Visuals,Title);
		
		case 'Custom_1_Total_Length'
			Custom_1_Total_Length(GUI_Parameters,GUI_Parameters.Visuals,'Length (\mum^2)','Total Length');
		case 'Custom_2_Vertices_Num'
			Custom_2_Vertices_Num(GUI_Parameters,GUI_Parameters.Visuals,'Count','Number of Vertices per Unit Length');
		case 'Custom_3_Tips_Num'
			Custom_3_Tips_Num(GUI_Parameters,GUI_Parameters.Visuals,'Count','Number of Tips per Unit Length');
		case 'Custom_4_Curvature_Hist'
			Custom_4_Curvature_Hist(GUI_Parameters,GUI_Parameters.Visuals,'Squared Curvature','Max Squared Curvature of Segments');			
		case 'Custom_5_Mean_Curvature'
			Custom_5_Mean_Curvature(GUI_Parameters,GUI_Parameters.Visuals,'Squared Curvature','Mean Squared Curvature of Segments');			
		case 'Custom_6_Rects_Orientation'
			Custom_6_Rects_Orientation(GUI_Parameters,GUI_Parameters.Visuals,['Angle (',char(176),')'],'Orientation of Vertices Relative to the Medial Axis');			
	
	end
	% assignin('base','Input_Struct',Input_Struct);
	
	function Set_Dynamic_Sliders_Values(Handles,Min_Value,Max_Value)
		set(Handles.Dynamic_Slider_Min,'Enable','on');
		set(Handles.Dynamic_Slider_Max,'Enable','on');
		if(Handles.Dynamic_Slider_Min.Min ~= Min_Value || Handles.Dynamic_Slider_Min.Max ~= Max_Value || ...
			Handles.Dynamic_Slider_Max.Min ~= Min_Value || Handles.Dynamic_Slider_Max.Max ~= Max_Value) % Update the slider only if the max or min have changed. Otherwise, keep the last chosen values.
			Handles.Dynamic_Slider_Min.Min = Min_Value; % Scale dynamic sliders.
			Handles.Dynamic_Slider_Min.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Max.Min = Min_Value;% ".
			Handles.Dynamic_Slider_Max.Max = Max_Value; % ".
			Handles.Dynamic_Slider_Min.Value = Min_Value;
			Handles.Dynamic_Slider_Max.Value = Max_Value;
			Handles.Dynamic_Slider_Text_Min.String = [num2str(Handles.Dynamic_Slider_Min.Value),char(181),'m']; % Update sliders text.
			Handles.Dynamic_Slider_Text_Max.String = [num2str(Handles.Dynamic_Slider_Max.Value),char(181),'m']; % ".
		end
	end
	
	function out = Fan(x,m,M)
		s = sum(x >= m & x<= M);
		if(s == 0)
			out = [];
		else
			out = s;
		end
	end
end