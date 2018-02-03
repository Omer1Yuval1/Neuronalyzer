function Rerconstruct_Curvature_1(Workspace)
	
	Eval_Res = 2;
	figure;
	imshow(Workspace.Image0);
	hold on;
	XYC = zeros(0,3);
	for s=1:numel(Workspace.Segments)
		if(numel(Workspace.Segments(s).Rectangles) > 2)
			X = [Workspace.Segments(s).Rectangles.X];
			Y = [Workspace.Segments(s).Rectangles.Y];
			
			
			F0 = fit(X',Y','smoothingspline','smoothingparam',0.1);
			[fx,fxx] = differentiate(F0,X);
			% disp(X);
			% V2 = fxx(X)';
			
			% F0 = csaps(X,Y,.01); % cscvn([X ; Y]); % Fit a cubic spline. F(t) = [x(t),y(t)].
			% F2 = fnder(F0,2); % Differentiate twice to get the 2nd derivative function of the fit object.
			% Eval_Points = linspace(F2.breaks(1),F2.breaks(end),Eval_Res.*length(X));
			% V0 = fnval(F0,Eval_Points)'; % Evaluate the fit object at different points along the curve.
			% V2 = fnval(F2,Eval_Points)'; % Evaluate the 2nd derivative at different points along the curve.
			% XYC = [XYC ; [Eval_Points' , V0 , Curvature]];
			
			Curvature = 1 ./ abs((1+fx)./fxx); % (sum(V2.^2))'; % The curvature at each point is the sum of the squares of the partial 2nd derivatives at that point.
			
			XYC = [XYC ; [X' , Y' , Curvature]];
        end
	end
	assignin('base','XYC0',XYC);
	
	M = 0.2;
	XYC(XYC(:,3)>M,3) = M;
	XYC(:,3) = XYC(:,3) ./ max([XYC(:,3)]);
	XYC(XYC(:,3)<0,3) = 0;
	Colors = [XYC(:,3),0.*XYC(:,3),1-XYC(:,3)];
	scatter(XYC(:,1),XYC(:,2),5,Colors,'filled');
	
	assignin('base','XYC',XYC);
end