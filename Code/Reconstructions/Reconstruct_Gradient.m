function Reconstruct_Gradient(Workspace1)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	Cm = length(find([Workspace1.Menorahs.Primary_Arc_Distance_From_CB] > 0)) + 2;
	Colors_Vector = jet(Cm);
	
	for AP=1:2 % Anterior\Posterior.
		if(AP == 1)
			F1 = find([Workspace1.Menorahs.Primary_Arc_Distance_From_CB] > 0);
			[F2,I] = sort([Workspace1.Menorahs(F1).Primary_Arc_Distance_From_CB]);
			F1 = F1(I);
		else
			F1 = find([Workspace1.Menorahs.Primary_Arc_Distance_From_CB] <= 0);
			[F2,I] = sort([Workspace1.Menorahs(F1).Primary_Arc_Distance_From_CB],'descend');
			F1 = F1(I);
		end
		
		for m=1:length(F1) % For each A\P menorah.
			Fb = find([Workspace1.Branches.Menorah] == Workspace1.Menorahs(F1(m)).Menorah_Index);
			for b=1:length(Fb)
				plot([Workspace1.Branches(Fb(b)).Rectangles.X],[Workspace1.Branches(Fb(b)).Rectangles.Y],'.', ...
					'Color',Colors_Vector(mod(m,Cm)+1,:),'MarkerSize',Workspace1.Branches(Fb(b)).Width/Scale_Factor);
					
				% for v=1:length(Workspace1.Branches(b).Vertices)
					% Fv = find([Workspace1.Vertices.Vertex_Index] == Workspace1.Branches(b).Vertices(v));
					% plot(Workspace1.Vertices(Fv).Coordinates(1),Workspace1.Vertices(Fv).Coordinates(2),'.','MarkerSize',5);
				% end
			end
		end
	end
	
end