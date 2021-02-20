function h = plot_line_edge(ax,x,y,W)

    % x = 0:0.1:10;
    % y = sin(x);
	
    xd = gradient(x);
    yd = gradient(y);
	
	Lxy = (xd.^2 + yd.^2).^0.5;
	
	xd = W .* (xd ./ Lxy);
	yd = W .* (yd ./ Lxy);
	
    R1 = rotz(90);
    R2 = rotz(-90);

    Edges1_XY = R1(1:2,1:2) * [xd ; yd];
    Edges2_XY = R2(1:2,1:2) * [xd ; yd];

    Edges_X = [Edges1_XY(1,:) , fliplr(Edges2_XY(1,:))] + [x , fliplr(x)];
    Edges_Y = [Edges1_XY(2,:) , fliplr(Edges2_XY(2,:))] + [y , fliplr(y)];
    
    h = patch(ax,Edges_X,Edges_Y,[0,0.6,0],'FaceAlpha',0.5,'EdgeColor',[0.435,0,0],'LineWidth',2);
end