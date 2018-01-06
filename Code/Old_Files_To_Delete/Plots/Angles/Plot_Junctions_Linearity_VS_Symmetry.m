function Plot_Junctions_Linearity_VS_Symmetry(GUI_Parameters)
	
	% assignin('base','GUI_Parameters',GUI_Parameters);
	
	% Features_Buttons_Handles
	
	Features = unique([[GUI_Parameters.Workspace.Genotype]' , [GUI_Parameters.Workspace.Crowding]'],'rows');
	% assignin('base','Features',Features);
	ColorMap = hsv(size(Features,1)); % hsv; % colorcube;
	% L = 0;
	for g=1:size(Features,1) % For each group.
		
		F1 = find([GUI_Parameters.Workspace.Genotype] == Features(g,1) & [GUI_Parameters.Workspace.Crowding] == Features(g,2));
		
		for w=1:length(F1) % For each image within group g.
			F2 = find([GUI_Parameters.Workspace(F1(w)).Workspace.Vertices.Num_of_Branches] == 3);
			Sym = [GUI_Parameters.Workspace(F1(w)).Workspace.Vertices(F2).Symmetry];
			Lin = [GUI_Parameters.Workspace(F1(w)).Workspace.Vertices(F2).Linearity];
			assignin('base','Sym',Sym);
			% Sym(find(Sym==0)) = [];
			% Sym = [Sym(1:2:end-1)' , Sym(2:2:end)'];
			
			% plot(Sym(1:2:end-1),Lin,'.','MarkerSize',15,'MarkerFaceColor',ColorMap(g,:));
			% plot(Sym(1:2:end-1)./Sym(2:2:end),Lin/pi,'.','MarkerSize',15,'MarkerFaceColor',ColorMap(g,:));
			plot(Sym(1:2:end-1),Lin/pi,'.','MarkerSize',15,'MarkerFaceColor',ColorMap(g,:));
			% hold on;
			
			% L = L + length(Sym(1:2:end-1));
			% if(length(find([Sym(1:2:end-1)] > 3)))
				% disp(g);
				% disp(w);
			% end
			
		end		
	end
	% disp(L);
	
	set(gca,'FontSize',24);
	xlabel('Symmetry (ratio of two closest angles)','FontSize',28);
	ylabel('Linearity (angle closest to pi)','FontSize',28);
	
end