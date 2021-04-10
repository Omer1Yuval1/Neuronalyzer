function [sig_mat_Y,sig_mat_X1,sig_mat_X2] = Get_Sig(ax,sig_mat)
	
	% TODO:
		% when I take the max of other bars, I should also consider their bar+errorbar, not only sig bars.
	
	% The graphics objects for the groups are assumed to be such that the first group is last.
	% Error bars are assumed to be plotted using the errorbar() function with groups corresponding to columns.
	
	% TODO:
		% negative values (in the same bar plot, or as a separate series pointing down, like dorsal-ventral).
		% consider scatter plots (data points).
	
	%{
	Example 1 - bar:
		rng(0);
		ax = gca;
		H = bar(ax,rand(5,4));
		X = cat(1,H(:).XEndPoints);
		Y = cat(1,H(:).YEndPoints);
		hold on;
		errorbar(ax,X',Y',0.05.*rand(size(X')),'Color','k','LineWidth',1.5,'LineStyle','none');
		set(ax,'FontSize',16); xlabel('X'); ylabel('Y');
		sig_mat = zeros(size(X,2),size(X,2),size(X,1),size(X,1));
		sig_mat(2,5,1,1) = 1;
		sig_mat(1,3,1,2) = 2;
		sig_mat(4,5,2,2) = 3;
		sig_mat(3,3,1,3) = 4;
		[sig_mat_Y,sig_mat_X1,sig_mat_X2] = Get_Sig(ax,sig_mat);
		
	% Example 2 - patch:
		rng(0);
		ax = gca;
		H = bar(ax,rand(5,4),'hist');
		X = squeeze(mean(cat(3,H(:).XData),1))';
		Y = squeeze(max(cat(3,H(:).YData),[],1))';
		hold on;
		errorbar(ax,X',Y',0.05.*rand(size(X')),'Color','k','LineWidth',1.5,'LineStyle','none');
		set(ax,'FontSize',16); xlabel('X'); ylabel('Y');
		sig_mat = zeros(size(X,2),size(X,2),size(X,1),size(X,1));
		sig_mat(2,5,1,1) = 1;
		sig_mat(1,3,1,2) = 2;
		sig_mat(4,5,2,2) = 3;
		sig_mat(3,3,1,3) = 4;
		[sig_mat_Y,sig_mat_X1,sig_mat_X2] = Get_Sig(ax,sig_mat);
	%}
	
	% This function...
	% Input arguments:
		% ax: handle of the axis containing the bar plot.
		% sig_mat: a 4D matrix containing the number stars for each possible pair.
			% sig_mat(b1,b2,i,j) contains the # of stars for the comparison between bar b1 in group i and bar b2 in group j.
	% Output arguments:
		% X and Y are matrices containing x,y values of a bar plot, with y-values being the maximum across bars and error-bars.
		% Each row of x and y corresponds to a different group.
	
	dy = 0.05 .* ax.YLim(2); % Distance between significance bars.
	y_star = 0.2*dy; % Distance of stars from their significance bar.
	Star_Font_Size = 20;
	
	% Find x and y positions of the bars:
	H = findall(ax.Children,'Type','bar','-or','Type','patch'); % Find all bar/patch objects.
	H = flipud(H); % The order of the objects is reversed in order to have the left-most group as the first.
	switch(H(1).Type)
		case 'bar'
			X = cat(1,H(:).XEndPoints);
			Y = cat(1,H(:).YEndPoints);
		case 'patch'	
			X = squeeze(mean(cat(3,H(:).XData),1))';
			Y = squeeze(max(cat(3,H(:).YData),[],1))';
	end
	
	% If error bars exist, change the y-values to the upper limit of the error bar:
	He = findall(ax.Children,'Type','ErrorBar'); % Find all error-bar objects.
	if(~isempty(He))
		He = flipud(He); % The order of the objects is reversed in order to have the left-most group as the first.
		Y = Y + cat(1,He(:).YPositiveDelta);
	end
	
	% disp(X);
	% disp(Y);
	
	sig_mat_Y = nan(size(sig_mat)); % Set y-values for each pair (or nan if there isn't any).
	sig_mat_X1 = nan(size(sig_mat)); % Set y-values for each pair (or nan if there isn't any).
	sig_mat_X2 = nan(size(sig_mat)); % Set y-values for each pair (or nan if there isn't any).
	
	for m=0:size(Y,2)-1 % Starting from pairs within the same block (m=0), then pairs in neighboring blocks (m=1), etc.
		for b1=1:size(X,2)
			for b2=1:size(X,2)
				for i=1:size(X,1)
					for j=1:size(X,1)
						if(sig_mat(b1,b2,i,j) > 0) % If a positive number of stars.
							if((b2-b1) == m)
								if(b1 == b2 && i ~= j) % Pairs within the same block are treated differently.									
									V1 = squeeze(sig_mat_Y(b1,b1,i:j,i:j)); % The bars for x-value of b1=b2, groups i:j.
									V2 = Y(i:j,b1); % The bars for x-value of b1=b2, groups i:j.
									
									sig_mat_Y(b1,b1,i,j) = nanmax([V1(:) ; V2(:) ; Y(i,b1) ; Y(j,b1)]) + dy; % Add dy to the maximum of any y-value of these bars (bar, error-bar or significance bar).
									sig_mat_X1(b1,b1,i,j) = X(i,b1);
									sig_mat_X2(b1,b1,i,j) = X(j,b1);
								elseif(b1 ~= b2)
									
									V11 = squeeze(sig_mat_Y(b1,:,i:end,:)); % The bars for block b1, groups i:end.
									V12 = squeeze(sig_mat_Y(:,b1,:,i:end)); % ".
									
									V21 = squeeze(sig_mat_Y(:,b2,:,1:j)); % The bars for block b2, groups 1:j.
									V22 = squeeze(sig_mat_Y(b2,:,1:j,:)); % ".
									
									V31 = squeeze(sig_mat_Y(b1+1:b2-1,:,:,:)); % All bars in between blocks b1 and b2.
									V32 = squeeze(sig_mat_Y(:,b1+1:b2-1,:,:)); % All bars in between blocks b1 and b2.
									
									V13 = Y(i:end,b1); % The bars for block b1, groups i:end.
									V23 = Y(1:j,b2); % The bars for block b2, groups 1:j.
									V33 = Y(:,b1+1:b2-1); % All bars in between blocks b1 and b2.
									
									V = nanmax([V11(:) ; V12(:) ; V13(:) ; V21(:) ; V22(:) ; V23(:) ; V31(:) ; V32(:) ; V33(:)]);
									
									sig_mat_Y(b1,b2,i,j) = nanmax([V ; Y(i,b1) ; Y(j,b2)]) + dy; % Add dy to the maximum of any y-value of these bars (bar, error-bar or significance bar).
									sig_mat_X1(b1,b2,i,j) = X(i,b1);
									sig_mat_X2(b1,b2,i,j) = X(j,b2);
								end
							end
						end
					end
				end
			end
		end
	end
	
	hold(ax,'on');
	% if(nargout == 0) % If no output arguments, plot the significance bars.
		for i=1:numel(sig_mat_Y)
			if(~isnan(sig_mat_Y(i))) % If not NaN, plot the significance bar and the stars.
				x1 = sig_mat_X1(i);
				x2 = sig_mat_X2(i);
				y = sig_mat_Y(i);
				Ns = sig_mat(i); % # of stars.
				
				plot(ax,[x1,x2],[y,y],'k','LineWidth',1.5);
				text(ax,mean([x1,x2]),y+y_star,repmat('*',1,Ns),'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',Star_Font_Size);

			end
		end
	% end
	
end