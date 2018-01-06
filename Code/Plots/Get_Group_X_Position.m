function Xp = Get_Group_X_Position(N,i,J)
	
	if(mod(N,2) == 0)
		if(i <= N/2)
			Xp = J*(i - (N/2 + 1)) + (J/2);
		else
			Xp = J*(i - (N/2)) - (J/2);
		end
	else
		Xp = J*(i - (ceil(N/2)));
	end
	
end