function [New_Cxy,Rc] = Find_Vertex_Center(Im_BW,Cxy,Theta,Vr,Center_Frame_Size,Centers_Scan_Res,Im_Rows,Min_Center_Radius)
	
	Plot1 = 0;
	Plot2 = 0;
	
	Potential_Centers_X = Cxy(1)-Center_Frame_Size:Centers_Scan_Res:Cxy(1)+Center_Frame_Size;
	Potential_Centers_Y = Cxy(2)-Center_Frame_Size:Centers_Scan_Res:Cxy(2)+Center_Frame_Size;
	
	Potential_Centers_XY = combvec(Potential_Centers_X,Potential_Centers_Y);
	
	% Find the indices of the potential centers that has a "1" (white) value in the binary image:
	F = find(Im_BW(sub2ind(size(Im_BW),round(Potential_Centers_XY(2,:)),round(Potential_Centers_XY(1,:)))));
	Cx = Potential_Centers_XY(1,F);
	Cy = Potential_Centers_XY(2,F);
	
	Cr = zeros(1,length(Cy));
	for j=1:length(Cy) % For each potential center.
		for ri=1:length(Vr) % For each potential center generate a series of circles with increasing radii.
			Cv = [Vr(ri)*cos(Theta') + Cx(j) , Vr(ri)*sin(Theta') + Cy(j)]; % A vector of circle coordinates.
			
			% TODO: I might want to do more than simple rounding to exclude circles that even touch a black pixel.
			Cv = round(Cv); % Cv = [floor(Cv) ; ceil(Cv) ; [floor(Cv(:,1)),ceil(Cv(:,2))] ; [ceil(Cv(:,1)),floor(Cv(:,2))]];
			
			Cv1 = Im_Rows*(Cv(:,1)-1)+Cv(:,2);
			
			if(length(find(Im_BW(Cv1) == 0))) % If there's is at least one black (background) pixel, stop.
				Cr(j) = Vr(max(1,ri-1)); % Cr(j) = Vr(ri);
				
				if(Plot2 && rand(1,1) >= 0 && Cr(j) > 0)
					C = rand(1,3);
					hold on;
					plot(Cx(j),Cy(j),'.','MarkerSize',15,'Color',C); % The center.
					% % viscircles([Cx(j),Cy(j)],r,'Color',[rand(1,1),rand(1,1),0.5]);
					% viscircles([Cx(j),Cy(j)],Cr(j),'Color',C);
					% for k=0:.3:Cr(j)
						% viscircles([Cx(j),Cy(j)],k,'Color',C);
					% end
					% plot(Cv(:,1),Cv(:,2),'.','MarkerSize',15);
				end
				break;
			end
		end
	end
	Cm = find(Cr == max(Cr));
	
	if(length(Cm))
		% New_Cxy = [mean([Cx(Cm),Cxy(1)]),mean([Cy(Cm),Cxy(2)])]; % The original center might already be included in Cx,Cy. This gives it more weight.
		New_Cxy = [mean(Cx(Cm)),mean(Cy(Cm))]; % The original center might already be included in Cx,Cy. This gives it more weight.
		Rc = max(max(Cr),Min_Center_Radius); % Take the maximal radius but don't let it be too small (Min_Center_Radius).
	else % No potential centers - all on black pixels.
		New_Cxy = Cxy; % Just use the original center.
		Rc = 0;
	end
	
	if(Plot1)
		% plot(Cxy(1),Cxy(2),'.b','MarkerSize',30); % Approximate center.
		% plot(Cx,Cy,'.r','MarkerSize',15); % Potential Centers.
		plot(New_Cxy(1),New_Cxy(2),'.r','MarkerSize',30); % The centers.
		for k=0:.3:Rc
			viscircles(New_Cxy,k,'Color','r');
		end
		viscircles(New_Cxy,Rc,'Color','r','LineWidth',4);
		
		%% Cv = [Rc*cos(Theta') + New_Cxy(1) , Rc*sin(Theta') + New_Cxy(2)]; % A vector of circle coordinates.
		%% plot(Cv(:,1),Cv(:,2),'.','MarkerSize',1);
	end
	% assignin('base','Theta',Theta);
	
end