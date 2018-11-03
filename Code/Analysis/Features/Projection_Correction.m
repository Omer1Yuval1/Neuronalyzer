function Rects = Projection_Correction(Iw,Im,XY_Eval,Cxy,Rects,Ap,Medial_Tangent,Rx,Rz,Scale_Factor,Corrected_Plane_Angle_Func)
	
	% TODO: first 3 arguments are temporary and used only for validation.
	
	Medial_Angle = atan2(Medial_Tangent(2),Medial_Tangent(1)); % TODO: validate.
	
	% disp([Dmin .* Scale_Factor,Ap*180/pi,Medial_Angle*180/pi]);
	
	Rects(end).Medial_Angle_Projected = -1; % Angle of the rectangle with the local tangent of the medial axis.
	Rects(end).Medial_Angle_Corrected = -1; % The same but this time using the corrected angle of the rectangle.
	Rects(end).Angle_Corrected = -1; % The the corrected angle relative to the original x-axis.
	for r=1:numel(Rects) % For each vertex rectangle (~vector).
		Vp = [cos(Rects(r).Angle),sin(Rects(r).Angle),0]; % The actual vecor translated to the origin (still the projected one). The angle is given in radians.
		Vp_M = Vp*Rz(-Medial_Angle); % Rotation (around z) of the vector such that the medial tangent is the new x-axis.		
		
		Ly = Vp(2); % The y-distance of the original vector from x-axis, is the same as the y'-distance of the rotated vector from the medial axis.
		Vr_M = Reconstruct_XY_Projected_Vector(Vp_M,Ap,Ly,Rx); % Returns the corrected\reconstructed vector Vr (Vr_xy_M is Vr_M rotated to the XY plane).
		
		Vr_XY = Vr_M * Rz(Medial_Angle); % Rotate back (around z) so that the original x-axis is the x-axis.
		Vr_XY = Vr_XY * Rx(Ap); % Then rotate around x to get the 3D vector in the XY plane.
		Vr_M_XY = Vr_XY*Rz(-Medial_Angle); % And finally rotate around z back such that the medial axis is the new x-axis.		
		
		Rects(r).Medial_Angle_Projected = mod(atan2(Vp(2) - Medial_Tangent(2) , Vp(1) - Medial_Tangent(1)),2.*pi); % atan2(norm(cross(Vp,Medial_Tangent)), dot(Vp,Medial_Tangent));
		Rects(r).Medial_Angle_Corrected = mod(atan2(Vr_M_XY(2) - Medial_Tangent(2) , Vr_M_XY(1) - Medial_Tangent(1)),2.*pi); % atan2(norm(cross(Vr_M,Medial_Tangent)), dot(Vr_M,Medial_Tangent));
		Rects(r).Angle_Corrected = mod(atan2(Vr_XY(2) - Medial_Tangent(2) , Vr_XY(1) - Medial_Tangent(1)),2.*pi); % atan2(norm(cross(Vr_M,Medial_Tangent)), dot(Vr_M,Medial_Tangent));
		
		%{
		Rects(r).Vr_M = Vr_M;
		Rects(r).Vr_XY = Vr_XY;
		Rects(r).Vr_M_XY = Vr_M_XY;
		% Rects(r).Vr_M_XY = atan2(norm(cross(Vr_M_XY,[1,0,0])), dot(Vr_M_XY,[1,0,0])); % Temporary;
		Rects(r).Vp_M = Vp_M; % Temporary;
		
		% Rects(r).Medial_Angle_Corrected_Global = atan2(norm(cross(Vr,Medial_Tangent)), dot(Vr,Medial_Tangent));
		%}
	end
	
	if(0 && Iw == 4 && numel(Rects) == 3)
		figure(2);
		clf(2);
		set(gcf,'WindowState','maximized');
		
		imshow(Im);
		set(gca,'YDir','normal');
		hold on;
		
		plot(Cxy(1),Cxy(2),'.r','MarkerSize',50);
		
		Colors_Mat = lines(numel(Rects));
		for r=1:numel(Rects)
			% The original rectangles:
			Rect_Width = 5;
			Rect_Length = 10;
			Angle = Rects(r).Angle.*180./pi;
			[XV,YV] = Get_Rect_Vector(Cxy,Angle,Rect_Width,Rect_Length,14);
			plot([XV,XV(1)],[YV,YV(1)],'LineWidth',2,'Color',Colors_Mat(r,:));
			
			%
			% The rectangles rotated such that the medial axis is the new x-axis:
			Angle_M = (Rects(r).Angle + Medial_Angle).*180./pi;
			[XV_M,YV_M] = Get_Rect_Vector(Cxy,Angle_M,Rect_Width,Rect_Length,14);
			plot([XV_M,XV_M(1)],[YV_M,YV_M(1)],'--','LineWidth',2,'Color',Colors_Mat(r,:));
			plot([Cxy(1),Cxy(1)+Rects(r).Vp_M(1).*10],[Cxy(2),Cxy(2)+Rects(r).Vp_M(2).*10],'--k','LineWidth',2,'Color',Colors_Mat(r,:)); % validation also using the Vp_M vector (directly).
			%}
			
			%
			% The corrected 3D vector:
				% plot3([0,Rects(r).Vr_M(1)]+Cxy(1),[0,Rects(r).Vr_M(2)]+Cxy(2),[0,Rects(r).Vr_M(3)],'LineWidth',4,'Color',Colors_Mat(r,:));
				% First a a test to see that if we project the reconstructed vector, we get exactly the same:
					% plot(10.*[0,Rects(r).Vr_M(1)]+Cxy(1),10.*[0,Rects(r).Vr_M(2)]+Cxy(2),'LineWidth',4,'Color',Colors_Mat(r,:));
				% But if instead we rotate it to the XY plane, then we get something slightly different (with bigger difference for angles farther from 0 and 90 (= closer to 45):
					plot(10.*[0,Rects(r).Vr_M_XY(1)]+Cxy(1),10.*[0,Rects(r).Vr_M_XY(2)]+Cxy(2),'LineWidth',2,'Color',Colors_Mat(r,:)); % This time rotated back to the XY plane.
					plot(10.*[0,Rects(r).Vr_XY(1)]+Cxy(1),10.*[0,Rects(r).Vr_XY(2)]+Cxy(2),'LineWidth',4,'Color',Colors_Mat(r,:)); % This time rotated back to the XY plane.
			%}
			
			%{
			% The corrected angle:
			Vr_M_XY = Rects(r).Vr_M_XY.*180./pi;
			[XVr_M_XY,YVr_M_XY] = Get_Rect_Vector(Cxy,Vr_M_XY,Rect_Width,Rect_Length,14);
			plot([XVr_M_XY,XVr_M_XY(1)],[YVr_M_XY,YVr_M_XY(1)],'LineWidth',1,'Color',Colors_Mat(r,:));
			%}
			
			% disp(Rects(r).Vr_M);
		end
		
		% Plot the local tangent vector:
		plot([Cxy(1),Cxy(1)+cos(Medial_Angle).*10],[Cxy(2),Cxy(2)+sin(Medial_Angle).*10],'m','LineWidth',4); % plot([Cxy(1),Cxy(1)+cos(Medial_Angle)],[Cxy(2),Cxy(2)+sin(Medial_Angle)],'.y','MarkerSize',10);
		
		scatter(XY_Eval(1,:),XY_Eval(2,:),30,jet(length(XY_Eval(1,:))),'filled');
		
		axis equal;
		% axis([Cxy(1)+[-30,30],Cxy(2)+[-30,30]]);
		
		if(1)
			disp(1);
		end
	end
end