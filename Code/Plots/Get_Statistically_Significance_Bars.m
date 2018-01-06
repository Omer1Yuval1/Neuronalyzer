function H = Get_Statistically_Significance_Bars(Groups_Struct,Bar_Color)
	
	Max_PValue = 0.05;
	PV_Font_Size = 60;
	LineWidth1 = 1;
	
	% Bar_Color = [0,0,0];
	
	L = numel(Groups_Struct);
	Axes_Limits = axis;
	I = 20;
	D = (Axes_Limits(4) - Axes_Limits(3)) / I; % The vertical length needed for each bar.
	M = 0;
	Pairs_Array = [];
	Test_Name = ['T-Test' ; 'U-Test'];
	
	for g=unique([Groups_Struct.Category]) % For each category.
		if(L > 1) % At least two groups (in the g-category).
			Pairs_Array = [];
			YMax = 0;
			F1 = find([Groups_Struct.Category] == g); % Find all g-category entries.
			for i=1:length(F1)-1 % For each entry in the g-category (except the last one).
				for j=i+1:length(F1) % Compare to each of the other entries in the g-category.					
					[H_TTEST,PV_TTEST] = ttest2(Groups_Struct(F1(i)).Values,Groups_Struct(F1(j)).Values); % TTEST.
					[PV_MWU,H_MWU] = ranksum(Groups_Struct(F1(i)).Values,Groups_Struct(F1(j)).Values); % Mann-Whitney.
					
					if(ttest(Groups_Struct(F1(i)).Values) == 0 && ttest(Groups_Struct(F1(j)).Values) == 0) % If both distribute normally.
						if(H_TTEST && PV_TTEST <= Max_PValue) % If TTEST is successful and the P-Value is small enough (0.05).
							Pairs_Array(end+1,1) = F1(i); % First in the pair.
							Pairs_Array(end,2) = F1(j); % Second in the pair.
							Pairs_Array(end,3) = PV_TTEST; % P-Value.
							Pairs_Array(end,4) = 1; % T-Test index.
							
							M = max(Groups_Struct(F1(i)).Mean+Groups_Struct(F1(i)).SE,Groups_Struct(F1(j)).Mean+Groups_Struct(F1(j)).SE);
							if(M > YMax)
								YMax = M;
							end
						end
					elseif(H_MWU && PV_MWU <= Max_PValue) % If Mann-Whitney is successful.
						Pairs_Array(end+1,1) = F1(i); % First in the pair.
						Pairs_Array(end,2) = F1(j); % Second in the pair.
						Pairs_Array(end,3) = PV_MWU; % P-Value.
						Pairs_Array(end,4) = 2; % U-Test index.
						
							M = max(Groups_Struct(F1(i)).Mean+Groups_Struct(F1(i)).SE,Groups_Struct(F1(j)).Mean+Groups_Struct(F1(j)).SE);
						if(M > YMax)
							YMax = M;
						end
					end
				end
			end
			
			S = size(Pairs_Array,1);
			hold on;
			for i=1:S % For each pair.
				if(Pairs_Array(i,3) <= 0.0005)
					Star1 = '***';
				elseif(Pairs_Array(i,3) <= 0.005)
					Star1 = '**';
				elseif(Pairs_Array(i,3) <= 0.05)
					Star1 = '*';
				end
				H1 = YMax + (i*D) + (D/5)*i;
				plot([Groups_Struct(Pairs_Array(i,1)).Group_ID,Groups_Struct(Pairs_Array(i,2)).Group_ID],[H1,H1],'Color',Bar_Color,'LineWidth',LineWidth1);
				plot([Groups_Struct(Pairs_Array(i,1)).Group_ID,Groups_Struct(Pairs_Array(i,1)).Group_ID],[H1 - D,H1],'Color',Bar_Color,'LineWidth',LineWidth1);
				plot([Groups_Struct(Pairs_Array(i,2)).Group_ID,Groups_Struct(Pairs_Array(i,2)).Group_ID],[H1 - D,H1],'Color',Bar_Color,'LineWidth',LineWidth1);
				text(mean([Groups_Struct(Pairs_Array(i,1)).Group_ID,Groups_Struct(Pairs_Array(i,2)).Group_ID]),H1+D/2,Star1,'FontSize',PV_Font_Size/2,'Color',Bar_Color,'HorizontalAlignment','center');
				% text(mean([Groups_Struct(Pairs_Array(i,1)).Group_ID,Groups_Struct(Pairs_Array(i,2)).Group_ID]),H1+D/2,num2str(Pairs_Array(i,3)),'FontSize',16,'Color',Bar_Color,'HorizontalAlignment','center');
			end
		end
	end
	
	% assignin('base','Groups_Struct',Groups_Struct);
	% assignin('base','Pairs_Array',Pairs_Array);
	
end