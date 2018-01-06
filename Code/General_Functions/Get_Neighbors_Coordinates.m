function [Neighbors_Mat,Im] = Get_Neighbors_Coordinates(Im,x0,y0,Avoid)
	
	Neighbors_Mat = []; % [x,y,type]. type 0 = 4 connected neighbor. type 1 = corners.
	for x=-1:1
		for y=-1:1
			if(Im(y0+y,x0+x) == 1 && ~(x == 0 && y == 0))
				Neighbors_Mat(end+1,1) = x0+x;
				Neighbors_Mat(end,2) = y0+y;
				if(x == 0 || y == 0)
					Neighbors_Mat(end,3) = 0;
				else
					Neighbors_Mat(end,3) = 1;
				end
				Im(y0+y,x0+x) = 0.5;
			end
		end
	end
	
	if(size(Neighbors_Mat,1) > 0)
		Neighbors_Mat = sortrows(Neighbors_Mat,3); % First type 0, then type 1.
	end
	
end