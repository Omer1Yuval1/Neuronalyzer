function [Angle_Corrected,Medial_Angle_Corrected_Diff,Angle_Medial,Angle_Corrected_Medial] = Correct_Projected_Angle(A,A0,At)
	
	% This function...
	% A is the angle to be corrected.
	% A0 is the reference angle (of the corresponding medial point).
	% At is the local tilting angle of the plane.
	
	Vp = [cos(A),sin(A),0]; % The projected direction vector translated to the origin (0,0). The angle A is given in radians.
	
	Vp_M = Vp*rotz(A0); % Clockwise rotation (around z) of the vector such that the tangent of the reference vector is the new x-axis.		
	Ly = Vp(2); % The y-distance of the original vector from the x-axis, is the same as the y'-distance of the rotated vector from the medial axis.
	
	Lz = Ly .* tan(At); % The z-coordinate of the reconstructed vector (that's missing in the projected vector), can be found using the distance from the medial axis (y*) and the rotation angle of the plane (which is x-invariant).
	Vr_M = [Vp(1),Vp(2),Lz]; % The reconstructed vector (with origin at 0).	
	
	% Vr_XY = Vr_M * rotz(-A0); % Rotate back (around z) so that the original x-axis is the x-axis (z-value does not change). This is only used to rotate to the XY plane.
	Vr_M_XY = Vr_M * rotx(At); % Now that the cartesian x-axis equals to the medial axis, rotate around x to get the 3D vector in the XY* plane.
	Vr_XY = Vr_M_XY*rotz(-A0); % And finally rotate around Z back such that the medial axis is the new x-axis.		
	
	Angle_Medial = mod(atan2(Vp_M(2),Vp_M(1)),2.*pi); % A in a coordinate system in which the x-axis points in the direction of the reference vector (A0).
	Angle_Corrected_Medial = mod(atan2(Vr_M_XY(2),Vr_M_XY(1)),2.*pi); % Corrected A in a coordinate system in which the x-axis points in the direction of the reference vector (A0).
	
	Angle_Corrected = mod(atan2(Vr_XY(2),Vr_XY(1)),2.*pi); % A corrected in Cartesian axes.
	
	d = max(A0,Angle_Corrected) - min(A0,Angle_Corrected);
	Medial_Angle_Corrected_Diff = min(d,(2.*pi)-d); % Angle difference between A0 and the corrected A.
end