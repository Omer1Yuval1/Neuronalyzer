function [D,A,L,phi,out] = Get_Corrected_Cylinder_Params(D0,A0,L0,R4)
	
	% Input arguments:
		% D0 is midline distance (distance of vertex center from closest midline point).
		% A0 is midline orientation (angle relative to tangent of the closest midline point).
		% L0 is the rectangle length.
		% R3 and R4 are the tertiary and quaternary distances from the midline point used for D0 and A (closest midline point to vertex center).
	% Output arguments:
		% D is the rescaling of the radial distance (D0) to [0,1].
		% phi is the conversion of the radial distance ([0,1]) to the cylinder angular coordinate asin([0,1]) = ([-pi/2,+pi/2]).
		% A is the corrected angle.
		% L is the corrected length.
	
	D = D0 ./ R4;
	out = find(abs(D) > 1); % Find points outside the cylinder.
	
	D(out) = nan;
	A0(out) = nan;
	L0(out) = nan;
	
	phi = asin(D); % Signed angle.
	
	% Break the length down into its x and y components:
	Lx = L0 .* cos(A0);
	Ly = L0 .* sin(A0);
	
	Ap = asin(D./1); % Local plane tilting angle. The cylinder radius is 1 because all midline distances are rescaled to be within [-1,+1]. asin(0) = 0. asin(1) = pi/2.
	
	Ly = Ly ./ cos(Ap); % Recover length in the y-direction.
	
	L = ( Lx.^2 + Ly.^2 ).^(0.5); % Recover the full length using Lx and the new Ly.
	
	A = asin(Ly ./ L); % Recover the midline orientation angle. %%% sign(D0) .* 
	
	%{
	Test 1:
		D0 = [Workspace.Workspace.All_Points.Midline_Distance];
		A0 = [Workspace.Workspace.All_Points.Midline_Orientation];
		L0 = [Workspace.Workspace.All_Points.Length];
		R3 = [Workspace.Workspace.All_Points.Half_Radius];
		R4 = [Workspace.Workspace.All_Points.Radius];
		
		[A,L,A0,L0] = Get_Corrected_Length_AND_Orientation(D0,A0,L0,R3,R4);
		
	Test 2:
		D0 = 2*rand(1,10^4) - 1; % [-1,+1].
		A0 = (pi/2) .* rand(1,10^4); % [0,pi/2].
		L0 = 0.5 .* ones(1,10^4); % 0.5.
		
		[A,L,A0,L0] = Get_Corrected_Length_AND_Orientation(D0,A0,L0,R3,R4);
		
	Test 3:
		D0 = 0.5;
		A0 = 45 .* pi ./ 180;
		L0 = 0.5;
		
		[A,L,A0,L0] = Get_Corrected_Length_AND_Orientation(D0,A0,L0,R3,R4);
	%}