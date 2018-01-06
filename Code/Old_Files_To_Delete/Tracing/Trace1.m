function Workspace1 = Trace1(Workspace1)
	
	% Description:
		% This function is the main neuron tracing function.
		% It uses the cell-body as a start-point and "walks" along the neuronal branches in discrete steps using convolving rectangles.
		% It can be run in automatic or semi-automatic mode.
		% In the semi-automatic mode, the user can edit the result of the automatic signal detection in each step.
		% Calling functions: Tracer_UI.
	% Input:
		% A structure containing the information of the steps used as start-points (the outsets of the branches connected to the cell-body.
		% Each row in the structure ("Workspace1") represents a single rectangle.
		% Fields:
			% Rectangle_Index: a unique index of the rectangle.
			% Step_Index: an index of a tracing step. A step can contain more than one rectangle.
			% Coordinates: the coordinates of the rotation origin of the convolving rectangles.
			% Angle: the orientation of the rectanlge in catesian axes in degrees ([0,360]).
			% Is_Mapped: a flag used to indicate if the rectangle was already used to trace a branch.
			% Connection: each step (except the start-point steps) is connected to its previous.
				% This field conatins a step index that corresponds to the previous step.
			% Current_Branch_Step_Index: A branch is a set of connected steps (each step is connected to its previous and
				% the first step is connected to the last step of the previous branch.
				% This field contains an integer indicating the step number in the branch.
			% Score: the mean pixel value\intensity inside the rectangle.
			% Looped_To_Step: a loop  occurs if a step overlaps with a previously traced step (excluding the last N steps).
				% This field contains a step index indicating the step the rectangle if looped with, or zero in case it does not form a loop.
			% Width: the width of the rectangle. This width corresponds to the local apparent width of the neuron.
			% Rect_Length: the length of the rectangle. The length is a function of the width (~2 times the width).
	% Output:
		% A structure containing the information about the traced steps (in the same format described in the input section).
	
	% User Inputs:
		if(strcmp(Workspace1.User_Input.Features.Tracing_Method,'Manual Tracing'))
			Tracing_Method = 1;
			Auto_Mode = 0;
		elseif(strcmp(Workspace1.User_Input.Features.Tracing_Method,'Automatic Tracing'))
			Tracing_Method = 2;
			Auto_Mode = 1;
			
			% Progress_Bitmap = zeros(Workspace1.Parameters.General_Parameters.Im_Rows,Workspace1.Parameters.General_Parameters.Im_Cols);
			% hold on;
			% imshow(Progress_Bitmap);
			imshow(Workspace1.Image0);
			set(gca,'YDir','normal');
			% hold on;
			h = animatedline('LineStyle','none','Marker','.','MarkerEdgeColor','r','MarkerSize',10);
			hold on;
			Last_Point = plot(-1,-1,'.g','MarkerSize',30);
		end
		
		Scale_Factor = Workspace1.User_Input.Scale_Factor;
		% TODO: cd(strcat(cd,'\Temp')); % Create a 'Temp' folder for temporary tracing backup files.
		
	% Parameters:
		Min_Branch_Steps = Workspace1.Parameters.Auto_Tracing_Parameters.Min_Branch_Steps;
		Rect_Length_Width_Ratio = Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Length_Width_Ratio;
		Rect_Step_Length_Ratio = Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Step_Length_Ratio;
		
		Zoom_Box = Workspace1.Parameters.Auto_Tracing_Parameters.Zoom_Box;
		Zoom_Length = Workspace1.Parameters.Manual_Tracing_Parameters.Zoom_Length;
		Save_Steps_Num = Workspace1.Parameters.Manual_Tracing_Parameters.Save_Steps_Num;
		
		Plot_On_Off = Workspace1.Parameters(1).Auto_Tracing_Parameters(1).Plot_On_Off;
		Plot_Trace = Workspace1.Parameters(1).Auto_Tracing_Parameters(1).Plot_Trace;
		Message = Workspace1.Parameters(1).General_Parameters(1).Message;
		Semi_Mode_Auto_Steps_Num = Workspace1.Parameters(1).Auto_Tracing_Parameters(1).Semi_Mode_Auto_Steps_Num;
		
		Im_Rows = Workspace1.Parameters.General_Parameters.Im_Rows;
		Im_Cols = Workspace1.Parameters.General_Parameters.Im_Cols;
		
		OverLap_Num_Of_Steps = Workspace1.Parameters.Auto_Tracing_Parameters.OverLap_Num_Of_Steps;
		Locations_Mat = zeros(Im_Rows,Im_Cols);
		Locations_Plot = struct('Handle',{});
		
		for p=1:numel(Workspace1.Path)
			if(Workspace1.Path(p).Is_Mapped > 0)
				Locations_Mat(round(Workspace1.Path(p).Coordinates(2)),round(Workspace1.Path(p).Coordinates(1))) = -Workspace1.Path(p).Step_Index;
				if(Workspace1.Path(p).Looped_To_Step > 0)
					plot(Workspace1.Path(p).Coordinates(1),Workspace1.Path(p).Coordinates(2),'.y','MarkerSize',20);
				end
			end
		end
		
		% Current_Location_Handle = plot(1,1,'.k');
	% ***********************************************************************
	
	Step_Parameters = struct('Step_Index',{},'Branch_Step_Index',{},'ConnectedTo_Index',{},'Rect_Width',{},'Rect_Length',{}, ... 
							'Step_Length',{},'Previous_Angle',{},'Step_Coordinates',{},'Step_Routes',{}, ...
							'Trial_Step_Index',{},'Stop_Flag',{},'Step_Normalization',{},'Looped_To_Step',{});
	Step_Parameters(1).Rect_Width = zeros(1,Workspace1.Parameters(1).Auto_Tracing_Parameters(1).Rect_Width_Num_Of_Last_Steps); % Reset the width array.
	Step_Normalization = struct('Noise_Size',0,'Noise_Width',0);
	Step_Parameters.Step_Normalization.Noise_Size = 0;
	Step_Parameters.Step_Normalization.Noise_Width = 1;
	
	% Calculate the CB center and perimeter:
		CB_Coordinates = reshape([Workspace1.Path(find([Workspace1.Path.Connection] == 0)).Coordinates],[],2);
		Workspace1.Parameters(1).Cell_Body(1).Center = [mean(CB_Coordinates(:,1)),mean(CB_Coordinates(:,2))];
		Workspace1.Parameters(1).Cell_Body(1).Perimeter = CB_Coordinates;
	%
	Path_Queue = find([Workspace1.Path.Is_Mapped] == 0);
	
	% Flags, Counters & Indexes:
		flag1 = 0; % Terminate entire program.
		Step_Parameters(1).Trial_Step_Index = 0; % 0 = Not in trial. +N = In trial and at the vertex center. -N = In trial but not at the vertex center.	
		Step_Parameters.Step_Index = max([Workspace1.Path.Step_Index])+1;
		Auto_In_Manual = 0; % Auto mode inside the manual mode. A Flag. Do not change.
	% *************************************************************************************
	
	while ~isempty(Path_Queue) % Map the Path of each unmapped rectangle.
		Step_Parameters.Stop_Flag = 0;
		Step_Parameters.Looped_To_Step = 0;
		Go_Back_Flag = 0;
		Step_Parameters.Max_Score_Step_Num = 0;
		RowN = Path_Queue(1); % Row number in 'Path'.
		Path_Queue(1) = []; % Delete this rect from the queue.
		Step_Parameters.Previous_Angle = Workspace1.Path(RowN).Angle;
		Step_Parameters.Branch_Step_Index = Workspace1.Path(RowN).Current_Branch_Step_Index + 1; % TODO: Isn't this always 2 ? ; TODO: Change field name in 'Workspace1.Path'.
		Step_Parameters.ConnectedTo_Index = Workspace1.Path(RowN).Rectangle_Index;
		
		Step_Parameters.Rect_Width = 0 * Step_Parameters.Rect_Width; % A vector of zeros (zeros are not taken into consideration in the smoothing of the width value.
		Step_Parameters.Rect_Width(end) = Workspace1.Path(RowN).Width/Scale_Factor;
		
		Step_Parameters.Rect_Length = Step_Parameters.Rect_Width(end)*Rect_Length_Width_Ratio;
		Step_Parameters.Step_Length = Step_Parameters.Rect_Length/Rect_Step_Length_Ratio;
		Step_Parameters.Step_Coordinates = Workspace1.Path(RowN).Coordinates;
		Step_Parameters.Step_Coordinates = [Step_Parameters.Step_Coordinates(1)+Step_Parameters.Step_Length*cosd(Step_Parameters.Previous_Angle) Step_Parameters.Step_Coordinates(2)+Step_Parameters.Step_Length*sind(Step_Parameters.Previous_Angle)]; % New Origin. Translation of the previous point one step (Step_Length) forward (without rotation).
		Workspace1.Path(RowN).Is_Mapped = 1;
		Step_Parameters.Trial_Step_Index = 0;
		if(Workspace1.Path(RowN).Connection == 0)
			Locations_Mat(1,1) = -2; % Used to avoid cell body pixels. TODO: Use a parameter.
		else
			Locations_Mat(1,1) = 0;
		end
		while 1 % Trace a branch.
			
			% Dynamic focus:
			if(Tracing_Method == 1 && (mod(Step_Parameters.Branch_Step_Index,Zoom_Length) == 0 || Step_Parameters.Branch_Step_Index == 2))
				
				figure(1);
				hold on;
				axis([Step_Parameters.Step_Coordinates(1)-2*Zoom_Box Step_Parameters.Step_Coordinates(1)+2*Zoom_Box Step_Parameters.Step_Coordinates(2)-2*Zoom_Box Step_Parameters.Step_Coordinates(2)+2*Zoom_Box]);
				
				delete([Locations_Plot(:).Handle]); % Delete all plots.
				Locations_Plot = struct('Handle',{}); % Reset the 'Locations_Plot' struct.
				
				XmM = [max(Step_Parameters.Step_Coordinates(1)-Zoom_Box/2,1) min(Step_Parameters.Step_Coordinates(1)+Zoom_Box/2,Im_Cols)];
				YmM = [max(Step_Parameters.Step_Coordinates(2)-Zoom_Box/2,1) min(Step_Parameters.Step_Coordinates(2)+Zoom_Box/2,Im_Rows)];
				
				% TODO: Do not use 'for' or predetermine the size of Locations_Plot.
				for i=round(XmM(1)):round(XmM(2))
					for j=round(YmM(1)):round(YmM(2))
						if(Locations_Mat(j,i) < 0)
							Locations_Plot(end+1).Handle = plot(i,j,'.m','MarkerSize',20);
						end
					end
				end
				hold off;
				drawnow;
			elseif(Tracing_Method == 2 && Plot_Trace && mod(Step_Parameters.Step_Index,2) == 0)
				Last_Point.XData = Step_Parameters.Step_Coordinates(1);
				Last_Point.YData = Step_Parameters.Step_Coordinates(2);
				addpoints(h,Step_Parameters.Step_Coordinates(1),Step_Parameters.Step_Coordinates(2));
				drawnow;
			end
			
			if(Tracing_Method == 1 && mod(Step_Parameters.Step_Index,Save_Steps_Num) == 0) % Create a backup .mat file/
				Version_Num = Workspace1.Parameters.General_Parameters.Version_Num;
				New_File_Name = strcat('MyTrace_Backup-V',Version_Num,'-',datestr(datetime,30),'.mat');
				uisave('Workspace1',New_File_Name);
			end
			
			if(Step_Parameters.Trial_Step_Index == 0) % If the trial is set OFF.
				Step_Parameters = Step1(Workspace1,Step_Parameters,Locations_Mat);
			end
			
			% % if(size(Step_Parameters.Step_Routes,1) > 1 || (Step_Parameters.Trial_Step_Index > 0 && Step_Parameters.Trial_Step_Index <= Step_Parameters.Max_Score_Step_Num)) % Start or continue a trial. % TODO: add another condition to start a trial: | peak width > w.
			if(size(Step_Parameters.Step_Routes,1) > 1 || Step_Parameters.Trial_Step_Index > 0) % Start or continue a trial. % TODO: add another condition to start a trial: | peak width > w.
				if(Step_Parameters.Trial_Step_Index == 0) % If it's the 1st step of Peaks_Scores.
					[Peaks_Scores,Stop1,Step_Parameters.Max_Score_Step_Num] = Probe_Vertex_Area(Workspace1,Step_Parameters,Locations_Mat);
				end
				
				Step_Parameters.Trial_Step_Index = Step_Parameters.Trial_Step_Index + 1;
				Step_Parameters.Step_Routes = Peaks_Scores(Step_Parameters.Trial_Step_Index).Paths;
				
				if(Step_Parameters.Trial_Step_Index == numel(Peaks_Scores))
				% if(Step_Parameters.Trial_Step_Index == Step_Parameters.Max_Score_Step_Num)
					Step_Parameters.Trial_Step_Index = 0; % Turn off vertex-probing flag. This var is set to 0 while the last step of the trial is still running.
					Step_Parameters.Stop_Flag = Stop1;
					Step_Parameters.Max_Score_Step_Num = 0;
				end
			end
			
			if(~Auto_Mode)
				if(size(Step_Parameters.Step_Routes,1) == 0)
					if(exist('Current_Location_Handle'))
						delete(Current_Location_Handle);
					end
					hold on;
					Current_Location_Handle = plot(Step_Parameters.Step_Coordinates(1),Step_Parameters.Step_Coordinates(2),'.g','MarkerSize',25); % ,'MarkerEdgeColor','r'
				end
				[Workspace1.Path,Path_Queue,Step_Parameters,Auto_Mode,Auto_In_Manual,Go_Back_Flag,flag1] = ...
						Auto_Manual(Workspace1.Path,Workspace1.Parameters,Path_Queue,RowN,Step_Parameters,Auto_Mode,Auto_In_Manual);		
			elseif(Auto_In_Manual > 0)
				if(Auto_In_Manual == Semi_Mode_Auto_Steps_Num)
					Auto_Mode = 0;
					Auto_In_Manual = 0;
				else
					Auto_In_Manual = Auto_In_Manual + 1;
				end
			end
			
			if(Step_Parameters.Stop_Flag == -1 || size(Step_Parameters.Step_Routes,1) == 0) % If Step_Routes is empty, stop before adding the step.
				break;
			end
			
			if(Step_Parameters.Stop_Flag == -2) % Loop flag.
				if(Auto_Mode)
					Step_Parameters.Stop_Flag = 2; % Add the step and stop (if the segment is too short, it will be deleted).
				else % Manual Mode. Don't stop (let the user decide) and plot a dot at the loop point.
					Looped_To_Step = Locations_Func(Locations_Mat,Step_Parameters,Workspace1.Parameters);
					Step_Parameters.Stop_Flag = 0; % Allow the user to continue the branch after a loop point.
					hold on;
					plot(Step_Parameters.Step_Coordinates(1),Step_Parameters.Step_Coordinates(2),'.y','MarkerSize',20);						
				end
			end % figure(2); clf(2); imshow(Locations_Mat); set(gca,'YDir','normal');
			
			[Workspace1.Path,Path_Queue,RowN,Step_Parameters] = Add_Step(Workspace1.Path,Path_Queue,RowN,Step_Parameters,Workspace1.Parameters,Workspace1.User_Input);
			
			% Add the current step (only main route) pixels to Locations_Mat:
			[XVs,YVs] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Step_Routes(1,1),2*Step_Parameters.Rect_Width(end),Step_Parameters.Step_Length,14); % TODO: use only 4 coordinates + Use a parameter (+2):
			Coordinates1 = InRect_Coordinates(Workspace1.Image0,[XVs',YVs']);
			Coordinates1(find([Locations_Mat(Coordinates1)] ~= 0)) = []; % Do not change the value of previously visited pixels.
			Locations_Mat(Coordinates1) = Step_Parameters.Step_Index;
			Locations_Mat(round(Step_Parameters.Step_Coordinates(2)),round(Step_Parameters.Step_Coordinates(1))) = -Step_Parameters.Step_Index; % Used to plot the trace during the tracing (using only one point for each step).
			% assignin('base','Locations_Mat',Locations_Mat);
			
			if(Step_Parameters.Stop_Flag > 0) % Stop after adding the step (Image_Boundaries OR X-Was_I_Here-X conditions).
				break;
			end
		end % End of the branch tracing loop.
		
		if(Tracing_Method == 2) % Automatic tracing mode.
			if(Workspace1.Path(RowN).Current_Branch_Step_Index <= Min_Branch_Steps) % If it's a very short branch.
				Fq = find(Path_Queue < 0); % Find all negative values in the queue (outsets of the current branch).
				% for q=Fq % Delete them from 'Path'.
				%	Workspace1.Path(abs(Path_Queue(q))).Is_Mapped = -1; % Delete all the outsets of new branches connected to that branch.
				% end
				Path_Queue(Fq) = []; % And, delete them also from the queue.
				[Workspace1.Path,Path_Queue,Step_Parameters] = Delete_Branch(Workspace1.Path,Path_Queue,RowN,Step_Parameters);
			else
				Path_Queue = abs(Path_Queue); % Convert all queue values to positive.
			end
		elseif(Tracing_Method == 1) % Semi-automatic mode.
			if(Workspace1.Path(RowN).Current_Branch_Step_Index == 1 && ~Go_Back_Flag)
				Workspace1.Path(RowN).Is_Mapped = -1;
				% [Workspace1.Path,Path_Queue,Step_Parameters] = Delete_Branch(Workspace1.Path,Path_Queue,RowN,Step_Parameters);
				if(Message) display('Current branch was deleted because it was too short'); end
			else
				Path_Queue = abs(Path_Queue); % Convert all queue values to positive.
			end
		end
		
		if(flag1) % User pressed escape-key in semi-automatic mode.
			break;
		end
	end
	
end