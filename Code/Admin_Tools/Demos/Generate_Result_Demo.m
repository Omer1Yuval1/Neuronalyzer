function Generate_Result_Demo(Workspace)
	
	Scale_Factor = 50/140;
	CB_GS2BW_Threshold = .9;
	
	figure(1);
	clf(1);
	imshow(Workspace.Image0);
	
	for s=1:numel(Workspace.Segments)
		for r=1:numel(Workspace.Segments(s).Rectangles)
			XY = [Workspace.Segments(s).Rectangles.Coordinates];
			hold on;
			plot(XY(1:2:end-1),XY(2:2:end),'LineWidth',2);
		end
	end
	
	[CB_Pixels,CB_Perimeter] = Detect_Cell_Body(Workspace.Image0,CB_GS2BW_Threshold,Scale_Factor,0);
	[CBy,CBx] = ind2sub(size(Workspace.Image0),CB_Pixels);
	
	if(length(CBy))
		hold on;
		plot(CBx,CBy,'r.');
		plot(CB_Perimeter(:,1),CB_Perimeter(:,2),'.b');
		
		CB_Vertices = Find_CB_Vertices(Workspace.Image0,CB_Perimeter,CB_Pixels,Scale_Factor,CB_GS2BW_Threshold,1);	
	end
end