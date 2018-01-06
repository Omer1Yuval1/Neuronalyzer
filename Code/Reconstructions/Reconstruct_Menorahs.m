function Reconstruct_Menorahs(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	% Cm = length(find([Workspace1.Menorahs.Primary_Arc_Distance_From_CB] > 0)) + 2;
	% Colors_Vector = jet(Cm);
	
	for m=1:numel(Workspace1.Menorahs)
		F1 = find([Workspace1.Branches.Menorah] == Workspace1.Menorahs(m).Menorah_Index);
		C = [rand,rand,rand];
		for b=1:length(F1)
			plot([Workspace1.Branches(F1(b)).Rectangles.X],[Workspace1.Branches(F1(b)).Rectangles.Y],'.', ...
				'Color',C,'MarkerSize',Workspace1.Branches(F1(b)).Width/Scale_Factor);
		end
	end
	
end