function Reconstruct_Curviness(Workspace1,Slider_Value,R)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	
	switch R
		case 7
			for i=1:numel(Workspace1.Segments)
				if(Workspace1.Segments(i).Curviness < Slider_Value)
					plot([Workspace1.Segments(i).Rectangles.X],[Workspace1.Segments(i).Rectangles.Y],'.g','MarkerSize',3*Workspace1.Segments(i).Width/Scale_Factor);
				else
					plot([Workspace1.Segments(i).Rectangles.X],[Workspace1.Segments(i).Rectangles.Y],'.r','MarkerSize',3*Workspace1.Segments(i).Width/Scale_Factor);
				end
			end
		case 8
			for i=1:numel(Workspace1.Branches)
				if(Workspace1.Branches(i).Curviness < Slider_Value)
					plot([Workspace1.Branches(i).Rectangles.X],[Workspace1.Branches(i).Rectangles.Y],'.g','MarkerSize',3*Workspace1.Branches(i).Width/Scale_Factor);
				else
					plot([Workspace1.Branches(i).Rectangles.X],[Workspace1.Branches(i).Rectangles.Y],'.r','MarkerSize',3*Workspace1.Branches(i).Width/Scale_Factor);
				end
			end
	end
	
end