function A = Find_Angle360_2_Points(P1,P2)
	
	dX = P2(1) - P1(1);
	dY = P2(2) - P1(2);
	
	A = abs(atand(dY/dX)); % [0,90].
	
	if(dX >= 0 && dY < 0)
		A = mod(-A,360);
	elseif(dX < 0 && dY >= 0)
		A = 180 - A;
	elseif(dX < 0 && dY < 0)
		A = A + 180;
	end
end