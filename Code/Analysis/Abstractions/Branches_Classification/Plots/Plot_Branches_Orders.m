function Plot_Branches_Orders(Workspace)
	
	% This function plots the branches overlayed on the original grayscale image.
	
	cmap = colormap(jet);
	rows = randi(size(cmap,1),[numel(Workspace.Branches),1]);
	
	imshow(Workspace.Image0);
	hold on;
	for b=1:numel(Workspace.Branches)
		if(Workspace.Branches(b).Order == 1)
			C = [.3,.3,.3];
		else
			C = cmap(rows(b),:);
		end
		for si = [Workspace.Branches(b).Segments_Indices]
			sr = find([Workspace.Segments.Segment_Index] == si);
			if(~isempty(sr))
				plot(Workspace.Segments(sr).Skel_X,Workspace.Segments(sr).Skel_Y,'Color',C,'linewidth',3);
			end
		end
	end
	hold off;
	set(gca,'YDir','normal');
end
