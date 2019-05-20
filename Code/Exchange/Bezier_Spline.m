function XYZ = Bezier_Spline(XYZ0,order,Eval_Num)

% function spline(n,order)
%
% Plots the B-slpine-curve of n control-points.
% The control points can be chosen by clicking
% with the mouse on the figure.
%
% COMMAND:  spline(n,order)
% INPUT:    n     Number of Control-Points
%           order Order ob B-Splines
%                 Argument is arbitrary
%                 default: order = 4
%
% Date:     2007-11-28
% Author:   Stefan Hüeber
	
	if(nargin < 3)
		Eval_Num = 1000;
	end
	
	n = size(XYZ0,1); % length(X);
	
	if(n < order)
		display([' !!! Error: Choose n >= order=',num2str(order),' !!!']);
		return;
	end
	
	y = linspace(0,1,Eval_Num);
	T = linspace(0,1,n-order+2);
	
	XYZ = DEBOOR(T,XYZ0,y,order);
	% XYZ = XYZ';
	
	if(0)
		figure(3); clf(3);

		plot3(XYZ0(:,1),XYZ0(:,2),XYZ0(:,3),'k-','LineWidth',2);
		hold on;
		plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'b-','LineWidth',4);
		plot3(XYZ0(:,1),XYZ0(:,2),XYZ0(:,3),'ro','MarkerSize',10,'MarkerFaceColor','r');

		title(['B-Spline-curve with ',num2str(n),' control points of order ',num2str(order)]);
		axis equal; % axis([0 1 0 1]);
		box on;
		
		waitforbuttonpress;
	end
	
	function val = DEBOOR(T,p,y,order)
		
		% function val = DEBOOR(T,p,y,order)
		%
		% INPUT:  T     Stützstellen
		%         p     Kontrollpunkte (nx2-Matrix)
		%         y     Auswertungspunkte (Spaltenvektor)
		%         order Spline-Ordnung
		%
		% OUTPUT: val   Werte des B-Splines an y (mx2-Matrix)
		%
		% Date:   2007-11-27
		% Author: Jonas Ballani
		
		m = size(p,1);
		Ny = length(y);
		X = zeros(order,order);
		Y = zeros(order,order);
		Z = zeros(order,order);
		a = T(1);
		b = T(end);
		T = [ones(1,order-1)*a,T,ones(1,order-1)*b];
		
		val = zeros(Ny,3);
		
		for l=1:Ny % For each spline eval point.
			t0 = y(l);
			id = find(t0 >= T);
			k = id(end);
			if (k > m)
				return;
			end
			X(:,1) = p(k-order+1:k,1);
			Y(:,1) = p(k-order+1:k,2);
			Z(:,1) = p(k-order+1:k,3);
			
			for i=2:order
				for j=i:order
					num = t0-T(k-order+j);
					if(num == 0)
						weight = 0;
						% disp([i,j]);
					else
						s = T(k+j-i+1)-T(k-order+j);
						weight = num/s;
					end
					X(j,i) = (1-weight)*X(j-1,i-1) + weight*X(j,i-1);
					Y(j,i) = (1-weight)*Y(j-1,i-1) + weight*Y(j,i-1);
					Z(j,i) = (1-weight)*Z(j-1,i-1) + weight*Z(j,i-1);
				end
			end
			val(l,1) = X(order,order);
			val(l,2) = Y(order,order);
			val(l,3) = Z(order,order);
		end
	end
end