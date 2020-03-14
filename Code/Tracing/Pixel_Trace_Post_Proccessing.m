function [Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints,Im_Skel_Rad] = Pixel_Trace_Post_Proccessing(Im1,Scale_Factor)
	
	% TODO: get params from the Parameters struct.
	
	EndPoint_Min_Distance = 3;
	% Min_Object_Pixel_Size = 30; % 30.
	Min_Object_Size_Ratio = round(10 ./ Scale_Factor); % um to pixels.
	
	
	% Fill "black holes" (isolated black pixels):
	[Hy,Hx] = find(Im1(2:end-1,2:end-1) == 0 & Im1(1:end-2,2:end-1) & ...
						Im1(3:end,2:end-1) & Im1(2:end-1,1:end-2) & Im1(2:end-1,3:end));
	H = sub2ind(size(Im1),Hy+1,Hx+1);
	Im1(H) = 1;
	
	% Skeletonize:
	if(1)
		Im1_thin = bwmorph(Im1,'thin',Inf); % 'skel' \ 'thin'.
		Im_Skel_Rad = 0;
	else
		Better_Skeletonization_Threshold = 20;
		[Im1_thin,Im_Skel_Rad] = skeleton(Im1);
		Im1_thin = bwmorph((Im1_thin > Better_Skeletonization_Threshold),'skel',inf);
	end
	
	% assignin('base','Im1_thin',Im1_thin);
	
	Im1_NoiseReduction = bwareaopen(Im1_thin,Min_Object_Size_Ratio);
	[Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Delete_Short_EndPoints(Im1_NoiseReduction);
	
	% Find white pixels that connect branch-points and delete the branchpoints if they are touching each other:
	% The idea is to avoid the definition of "fake" branch-points along segments.
	
	[Ty,Tx] = find(Im1_NoiseReduction(2:end-1,2:end-1) & (Im1_branchpoints(1:end-2,2:end-1) + ... % Find "black holes".
					Im1_branchpoints(3:end,2:end-1) + Im1_branchpoints(2:end-1,1:end-2) + Im1_branchpoints(2:end-1,3:end)) == 2); % Find neighborhoods that contain more than one branch-point.
	Ty = Ty + 1;
	Tx = Tx + 1;
	for t=1:length(Ty) % For each such pixel.
		% [Yb,Xb] = find(Im1_branchpoints(Ty(t)-1:Ty(t)+1,Tx(t):Tx(t)+1)); % Find the branch-points in the 8-connected neighborhood.
		if(Im1_branchpoints(Ty(t)+1,Tx(t)) && Im1_branchpoints(Ty(t),Tx(t)+1))
			Im1_branchpoints(Ty(t)-1:Ty(t)+1,Tx(t)-1:Tx(t)+1) = 0;
		elseif(Im1_branchpoints(Ty(t)+1,Tx(t)) && Im1_branchpoints(Ty(t),Tx(t)-1))
			Im1_branchpoints(Ty(t)-1:Ty(t)+1,Tx(t)-1:Tx(t)+1) = 0;
		elseif(Im1_branchpoints(Ty(t)-1,Tx(t)) && Im1_branchpoints(Ty(t),Tx(t)-1))
			Im1_branchpoints(Ty(t)-1:Ty(t)+1,Tx(t)-1:Tx(t)+1) = 0;
		elseif(Im1_branchpoints(Ty(t)-1,Tx(t)) && Im1_branchpoints(Ty(t),Tx(t)+1))
			Im1_branchpoints(Ty(t)-1:Ty(t)+1,Tx(t)-1:Tx(t)+1) = 0;
		end
	end
	
	if(0)
		figure;
		imshow(Im1_NoiseReduction);
		Im1_endpoints = bwmorph(Im1_NoiseReduction,'endpoints');
		[Fy,Fx] = find(Im1_endpoints);
		[By,Bx] = find(Im1_branchpoints);
		hold on;
		plot(Fx,Fy,'.r','MarkerSize',15);
		plot(Bx,By,'.g','MarkerSize',15); % Branch-points.
		plot(Hx,Hy,'.b','MarkerSize',15); % "Black Holes".
		plot(Tx,Ty,'.m','MarkerSize',15);
	end

	function [Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Delete_Short_EndPoints(Im1_NoiseReduction)
		Im1_branchpoints = bwmorph(Im1_NoiseReduction,'branchpoints'); % Find the new (reduced) set of branch-points.
		[By,Bx] = find(Im1_branchpoints);
		Im1_Distances = bwdistgeodesic(Im1_NoiseReduction,Bx,By,'quasi'); % Find the distance of each "1" pixel in Im1_Skel to the closest branch-point.
		Im1_endpoints = bwmorph(Im1_NoiseReduction,'endpoints');
		F = find(Im1_endpoints & Im1_Distances < EndPoint_Min_Distance);
		while(length(F))
			Im1_NoiseReduction(F) = 0; % Delete the chosen end-points to be able to find the next set of end-points.
			Im1_branchpoints = bwmorph(Im1_NoiseReduction,'branchpoints'); % Find the new (reduced) set of branch-points.
			[By,Bx] = find(Im1_branchpoints);
			Im1_Distances = bwdistgeodesic(Im1_NoiseReduction,Bx,By,'quasi'); % Find the distance of each "1" pixel in Im1_Skel to the closest branch-point.
			Im1_endpoints = bwmorph(Im1_NoiseReduction,'endpoints');
			F = find(Im1_endpoints & Im1_Distances < EndPoint_Min_Distance);
			% display(1);
		end
	end
	
	function Im1_NoiseReduction = Get_Rid_Of_Black_Holes(Im1_NoiseReduction)
		% This function is currently not is use since I now fill "black holes" before skeletonization which solves the problem.
		% After running this functions I ran this again:
		% [Im1_NoiseReduction,Im1_branchpoints,Im1_endpoints] = Delete_Short_EndPoints(Im1_NoiseReduction);
		[Hy,Hx] = find(Im1_NoiseReduction(2:end-1,2:end-1) == 0 & Im1_NoiseReduction(1:end-2,2:end-1) & ...
						Im1_NoiseReduction(3:end,2:end-1) & Im1_NoiseReduction(2:end-1,1:end-2) & Im1_NoiseReduction(2:end-1,3:end));
		Hy = Hy + 1;
		Hx = Hx + 1;
		for i=1:length(Hy) % Delete white pixels around them that do not touch more than one branch point.
			for y=-1:1
				for x=-1:1
					x1 = Hx(i) + x;
					y1 = Hy(i) + y;
					I = Im1_branchpoints(y1-1:y1+1,x1-1:x1+1);
					if(sum(I(:)) < 2 && Im1_branchpoints(y1,x1) == 0)
						Im1_NoiseReduction(y1,x1) = 0;
					end
				end
			end
			Im1_NoiseReduction(Hy(i),Hx(i)) = 1;
		end % figure; imshow(Im1_NoiseReduction);
	end
	
	if(0)
		figure;
		imshow(Im1_NoiseReduction);
		set(gca,'YDir','normal');
		hold on;
		plot(CBx,CBy,'.');
		
		figure(1);
	end
	
end