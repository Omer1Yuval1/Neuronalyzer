function Plot_Junctions_Symmetry(GUI_Parameters)
	
	assignin('base','GUI_Parameters',GUI_Parameters);
	
	% Features_Buttons_Handles
	
	Features = unique([[GUI_Parameters.Workspace.Genotype]' , [GUI_Parameters.Workspace.Crowding]'],'rows');
	% assignin('base','Features',Features);
	ColorMap = hsv(size(Features,1)); % hsv; % colorcube;
	% L = 0;
	for g=1:size(Features,1) % For each group.
		
		F1 = find([GUI_Parameters.Workspace.Genotype] == Features(g,1) & [GUI_Parameters.Workspace.Crowding] == Features(g,2));
		
		for w=1:length(F1) % For each image within group g.
			F2 = find([GUI_Parameters.Workspace(F1(w)).Workspace.Vertices.Num_of_Branches] == 3);
			A = [GUI_Parameters.Workspace(F1(w)).Workspace.Vertices(F2).Symmetry];
			assignin('base','A',A);
			% A(find(A==0)) = [];
			% A = [A(1:2:end-1)' , A(2:2:end)'];
			
			plot(A(1:2:end-1),A(2:2:end)/pi,'.','MarkerSize',15,'MarkerFaceColor',ColorMap(g,:));
			% hold on;
			
			% L = L + length(A(1:2:end-1));
			% if(length(find([A(1:2:end-1)] > 3)))
				% disp(g);
				% disp(w);
			% end
			
		end		
	end
	% disp(L);
	
	set(gca,'FontSize',24);
	xlabel('Symmetry (ratio of the two closest angles)','FontSize',28);
	ylabel('Angle 3 (the other angle)','FontSize',28);
	
end