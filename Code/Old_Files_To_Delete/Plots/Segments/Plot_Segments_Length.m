function Plot_Segments_Length(GUI_Parameters)
	
	assignin('base','GUI_Parameters',GUI_Parameters);
	
	% Features_Buttons_Handles
	
	Features = unique([[GUI_Parameters.Workspace.Genotype]' , [GUI_Parameters.Workspace.Grouping]'],'rows');
	% assignin('base','Features',Features);
	ColorMap = hsv(size(Features,1)); % hsv; % colorcube;
	% L = 0;
	Values = [];
	for g=size(Features,1) % For each group.
		F1 = find([GUI_Parameters.Workspace.Genotype] == Features(g,1) & [GUI_Parameters.Workspace.Grouping] == Features(g,2));
		for w=1:length(F1) % For each image within group g.
			F2 = find([GUI_Parameters.Workspace(F1(w)).Workspace.Segments.Length] > 0);
			Values = [Values,[GUI_Parameters.Workspace(F1(w)).Workspace.Segments(F2).Length]];
		end		
	end
	histogram(Values,0:2:50); % ,'Normalization','probability');
	
	set(gca,'FontSize',24);
	xlabel('Segment Length (\mum)','FontSize',28);
	ylabel('Count','FontSize',28);
	xlim([0,50]);
	% title(num2str(g),'Color',[1,1,1]);
end