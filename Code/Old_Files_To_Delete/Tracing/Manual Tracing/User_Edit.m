function [Step_Parameters,c1] = User_Edit(Step_Parameters,Rect_Rotation_Origin)
	
	arr = Step_Parameters.Step_Routes;
	
	handles_arr = [];
	ARR = [];
	list1 = [];
	origin1 = [];
	Colors_Arr = [0,1,0 ; 1,1,0 ; 0,1,1];
	LineWidth1 = 2;
	N = size(arr,1);
	
	if(N > 0)
		for i=1:N % Plot initial paths and define handles.
			[XV0,YV0] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,arr(i,1),Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,Rect_Rotation_Origin);
			handles_arr(i) = plot(XV0,YV0,'Color',Colors_Arr(i,:),'LineWidth',LineWidth1);
			% set(handles_arr(i),'visible','off');
			% annotation('textarrow', [XV0(1)/rows1 YV0(1)/cols1],[0.5,0.5],'String', 'Straight Line Plot 1 to 10');
			list1(i) = 1;
		end
	end
	
    H = figure(1);
	while 1
		set(H,'KeyPressFcn',' ');
		waitforbuttonpress;
		c1 = double(get(H,'CurrentCharacter'));
		if(~isscalar(c1))
			continue;
		end
		
		if((c1 == 30 || c1 == 56) && size(arr,1) == 0) % Up arrow + No routes.
			continue;
		end
		
		switch c1
			case {27,30,31,96,59,108,76,56} % Escape, UP arrow, DOWN arrow, ~, {l,L}, 8. % Not in use: 42 = '*'.
				break;
			case 48 % Zero (0). Use the angle of the previous step and delete all 2+ rects.
				if(size(arr,1) > 0)
					arr = arr(1,:);
					arr(1,1) = Step_Parameters.Previous_Angle;
					% list1 = [1,zeros(1,length(list1)-1)];
					list1 = 1;
					
					[XV0,YV0] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,arr(1,1),Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,Rect_Rotation_Origin);
					% assignin('base','handles_arr',handles_arr);
					delete(handles_arr);
					handles_arr = [];
					handles_arr(1) = plot(XV0,YV0,'Color',Colors_Arr(1,:),'LineWidth',LineWidth1);
				end
			case {49,50,51,52} % 1,2,3,4 (path selection).
				j = c1-48;
				if(size(handles_arr,2) < j | list1(j) == 0)
					display('Reference to a non-existing (not created or deleted route. Please press a lower number or continue.');
					continue;
				end
				set(handles_arr(j),'color','red');
				a1 = arr(j,1);
				while 1
					set(H,'KeyPressFcn',' ');
					waitforbuttonpress;
					c2 = double(get(H,'CurrentCharacter'));
					if(~isscalar(c2))
						continue;
					end
					origin1 = [Step_Parameters.Step_Coordinates 0];
					switch c2
						case 28 % Right arrow.
							rotate(handles_arr(j),[0,0,1],5,origin1);
							a1 = a1 + 5;
						case 29 % Left arrow.
							rotate(handles_arr(j),[0,0,1],-5,origin1);
							a1 = a1 - 5;
						case 127 % Delete button - deletes the rectangle.
							if(j > 1)
								delete(handles_arr(j));
								handles_arr(j) = [];
								list1(j) = [];
								arr(j,:) = [];
								break;
							else
								display('Cannot delete the primary rectangle. Change Orientation or press ~ to end this branch. ');
								continue;
							end
						case 13 % Enter = Approve this specific path.
							set(handles_arr(j),'color',Colors_Arr(mod(j-1,3)+1,:),'LineWidth',LineWidth1);
							arr(j,1) = a1;
							break;
						otherwise
							continue;
					end
				end
			case {43,61} % Plus buttons - adds a new rectangle.
				if(length(list1) == 4)
					display('4 is the maximum number of routes.');
					continue;
				elseif(isempty(arr))
					arr(1,1) = Step_Parameters.Previous_Angle;
					% arr(1,2) = 0;
				else % If there's already at least one route.
					arr(end+1,1) = arr(1,1); % Use the angle of the 1st route.
					% display(arr);
					% display(handles_arr);
					% arr(end,1) = 0; % The Score.
				end
				arr(end,2:5) = 0; % TODO: retrieve rect info (score, peak prominence, peak width).
				[XV0,YV0] = Get_Rect_Vector(Step_Parameters.Step_Coordinates,arr(1,1),Step_Parameters.Rect_Width(end),Step_Parameters.Rect_Length,Rect_Rotation_Origin);
				handles_arr(end+1) = plot(XV0,YV0,'m','LineWidth',LineWidth1);
				list1(end+1) = 1;
			otherwise
				continue;
		end
	end
	
	% Copy to the final angles array only those that their handle hasn't been deleted.
	% TODO: use find and '[]';
	for i=1:size(arr,1)
		if(list1(i) == 1 && (i == 1 || (i > 1 && arr(i,1) ~= arr(1,1))))
			ARR(end+1,:) = arr(i,:);
			delete(handles_arr(i));
		end
	end

	if(c1 == 56 && size(ARR,1) > 1) % '8' key.
		ARR = ARR(1,:);
	end	
	
	Step_Parameters.Step_Routes = ARR;
	
	% TODO: Sort using relative angle.
	
end