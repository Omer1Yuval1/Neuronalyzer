function Reconstruct_Persistence_Length(Workspace1,R,Slider_Value)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	
	switch R
		case 10
			M = max(log([Workspace1.Branches.Persistence_Length]))*Slider_Value;
			for b=1:numel(Workspace1.Branches)
				
				if(Workspace1.Branches(b).Persistence_Length >= 0)
					PL = min(M,log(Workspace1.Branches(b).Persistence_Length))/M;
					plot([Workspace1.Branches(b).Rectangles.X],[Workspace1.Branches(b).Rectangles.Y],'.','Color',[1-PL 0 PL],'MarkerSize',3*Workspace1.Branches(b).Width/Scale_Factor);
				else
					plot([Workspace1.Branches(b).Rectangles.X],[Workspace1.Branches(b).Rectangles.Y],'.','Color',[0,1,0],'MarkerSize',3*Workspace1.Branches(b).Width/Scale_Factor);
				end
			end
	end
	
	for i=1:numel(Workspace1.Branches) % Go over each branch.
		F0 = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Branches(i).Vertices(end));
		plot(Workspace1.Vertices(F0).Coordinates(1),Workspace1.Vertices(F0).Coordinates(2),'.','Color',[1,1,1],'MarkerSize',20);
	end
end