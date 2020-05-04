function Coordinates1 = InRect_Coordinates(Mat1,Rxy)
	
	% TODO:
		% flipud. the y-axis is now upside-down.
		% maybe I can use the sign(+\-) of the distance and check only 2 perpendicular side (instead of 4).
		% Scale 'S' based of the # of pixels in the smallest bounding matrix.
		% Make sure the coordinates of the rectangle to are not outside the matrix (max(1,Rxy(1,1))...
	
	% Mat1 is the input image.
	% Rxy is an NX2 [x,y] ordered vector of the coordinates of a rectangle inside Mat1.
	% 1---------2
	% |         |
	% 4---------3
	
	S = 0.01;
	
	[Rows1,Cols1] = size(Mat1); % TODO: Get from input.
	Nr1 = floor(min(Rxy(:,2))); % y-values of the minimal bounding rectangle (aligned with the grid).
	Nr2 = ceil(max(Rxy(:,2))); % ".
	Nc1 = floor(min(Rxy(:,1))); % x-values of the minimal bounding rectangle (aligned with the grid).
	Nc2 = ceil(max(Rxy(:,1))); % ".
	
	r = 0;
	
	if(0) % abs(Rxy(1,1) - Rxy(2,1)) < S || abs(Rxy(1,2) - Rxy(2,2)) < S) % If the rectangle is "straight" (or almost straight), just use the grid.
		Coordinates0 = combvec(Nc1:Nc2,Nr1:Nr2); % A vector of coordinates of the cropped image (minimal bounding rectangle).
		% assignin('base','Coordinates0',Coordinates0);
		Coordinates1 = Rows1*([Coordinates0(1,:)]-1)+[Coordinates0(2,:)]; % Conversion to linear indices.
		Coordinates1(2,:) = 1;
	else
		Coordinates1 = zeros(2,(Nr2-Nr1+1)*(Nc2-Nc1+1)); % One row for each coordinate. [x,y,in\out].
		L12 = ((Rxy(2,2) - Rxy(1,2))^2 + (Rxy(2,1) - Rxy(1,1))^2)^0.5; % The Length of the rectangle.
		L14 = ((Rxy(4,2) - Rxy(1,2))^2 + (Rxy(4,1) - Rxy(1,1))^2)^0.5; % The Width of the rectangle.
		for y0=Nr1:Nr2 % Go over each row in Mat1.
			for x0=Nc1:Nc2 % Go over each column in Mat1.
				% Calculate the perpendicular distances of pixel (i,j) from the edges of the rectangle\polygon:
				if( 	L14 >= abs( (Rxy(2,2)-Rxy(1,2))*x0 - (Rxy(2,1) - Rxy(1,1))*y0 + Rxy(2,1)*Rxy(1,2) - Rxy(2,2)*Rxy(1,1) ) / ( (Rxy(2,2)-Rxy(1,2))^2 + (Rxy(2,1) - Rxy(1,1))^2 )^0.5 ...
					&& 	L12 >= abs( (Rxy(3,2)-Rxy(2,2))*x0 - (Rxy(3,1) - Rxy(2,1))*y0 + Rxy(3,1)*Rxy(2,2) - Rxy(3,2)*Rxy(2,1) ) / ( (Rxy(3,2)-Rxy(2,2))^2 + (Rxy(3,1) - Rxy(2,1))^2 )^0.5 ...
					&& 	L14 >= abs( (Rxy(4,2)-Rxy(3,2))*x0 - (Rxy(4,1) - Rxy(3,1))*y0 + Rxy(4,1)*Rxy(3,2) - Rxy(4,2)*Rxy(3,1) ) / ( (Rxy(4,2)-Rxy(3,2))^2 + (Rxy(4,1) - Rxy(3,1))^2 )^0.5 ...
					&& 	L12 >= abs( (Rxy(1,2)-Rxy(4,2))*x0 - (Rxy(1,1) - Rxy(4,1))*y0 + Rxy(1,1)*Rxy(4,2) - Rxy(1,2)*Rxy(4,1) ) / ( (Rxy(1,2)-Rxy(4,2))^2 + (Rxy(1,1) - Rxy(4,1))^2 )^0.5)
					
					r = r + 1;
					Coordinates1(1,r) = Rows1*(x0-1)+y0; % Conversion to linear indices.
					Coordinates1(2,r) = 1; % Not marked for deletion.
				end
			end
		end
    end
	Coordinates1(:,find([Coordinates1(2,:)] == 0)) = [];
	Coordinates1(2,:) = [];
end