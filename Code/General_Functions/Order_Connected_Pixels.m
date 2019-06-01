function Pixels_List = Order_Connected_Pixels(Im_BW,P0,P1)
	
	% This function gets a binary image and two [x,y] coordinates (P0,P1).
	% It returns an ordered list of the coordinates of the 1-pixels ("white").
	% The ordering is according to the connectivity, starting from P0.
	% P1 is used for directionality to account for cases in which there is more than one direction to step away from P0 (e.g. a loop).
	
	if(nargin == 3) % If P1 is given.
		Im_BW(P0(2),P0(1)) = 0;
		Im_Dis = bwdistgeodesic(Im_BW,P1(1),P1(2));
		
		[Fy,Fx] = find(Im_BW);
		F = find(Im_BW);
		
		Pixels_List = zeros(length(Fx)+1,3);
		Pixels_List(1,:) = [P0(1),P0(2),0];
		Pixels_List(2:end,1) = Fx;
		Pixels_List(2:end,2) = Fy;
		Pixels_List(2:end,3) = Im_Dis(F)+1;
	else
		Im_Dis = bwdistgeodesic(Im_BW,P0(1),P0(2));
		
		[Fy,Fx] = find(Im_BW);
		F = find(Im_BW); % Assuming the orders of pixels in F and [Fy,Fx] match.
		
		Pixels_List = zeros(length(Fx),3);
		Pixels_List(1:end,1) = Fx;
		Pixels_List(1:end,2) = Fy;
		Pixels_List(1:end,3) = Im_Dis(F);
	end
	
	Pixels_List = sortrows(Pixels_List,3);
	Pixels_List = Pixels_List(:,1:2);
end