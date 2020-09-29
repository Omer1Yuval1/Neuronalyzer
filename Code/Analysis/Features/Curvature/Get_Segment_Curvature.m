function [Mean_Curvature,SxS,SyS,xx,Cxy] = Get_Segment_Curvature(X,Y,Min_Points_Num_Smoothing,Im)
	
	if(nargin == 4) % If an image if provided.
		Plot = 1;
	else
		Plot = 0;
	end
	
	X0 = X;
	Y0 = Y;
	N0 = length(X0);
	L0 = ( sum((X0(2:end) - X0(1:end-1)).^2) + sum((Y0(2:end) - Y0(1:end-1)).^2) );
	
	%{
	% X = linspace(X0(1),X0(end),2*L0);
	% Y = linspace(Y0(1),Y0(end),2*L0);
	%}
	
	if(length(X0) >= Min_Points_Num_Smoothing)
		SP2 = 100; % 50 ./ (L0);
		[X,Y] = Smooth_Points(X0,Y0,SP2);
	end
	
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
	
	Mean_Curvature = mean(Cxy);
	
	function Ri = Get_Radius_Of_Curvature(pi,p1,p2)
		D = cross(p1-pi,p2-pi);
		a = norm(p1-p2);
		b = norm(pi-p2);
		c = norm(pi-p1);
		Ri = (a*b*c/2) / norm(D);
	end
	
	function [X,Y] = Smooth_Points(X,Y,Smoothing_Parameter) % X=[1,n]. Y=[1,n].
		% Eval_Points_Num = length(X); % TODO: normalize to the original number of points.
		
		u = smoothn(num2cell([X',Y'],1),Smoothing_Parameter);
		Suxy = horzcat(u{:});
		X = Suxy(:,1)'; % Smoothed x-coordinates.
		Y = Suxy(:,2)'; % Smoothed y-coordinates.
	end
	
	if(Plot)
		d = 20;
		Colors = Cxy ./ max(Cxy);
		figure(1); clf(1);
		
		subplot(2,2,1);
			imshow(Im);
			axis([mean(X0)+[-d,d],mean(Y0)+[-d,d]]); % axis equal;
			title('Raw Curve');
		subplot(2,2,2);
			imshow(Im);
			hold on;
			plot(X0,Y0,'r','LineWidth',2);
			axis([mean(X0)+[-d,d],mean(Y0)+[-d,d]]); % axis equal;
			title('Original Trace');
		subplot(2,2,3);
			imshow(Im);
			hold on;
			plot(X,Y,'r','LineWidth',2);
			scatter(X,Y,[],[Colors',zeros(length(Colors),1),1-Colors'],'filled');
			axis([mean(X0)+[-d,d],mean(Y0)+[-d,d]]); % axis equal;
			title('Smoothing Spline');
		subplot(2,2,4);
			
		waitforbuttonpress;
	end
end