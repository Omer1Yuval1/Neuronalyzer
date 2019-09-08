function Reconstruct_Vertices(W,Display_Image)
	
	Path1 = uigetdir;
	
	Scale_Factor = W.User_Input(1).Scale_Factor;
	% SmoothingParameter = 5000000;
	D = 10;
	[R,C] = size(W.Image0);
	
	if(nargin == 2)
		imshow(W.NN_Probabilities);
		hold on;
		
        %{
		if(isfield(W,'Medial_Axis') && ~isempty(W.Medial_Axis))
			Xm = [W.Medial_Axis(:,1)];
			Ym = [W.Medial_Axis(:,2)];
			plot(Xm,Ym,'Color',[.3,.5,.8],'LineWidth',5);
		end
        %}
	end
	
	for v=1:numel(W.Vertices)
		
		if(W.Vertices(v).Order == 3 && length(W.Vertices(v).Angles) == 3)
			
			O = W.Vertices(v).Coordinate;
			V = sort([W.Vertices(v).Rectangles.Angle]);
			
			t1 = linspace(V(1),V(2),100);
			t2 = linspace(V(2),V(3),100);
			t3 = [linspace(V(3),2*pi,100) , linspace(0,V(1),100)];
			
			d = 6;
			x1 = d.*[0,cos(t1),0]; y1 = d.*[0,sin(t1),0];
			x2 = d.*[0,cos(t2),0]; y2 = d.*[0,sin(t2),0];
			x3 = d.*[0,cos(t3),0]; y3 = d.*[0,sin(t3),0];
			
			if(isnumeric(Path1))
				hold on;
				patch(x1+O(1),y1+O(2),[0.8,0,0],'FaceAlpha',.3,'LineWidth',3);
				patch(x2+O(1),y2+O(2),[0,0.8,0],'FaceAlpha',.3,'LineWidth',3);
				patch(x3+O(1),y3+O(2),[0,0,0.8],'FaceAlpha',.3,'LineWidth',3);
			else
				if(O(1) > D && O(1) < C-D && O(2) > D && O(2) < R-D)
					ImC = W.Image0(round(O(2))+[-D:D],round(O(1))+[-D:D]);
					H = figure(3); clf(3);
					imshow(ImC);
                    set(H,'WindowState','maximized');
					hold on;
					patch(x1+D+1,y1+D+1,[0.8,0,0],'FaceAlpha',.3,'LineWidth',3);
					patch(x2+D+1,y2+D+1,[0,0.8,0],'FaceAlpha',.3,'LineWidth',3);
					patch(x3+D+1,y3+D+1,[0,0,0.8],'FaceAlpha',.3,'LineWidth',3);
					export_fig([Path1,filesep,num2str(v),'.tif'],'-tif',gca);
				end
			end
		end
		
		% H = polarhistogram(theta,3);
		%{
		C = lines(numel(W.Vertices(v).Rectangles));
		for r=1:numel(W.Vertices(v).Rectangles)
			O = W.Vertices(v).Rectangles(r).Origin;
			Rect_Width = W.Vertices(v).Rectangles(r).Width ./ Scale_Factor;
			Rect_Length = W.Vertices(v).Rectangles(r).Length ./ Scale_Factor;
			A = W.Vertices(v).Rectangles(r).Angle .* 180 ./ pi;
			
			[XV,YV] = Get_Rect_Vector(O,A,Rect_Width,Rect_Length,14);
			
			plot(W.Vertices(v).Coordinate(1),W.Vertices(v).Coordinate(2),'.','Color',[1,.2,0],'MarkerSize',30); % Orange.
			hold on;
			% plot(XV,YV,'--','Color',C(r,:),'LineWidth',2); % ,'Color',[.9,0,.4].
			plot(XV,YV,'Color',C(r,:),'LineWidth',4); % ,'Color',[.9,0,.4].
			
			if(isfield(W.Vertices(v).Rectangles,'Angle_Corrected') && all([W.Vertices(v).Rectangles(r).Angle_Corrected]))
				Ac = W.Vertices(v).Rectangles(r).Angle_Corrected .* 180 ./ pi;
				[XVc,YVc] = Get_Rect_Vector(O,Ac,Rect_Width,Rect_Length,14);
				plot(XVc,YVc,'Color',C(r,:),'LineWidth',2); % ,'Color',[.9,0,.4].
			end
		end
		%}
	end
	disp('Done');
	% hold on;
	% for s=1:numel(W.Segments)
		% plot(W.Segments(s).Skel_X,W.Segments(s).Skel_Y,'k');
	% end
end