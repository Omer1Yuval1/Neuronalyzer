function Rects = Projection_Correction(Iw,v,Im,XY_Eval,Cxy,Rects,Ap,Medial_Tangent,Rx,Rz,Scale_Factor,Corrected_Plane_Angle_Func)
	
	% TODO: first 3 arguments are temporary and used only for validation.
	
	Medial_Angle = mod(atan2(Medial_Tangent(2),Medial_Tangent(1)),pi); % Taking the mode to obtain an angle within [0,180].
	
	% disp([Dmin .* Scale_Factor,Ap*180/pi,Medial_Angle*180/pi]);
	
	Rects(end).Angle_Medial = -1; % Angle of the rectangle with the local tangent of the medial axis.
	Rects(end).Angle_Corrected_Medial = -1; % The same but this time using the corrected angle of the rectangle.
	Rects(end).Angle_Corrected = -1; % The the corrected angle relative to the original x-axis.
	for r=1:numel(Rects) % For each vertex rectangle (~vector).
		Vp = [cos(Rects(r).Angle),sin(Rects(r).Angle),0]; % The actual vecor translated to the origin (still the projected one). The angle is given in radians and the vector's origin is [0,0].
		Vp_M = Vp*Rz(Medial_Angle); % Clockwise rotation (around z) of the vector such that the medial tangent is the new x-axis.		
		
		Ly = Vp(2); % The y-distance of the original vector from the x-axis, is the same as the y'-distance of the rotated vector from the medial axis.
		Vr_M = Reconstruct_XY_Projected_Vector(Vp_M,Ap,Ly,Rx); % Returns the corrected\reconstructed vector using the medial axis as the x-axis.
		
		% Vr_XY = Vr_M * Rz(-Medial_Angle); % Rotate back (around z) so that the original x-axis is the x-axis (z-value does not change). This is only used to rotate to the XY plane.
		Vr_M_XY = Vr_M * Rx(Ap); % Now that the cartesian x-axis equals to the medial axis, rotate around x to get the 3D vector in the XY* plane.
		Vr_XY = Vr_M_XY*Rz(-Medial_Angle); % And finally rotate around Z back such that the medial axis is the new x-axis.		
		
		Rects(r).Angle_Medial = mod(atan2(Vp_M(2),Vp_M(1)),2.*pi);
		Rects(r).Angle_Corrected_Medial = mod(atan2(Vr_M_XY(2),Vr_M_XY(1)),2.*pi);
		Rects(r).Angle_Corrected = mod(atan2(Vr_XY(2),Vr_XY(1)),2.*pi);
		
		%{
		Rects(r).Vp = Vp;
		Rects(r).Vp_M = Vp_M;
		Rects(r).Vr_M = Vr_M;
		Rects(r).Vr_XY = Vr_XY;
		Rects(r).Vr_M_XY = Vr_M_XY;
		%}
	end
	
	if(0 && v == 14) % Iw == 4 && numel(Rects) == 3)
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
			
			%{
			Angle = Rects(r).Angle.*180./pi;
			[XV,YV] = Get_Rect_Vector(Cxy,Angle,Rect_Width,Rect_Length,14);
			plot([XV,XV(1)],[YV,YV(1)],'LineWidth',2,'Color',Colors_Mat(r,:));
            %}
			
			%
			% Simply the original angles:
				% Angle = atan2(norm(cross([1,0,0],Rects(r).Vp)), dot([1,0,0],Rects(r).Vp));
				Angle = atan2(Rects(r).Vp(2),Rects(r).Vp(1));
				[XV,YV] = Get_Rect_Vector(Cxy,Angle.*180./pi,Rect_Width,Rect_Length,14);
				plot([XV,XV(1)],[YV,YV(1)],'LineWidth',1,'Color',Colors_Mat(r,:));
                disp([num2str(Rects(r).Angle*180/pi) ,'_______', num2str(Angle*180/pi)]);
			%}
			
            %
			% Simply the original rects rotated such that the medial axis is the new x-axis:
				% Angle = atan2(norm(cross(Rects(r).Vp_M,[1,0,0])), dot(Rects(r).Vp_M,[1,0,0]));
				Angle = mod(atan2(Rects(r).Vp_M(2),Rects(r).Vp_M(1)),2.*pi);
                [XV,YV] = Get_Rect_Vector(Cxy,Angle.*180./pi,Rect_Width,Rect_Length,14);
				plot([XV,XV(1)],[YV,YV(1)],'--','LineWidth',3,'Color',Colors_Mat(r,:));
                disp([num2str(Rects(r).Angle*180/pi) ,'_______', num2str(Angle*180/pi)]);
			%}
			
			%{
			% The corrected 3D vector (such that the medial axis is the new x-axis):
			% **** we project it to the XY plane (by using only the x,y values), so it must look the same as Vp_M.
				Angle = mod(atan2(Rects(r).Vr_M(2),Rects(r).Vr_M(1)),2.*pi);
                [XV,YV] = Get_Rect_Vector(Cxy,Angle.*180./pi,Rect_Width,Rect_Length,14);
				plot([XV,XV(1)],[YV,YV(1)],'LineWidth',1,'Color',Colors_Mat(r,:));
                disp([num2str(Rects(r).Angle*180/pi) ,'_______', num2str(Angle*180/pi)]);
			%}
			
			%
			% The corrected rotated to the XY plane (so z is now 0) (such that the medial axis is the "x"-axis):
				Angle = mod(atan2(Rects(r).Vr_M_XY(2),Rects(r).Vr_M_XY(1)),2.*pi);
                [XV,YV] = Get_Rect_Vector(Cxy,Angle.*180./pi,Rect_Width,Rect_Length,14);
				plot([XV,XV(1)],[YV,YV(1)],'LineWidth',3,'Color',Colors_Mat(r,:));
                disp([num2str(Rects(r).Angle*180/pi) ,'_______', num2str(Angle*180/pi),'_______',num2str((Rects(r).Angle-Angle)*180/pi)]);
			%}
			
            %{
			% The corrected vector, rotated to the XY plane (relative to the original x-axis):
				Angle = mod(atan2(Rects(r).Vr_XY(2),Rects(r).Vr_XY(1)),2.*pi);
                [XV,YV] = Get_Rect_Vector(Cxy,Angle.*180./pi,Rect_Width,Rect_Length,14);
				plot([XV,XV(1)],[YV,YV(1)],'--','LineWidth',3,'Color',Colors_Mat(r,:));
                disp([num2str(Rects(r).Angle*180/pi) ,'_______', num2str(Angle*180/pi)]);
			%}
		end
		
		% Plot the local tangent vector:
		plot([Cxy(1),Cxy(1)+cos(Medial_Angle).*10],[Cxy(2),Cxy(2)+sin(Medial_Angle).*10],'m','LineWidth',4); % plot([Cxy(1),Cxy(1)+cos(Medial_Angle)],[Cxy(2),Cxy(2)+sin(Medial_Angle)],'.y','MarkerSize',10);
		
		scatter(XY_Eval(1,:),XY_Eval(2,:),30,jet(length(XY_Eval(1,:))),'filled');
		
		axis equal;
		Dz = 15
		axis([Cxy(1)+[-Dz,Dz],Cxy(2)+[-Dz,Dz]]);
		
		if(1)
			disp(1);
		end
	end
end