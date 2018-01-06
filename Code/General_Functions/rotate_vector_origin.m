function [xv4,yv4] = rotate_vector_origin(xv1,yv1,origin1,angle1)

	% xv, yv are the rectangle vectors. xv1 = [px1 px2 px3 px4 px1]. yv1 = [py1 py2 py3 py4 py1].
	% origin1 is the origin coordinates. origin1 = [x,y].
	% angle1 is the rotation angle in degrees.

	% Translation to the axis origin:
	xv2 = xv1 - origin1(1);
	yv2 = yv1 - origin1(2);
	zv2 = xv2*0;
	
	% Rotation matrix definition:
	% R = rotz(angle1);
	
	% Rotation:
	vxyz2 = [cosd(angle1) -sind(angle1) 0 ; sind(angle1) cosd(angle1) 0 ; 0 0 1]*[xv2 ; yv2 ; zv2];
	xv3 = vxyz2(1,:);
	yv3 = vxyz2(2,:);
	
	% Back-translation to original position:
	xv4 = xv3 + origin1(1);
	yv4 = yv3 + origin1(2);
	
end