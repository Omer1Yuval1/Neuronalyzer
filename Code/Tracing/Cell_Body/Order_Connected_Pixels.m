function Pixels_List = Order_Connected_Pixels(Im_BW,P0,P1)
	
	Im_BW(P0(2),P0(1)) = 0;
	
	Im_Dis = bwdistgeodesic(Im_BW,P1(1),P1(2));
	
	[Fy,Fx] = find(Im_BW);
	F = find(Im_BW);
	
	Pixels_List = zeros(length(Fx)+1,3);
	Pixels_List(1,:) = [P0(1),P0(2),0];
	Pixels_List(2:end,1) = Fx;
	Pixels_List(2:end,2) = Fy;
	Pixels_List(2:end,3) = Im_Dis(F)+1;
	
	Pixels_List = sortrows(Pixels_List,3);
end