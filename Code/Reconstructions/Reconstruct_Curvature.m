function Reconstruct_Curvature(Workspace,Slider_Value)
	
	Min_Eval_Points = 5;
	XYC = zeros(0,3);
	for s=1:numel(Workspace.Segments)
		if(numel(Workspace.Segments(s).Rectangles) > Min_Eval_Points)
			X = [Workspace.Segments(s).Rectangles.X];
			Y = [Workspace.Segments(s).Rectangles.Y];
			
			[Mean_Curvature,Xs,Ys,Cxy] = Get_Segment_Curvature(X,Y);
			
			% if(max(Cxy) > 0.15)
			% 	disp([num2str(numel(Workspace.Segments(s).Rectangles)) ,' ; ', num2str(Workspace.Segments(s).Length)]);
			% end
			
			XYC = [XYC ; [X' , Y' , Cxy']];
        end
	end
	% assignin('base','XYC0',XYC);
    
	% It seems that that interesting range is within [0.3,0.7]. This excludes the turn points of terminal tertiary segments.
	m = 0; % 0.03.
	M = 0.1; % 0.05.
	
	XYC(XYC(:,3) < m,:) = [];
	XYC(XYC(:,3) > M,:) = [];
	% XYC(XYC(:,3) > m & XYC(:,3) < M,:) = [];
	
	XYC(:,3) = rescale(XYC(:,3));
	
	% XYC(XYC(:,3) <= Slider_Value,:) = [];
	
	
	Colors = XYC(:,3) ./ max(XYC(:,3));
	% XYC(XYC(:,3)<0,3) = 0;
	
	Colors = [XYC(:,3),0.*XYC(:,3),1-XYC(:,3)];
	% figure;
	% imshow(Workspace.Image0);
	hold on;
	scatter(XYC(:,1),XYC(:,2),30,Colors,'filled');
	
	% assignin('base','XYC',XYC);
end