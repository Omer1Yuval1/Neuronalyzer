function reconstruct_vertex(vertex_shape,col,row,im)

	vs = vertex_shape;
	row = size(im,1)-row;
	% hold on;
	% imshow(im);
	whitebg('black');
	axis([col-25 col+25 row-25 row+25]);
	set(gca,'YDir','normal');
	for i=1:size(vs,1)
		if(vs(i,2) < 3*pi/2 & vs(i,2) > pi/2) % 2nd & 3rd quadrants.
			xv = linspace(col-50,col);
		else % 1st & 4th quadrants.
			xv = linspace(col,col+50);
		end
		yv = (xv-col).*tan(vs(i,2))+row;
		color1 = order_colormap(vs(i,4));
		hold on;
		plot(xv,yv,'linewidth',4, 'color',color1);
		viscircles([col row],20,'EdgeColor','w');
	end
	hold off;
	% saveas(gcf,'v.tif');
end

% How to use:
% choose row %. For example: n=4.
% Run this:
% reconstruct_vertex(Vertices(n).vertex_shape,Vertices(n).col,Vertices(n).row,Skeletonized_Image);