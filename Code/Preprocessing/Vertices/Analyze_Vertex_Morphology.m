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
	Vr = .1:.01:5; % Radii (of increasing concentric circles) vector for junction center detection.
	N = 500*Scale_Factor;
	Min_Center_Radius = 4*Scale_Factor;
	Theta = linspace(0,2*pi,N);
	Center_Frame_Size = 4*Scale_Factor; % [6.5]. Neighborhood to test new potential centers around the approximated center. ~2.3 pixels for Scale_Factor=50/140.
	Centers_Scan_Res = .25*Scale_Factor; % vertical\horizontal distance between potential centers. ~0.35 pixels for Scale_Factor=50/140.
	Im_Cropped_Half_Size = 30*Scale_Factor; % 30 micrometers.
	
	if(Plot1)
		[Yb,Xb] = find(Im_branchpoints);
		% close all;
		figure(1);
		imshow(Im_BW);
		set(gca,'YDir','normal');
		hold on;
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
		if(Vertices(i).Order >= 3) % If it's a junction.
			[New_Cxy,Rc] = Find_Vertex_Center(Im_BW,Vertices(i).Coordinate,Theta,Vr,Center_Frame_Size,Centers_Scan_Res,Im_Rows,Min_Center_Radius);
		elseif(Vertices(i).Order == 1) % If it's a tip.
			New_Cxy = Vertices(i).Coordinate; % Do not correct the center of end-point.
			Rc = 0; % Vertex center radius. Tips are assigned with a 0 radius.
		end
		Rectangles = Find_Vertex_Angles(Im_BW,New_Cxy,Rc,Scale_Factor,Vertices(i).Order,Im_Rows,Im_Cols);
		Vertices(i).Coordinate = New_Cxy;
		Vertices(i).Rectangles = Rectangles;
		Vertices(i).Center_Radius = Rc;
		
		% assignin('base','Rectangles',Rectangles);		
		if(Plot1 && numel(Rectangles) == 0)
			disp(['No peaks found for vertex ',num2str(Vertices(i).Vertex_Index)]);
		end
	end
	
	% assignin('base','Vertices1',Vertices);
end