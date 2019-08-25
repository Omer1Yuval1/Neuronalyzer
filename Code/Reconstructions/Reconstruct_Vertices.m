function Reconstruct_Vertices(W,Display_Image)
	
	Scale_Factor = W.User_Input(1).Scale_Factor;
	% SmoothingParameter = 5000000;
	
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
		% Av = [W.Vertices(v).Rectangles.Angle];
		% if(length(unique(Av)) < length(Av))
			% C = [0,.6,0];
		% else
			% C = [.8,0,0];
		% end
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
	end
	% hold on;
	% for s=1:numel(W.Segments)
		% plot(W.Segments(s).Skel_X,W.Segments(s).Skel_Y,'k');
	% end
end