function Construct_Branches(Workspace)
	
	% TODO: before running this function, get rid of untraced segments and update the vertices DB (order and rectnalges).
	
	% This function construct branches from segments.
	% Algorithm:
		% Get rid of segments that are below any of the thresholds (e.g. length threshold) and update the connectivity.
		% Then, for each junction, assign probabilities (normalized scores) to each possible pair based on a weighted list of features.
		% Then connect the pairs with the highest probabilities of being a pair.
		% Define branches.
		% Finally reconnect the excluded segments and link them to a branch.
	
	Length_Threshold = 3; % Micrometers.
	[Segments_Reduced,Vertices_Reduced] = Reduce_Connectivity(Workspace,Length_Threshold);
	
	% Create the probability matrix:
		% TODO: delete the excluded segments and vertices.
		% TODO: generate the probability matrix ([pair,score,vertex]
	for i=1:numel(Vertices_Reduced)
		% TODO: it's possible to have two segments connected to the same two segments. Think about this case.
		C = combntns([Vertices_Reduced(i).Rectangles.Segment_Index],2);
		for j=1:size(C,1) % Assign a probability to each possible pair.
			 = ; % Weighted average of scores. end2end Angles diff, junction angles diff, width.
		end
	end
	
end