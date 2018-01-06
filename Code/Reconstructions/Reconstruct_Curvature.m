function Reconstruct_Curvature(Workspace1,R,Slider_Value)
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	
	Max0 = 0.15;
	Min0 = 0;
	
	ColorMap1 = jet(64);
	Max1 = 64;
	Min1 = 1;
	
	switch R
		case 1
			for b=1:numel(Workspace1.Segments)
				M = max([Workspace1.Segments.Curvature])*Slider_Value;
				for p=1:numel(Workspace1.Segments(b).Rectangles)
					if(Workspace1.Segments(b).Rectangles(p).Curvature >= 0)
						MLS = min(M,Workspace1.Segments(b).Rectangles(p).Curvature)/M;
						plot(Workspace1.Segments(b).Rectangles(p).X,Workspace1.Segments(b).Rectangles(p).Y,'.','Color',[MLS 0 1-MLS],'MarkerSize',3*Workspace1.Segments(b).Width/Scale_Factor);
					else
						plot(Workspace1.Segments(b).Rectangles(p).X,Workspace1.Segments(b).Rectangles(p).Y,'.','Color',[0,1,0],'MarkerSize',3*Workspace1.Segments(b).Width/Scale_Factor);
					end
				end
			end
		case 2
			for b=1:numel(Workspace1.Branches)
				for p=1:numel(Workspace1.Branches(b).Rectangles)
					if(Workspace1.Branches(b).Rectangles(p).Curvature >= 0)
						
						Output_Vector = Convert_Range(Workspace1.Branches(b).Rectangles(p).Curvature,[Min0,Max0],[Min1,Max1]);
						Output_Vector = min(Max1,round(Output_Vector)); % Round and make sure the output number is not higher than the maximum in the new range.
						Color1 = ColorMap1(Output_Vector,:);
						plot(Workspace1.Branches(b).Rectangles(p).X,Workspace1.Branches(b).Rectangles(p).Y,'.','Color',Color1,'MarkerSize',3*Workspace1.Branches(b).Width/Scale_Factor);
					else
						plot(Workspace1.Branches(b).Rectangles(p).X,Workspace1.Branches(b).Rectangles(p).Y,'.','Color',[0,0,0],'MarkerSize',Workspace1.Branches(b).Width/Scale_Factor);
					end
				end
			end
	end
end