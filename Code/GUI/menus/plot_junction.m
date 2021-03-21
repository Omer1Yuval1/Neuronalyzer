function plot_junction(ax,x,y,angles)
	
	% angles = [pi/4,pi/2,pi];
	angles = sort(angles);
	
	Alpha = 0.5;
	
	CM2 = [0.8,0,0 ; 0,0.8,0 ; 0,0,0.8];
	
	t0 = linspace(0,2*pi,100); % Angle range 1.
	t1 = linspace(angles(1),angles(2),100); % Angle range 1.
	t2 = linspace(angles(2),angles(3),100); % Angle range 2.
	t3 = [linspace(angles(3),2*pi,100) , linspace(0,angles(1),100)]; % Angle range 3.
	
	d = 2; % 3.5.
	
	x1 = d.*[0,cos(t1),0];
	y1 = d.*[0,sin(t1),0];
	
	x2 = d.*[0,cos(t2),0];
	y2 = d.*[0,sin(t2),0];
	
	x3 = d.*[0,cos(t3),0];
	y3 = d.*[0,sin(t3),0];
	
	hold(ax,'on');
	
	patch(ax,x1+x,y1+y,CM2(1,:),'FaceAlpha',Alpha,'EdgeColor','k','LineWidth',2);
	patch(ax,x2+x,y2+y,CM2(2,:),'FaceAlpha',Alpha,'EdgeColor','k','LineWidth',2);
	patch(ax,x3+x,y3+y,CM2(3,:),'FaceAlpha',Alpha,'EdgeColor','k','LineWidth',2);
	
	plot(ax,x + d.*cos(t0) , y + d.*sin(t0),'k','LineWidth',2);
end