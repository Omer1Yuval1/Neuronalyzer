function Scores = Rect_Scan_Generalized(im,Origin0,Angle,Rect_Width,Rect_Length,Rotation_Range,Rotation_Res,Origin_Type,Im_Rows,Im_Cols,Plot0)
	
	if(nargin == 11 && isequal(round(Origin0),round([533.548724265609,515.320512150550]))) % [545.423935392320,517.663121293358]
		Plot0 = 0; % Compatible with image '0'.
	else
		Plot0 = 0;
	end
	
	%	1---------2
	%	|	 |	  ------>
	%	4---------3
	% Origin0 is the rotation origin coordinates (x,y).
	% Angle is angle of the vector (in degrees). The rotation will be around this angle.
	% All the angle variables are in degrees.
	
	Rects_Num = round(Rotation_Range/Rotation_Res); % Number of rectangles (to each side (clockwise\counterclockwise)).
	Scores = zeros(2*Rects_Num+1,2);
	aa = Angle;
	[XV0,YV0] = Get_Rect_Vector(Origin0,Angle,Rect_Width,Rect_Length,Origin_Type);
	
	if(Plot0)
		CM = hsv(Rects_Num+2);
		ii = 0;
		figure; imshow(im);
		set(gca,'unit','normalize');
		set(gca,'position',[0,0,1,1]);
		axis tight; % figure(1);
		set(gca,'YDir','normal');
		delete(findobj(gca,'-not','Type','image','-and','-not','Type','axes')); % Delete all graphical objects (except for the axes and the image).
		
		r = 10;
		axis([Origin0(1)+[-r,+r]+2 , Origin0(2)+[-r,+r]]);
		hold on;
	end
	
	for i=1:2*Rects_Num+1 % Clockwise Rotation around origin0.
		
		if(i <= Rects_Num+1)
			[XV1,YV1] = rotate_vector_origin(XV0,YV0,[Origin0(1) Origin0(2)],Rotation_Res*(i-1));
			Angle = aa + Rotation_Res*(i-1);
		else
			[XV1,YV1] = rotate_vector_origin(XV0,YV0,[Origin0(1) Origin0(2)],-Rotation_Res*(i-Rects_Num-1));		
			Angle = aa - Rotation_Res*(i-Rects_Num-1);
		end
		
		if(any([XV1,YV1] < 1) || any(XV1 > Im_Cols) || any(YV1 > Im_Rows)) % If any of the rectangle's corners is out of the image boundaries.
			Mean_Pixel_Value = 0;
			if(0)
				disp('Image Boundaries Alert. Terminating Segment Tracing');
			end
		else
			Mean_Pixel_Value = Get_Rect_Score(im,[XV1' YV1']); % Average pixel value.
		end
		Scores(i,:) = [Angle,Mean_Pixel_Value]; % i = rect index. Mean_Pixel_Value = rect mean value. Angle = angle (global). abs(Angle-aa) = angle diff with the previous rect.
		
        %
        % Nr = 2*Rects_Num+1;
		if(Plot0) %  && ismember(i,[1,6,11,16,21,26,31,36,41]))
			ii = ii + 1;
			if(i == Rects_Num+1)
				ii = 1;
			end
			h = plot([XV1,XV1(1)],[YV1,YV1(1)],'Color',CM(ii,:),'LineWidth',3);
			h.Color(4) = 0.3;
			
			% plot([XV1,XV1(1)],[YV1,YV1(1)],'--','LineWidth',4);
			% assignin('base','XV1',XV1);
			% assignin('base','YV1',YV1);
        end
        %}
	end
	Scores = sortrows(Scores,1);
	
	if(Plot0)
		plot(Origin0(1),Origin0(2),'.','Color',[0.6,0,0],'MarkerSize',60);
		set(gcf,'Position',[10,50,900,900]);
        
        figure;
        FitObject = fit(Scores(:,1),Scores(:,2),'smoothingspline','SmoothingParam',0.01);
        Scores_Fit(:,1) = linspace(Scores(1,1),Scores(end,1),1000);
        Scores_Fit(:,2) = FitObject(Scores_Fit(:,1));
        
        plot(Scores_Fit(:,1),Scores_Fit(:,2),'Color',[0.8,0,0],'LineWidth',3);
        hold on;
        % plot(Scores(:,1),Scores(:,2),'.k','MarkerSize',20);
        
        [~,Locs] = findpeaks(Scores_Fit(:,2),Scores_Fit(:,1),'MinPeakDistance',15,'SortStr','descend');
        plot(Locs(1).*[1,1],[0,FitObject(Locs(1))],'--','Color',[0.5,0.5,0.5],'LineWidth',3);
        plot(Locs(1),FitObject(Locs(1)),'.','Color',[0.1,0.6,0],'MarkerSize',50);
        
        xlabel(['Angle (',char(176),')']);
        ylabel('Score');
        set(gca,'FontSize',36);
        xlim([min(Scores(:,1))-5,max(Scores(:,1))+5]);
        ylim([min(Scores(:,2))-5,max(Scores(:,2))+5]);
        
        set(gca,'unit','normalize');
        set(gca,'position',[0.11,0.11,0.87,0.88]);
        set(gcf,'Position',[10,50,900,900]);
        grid on; grid minor;
	end
end