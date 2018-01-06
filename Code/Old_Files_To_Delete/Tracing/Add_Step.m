function [Path,Path_Queue,RowN,Step_Parameters] = Add_Step(Path,Path_Queue,RowN,Step_Parameters,Parameters1,User_Input)
	
	% Description:
		% This function add the information of each rectangle in a single tracing step to the database.
	% Input:
		% Path: the tracing database.
		% Path_Queue: a queue for rectnalges to be traced.
		% RowN: the row number in 'Path' of the previous step.
		% Step_Parameters, Parameters1, User_Input: parameters structures.
	% Output:
		% Same as input exept the parameters structures: Parameters1 and User_Input.
	
	Scale_Factor = User_Input.Scale_Factor;
	
	Si = numel(Path); % TODO: Use a variable.
	% TODO: Get rid of the following "if":
	if(size(Step_Parameters.Step_Routes,1) > 0) % else (no results in manual mode) - do nothing.
		for i=1:size(Step_Parameters.Step_Routes,1)
			
			Path(Si+i).Rectangle_Index = Si+i;
			Path(Si+i).Step_Index = Step_Parameters.Step_Index;
			Path(Si+i).Connection = Path(RowN).Rectangle_Index;
			Path(Si+i).Looped_To_Step = Step_Parameters.Looped_To_Step;
			Path(Si+i).Coordinates = Step_Parameters.Step_Coordinates;			
			Path(Si+i).Angle = mod(Step_Parameters.Step_Routes(i,1),360);
			Path(Si+i).Width = Step_Parameters.Rect_Width(end)*Scale_Factor;
			Path(Si+i).Score = Step_Parameters.Step_Routes(i,2);
			Path(Si+i).Rect_Length = Step_Parameters.Step_Length*Scale_Factor; % This is the length of the step rectangle and not the probing\convolution rectangle.
			% % Path(Si+i).Number_Of_Pixels = Pix_num; % TODO: Fix.
			
			if(i == 1) % Primary branch.
				RowN_Temp = Si+i;
				Path(Si+i).Current_Branch_Step_Index = Step_Parameters.Branch_Step_Index;
				Path(Si+i).Is_Mapped = 1;
				Step_Parameters.ConnectedTo_Index = Path(Si+i).Rectangle_Index; % This is used for the next step.				
			else % A 2ndary branch.
				Path(Si+i).Current_Branch_Step_Index = 1; % The 2ndary rect of a junction is the 1st rect of a new branch.
				Path(Si+i).Is_Mapped = 0;
				Path_Queue(end+1) = -(Si+i); % Save the row number (in Path) of unmapped branches. Use negative values to differentiate the outsets of the current branch.
			end
			
		end
		
		% if(Step_Parameters.Trial_Step_Index == 0 || Step_Parameters.Trial_Step_Index > Step_Parameters.Max_Score_Step_Num)
			Step_Parameters.Previous_Angle = Step_Parameters.Step_Routes(1,1);
		% end
		
		RowN = RowN_Temp;
		Step_Parameters.Step_Index = Step_Parameters.Step_Index + 1;
		Step_Parameters.Branch_Step_Index = Step_Parameters.Branch_Step_Index + 1; % Incrementing the branch index for the next step.
		Step_Parameters.Step_Coordinates = [Step_Parameters.Step_Coordinates(1)+Step_Parameters.Step_Length*cosd(Step_Parameters.Previous_Angle),Step_Parameters.Step_Coordinates(2)+Step_Parameters.Step_Length*sind(Step_Parameters.Previous_Angle)]; % New Origin. Translation of the previous point one step (Step_Length) forward (without rotation).
	end
	Step_Parameters.Looped_To_Step = 0;
	
end