function [Path,Path_Queue,Step_Parameters] = Delete_Branch(Path,Path_Queue,RowN,Step_Parameters)
	
	% Description:
		% This function deletes a branch during the tracing process.
		% Calling functions: Trace1.
	% Input:
		% Path: the tracing structure.
		% Path_Queue: a queue for rectangles\branches to be traced.
		% RowN: the row number in 'Path' of the current rectangle.
		% Step_Parameters: step-specific parameters.
	% Output:
		% Path: updated tracing structure.
		% Path_Queue: updated queue.
		% Step_Parameters: updated step-specific parameters.
	
	f1 = find([Path.Connection] == Path(RowN).Rectangle_Index);
	if(isempty(f1)) % If the current step was not added, no need to delete it.
		f1 = RowN;
		f0 = RowN;
	else
		f0 = f1(1); % The Current_Branch_Step_Index of this step cannot be 1.
	end
	
	while 1
		if(Path(f0).Current_Branch_Step_Index == 1) % For the 1st rect of the branch, delete only this rect (and not the entire step) and break.
			Path(f0).Is_Mapped = -1;
			Path_Queue(find(Path_Queue == f0)) = [];
			break;
		else
			for i=1:length(f1)
				Path(f1(i)).Is_Mapped = -1;
				Path_Queue(find(Path_Queue == f1(i))) = [];
			end
			f0 = find([Path.Rectangle_Index] == Path(f1(1)).Connection);
			f1 = find([Path.Step_Index] == Path(f0).Step_Index);
		end
	end
	
end