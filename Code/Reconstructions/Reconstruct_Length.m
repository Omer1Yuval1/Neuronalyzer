function Reconstruct_Length(Workspace1,Slider_Value,R)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	
	switch R
		case 11
			M = max([Workspace1.Segments.Length]);
			for s=1:numel(Workspace1.Segments)
				if(Workspace1.Segments(s).Length/M < Slider_Value)
					plot([Workspace1.Segments(s).Rectangles.X],[Workspace1.Segments(s).Rectangles.Y],'.g','MarkerSize',3*Workspace1.Segments(s).Width/Scale_Factor);
				else
					plot([Workspace1.Segments(s).Rectangles.X],[Workspace1.Segments(s).Rectangles.Y],'.r','MarkerSize',3*Workspace1.Segments(s).Width/Scale_Factor);
				end
			end
		case 12
			M = max([Workspace1.Branches.Length]);
			for s=1:numel(Workspace1.Branches)
				if(Workspace1.Branches(s).Length/M < Slider_Value)
					plot([Workspace1.Branches(s).Rectangles.X],[Workspace1.Branches(s).Rectangles.Y],'.g','MarkerSize',3*Workspace1.Branches(s).Width/Scale_Factor);
				else
					plot([Workspace1.Branches(s).Rectangles.X],[Workspace1.Branches(s).Rectangles.Y],'.r','MarkerSize',3*Workspace1.Branches(s).Width/Scale_Factor);
				end
			end
	end
	
end