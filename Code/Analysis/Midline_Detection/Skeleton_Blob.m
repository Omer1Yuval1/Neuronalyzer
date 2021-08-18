function [Blob_Skel,xe,ye] = Skeleton_Blob(Blob_Image)
	
	Min_Branch_Length = 300;

	Blob_Skel = bwskel(Blob_Image,'MinBranchLength',Min_Branch_Length);
	
	E = bwmorph(Blob_Skel,'endpoints');
	[ye,xe] = find(E);
	
	if(length(xe) > 2) % If more than two end-points.
		Pb = find(bwmorph(Blob_Skel,'branchpoints')); % Find branch-point pixels.
		
		De = nan(1,length(xe)); % Minimum distance of each end-point from all branch-points.
		for i=1:length(xe) % For each end-point.
			D = bwdistgeodesic(Blob_Skel,xe(i),ye(i)); % Compute the geodesic distances for all pixels in the skeleton image with respect to pixel [xe(i),ye(i)].
			De(i) = min(D(Pb)); % Find the minimum distance of point [xe(i),ye(i)] to a branch-point.
		end
		
		[~,I] = sort(De,'descend'); % Sort distances in decreasing order.
		xe = xe(I);
		ye = ye(I);
		
		for i=3:length(xe) % For each additional end-point.
			Blob_Skel(ye(i),xe(i)) = false;
		end
		
		xe = xe(1:2);
		ye = ye(1:2);
	end
end