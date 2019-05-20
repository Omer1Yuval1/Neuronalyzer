function H = Get_Stats_Bars_XY(Y,Pairs)
	
	% Input Arguments
		 % Y is a cell array of vectors.
		 % Pairs is a Nx2 matrix with pairs of indices to apply the statistical test to.
	
	Max_PValue = 0.01;
	PV_Font_Size = 60;
	LineWidth1 = 1;
	
	Bar_Color = [0,0,0];
	
	L = length(Y);
	Axes_Limits = axis;
	I = 20;
	d1 = (Axes_Limits(4) - Axes_Limits(3)) / 20; % The vertical length needed for each bar.
	d2 = (Axes_Limits(4) - Axes_Limits(3)) / 30; % The vertical length needed for each bar.
	M = 0;
	P = zeros(0,8);
	Test_Name = ['T-Test' ; 'U-Test'];
	
	if(nargin < 2)
		Pairs = transpose(combvec(1:L,1:L)); % Nx2.
	end
	
	YMax = 0;
	
	for p=1:size(Pairs,1)
		
		i = Pairs(p,1);
		j = Pairs(p,2);
		
		if(i == j || isempty(Y{i}) || isempty(Y{j}))
			continue;
		end
			
		if(ttest(Y{i}) == 0 && ttest(Y{j}) == 0) % If both distribute normally.
			
			[H_TTEST,PV_TTEST] = ttest2(Y{i},Y{j}); % TTEST.
			
			if(H_TTEST && PV_TTEST <= Max_PValue) % If TTEST is successful and the P-Value is small enough (0.05).
				
				Mean_i = mean(Y{i});
				SD_i = std(Y{i});
				Mean_j = mean(Y{j});
				SD_j = std(Y{j});
				P(end+1,:) = [i,j,PV_TTEST,Mean_i,SD_i,Mean_j,SD_j,1];
				
				M = max(Mean_i+SD_i,Mean_i+SD_i);
				if(M > YMax)
					YMax = M;
				end
				disp('T-Test');
			end
		else
			[PV_MWU,H_MWU] = ranksum(Y{i},Y{j}); % Mann-Whitney.
			
			if(H_MWU && PV_MWU <= Max_PValue) % If Mann-Whitney is successful.
				
				Mean_i = mean(Y{i});
				SD_i = std(Y{i});
				Mean_j = mean(Y{j});
				SD_j = std(Y{j});
				P(end+1,:) = [i,j,PV_MWU,Mean_i,SD_i,Mean_j,SD_j,2];
				
				M = max(Mean_i+SD_i,Mean_i+SD_i);
				if(M > YMax)
					YMax = M;
				end
				disp('U-Test');
			end
		end
	end
	
	% Plot the significance bars:
	S = size(P,1);
	hold on;
	for i=1:S % For each pair.
		if(P(i,3) <= Max_PValue ./ 100)
			% Star1 = '***';
			LineWidth_0 = 3;
		elseif(P(i,3) <= Max_PValue ./ 10)
			% Star1 = '**';
			LineWidth_0 = 2;
		elseif(P(i,3) <= Max_PValue)
			% Star1 = '*';
			LineWidth_0 = 1;
		end
		
		if(P(i,8) == 1)
			LineStyle = '-';
		elseif(P(i,8) == 2)
			LineStyle = '--';
		end
		
		y1 = sum(P(i,[4,5]));
		y2 = sum(P(i,[6,7]));
		H1 = YMax + (i*d1) + (d1/5)*i;
		
		plot(P(i,[1,1,2,2]),[H1-d1,H1,H1,H1-d1],LineStyle,'Color',Bar_Color,'LineWidth',LineWidth_0);
	end
	
	% assignin('base','Groups_Struct',Groups_Struct);
	% assignin('base','P',P);
	
end