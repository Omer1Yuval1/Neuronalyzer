function Step_Parameters = Step1(Workspace1,Step_Parameters,Locations_Mat)
	
	% Description:
		% This function performs the tracing of a single step.
		% It does that by generating a seires of convolving rectangles, rotating around a mutual rotation origin.
		% It then calculates the mean pixel value within each oriented rectangle, normalizes the these values and performs peak analysis 
		% to detect the routes in which the neuron continues.
		% Next, it detects the local apparent width of the neuron and sets the width and length of the rectangle accordingly.
		% Finaly, it delets unwanted routes as a result of image boundaties, relative orientation (to the previous step)or
		% overlap with previously traced pixels.
		% Calling functions: Trace1.
	% Input:
		% Workspace1 and Step_Parameters: General and step-specific parameters (respectively).
		% Locations_Mat: a hash table that records previously traced pixels.
	% Output:
		% Step_Parameters: updated step-specific parameters.
		
	Step_Parameters.Step_Routes = Rect_Scan(Workspace1.Image0,Step_Parameters,Workspace1.Parameters);
	[Step_Parameters.Step_Routes,Step_Parameters.Step_Normalization] = Normalize_Rects_Values(Workspace1.Image0,Step_Parameters,Workspace1.Parameters);
	Step_Parameters.Step_Routes = Choose_Paths(Step_Parameters,Workspace1.Parameters);
	
	if(~isempty(Step_Parameters.Step_Routes))
		% Adjust width and update Rect_Length & Step_Length (only if NOT in a trial):
		if(Step_Parameters.Trial_Step_Index == 0 && Step_Parameters.Branch_Step_Index > 1) % If not in a trial and not the 1st rect of a branch.
			
			Step_Parameters.Rect_Width = [Step_Parameters.Rect_Width(2:end),Adjust_Rect_Width_Rot(Workspace1,Step_Parameters)]; % Delete the head of the queue, move all values one step up and add the new value to the tail.
			Step_Parameters.Rect_Width(end) = mean([Step_Parameters.Rect_Width(find(Step_Parameters.Rect_Width > 0))]); % Replace the new value (in the tail) with the average of all the non-zero values (including the new one). 			
			
			Step_Parameters.Rect_Length = Step_Parameters.Rect_Width(end)*Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Length_Width_Ratio;
			Step_Parameters.Step_Length = Step_Parameters.Rect_Length/Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Step_Length_Ratio;
		end
		% Delete unwanted routes (rectangles in a specific step):
		if(Step_Parameters.Branch_Step_Index < ceil(Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Step_Length_Ratio)) % If one of the 1st steps of a branch.
			
			F1 = find(Step_Parameters.Step_Routes(:,3) > Workspace1.Parameters.Auto_Tracing_Parameters.Max_Angle_Diff); % Find routes with orientation close to the opposite orientation of the main route in the previous step.
			if(length(F1) > 0)
				Step_Parameters.Step_Routes(F1,:) = []; % Delete peaks that are too close to 180 degrees relative to the previous step.
				if(Workspace1.Parameters.General_Parameters.Message)
					display('A route was deleted because of a relative angle limit at the begining of the branch');
				end
			end
		else % If not one the first steps of a branch (TODO: currently the same condition - Max_Angle_Diff).
			Arr_Delete = find(Step_Parameters.Step_Routes(:,3) > Workspace1.Parameters.Auto_Tracing_Parameters.Max_Angle_Diff);
			Step_Parameters.Step_Routes(Arr_Delete,:) = [];% Delete peaks that are too close to 180 degrees relative to the previous step.
			if(Workspace1.Parameters.General_Parameters.Message && length(Arr_Delete))
				display('A route was deleted because its angle was too close to the previous step route');
			end
		end
		
		if(size(Step_Parameters.Step_Routes,1) > 3) % If one of the 1st steps of a branch + more than 3 routes.
			Step_Parameters.Step_Routes(2:end,:) = []; % Delete 2ndary rountes.
			if(Workspace1.Parameters.General_Parameters.Message)
				display('Too Many Routes. All 2+ Routes Were Deleted.');
			end
		end
	end
	if(~isempty(Step_Parameters.Step_Routes)) % If Step_Routes contains at least one route.
		% Check if the current point is close to the image boundaries.
		if(Step_Parameters.Step_Coordinates(1) < 4*Step_Parameters.Rect_Length || ...
			Step_Parameters.Step_Coordinates(1) > Workspace1.Parameters.General_Parameters.Im_Cols-4*Step_Parameters.Rect_Length || ... 
			Step_Parameters.Step_Coordinates(2) < 4*Step_Parameters.Rect_Length || ...
			Step_Parameters.Step_Coordinates(2) > Workspace1.Parameters.General_Parameters.Im_Rows-4*Step_Parameters.Rect_Length)
			Step_Parameters.Stop_Flag = 1;
			if(Workspace1.Parameters.General_Parameters.Message)
				display('Branch mapping stopped because of image boundaries condition.');
			end
		end
	else % If Step_Routes contains no routes.
		Step_Parameters.Stop_Flag = -1;
		if(Workspace1.Parameters.General_Parameters.Message)
			display('Tip - End of Branch.');
		end
	end
	
	% Check if any of the rectangles is covering a previously visited pixel (exclude the previous step):
	Arr_Delete = zeros(1,size(Step_Parameters.Step_Routes,1));
	
	for r=1:size(Step_Parameters.Step_Routes,1) % For each route.
		[XVr,YVr] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,Step_Parameters.Step_Routes(r,1),Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,14); % Get the rectangle vector of coordinates.
		Coordinates1 = InRect_Coordinates(Workspace1.Image0,[XVr',YVr']); % Get the pixels linear coordinates covered by this rectangle.
		
		Values1 = abs([Locations_Mat(Coordinates1)]); % Take the absolute value of all values of these coordinates in "Locations_Mat".
		Values1(find(Values1 == 0)) = []; % Delete 0 values.
		
		% Find pixels in this route that overlap with any of the last N steps:
		F1 = find(Values1 < Step_Parameters.Step_Index - 2 & ... % Not the 1st previous step (only 2+).
				Values1 > Step_Parameters.Step_Index - ... % One of the last steps (except the last one ^).
				(Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Step_Length_Ratio + 1));
		
		if(length(F1) > 0) % If the rectangle overlaps with one of the last steps,
			if(r == 1) % If it's the 1st route.
				Arr_Delete = Arr_Delete + 1; % Delete all routes.
				Step_Parameters.Stop_Flag = -1; % Terminate the tracing of this segment (do not add it).
				% In the Automatic mode, this is not considered as a loop.
				% display('Last Steps Deletion 1');
				if(Workspace1.Parameters.General_Parameters.Message)
					display('Main rectangle overlaps with one the last steps. Branch tracing terminated (all routes were deleted).');
				end
				break;
			else % 2+ routes.
				Arr_Delete(r) = 1; % Delete this specific route (both for manual and auto modes).
				if(Workspace1.Parameters.General_Parameters.Message)
				end
			end
		end
		% TODO: use a variable.
		if(Step_Parameters.Branch_Step_Index > 2 && Workspace1.User_Input.Features.Tracing_Method(1) == 'A') % If 'Automatic' mode. In manual mode, I let the user decide about these kind of loops.
			F2 = find(Values1 <= Step_Parameters.Step_Index - ... % Non-zero values AND Values in Locations_Mat smaller
					(Workspace1.Parameters.Auto_Tracing_Parameters.Rect_Step_Length_Ratio + 1)); % than the -N step index.
					
			if(length(F2) > 0) % If the rectangle overlaps with a far previous step,
				if(r == 1) % If it's the main route.
					Step_Parameters.Stop_Flag = -2; % Turn ON the loop flag.
					Step_Parameters.Looped_To_Step = max(Values1); % Choose the looped step index.
					Arr_Delete(2:end) = 1; % But delete all 2+ routes.
					% Arr_Delete(1) = 0; % ". I'm doing this separately just in case Arr_Delete has only one value.
				else % If it's a 2+ route (r > 1).
					Arr_Delete(r) = 1;
				end
			end
		end
	end
	Step_Parameters.Step_Routes(find(Arr_Delete == 1),:) = [];
	
end