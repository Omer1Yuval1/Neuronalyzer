function [DataSet,MeanR,MeanR2] = Calc_Mean_Curvature(DataSet,Scale_Factor,Parameters)
	
	% This function gets a series of coordinates of a segment.
	% It calculates the radius of curvature at each coordinates,
	% And finally calculates the mean squared curvature of the entire segment.
	% DataSet is a struct containing two fiels - X & Y (coordinates).
	% An additional field is added for the curvature at each coordinate.
	
	SmoothingParameter = Parameters.Analysis.Curvature.SmoothingParameter;
	s = Parameters.Analysis.Curvature.Distance_From_Tips;
	Mn = round(Parameters.Analysis.Curvature.Sample_Length / mean([DataSet.Length]*Scale_Factor)); % Number of points\steps to use (from each side of the examined point\step). ~5.
	Min_Num_Points = Parameters.Analysis.Curvature.Min_Points_Num;
	
	N = numel(DataSet);
	% [DataSet.Curvature] = deal(-1);
	Vt = [DataSet.Coordinates];
	V = zeros(N,3);
	V(:,1:2) = [Vt(1:2:end-1)',Vt(2:2:end)'];
	
	if(N >= 2*s + Min_Num_Points) % At least 3 points are needed for this calculation.
		
		DataSet_Fit = Fit_And_Smooth(V(:,1)',V(:,2)',Scale_Factor,SmoothingParameter);
		
		for i=(s+1):(N-s-1) % For each starting point (exept the last one).			
			R = Calc_Radius_Of_Curvature([DataSet_Fit(max(1,i-Mn):min(N,i+Mn)).X]',[DataSet_Fit(max(1,i-Mn):min(N,i+Mn)).Y]');
			V(i,3) = 1/(R*Scale_Factor); % The curvature of coordinate i.
		end
		F1 = find([V(:,3)] > -1);
		if(length(F1) > 0) % If at least one curvature value.
			MeanR = sum([[V(F1,3)'] .* [DataSet_Fit(F1).Step_Length] ]) / sum([DataSet_Fit(F1).Step_Length]);
			MeanR2 = sum([[V(F1,3)'].^2 .* [DataSet_Fit(F1).Step_Length] ]) / sum([DataSet_Fit(F1).Step_Length]);
		else
			MeanR = -1;
			MeanR2 = -1;
		end
	else
		MeanR = -1;
		MeanR2 = -1;
	end
	
end