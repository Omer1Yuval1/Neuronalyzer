function Custom_4_5_Rects_Curvature_VS_Distance_2D_Hist(GUI_Parameters,Visuals,YLabel,Title1)
	
	Curvature_Min_Max = [10^(-2),0.2];
	Medial_Dist_Range = [0,60];
	
	Dist_Func = @(x0,y0,Vx,Vy) ( (Vx-x0).^2 + (Vy-y0).^2).^(.5);
	
	Crowding_Groups = [1,2];
	Genotype_Groups = 1:8;
	Groups = combvec(Crowding_Groups,Genotype_Groups); % [2,N].
	Groups_Num = size(Groups,2);
	
	Groups_Names = num2cell(1:Groups_Num); % Cell array of group names.
	Groups_Struct = struct('Group_ID',{},'Values',{},'Mean',{});
	ColorMap = lines(Groups_Num);
	
	Legend_Handles_Array = zeros(1,Groups_Num);
	
	V1 = []; % Curvature.
	V2 = []; % Medial Distance.
	for g=1:size(Groups,2)
		
		Fg = find([GUI_Parameters.Workspace.Grouping] == Groups(1,g) & [GUI_Parameters.Workspace.Genotype] == Groups(2,g));
		
		for w=1:length(Fg) % For each neuron (=animal).
			
			W = GUI_Parameters.Workspace(Fg(w)).Workspace;
			
			if(isempty(W.Medial_Axis))
				continue;
			end
			
			Scale_Factor = W.User_Input.Scale_Factor;
			
			for s=1:numel(W.Segments)
				if(numel(W.Segments(s).Rectangles) <= 2)
					continue;
				end
				
				R = W.Segments(s).Rectangles;
                
				Rects_Distances = -ones(1,numel(R));
				% [Rect_Curvature,~,~] = Reconstruct_Curvature(W,Curvature_Min_Max(1),Curvature_Min_Max(2),Medial_Dist_Range(1),Medial_Dist_Range(2),1);
				Rect_Curvature = [W.Segments(s).Rectangles.Curvature];
				
				for r=1:numel(R)
					D = Dist_Func(R(r).X,R(r).Y , W.Medial_Fit.X,W.Medial_Fit.Y);
					f1 = find(D == min(D));
					f1 = f1(1);
					
					Cxy = [R(r).X , R(r).Y];
					Rects_Distances(r) = Find_Medial_Distance(Cxy,W.Medial_Axis,Scale_Factor);
				end
				f2 = find(Rect_Curvature >= Curvature_Min_Max(1) & Rect_Curvature <= Curvature_Min_Max(2) & Rects_Distances >= Medial_Dist_Range(1) & Rects_Distances <= Medial_Dist_Range(2));
				% f2 = find(Rect_Curvature >= 0.1 & Rect_Curvature <= 0.4 & Rects_Distances >= 0);
				V1 = [V1 , Rect_Curvature(f2)];
				V2 = [V2 , Rects_Distances(f2)];
			end
			
		end
	end
	
	% histogram(V1,0:.002:.1,'Normalization','probability');
	histogram2(V1,V2,'Normalization','probability','FaceColor','flat');
	
    % set(gca,'XTick',0:pi/6:pi./2,'XTickLabel',0:30:90,'FontSize',16); % 0:pi/3:2*pi
	xlabel('Curvature [1/\mum]','FontSize',20);
	ylabel('Distance [\mum]','FontSize',20);
	zlabel('Probability','FontSize',20);
	
	set(gca,'YColor',Visuals.Active_Colormap(1,:));
	title('Rects Curvature VS Medial Distance','FontSize',22,'Color',Visuals.Active_Colormap(1,:));
	% xlim([0,pi./2]); % xlim([0,pi]);
	xlim([0,Curvature_Min_Max(2)]);
	ylim([0,45]);
	grid on;
	
	function D = Find_Medial_Distance(Cxy,XY_Med,Scale_Factor)
		Dm = Dist_Func(XY_Med(:,1),XY_Med(:,2),Cxy(1),Cxy(2));
		f1 = find(Dm == min(Dm));
		Medial_Distance = Dm(f1(1)); % Minimal distance of the vertex center of the medial axis (= distance along the Y' axis).
		D = Medial_Distance.*Scale_Factor;
	end
end