function Weighted_Counts = Weighted_Histogram(Values,Weights,Edges_Vector,Sum1_Mean2)
	
	Weighted_Counts = zeros(1,length(Edges_Vector)-1);
	
	for i=1:length(Edges_Vector)-1
		F1 = find(Values >= Edges_Vector(i) & Values < Edges_Vector(i+1));
		if(Sum1_Mean2 == 1)
			Weighted_Counts(i) = nansum([Weights(F1)]);
		elseif(Sum1_Mean2 == 2)
			Weighted_Counts(i) = nanmean([Weights(F1)]);
		end
		% Weighted_Counts(i) = sum([abs(Values(F1)) .* Weights(F1)]);
	end
	
end