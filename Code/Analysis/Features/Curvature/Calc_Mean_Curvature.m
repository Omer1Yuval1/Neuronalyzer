function [Point_Curvature_Values,Mean_Curvature,Mean_Squared_Curvature] = Calc_Mean_Curvature(X,Y,Steps_Length,Scale_Factor,Parameters)
	
	% This function gets a series of coordinates of a segment.
	% It calculates the radius of curvature at each coordinates,
	% And finally calculates the mean squared curvature of the entire segment.
	% DataSet is a struct containing two fiels - X & Y (coordinates).
	% An additional field is added for the curvature at each coordinate.
	
	% SmoothingParameter = Parameters.Analysis.Curvature.SmoothingParameter;
	s = Parameters.Analysis.Curvature.Distance_From_Tips;
	Mn = round(Parameters.Analysis.Curvature.Sample_Length / mean([Steps_Length])) / Scale_Factor; % Number of steps to use (from each side of the examined point\step), converted to pixels (~5).
	Min_Num_Points = Parameters.Analysis.Curvature.Min_Points_Num;
	
	N = length(X);
	Point_Curvature_Values = zeros(1,N)-1; % Vector of curvature values ("-1" for points where the curvature could not be calculated).
	
	if(N >= 2*s + Min_Num_Points) % At least 3 points are needed for this calculation.
		
		% DataSet_Fit = Fit_And_Smooth(Point_Curvature_Values(:,1)',Point_Curvature_Values(:,2)',Scale_Factor,SmoothingParameter);
		
		for i=(s+1):(N-s-1) % For each starting point (exept the last one).			
			R = Calc_Radius_Of_Curvature([X(max(1,i-Mn):min(N,i+Mn))]',[Y(max(1,i-Mn):min(N,i+Mn))]');
			Point_Curvature_Values(i) = 1/(R*Scale_Factor); % The curvature of coordinate i.
		end
		F1 = find([Point_Curvature_Values(:,3)] > -1);
		if(length(F1) > 0) % If at least one curvature value.
			Mean_Curvature = sum([[Point_Curvature_Values(F1)] .* [Steps_Length(F1)] ]) / sum([Steps_Length(F1)]);
			Mean_Squared_Curvature = sum([[Point_Curvature_Values(F1)].^2 .* [Steps_Length(F1)] ]) / sum([Steps_Length(F1)]);
		else
			Mean_Curvature = -1;
			Mean_Squared_Curvature = -1;
		end
	else
		Mean_Curvature = -1;
		Mean_Squared_Curvature = -1;
	end
	
end