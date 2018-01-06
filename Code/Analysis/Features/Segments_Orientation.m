function Workspace1 = Segments_Orientation(Workspace1)
	
	% Make a list of the coordinates of the 1st and last primary branches:
		Vxy1 = [[Workspace1.Branches(1).Rectangles(:).X]',[Workspace1.Branches(1).Rectangles(:).Y]'];
		Vxy2 = [[Workspace1.Branches(2).Rectangles(:).X]',[Workspace1.Branches(2).Rectangles(:).Y]'];
		Coordinates1 = [Vxy1 ; Vxy2];
	%
	% Fit a curve to each primary branch (only first 2):
		FitObject1 = fit(Vxy1(:,1),Vxy1(:,2),'smoothingspline','SmoothingParam',Workspace1.Parameters.Menorah_Orders.Smoothing_Parameter);
		FitObject2 = fit(Vxy2(:,1),Vxy2(:,2),'smoothingspline','SmoothingParam',Workspace1.Parameters.Menorah_Orders.Smoothing_Parameter);
		
		XVf1 = linspace(Vxy1(1,1),Vxy1(end,1),2*abs(Vxy1(1,1)-Vxy1(end,1)));
		YVf1 = FitObject1(XVf1);
		Der1 = differentiate(FitObject1,XVf1);
		
		XVf2 = linspace(Vxy2(1,1),Vxy2(end,1),2*abs(Vxy2(1,1)-Vxy2(end,1)));
		YVf2 = FitObject2(XVf2);
		Der2 = differentiate(FitObject2,XVf2);
		
		Coordinates1 = [[XVf1'; XVf2'] , [YVf1 ; YVf2]];
		Derivatives1 = [Der1',Der2'];
		
		% figure(3);
		% imshow(Workspace1.Image0);
		% hold on;
		% plot(XVf1,YVf1,'.','MarkerSize',10);
		% hold on;
		% plot(XVf2,YVf2,'.','MarkerSize',10);
	
	% Find the closest points along the 1st order branch to the endpoints of each segment:
	for i=1:numel(Workspace1.Segments)
		if(Workspace1.Segments(i).Order ~= 1)
			C1 = [Workspace1.Segments(i).Rectangles(1).X,Workspace1.Segments(i).Rectangles(1).Y];
			C2 = [Workspace1.Segments(i).Rectangles(end).X,Workspace1.Segments(i).Rectangles(end).Y];
			
			Min_Length1 = Workspace1.Parameters.General_Parameters.Im_Rows; % Using the number of columns in the image as a maximum distance (in pixels).
			Min_Length2 = Workspace1.Parameters.General_Parameters.Im_Rows;
			XY1m = [0,0]; % The closest primary coordinate to the 1st vertex.
			XY2m = [0,0]; % The closest primary coordinate to the 2nd vertex.
			M1 = -1;
			M2 = -1;
			for j=1:size(Coordinates1,1) % For each 1st order coordinate.
				% Calculate the distance of the i-segments tips from the j-1st order point:
				Length1 = ((C1(1)-Coordinates1(j,1))^2+(C1(2)-Coordinates1(j,2))^2)^0.5; % The distance of primary point 'j' from the 1st vertex of the segments.
				Length2 = ((C2(1)-Coordinates1(j,1))^2+(C2(2)-Coordinates1(j,2))^2)^0.5; % The distance of primary point 'j' from the 2nd vertex of the segments.
				
				if(Length1 < Min_Length1)
					Min_Length1 = Length1;
					XY1m = [Coordinates1(j,1),Coordinates1(j,2)]; % The closest primary coordinate to the 1st vertex.
					M1 = j;
				end
				if(Length2 < Min_Length2)
					Min_Length2 = Length2;
					XY2m = [Coordinates1(j,1),Coordinates1(j,2)]; % The closest primary coordinate to the 2nd vertex.
					M2 = j;
				end
			end
			
			% Add the orientation relative to the 1st order branch:
			Orientation2 = Workspace1.Segments(i).Line_Angle; % The orientation of the segment ([0,360] degrees).
			Orientation1 = mod(atand(mean([Derivatives1(M1),Derivatives1(M2)])),360);
			
			Orientation12 = min(abs(Orientation1-Orientation2),360-abs(Orientation1-Orientation2)); % [0,180].
			Orientation12 = atan2d(sind(Orientation12),abs(cosd(Orientation12))); % Convert [0,180] => [0,90].
			Workspace1.Segments(i).Orientation = Orientation12;
			
			Length1 = ((C1(1)-XY1m(1))^2+(C1(2)-XY1m(2))^2)^0.5; % The distance of primary point 'j' from the 1st vertex of the segments.
			Length2 = ((C2(1)-XY2m(1))^2+(C2(2)-XY2m(2))^2)^0.5; % The distance of primary point 'j' from the 2nd vertex of the segments.
			if(Length2 < Length1) % If the segment is oriented "down" (towards the primary branch),
				Workspace1.Segments(i).Orientation = (-1)*Workspace1.Segments(i).Orientation; % ...assign the orientation [0,90] with a negative value (reflection in y-axis).
			end
		else
			Workspace1.Segments(i).Orientation = 0; % Define the orientation of 1st order segments as 0.
		end
	end
	
end