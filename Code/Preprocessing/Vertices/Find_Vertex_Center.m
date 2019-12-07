function [New_Cxy,Rc] = Find_Vertex_Center(Im_BW,Cxy,Vr,Circles_X,Circles_Y,Potential_Centers_XY,Im_Rows,Min_Center_Radius)
	
	Plot1 = 0;
	Plot2 = 0;
	Plot3 = 0;
	
	if(Plot1 || Plot2)
		Centers_Scan_Res = 0.3;
		% Centers_Scan_Res = 0.5;
	end
	
	Potential_Centers_XY = Potential_Centers_XY + [Cxy(1) ; Cxy(2)]; % Translate the matrix of potential centers to the current center Cxy.
	
	% Find the indices of the potential centers that has a "1" (white) value in the binary image:
	F = find(Im_BW(sub2ind(size(Im_BW),round(Potential_Centers_XY(2,:)),round(Potential_Centers_XY(1,:)))));
	Cx = Potential_Centers_XY(1,F);
	Cy = Potential_Centers_XY(2,F);
	
	Cr = zeros(1,length(Cy));
	for j=1:length(Cy) % For each potential center.
		
		Circles_Xj = round(Circles_X + Cx(j)); % A matrix of circle coordinates [X,Y].
		Circles_Yj = round(Circles_Y + Cy(j));
		% Cv = round([Circles_X(ri,:)' + Cx(j) , Circles_Y(ri,:)' + Cy(j)]); % A matrix of circle coordinates [X,Y].
		
		Circles_XYj = Im_Rows*(Circles_Xj-1)+Circles_Yj; % [4 x N]. Pixel values of circumference coordinates.
		% Circles_XYj = max(Circles_XYj);
		
		for ri=1:length(Vr) % For each concentric circle of center j.
			if(any(~(Im_BW(Circles_XYj(ri,:))),[1,2])) % If there's is at least one black (background) pixel, stop.
				Cr(j) = Vr(max(1,ri-1)); % Cr(j) = Vr(ri);
				
				if(Plot2 && rand(1,1) >= 0.93 && Cr(j) > 0.1)
					C = rand(1,3);
					hold on;
					% plot(Cx(j),Cy(j),'.','MarkerSize',15,'Color',[.8,0,0]); % The center.
					plot(Cx(j),Cy(j),'.','MarkerSize',15,'Color',C); % The center.
					
					% % viscircles([Cx(j),Cy(j)],r,'Color',[rand(1,1),rand(1,1),0.5]);
					viscircles([Cx(j),Cy(j)],Cr(j),'Color',C);
					for k=0:.3:Cr(j)
						viscircles([Cx(j),Cy(j)],k,'Color',C);
					end
					% plot(Cv(:,1),Cv(:,2),'.','MarkerSize',15);
				end
				break;
			end
		end
	end
	Cm = find(Cr == max(Cr));
	
	if(~isempty(Cm))
		% New_Cxy = [mean([Cx(Cm),Cxy(1)]),mean([Cy(Cm),Cxy(2)])]; % The original center might already be included in Cx,Cy. This gives it more weight.
		New_Cxy = [mean(Cx(Cm)),mean(Cy(Cm))]; % The original center might already be included in Cx,Cy. This gives it more weight.
		Rc = max(max(Cr),Min_Center_Radius); % Take the maximal radius but don't let it be too small (Min_Center_Radius).
	else % No potential centers - all on black pixels.
		New_Cxy = Cxy; % Just use the original center.
		Rc = 0;
	end
	
	if(Plot1)
		plot(Cx,Cy,'.','MarkerSize',15,'Color',[.8,0,0]); % Potential Centers.
		plot(Cxy(1),Cxy(2),'.b','MarkerSize',30); % Approximate center.
		
		%% Cv = [Rc*cos(Theta') + New_Cxy(1) , Rc*sin(Theta') + New_Cxy(2)]; % A vector of circle coordinates.
		%% plot(Cv(:,1),Cv(:,2),'.','MarkerSize',1);
		D = 8;
		axis([Cxy(1)+[-D,+D],Cxy(2)+[-D,+D]]);
	end
	if(Plot2)
		plot(Cxy(1),Cxy(2),'.b','MarkerSize',30); % Approximate center.
		D = 8;
		axis([Cxy(1)+[-D,+D],Cxy(2)+[-D,+D]]);
	end
	
	if(Plot3)
		
		D = 8;
		axis([Cxy(1)+[-D,+D],Cxy(2)+[-D,+D]]);
		
		for k=0:.3:Rc
			viscircles(New_Cxy,k,'Color','r');
		end
		viscircles(New_Cxy,Rc,'Color',[0,0.8,0],'LineWidth',4);
		plot(New_Cxy(1),New_Cxy(2),'.','MarkerSize',30,'Color',[0,0.8,0]); % The new center.
		plot(Cxy(1),Cxy(2),'.','Color',[0.8,0,0],'MarkerSize',30); % Approximate center.
        % viscircles(Cxy,1.5,'Color',[0.8,0,0],'LineWidth',4);
	end
	% assignin('base','Theta',Theta);
	
end