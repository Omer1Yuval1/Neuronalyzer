function Reconstruct_Vertices(W,Display_Image)
	
	Path1 = uigetdir;
	
	Scale_Factor = W.User_Input(1).Scale_Factor;
	% SmoothingParameter = 5000000;
	D = 10;
	[Rows,Cols] = size(W.Image0);
	
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
	
	if(~isnumeric(Path1))
		H = figure(3);
		clf(3);
		imshow(W.Image0);
		set(H,'WindowState','maximized');
		Ax = gca;
	end
	
	CM = lines(10);
	CM2 = [0.8,0,0 ; 0,0.8,0 ; 0,0,0.8];
	for v=1:numel(W.Vertices)
		
		if(W.Vertices(v).Order == 3 && length(W.Vertices(v).Angles) == 3)
			
			O = W.Vertices(v).Coordinate;
			[V,I] = sort([W.Vertices(v).Rectangles.Angle]); % Angles of the neuronal segments forming the junctions.
			
			C = [W.Vertices(v).Rectangles.Segment_Class]; % The Menorah order of each segment forming the junctions.
			C = C(I); % Re-order according to V.
			
			if(v == 13)
				disp(1);
			end
			
			dt = [V(2)-V(1) , V(3)-V(2) , 2*pi-V(3)+V(1)];
			dts = sort(dt);
			Idt = [find(dts == dt(1),1) , find(dts == dt(2),1) , find(dts == dt(3),1)]; % [~,Idt] = sort(dt);
			
			t1 = linspace(V(1),V(2),100);
			t2 = linspace(V(2),V(3),100);
			t3 = [linspace(V(3),2*pi,100) , linspace(0,V(1),100)];
			
			d = 6;
			d1 = 6.4;
			x1 = d.*[0,cos(t1),0]; y1 = d.*[0,sin(t1),0];
			x2 = d.*[0,cos(t2),0]; y2 = d.*[0,sin(t2),0];
			x3 = d.*[0,cos(t3),0]; y3 = d.*[0,sin(t3),0];
			
			if(isnumeric(Path1))
				hold on;
				patch(x1+O(1),y1+O(2),CM2(Idt(1),:),'FaceAlpha',.3,'LineWidth',5);
				patch(x2+O(1),y2+O(2),CM2(Idt(2),:),'FaceAlpha',.3,'LineWidth',5);
				patch(x3+O(1),y3+O(2),CM2(Idt(3),:),'FaceAlpha',.3,'LineWidth',5);
				
				for c=1:length(C)
					if(~isnan(C(c)))
						quiver(O(1),O(2),d1.*cos(V(c)),d1.*sin(V(c)),'Color',CM(C(c),:),'LineWidth',5,'MaxHeadSize',1);
					end
				end
			else
				if(O(1) > D && O(1) < Cols-D && O(2) > D && O(2) < Rows-D)
					if(ismember(W.Vertices(v).Class,[112,233,334,344]))
						delete(findobj(Ax,'-not','Type','image','-and','-not','Type','axes')); % Delete all graphical objects (except for the axes and the image).
						axis(Ax,[round(O(1))+[-D,D],round(O(2))+[-D,D]]);
						
						hold on;
						patch(Ax,x1+O(1),y1+O(2),CM2(Idt(1),:),'FaceAlpha',.3,'LineWidth',5);
						patch(Ax,x2+O(1),y2+O(2),CM2(Idt(2),:),'FaceAlpha',.3,'LineWidth',5);
						patch(Ax,x3+O(1),y3+O(2),CM2(Idt(3),:),'FaceAlpha',.3,'LineWidth',5);
						
						for c=1:length(C)
							if(~isnan(C(c)))
								quiver(Ax,O(1),O(2),d1.*cos(V(c)),d1.*sin(V(c)),'Color',CM(C(c),:),'LineWidth',10,'MaxHeadSize',2);
							end
						end
						export_fig([Path1,filesep,num2str(v),'.tif'],'-tif',gca); % export_fig([Path1,filesep,num2str(v),'.svg'],'-svg',gca);
					end
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