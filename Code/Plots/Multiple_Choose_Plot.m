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
	
	switch GUI_Parameters.General.Active_Plot
		case 'Mean Segment Length'
			Var_Operations{1} = @(x) x(x>=0); % The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Length'};
			Filter_Fields = [];
			% 
			Y_Label = 'Length (\mum)';
			Title = 'Mean Length of Segments';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Total Length'
			Var_Operations{1} = @(x) sum(x(x>=0)); % Sum up all segments lengths of each individual animal (=workspace). The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'Length'};
			Filter_Fields = [];
			%
			Y_Label = 'Length (\mum)';
			Title = 'Total Length';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'End2End Length Of Segments'
			Var_Operations{1} = @(x) x(x>=0); % The length of a segment has to be positive.
			Filter_Operations = [];
			Var_Fields = {'End2End_Length'};
			Filter_Fields = [];
			%
			Y_Label = 'Length (\mum)';
			Title = 'End2End Length Of Segments';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Mean Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Curvature'};
			Filter_Fields = {};
			%
			Y_Label = 'Mean Squared Curvature (1/(\mum)^2)';
			Title = 'Curvature Of Segments';
			RowWise = 0;
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Means_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,Y_Label,Title);
			
		case 'Distribution of Curvature Of Segments'
			Var_Operations{1} = @(x) x(x>=0 & x<=0.1); % The curvature of a segment has to be positive.
			Filter_Operations = {};
			Var_Fields = {'Curvature'};
			Filter_Fields = {};
			%
			X_Label = 'Squared Curvature (1/(\mum)^2)';
			Y_Label = 'Count';
			Title = 'Curvature Of Segments';
			%
			RowWise = 0;
			%
			X_Min_Max = [0,0.1];
			BinSize = 0.005 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Segments',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
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
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distances Of 3-Way Junctions From The Medial Axis - Histogram'
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = @(x) (x == 3); % Choose third order vertices only (= 3-way junctions).
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of 3-Way Junctions From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
			Histogram_Plot(Input_Struct,GUI_Parameters,GUI_Parameters.Visuals,X_Min_Max,BinSize,X_Label,Y_Label,Title);
			
		case 'Distances Of Tips From The Medial Axis - Histogram'
			Var_Operations{1} = @(x) x(x>=0); % Only non-negative distance values.
			Filter_Operations{1} = @(x) (x == 1); % Choose first order vertices only (= tips).
			Var_Fields = {'Distance_From_Medial_Axis'};
			Filter_Fields = {'Order'};
			%
			RowWise = 1;
			%%%
			X_Label = 'Distance (\mum)';
			Y_Label = 'Count';
			Title = 'Distribution of Distances of Tips From the Medial Axis';
			X_Min_Max = [0,50];
			BinSize = 10 .* GUI_Parameters.Handles.Analysis.Slider.Value;
			%%%
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
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
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
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
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
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
			Input_Struct = Generate_Plot_Input(GUI_Parameters,'Vertices',Var_Fields,Filter_Fields,Var_Operations,Filter_Operations,RowWise);
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

	end
	assignin('base','Input_Struct',Input_Struct);
end