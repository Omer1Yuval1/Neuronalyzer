T0 = 0;
T1 = 0.3;

C = [];
Cm = [];
for s=1:numel(Workspace(1).Workspace.Segments)
	if(~isempty(Workspace(1).Workspace.Segments(s).Rectangles))
		Cs = [Workspace(1).Workspace.Segments(s).Rectangles.Curvature];
		Cs = Cs(Cs >= 0 & Cs <= T);
		C = [C , Cs];
		Cm = [Cm , max(Cs)];
	end
end

figure;
subplot(2,2,[1,3]);
	Reconstruct_Curvature(Workspace.Workspace);
	axis equal;
subplot(2,2,2);
	histogram(C,25);
	xlim([T0,T1]);
	title('Squared Curvature of Segments');
	xlabel('Squared Curvature');
	ylabel('Count');
subplot(2,2,4);
	histogram(Cm,25);
	xlim([T0,T1]);
	title('Max Squared Curvature of Segments');
	xlabel('Squared Curvature');
	ylabel('Count');