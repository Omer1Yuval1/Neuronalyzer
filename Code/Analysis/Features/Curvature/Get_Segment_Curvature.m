function [Mean_Curvature,SxS,SyS,Cxy] = Get_Segment_Curvature(X,Y)
	
	% 0. Parameters:
	Plot = 0;
	Smoothing_Parameter = 100;
	Eval_Points_Num = length(X); % TODO: normalize to the original number of points.
	
	% 1. Smooth the curve using a smoothing parameter that determines the resolution of the desired curvature:
	u = smoothn(num2cell([X',Y'],1),Smoothing_Parameter);
	Suxy = horzcat(u{:});
	SxS = Suxy(:,1)'; % Smoothed x-coordinates.
	SyS = Suxy(:,2)'; % Smoothed y-coordinates.
	
	% 2. Fit a piecewise cubic spline:
	Fs = cscvn([SxS ; SyS]);
	Vb = linspace(Fs.breaks(1),Fs.breaks(end),Eval_Points_Num);
	SFxy = fnval(Fs,Vb); % Evaluate at the spline at different points along the curve.
	
	% 3. Get the 1st and 2nd derivatives of the fitted spline:
	Fs_Der1 = fnder(Fs,1);
	SFxy_Der1 = (fnval(Fs_Der1,Vb));
	Fs_Der2 = fnder(Fs,2);
	SFxy_Der2 = (fnval(Fs_Der2,Vb));
	
	% Compute the radius of curvature and the curvature at each evaluation point:
		% Source: http://mathworld.wolfram.com/RadiusofCurvature.html
	R = ((SFxy_Der1(1,:).^2 + SFxy_Der1(2,:).^2).^1.5) ./ abs( SFxy_Der1(1,:).*SFxy_Der2(2,:) - SFxy_Der1(2,:).*SFxy_Der2(1,:) );
	Cxy = (1./R);
	
	Mean_Curvature = mean(Cxy);
	
	if(Plot)
		Colors = Cxy ./ max(Cxy);
		figure(1);
		clf(1);
		subplot(1,3,1);
			plot(X,Y,'k','LineWidth',2);
			hold on;
			plot(X,Y,'.r','MarkerSize',10);
			title('Source Curve');
			XLIM = get(gca,'xlim');
			YLIM = get(gca,'ylim');
		subplot(1,3,2);
			plot(X,Y,'k','LineWidth',2);
			hold on;
			plot(Suxy(:,1),Suxy(:,2),'Color',[.2,.7,0],'LineWidth',2); % Smoothed.
			title('Smoothed Curve');
			axis([XLIM,YLIM]);
		subplot(1,3,3);
			plot(X,Y,'w','LineWidth',2);
			hold on;
			plot(Suxy(:,1),Suxy(:,2),'Color',[.2,.7,0],'LineWidth',2); % Smoothed.
			hold on;
			scatter(SFxy(1,:),SFxy(2,:),[],[Colors',zeros(length(Colors),1),1-Colors'],'filled');
			title('Curvature Heatmap');
			axis([XLIM,YLIM]);
		% axis equal;
	end
end