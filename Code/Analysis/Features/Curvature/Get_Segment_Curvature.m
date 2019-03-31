function [Mean_Curvature,SxS,SyS,xx,Cxy] = Get_Segment_Curvature(X,Y)
	
	Method = 1;
	Distance_Func = @(x1,y1,x2,y2) ( (x1-x2).^2 + (y1-y2).^2).^(.5);
	Plot = 0;
	
	switch Method
		case 1
			
			[X,Y] = Smooth_Points(X,Y,100);
			
			Ri = nan(1,length(X));
			% Cxy = nan(1,length(X));
			for i=2:length(X)-1 % For each point (end-points NOT included).
				
				Pi = [X(i) ; Y(i) ; 0];
				P1 = [X(i-1) ; Y(i-1) ; 0];
				P2 = [X(i+1) ; Y(i+1) ; 0];
				
				Ri(i) = Get_Radius_Of_Curvature(Pi,P1,P2);
			end
			
			if(0)
				xx = 2:length(X)-1;
				Fit_Object = fit(xx',Ri(xx)','smoothingspline','smoothingparam',.6);
				Ri(xx) = transpose(Fit_Object(xx));
			end
			
			Cxy = 1 ./ Ri;
			SxS = X;
			SyS = Y;
			xx = 1:length(Cxy);
		case 2
			[X,Y] = Smooth_Points(X,Y,5);
			Cxy = nan(1,length(X));
			for i=2:length(X)-1 % For each point (end-points NOT included).
				
				Pi = [X(i) , Y(i) , 0];
				P1 = [X(i-1) , Y(i-1) , 0];
				P2 = [X(i+1) , Y(i+1) , 0];
				
				V1 = Pi - P1;
				V2 = P2 - Pi;
				
				t = atan2(V2(2) - V1(2) , V2(1) - V1(1));
				s1 = Distance_Func(P1(1),P1(2),Pi(1),Pi(2));
				s2 = Distance_Func(Pi(1),Pi(2),P2(1),P2(2));
				
				% Ri = 4*(1 - cos(t))/(s1+s2);
				Ri = 2*(1 - cos(t))*(1/s1+1/s2);
				
				Cxy(i) = Ri;
				% Cxy(i) = 1 / Ri;
			end
			SxS = X;
			SyS = Y;
			xx = 1:length(Cxy);
			yy = Cxy(2:end-1);
		
			if(0) % && all(~isnan(yy)) && all(~isinf(yy)))
				xf = xx(2:end-1);
				Fit_Object = fit(xf',yy','smoothingspline','smoothingparam',.6);
				Cxy(xf) = transpose(Fit_Object(xf));
			end
			% Cxy = Cxy.^(0.5);
		case 3
			
			Smoothing_Parameter = 100;
			Eval_Points_Num = length(X); % TODO: normalize to the original number of points.
			
			% 1. Smooth the curve using a smoothing parameter that determines the resolution of the desired curvature:
			u = smoothn(num2cell([X',Y'],1),Smoothing_Parameter);
			Suxy = horzcat(u{:});
			SxS = Suxy(:,1)'; % Smoothed x-coordinates.
			SyS = Suxy(:,2)'; % Smoothed y-coordinates.
			
			% SxS = X;
			% SyS = Y;
			
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
			
			% if(any(Cxy < 10^(-2)))
			% 	disp(1);
			% end
			
			xx = 1:length(Cxy);
	end
	
	Mean_Curvature = mean(Cxy);
	
	function Ri = Get_Radius_Of_Curvature(pi,p1,p2)
		D = cross(p1-pi,p2-pi);
		a = norm(p1-p2);
		b = norm(pi-p2);
		c = norm(pi-p1);
		Ri = (a*b*c/2) / norm(D);
	end
	
	function [X,Y] = Smooth_Points(X,Y,Smoothing_Parameter) % X=[1,n]. Y=[1,n].
		Eval_Points_Num = length(X); % TODO: normalize to the original number of points.
		
		u = smoothn(num2cell([X',Y'],1),Smoothing_Parameter);
		Suxy = horzcat(u{:});
		X = Suxy(:,1)'; % Smoothed x-coordinates.
		Y = Suxy(:,2)'; % Smoothed y-coordinates.
	end
	
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