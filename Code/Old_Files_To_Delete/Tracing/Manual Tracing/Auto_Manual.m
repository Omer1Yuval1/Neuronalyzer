function [Path,Path_Queue,Step_Parameters,Auto_Mode,Auto_In_Manual,Go_Back_Flag,flag1] = Auto_Manual(Path,Parameters1,Path_Queue,RowN,Step_Parameters,Auto_Mode,Auto_In_Manual)
	
	% Description:
		% This is function a general function that allows manual editing of various aspects in each step.
		% Calling functions: Trace1.
	% Input:
		% Path: the tracing structure.
		% Path_Queue: a queue for rectangles\branches to be traced.
		% RowN: the row number in 'Path' of the current rectangle.
		% Parameters1 and Step_Parameters: General and step-specific parameters (respectively).
		% Auto_Mode: a parameter used to indicate if the tracing is performed manually (0) or automatically (1).
		% Auto_In_Manual: a flag used to indicate that the user asked to perform N tracing steps automatically (in manual mode).
	% Output:
		% Same as input exept:
		% Go_Back_Flag: a flag used to indicate that the user asked to go one step backwards.
		% flag1: a flag used to indicate that the user asked to terminate the tracing.
	
	Go_Back_Flag = 0;
	flag1 = 0;
	
	if(Auto_Mode == 0) % Manual mode.
		figure(1);
		hold on;
		[Step_Parameters,c1] = User_Edit(Step_Parameters,Parameters1.Auto_Tracing_Parameters(1).Rect_Rotation_Origin);
		hold off;
		switch c1
			case 31 % Go one step backwards.
				% TODO: Do not pass the entire 'Path' struct (also to the function 'Auto_Manual'.
				if(Step_Parameters.Branch_Step_Index >= 2)
					[Path,Path_Queue,Step_Parameters] = Go_Back(Path,Path_Queue,RowN,Step_Parameters);
					Step_Parameters.Trial_Step_Index = 0; % Reset trial.
					Go_Back_Flag = 1;
				end
			% case 42 % '*'. Jump n step forward (automatically).
				% Auto_In_Manual = 1; % Set temporal auto mode ON.
				% Auto_Mode = 1;
			case 27 % Escape key. End program.
				flag1 = 1;
				Step_Parameters.Stop_Flag = -1;
			case {96,59} % ~ key. End branch.
				Step_Parameters.Trial_Step_Index = 0; % Reset trial.
				Step_Parameters.Stop_Flag = -1;
				if(Parameters1.General_Parameters.Message)
					display('Terminate current branch mapping.');
				end
			case {108,76} % Loop. The letter 'L' (capital and regular).
				Step_Parameters.Stop_Flag = -2;
			% case 48 % Zero. Use the angle of the previous step and delete all 2+ rects.
			otherwise
				% if(Step_Parameters.Stop_Flag == -1 || Step_Parameters.Looped_To_Step) % If the routes array was empty (in manual mode) - tip,
				if(Step_Parameters.Stop_Flag == -1) % If the routes array was empty (in manual mode) - tip,
					Step_Parameters.Stop_Flag = 0; % do not terminate automatically (so that the user can continue the tracing of the same branch.
				end
		end
	end

end