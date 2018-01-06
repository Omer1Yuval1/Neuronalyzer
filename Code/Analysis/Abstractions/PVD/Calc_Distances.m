function Workspace1 = Calc_Distances(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	MinD0 = max(Workspace1.Parameters.General_Parameters.Im_Rows,Workspace1.Parameters.General_Parameters.Im_Cols);
	
	% Make a list of all 1st order coordinates:	
	F1 = find([Workspace1.Branches.Order] == 1); % Find all 1st order branches.
	
	if(Workspace1.Branches(F1(2)).Rectangles(1).Angle > 90 && Workspace1.Branches(F1(2)).Rectangles(1).Angle < 270)
		F1 = fliplr(F1); % Set F1 such that the first branch is the anterior branch (pointing to the left).
	end
	
	Workspace1.Branches(F1(1)).Rectangles(1).Primary_Arc_Distance_From_CB = 0;
	Xa = Workspace1.Branches(F1(1)).Rectangles(1).X; % 1st anterior coordinate.
	Ya = Workspace1.Branches(F1(1)).Rectangles(1).Y; % ".
	Xp = Workspace1.Branches(F1(2)).Rectangles(1).X; % 1st posterior coordinate.
	Yp = Workspace1.Branches(F1(2)).Rectangles(1).Y; % ".
	XCap = (Xa + Xp) / 2; % Center (0) coordinate.
	YCap = (Ya + Yp) / 2; % ".
	Dap = [((Xa-XCap)^2+(Ya-YCap)^2)^0.5 , ((XCap-Xp)^2+(YCap-Yp)^2)^0.5] * Scale_Factor; % Distances of start points from the center.
	
	for i=1:2 % For the two primary branches: anterior(1) & posterior(2). Assign 'Primary_Arc_Distance_From_CB' to each 1st order rectangle.
		t = (-1)^(i-1);
		[Workspace1.Branches(F1(i)).Rectangles.Distance_From_Primary] = deal(0);
		for j=1:numel(Workspace1.Branches(F1(i)).Rectangles)
			Workspace1.Branches(F1(i)).Rectangles(j).Primary_Arc_Distance_From_CB = t*(Dap(i) + sum([Workspace1.Branches(F1(i)).Rectangles(1:j-1).Step_Length]));
		end
	end
	
	% Add points between the start points (on the cell body):
	Xcv = Xa:Xp; % A vector of pixels between the primary start points.
	Ycv = ones(1,length(Xcv))*YCap;
	Dcv = (((Xcv-XCap).^2+(Ycv-YCap).^2).^0.5) * Scale_Factor;
	Dcv(find(Xcv > XCap)) = Dcv(find(Xcv > XCap)) * (-1);
	
	X1 = [Workspace1.Branches(F1(1)).Rectangles(:).X]; % Anterior.
	Y1 = [Workspace1.Branches(F1(1)).Rectangles(:).Y]; % ".
	D1 = [Workspace1.Branches(F1(1)).Rectangles(:).Primary_Arc_Distance_From_CB]; % ".
	X2 = [Workspace1.Branches(F1(2)).Rectangles(:).X]; % Posterior.
	Y2 = [Workspace1.Branches(F1(2)).Rectangles(:).Y]; % ".
	D2 = [Workspace1.Branches(F1(2)).Rectangles(:).Primary_Arc_Distance_From_CB]; % ".
	
	MATap = [Xcv',Ycv',Dcv' ; X1',Y1',D1' ; X2',Y2',D2'];
	
	% assignin('base','MATap',MATap);
	% figure;
	% imshow(Workspace1.Image0);
	% hold on;
	% plot([MATap(:,1)],[MATap(:,2)],'.r');
	% return;
	
	% Create a polygon that contains the ventral region but not contain the dorsal region.
	Xp = ([1,1,fliplr(X1),X2,Workspace1.Parameters.General_Parameters.Im_Cols,Workspace1.Parameters.General_Parameters.Im_Cols]);
	Yp = ([1,Y1(end),fliplr(Y1),Y2,Y2(end),1]);
	% plot([1,1,fliplr(X1),X2,Workspace1.Parameters.General_Parameters.Im_Cols,Workspace1.Parameters.General_Parameters.Im_Cols] , [1,Y1(end),fliplr(Y1),Y2,Y2(end),1],'m','LineWidth',3);
	
	V1 = [Workspace1.Vertices.Coordinates]; % Create a N*2 matrix of all the vertices coordinates.
	Vertices_Coordinates = [V1(1:2:end)' , V1(2:2:end)']; % ".
	
	[in,on] = inpolygon(Vertices_Coordinates(:,1),Vertices_Coordinates(:,2),Xp,Yp); % Find which vertices coordinates are in (ventral), on (prinary branches) or out (dorsal) of the polygon.
	Xp([1,2,end-1,end]) = [];
	Yp([1,2,end-1,end]) = [];
	
	for i=1:numel(Workspace1.Vertices) % For each vertex, assign its shortest distance from the primary branches.
		if(on(i) == 1)
			Workspace1.Vertices(i).Dorsal_Ventral = 0; % If it's inside the "box", it's ventral.
			% plot(Workspace1.Vertices(i).Coordinates(1),Workspace1.Vertices(i).Coordinates(2),'.b');
		elseif(in(i) == 1)
			Workspace1.Vertices(i).Dorsal_Ventral = -1; % If it's inside the "box", it's ventral.
			% plot(Workspace1.Vertices(i).Coordinates(1),Workspace1.Vertices(i).Coordinates(2),'.r');
		else
			Workspace1.Vertices(i).Dorsal_Ventral = 1; % If it's inside the "box", it's ventral.
			% plot(Workspace1.Vertices(i).Coordinates(1),Workspace1.Vertices(i).Coordinates(2),'.g');
		end
		
		Length1 = MinD0;
		X = Workspace1.Vertices(i).Coordinates(1);
		Y = Workspace1.Vertices(i).Coordinates(2);
		X1 = 0;
		Y1 = 0;
		for j=1:length(Xp) % For each 1st order coordinate.
			Length2 = ((X-Xp(j))^2+(Y-Yp(j))^2)^0.5;
			if(Length2 < Length1)
				Length1 = Length2;
				X1 = Xp(j);
				Y1 = Yp(j);
			end
		end
		Workspace1.Vertices(i).Distance_From_Primary = Length1*Scale_Factor; % Assign the shortest distance from the primary branches.
	end
	
	% Assign each rectangle of each segment with its 'Primary_Arc_Distance_From_CB' and 'Distance_From_Primary':
	for i=1:numel(Workspace1.Segments) % For each segment.
		for j=1:numel(Workspace1.Segments(i).Rectangles) % For each coordinate of segment i.
			Xs = Workspace1.Segments(i).Rectangles(j).X;
			Ys = Workspace1.Segments(i).Rectangles(j).Y;
			MinD1 = MinD0;
			L = 0;
			for p=1:size(MATap,1) % Go over all 1st order coordinates.
				D = ( (Xs-MATap(p,1))^2 + (Ys-MATap(p,2))^2 )^0.5;
				if(D < MinD1)
					MinD1 = D;
					L = MATap(p,3);
				end
			end
			Workspace1.Segments(i).Rectangles(j).Primary_Arc_Distance_From_CB = L;
			
			Fv = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Segments(i).Vertex2); % Find the 2nd vertex of the i-segment to determin dorsal-ventral.
			Workspace1.Segments(i).Rectangles(j).Distance_From_Primary = MinD1 * Scale_Factor * Workspace1.Vertices(Fv).Dorsal_Ventral;
		end
	end
	
end