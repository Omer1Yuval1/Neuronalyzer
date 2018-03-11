function Generate_Result_Demo(Workspace)
	
	Scale_Factor = 50/140;
	CB_GS2BW_Threshold = .9;
	
	figure(1);
	clf(1);
	imshow(Workspace.Image0);
	set(gca,'YDir','normal');
	hold on;
	
	for s=1:numel(Workspace.Segments)
		for r=1:numel(Workspace.Segments(s).Rectangles)
			plot([Workspace.Segments(s).Rectangles.X],[Workspace.Segments(s).Rectangles.Y],'LineWidth',2);
		end
	end
	
	Vi = [Workspace.Vertices.Coordinate];
	Vi = [Vi(1:2:end-1)',Vi(2:2:end)'];
	viscircles(Vi,[Workspace.Vertices.Center_Radius]');
	
	[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Workspace.Image0,CB_GS2BW_Threshold,Scale_Factor,0);
	[CBy,CBx] = ind2sub(size(Workspace.Image0),CB_Pixels);
	
	if(length(CBy))
		hold on;
		plot(CBx,CBy,'r.');
		plot(CB_Perimeter(:,1),CB_Perimeter(:,2),'.b');
		
		CB_Vertices = Find_CB_Vertices(Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_GS2BW_Threshold,1);	
	end
end