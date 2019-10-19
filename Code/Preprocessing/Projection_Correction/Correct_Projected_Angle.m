function Corrected_Angle = Correct_Projected_Angle(A,A0,At)
	
	% This function...
	% All angles are given in radians.
	% A is the angle to be corrected (radians) of the rectangle, pointing from the vertex center outside.
	% A0 is the reference angle (of the corresponding midline point).
	% At is the local tilting angle of the plane in the midline coordinates system (the midline is the new x-axis).
		% This local tilted plane intersects with the X-Y plane at the vertex center and the midline axis.
		% This means that on the upper side of the junction (positive midline distance) it goes inside the screen, and on the lower side it comes outside.
		% The vertex center is the rotation origin for rotation around the midline axis.
		
	% Algorithm:
		% 1. Translate the vertex center to the origin [0,0].
		% 2. Find the z-value of the vector on the plane.
			% The plane can be represented by two vectors that lie on it.
			% The tangent is v1. v2 is perpendicular to it in X-Y, and rotated around the tangent to the tilted plane.
			% N = cross(v1,v2); % Normal to the plane.
			% v0 is the rectangle vector.
			% alpha = abs( pi/2 - acos( dot(v0, N)/norm(N)/norm(v0) ) );
		% 3. rotate it back to the X-Y plane by rotating aroung the midline only (use axis-angle representation).
		% 4. 
	
	% The projection always makes the angle smaller than it realy is. The angle is the smallest diff between the rectangle and midline orientation within [0,pi/2].
	% In other words, the orientation of the rectangle relative to the midline always increases as a result of the correction.
	% The bigger the angle ([0,pi/2]), the bigger the y-component and the bigger the tilting angle from the origin of the vetex, but also the smaller the x-component.
	% Altogether, the peak of the error is at pi/4 (45 degrees).
	
	Vt = [cos(A0),sin(A0),0]; % The midline tangent vector.
	
	% TODO: check if this needs to be normalized:
	Rt = axang2rotm([Vt,At]); % [x,y,z,a]. Axis-angle form.
	
	Vt_90 = [cos(A0+pi/2),sin(A0+pi/2),0];
	Vt_N_3D = transpose(transpose(Rt) * transpose(Vt_90)); % Rotate to get another vector that lies on the tilted plane.
	Nt = cross(Vt,Vt_N_3D); % Normal vector to the tilted plane. Also still a normal to the midline tangent because it is rotated around it.
	

	% Dz = dot(Nt,Vr) ./ norm(Nt); % The signed distance between the end of the rect vector and the tilted plane, is the projection of the rectangle vector onto the normal to the plane.
	% Vr_M = [Vr(1),Vr(2),Dz]; % The reconstructed vector (with origin at 0) that lies on the tilted plane.
	
	% Find the vector corresponding to Vr on the plane if it was to be rotate around z only:
	Vr = [cos(A),sin(A),0]; % The vector of the rectangle to be corrected.
	R1 = axang2rotm([0,0,1,-A0]); % Rotation to be in the midline reference axes with the x-axis.
	R2 = axang2rotm([1,0,0,At]); % Rotation of the local plane around x.
	R3 = R1'*R2*R1; % This is equivalent to Rt. But it goes through x-rotation.
	Vr_3D = transpose(transpose(R3) * transpose(Vr)); % A vector the same length as Vr on the tilted plane.
	z-rotation  = [Vr_3D(1),Vr_3D(2),0]; % Projection of Vr_3D by setting z=0.

	Ar = atan2(Vr(2),Vr(1)) - atan2(Vr_2D(2),Vr_2D(1)); % The z-rotation angle needed to align Vr_2D with Vr. Will be used to rotate Vr_3D on the plane around z.
	R4 = axang2rotm([0,0,1,Ar]);
	Vr_3D = transpose(R4 * transpose(Vr_3D)); % This is Vr with the addition of a z-factor that makes it lie on the tilted plane. Their x,y coordinates are equal.
	
	% Finally, rotate Vr_3D back the XY plane using midline rotation:
	Vr_M_XY = transpose(Rt * transpose(Vr_3D)); % Rotate back to the XY plane around the midline vector to obtain the corrected vector.
	
    Corrected_Angle = atan2(Vr_M_XY(2),Vr_M_XY(1)); % The angle of the corrected vector.
    
	if(0)
		figure;
		plot([0,cos(A)],[0,sin(A)],'LineWidth',2); % Rectangle (blue).
		hold on; plot([0,Vt(1)],[0,Vt(2)],'LineWidth',2); % Midline (orange).
		hold on; plot(0,0,'.k','MarkerSize',20);
		hold on; plot([0,Vt_90(1)],[0,Vt_90(2)],'LineWidth',2); % Normal to midline in XY (yellow).
		
		hold on; plot3([0,Vt_N_3D(1)],[0,Vt_N_3D(2)],[0,Vt_N_3D(3)],'--','LineWidth',1); % Normal to the midline in 3D (purple).
		hold on; plot3([0,Nt(1)],[0,Nt(2)],[0,Nt(3)],'--k','LineWidth',2); % Normal to the tilted plane (black). Coming out of the screen.
		
		axis square equal;
		grid on;
		grid minor;
		
		hold on; plot3([0,Vr_3D(1)],[0,Vr_3D(2)],[0,Vr_3D(3)],'r','LineWidth',1);
		hold on; plot3([0,Vr_M_XY(1)],[0,Vr_M_XY(2)],[0,Vr_M_XY(3)],'b','LineWidth',3);
	end
end