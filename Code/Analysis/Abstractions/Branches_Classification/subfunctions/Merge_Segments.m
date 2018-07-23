function Scores = Merge_Segments(Scores)
	
	% This function takes the a structure that contains all segments pairing options (including non-pairing),
	% And uses the pairing scores to determine which of these will be paired.
	% The resulting structure will be used to then merge higher-level pairs into branches (not in this function).
	
	[Scores.Merged] = deal(0);
	V = unique([Scores.Vertices]); % A vector of unique vertex indices. At this point Scores.Vertices contains a single value per row.
	for v=V
		
		F1 = find([Scores.Vertices] == v); % Find all rows in "scores" that correspond to vertex v.
		[S,I] = sort([Scores(F1).Score],'descend');
		F1 = F1(I); % Sort row numbers such that their scores are descending.
		for ri=F1 % For each pairing (or-non pairing) option in vertex v.
			if(Scores(ri).Merged == 0 && Scores(ri).Segment_Index_2 > 0) % If this option has not been treated yet && If it's a pair.
				Scores(ri).Merged = 1;
				F2 = find([Scores(F1).Merged] == 0 & ...
							([Scores(F1).Segment_Index_1] == Scores(ri).Segment_Index_1 | [Scores(F1).Segment_Index_2] == Scores(ri).Segment_Index_1 ...
							| [Scores(F1).Segment_Index_1] == Scores(ri).Segment_Index_2 | [Scores(F1).Segment_Index_2] == Scores(ri).Segment_Index_2));
				[Scores(F1(F2)).Merged] = deal(-1); % Mark for deletion all other options that contain one of two segments.
			end % Note: Single unmerged segments should have Merged=0.
		end
	end
	
	Scores([Scores.Merged] == -1) = [];
end