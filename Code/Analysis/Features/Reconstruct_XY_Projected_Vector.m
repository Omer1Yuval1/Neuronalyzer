function Vr = Reconstruct_XY_Projected_Vector(Vp,Ap,Ly,Rx)
	
	% Input:
		% Vp is the projected vector given as a 3D coordinate [x,y,z] (assuming origin at 0).
		% Ap is the rotation angle of the plane in *radians*. The direction (sign) of this angle is from XZ.
		% Rx is a function for the rotation matrix around the x-axis (in radians).
	% Output:
		% Vr is the reconstructed vector.
		% Vr_xy is the reconstructed vector rotated around x to lie on the XZ plane.
	
	Ly = Vp(2);
	Lz = Ly .* tan(Ap); % The z-coordinate of the reconstructed vector (that's missing in the projected vector), can be found using the distance from the medial axis (y*) and the rotation angle of the plane (which is x-invariant).
	
	Vr = [Vp(1),Vp(2),Lz]; % The reconstructed vector (with origin at 0).	
end