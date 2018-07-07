function Reconstruct_Curvature(Workspace)
	
	Min_Eval_Points = 5;
	XYC = zeros(0,3);
	for s=1:numel(Workspace.Segments)
		if(numel(Workspace.Segments(s).Rectangles) > Min_Eval_Points)
			X = [Workspace.Segments(s).Rectangles.X];
			Y = [Workspace.Segments(s).Rectangles.Y];
			
			[Mean_Curvature,Xs,Ys,Cxy] = Get_Segment_Curvature(X,Y);
			
			XYC = [XYC ; [X' , Y' , Cxy']];
        end
	end
	% assignin('base','XYC0',XYC);
    
	M = 0.1;
	XYC(XYC(:,3) > M,3) = M;
	XYC(:,3) = XYC(:,3) ./ M;
	Colors = XYC(:,3) ./ max(XYC(:,3));
	% XYC(XYC(:,3)<0,3) = 0;
	
	Colors = [XYC(:,3),0.*XYC(:,3),1-XYC(:,3)];
	figure;
	imshow(Workspace.Image0);
	hold on;
	scatter(XYC(:,1),XYC(:,2),10,Colors,'filled');
	
	% assignin('base','XYC',XYC);
end