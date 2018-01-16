function Vertices = Analyze_Vertex_Morphology(Vertices,Segments,Im_BW,Im_branchpoints,Scale_Factor)
	
	Plot1 = 0;
	
	if(0)
		assignin('base','Vertices0',Vertices);
		assignin('base','Segments0',Segments);
		assignin('base','Im_branchpoints',Im_branchpoints);
		assignin('base','Im_BW',Im_BW);
		assignin('base','Scale_Factor',Scale_Factor);
	end
	
	% TODO: Move to the parameters func:
	[Im_Rows,Im_Cols] = size(Im_BW);
	Vr = .1:.01:5;
	N = 1080*Scale_Factor;
	Min_Center_Radius = 4*Scale_Factor;
	Theta = linspace(0,2*pi,N);
	Center_Frame_Size = 6.5*Scale_Factor; % Neighborhood to test new potential centers around the approximated center. ~2.3 pixels for Scale_Factor=50/140.
	Centers_Scan_Res = 1*Scale_Factor; % vertical\horizontal distance between potential centers. ~0.35 pixels for Scale_Factor=50/140.
	Im_Cropped_Half_Size = 30*Scale_Factor; % 30 micrometers.
	
	if(Plot1)
		[Yb,Xb] = find(Im_branchpoints);
		% close all;
		figure(1);
		hold on;
		imshow(Im_BW);
		set(gca,'YDir','normal');
		% imshow(Input);
		% hold on;
		% plot(Xb,Yb,'.b','MarkerSize',10); % The approximate center.
	end
	
	% Delete_Vertices = [];
	% Segments_Vertices = [Segments.Vertices];
	% Segments_Vertices = [Segments_Vertices(1:2:end-1)' , Segments_Vertices(2:2:end)'];
	
	% parfor i=1:length(Yb) % For each approximate center.
	% for i=1:length(Yb) % For each approximate center.
	% for i=[63] % For each approximate center.
	for i=1:numel(Vertices) % For each approximate center.
		
		% [Yb,Xb] = ind2sub([Im_Rows,Im_Cols],Vertices(i).Coordinate); % Center Coordinate.
		% Segment_Coordinates = [];
		if(Vertices(i).Order >= 3) % If it's a junction.
			[New_Cxy,Rc] = Find_Vertex_Center(Im_BW,Vertices(i).Coordinate,Theta,Vr,Center_Frame_Size,Centers_Scan_Res,Im_Rows,Min_Center_Radius);
		elseif(Vertices(i).Order == 1) % If it's a tip.
			New_Cxy = Vertices(i).Coordinate; % Do not correct the center of end-point.
			Rc = 0; % Vertex center radius. Tips are assigned with a 0 radius.
			
			% S = [Segments.Vertices]; % If it's a tip, extract the coordinates of the corresponding segment.
			% S = [S(1:2:end-1)' , S(2:2:end)'];
			% F = find(S(:,1) == Vertices(i).Vertex_Index | S(:,2) == Vertices(i).Vertex_Index);
			% if(~isempty(F))
				% Segment_Coordinates = Segments(F(1)).Skeleton_Linear_Coordinates;
			% end
		end
		Rectangles = Find_Vertex_Angles(Im_BW,New_Cxy,Rc,Im_Rows,Im_Cols,Scale_Factor,Vertices(i).Order);
		Vertices(i).Coordinate = New_Cxy;
		Vertices(i).Rectangles = Rectangles;
		Vertices(i).Center_Radius = Rc;
		
		% assignin('base','Rectangles',Rectangles);
		
		% if(numel(Rectangles) == 2)
			% Delete_Vertices(end+1) = Vertices(i).Vertex_Index; % Mark vertex for deletion.
		% end
		
		if(Plot1 && numel(Rectangles) == 0)
			disp(['No peaks found for vertex ',num2str(Vertices(i).Vertex_Index)]);
		end
	end
	
	% assignin('base','Vertices1',Vertices);
end