ii = 0;
for w=1:numel(Workspace)
	for v=1:numel(Workspace(w).Workspace.Vertices)
		if(length(Workspace(w).Workspace.Vertices(v).Angles) == 3 && length(Workspace(w).Workspace.Vertices(v).Corrected_Angles) == 3)
			ii = ii + 1;
			Angles(ii).Angles = Workspace(w).Workspace.Vertices(v).Angles;
			Angles(ii).Corrected_Angles = Workspace(w).Workspace.Vertices(v).Corrected_Angles;
			Angles(ii).Class = sort(Workspace(w).Workspace.Vertices(v).Class);
			Angles(ii).Group = Workspace(w).Workspace.User_Input.Features.Genotype;
		end
	end
end