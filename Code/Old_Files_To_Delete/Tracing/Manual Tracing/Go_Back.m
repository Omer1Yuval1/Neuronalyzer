function [Path,Path_Queue,Step_Parameters] = Go_Back(Path,Path_Queue,RowN,Step_Parameters)
	
	% Description:
		% This function goes one step back in semi-automatic mode to allow the user to correct the trace of previous steps.
		% It is intiated using the "down-arrow" key and can only be used to go back within the current branch.
		% Calling functions: Auto_Manual.
	% Input:
		% Path: the tracing structure.
		% Path_Queue: a queue for rectangles\branches to be traced.
		% RowN: the row number in 'Path' of the current rectangle.
		% Step_Parameters: step-specific parameters.
	% Output:
		% Same as input exept RowN.
	
	% TODO: If in a trial - maybe go back to the beginning of the trial? OR just reset trial vars.
	% RowN is the row# of the last added rect.

	f1 = find([Path.Step_Index] == Step_Parameters.Step_Index-2 & [Path.Is_Mapped] ~= -1); % Find the rect to which the previous rect is connected.
	f2 = find([Path.Step_Index] == Step_Parameters.Step_Index-1 & [Path.Is_Mapped] ~= -1); % Find all the rects of the previous step.
	% f3 = find([Path.Step_Index] == Step_Parameters.Step_Index & [Path.Is_Mapped] ~= -1); % Find all the rects of the previous step.
	
	if(~isempty(f1))
		% TODO: Do not use 'for'.
		for k=1:size(f2,2) % For each rect of the previous (to-delete) step.
			% TODO: Set the point to 0 in 'Location_Mat'.
			Path(f2(k)).Is_Mapped = -1; % Mark as deleted in "Path".
			Path_Queue(find(abs(Path_Queue) == f2(k))) = []; % If the rectangle is in the queue, remove it.
		end
		
		Step_Parameters.Step_Index = Step_Parameters.Step_Index - 1;
		Path(f1(1)).Is_Mapped = 0;
		Path_Queue = [-f1(1) Path_Queue]; % Add the step before the previous step to the head of the queue.
		Step_Parameters.Stop_Flag = -1;
	end
end