function Workspace = Classify_Branches(Workspace)
	% This function classifies branches according to the "order" convention in the PVD neuron.Branches struct,
	% The result appears a an integer in field called "order" in the Workspace.Branches structure.
	
	CB_Distance_Threshold = 15.*Workspace.User_Input.Scale_Factor;
	
	[Workspace.Branches.Order] = deal(-1);
	
	% Add branches features:
	for b=1:numel(Workspace.Branches)
		L = 0;
		for s=1:length(Workspace.Branches(b).Segments_Indices)
			F1 = find([Workspace.Segments.Segment_Index] == Workspace.Branches(b).Segments_Indices(s));
			L = L + Workspace.Segments(F1).Length;
		end
		Workspace.Branches(b).Length = L;
	end
	
	Workspace = Detect_Primary_Branch(Workspace,5);
	
end