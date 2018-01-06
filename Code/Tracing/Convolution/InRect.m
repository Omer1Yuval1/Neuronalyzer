% function [Ion1,Vals1] = InRect(Mat1,Rxy)
function Vals1 = InRect(Mat1,Rxy)
	
	% TODO:
		% flipud. the y-axis is now upside-down.
		% maybe I can use the sign(+\-) of the distance and check only 2 perpendicular side (instead of 4).
		% Scale 'S' based of the # of pixels in the smallest bounding matrix.
		% Make sure the coordinates of the rectangle to are not outside the matrix (max(1,Rxy(1,1))...
	
	% Mat1 is the image.
	% Rxy is an 4X2 [x,y] ordered vector of the coordinates of a rectangle inside Mat1.
	% 1---------2
	% |         |
	% 4---------3
	
	S = 0.01;
	
	[Rows1,Cols1] = size(Mat1);
	Nr1 = floor(min(Rxy(:,2))); % y-values of the minimal bounding rectangle (aligned with the grid).
	Nr2 = ceil(max(Rxy(:,2))); % ".
	Nc1 = floor(min(Rxy(:,1))); % x-values of the minimal bounding rectangle (aligned with the grid).
	Nc2 = ceil(max(Rxy(:,1))); % ".
	% Ion1 = zeros(Rows1*Cols1,1);
	Vals1 = zeros((Nr2-Nr1+1)*(Nc2-Nc1+1),1);
	v = 0;
	
	if(0) % abs(Rxy(1,1) - Rxy(2,1)) < S || abs(Rxy(1,2) - Rxy(2,2)) < S) % If the rectangle is "straight" (or almost straight), just use the grid.
		C1 = combvec(Nc1:Nc2,Nr1:Nr2)'; % A vector of coordinates of ImC.
		Ci = Rows1*(C1(:,1)-1)+C1(:,2);
		% Ion1(Ci) = 1;
		Vals1 = Mat1(Ci);
	else
		L12 = ((Rxy(2,2) - Rxy(1,2))^2 + (Rxy(2,1) - Rxy(1,1))^2)^0.5; % The Length of the rectangle.
		L14 = ((Rxy(4,2) - Rxy(1,2))^2 + (Rxy(4,1) - Rxy(1,1))^2)^0.5; % The Width of the rectangle.
		for y0=Nr1:Nr2 % Go over each row in Mat1.
			for x0=Nc1:Nc2 % Go over each column in Mat1.
				% Calculate the perpendicular distances of pixel (i,j) from the sides of the rectangle\polygon:
				if( 	L14 >= abs( (Rxy(2,2)-Rxy(1,2))*x0 - (Rxy(2,1) - Rxy(1,1))*y0 + Rxy(2,1)*Rxy(1,2) - Rxy(2,2)*Rxy(1,1) ) / ( (Rxy(2,2)-Rxy(1,2))^2 + (Rxy(2,1) - Rxy(1,1))^2 )^0.5 ...
					&& 	L12 >= abs( (Rxy(3,2)-Rxy(2,2))*x0 - (Rxy(3,1) - Rxy(2,1))*y0 + Rxy(3,1)*Rxy(2,2) - Rxy(3,2)*Rxy(2,1) ) / ( (Rxy(3,2)-Rxy(2,2))^2 + (Rxy(3,1) - Rxy(2,1))^2 )^0.5 ...
					&& 	L14 >= abs( (Rxy(4,2)-Rxy(3,2))*x0 - (Rxy(4,1) - Rxy(3,1))*y0 + Rxy(4,1)*Rxy(3,2) - Rxy(4,2)*Rxy(3,1) ) / ( (Rxy(4,2)-Rxy(3,2))^2 + (Rxy(4,1) - Rxy(3,1))^2 )^0.5 ...
					&& 	L12 >= abs( (Rxy(1,2)-Rxy(4,2))*x0 - (Rxy(1,1) - Rxy(4,1))*y0 + Rxy(1,1)*Rxy(4,2) - Rxy(1,2)*Rxy(4,1) ) / ( (Rxy(1,2)-Rxy(4,2))^2 + (Rxy(1,1) - Rxy(4,1))^2 )^0.5)
					
					% Ion1(Rows1*(x0-1)+y0) = 1;
					v = v + 1;
					Vals1(v) = Mat1(y0,x0);
				end
			end
		end
		Vals1 = Vals1(1:v);
    end 
end