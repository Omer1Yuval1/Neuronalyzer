function [XV,YV] = Get_Rect_Vector(O,Angle1,Rect_Width,Rect_Length,Rect_Rotation_Origin)
	
	%	1----------2
	%  14	 0	   |------>
	%	4----------3
	
	% O = [x,y] is the the reference point for the rectangle's coordinates (rotation origin).
	% Angle1: Orientation of the rectangle (relative to the rotation origin) in degrees.
	
	switch Rect_Rotation_Origin
		case 14
			XV = [O(1) O(1)+Rect_Length O(1)+Rect_Length O(1)];
			YV = [O(2)+Rect_Width/2 O(2)+Rect_Width/2 O(2)-Rect_Width/2 O(2)-Rect_Width/2];
			O2(1) = mean([XV(1),XV(4)]);
			O2(2) = mean([YV(1),YV(4)]);
		case 0
			XV = [O(1)-Rect_Length/2 O(1)+Rect_Length/2 O(1)+Rect_Length/2 O(1)-Rect_Length/2];
			YV = [O(2)+Rect_Width/2 O(2)+Rect_Width/2 O(2)-Rect_Width/2 O(2)-Rect_Width/2];			
			O2(1) = mean([XV(1),XV(3)]);
			O2(2) = mean([YV(1),YV(3)]);
		end
	
	% figure(3), plot(XV,YV,'r');
	[XV,YV] = rotate_vector_origin(XV,YV,[O2(1) O2(2)],Angle1);
	% hold on;
	% figure(3), plot(XV,YV,'g');
end