function [DataSet,MeanR,MeanR2,PL] = Curvature_And_Persistence_Length(DataSet,Scale_Factor,SmoothingParameter,Parameters)
	
	Step_Size = Parameters.Persistence_Length.BinSize; % For the persistence length calculation (binning of the contour length).
	s = Parameters.Curvature.Distance_From_Tips;
	Mn = round(Parameters.Curvature.Sample_Length / mean([DataSet.Step_Length])); % Number of points\steps to use (from each side of the examined point\step). ~5.
	Min_Num_Points = Parameters.Curvature.Min_Points_Num;
	
	N = numel(DataSet);
	[DataSet.Curvature] = deal(-1);
	
	if(N >= 2*s + Min_Num_Points) % At least 3 points are needed for this calculation.
		
		DataSet_Fit = Fit_And_Smooth([DataSet(:).X],[DataSet(:).Y],Scale_Factor,SmoothingParameter);
		
		% Points_Array = []; % Create an array of coordinates [Steps Length ; R^2].
		Points_Array = zeros(sum(N - ((s+1):(N-s-1))),2); % Create an array of coordinates [Steps Length ; R^2].
		k = 1;
		for i=(s+1):(N-s-1) % For each starting point (exept the last one).			
			for j=i+1:(N-s)
				k = k +1;
				Points_Array(k,1) = sum([DataSet(i:j-1).Step_Length]); % Contour Length.
				Points_Array(k,2) = ((((DataSet(i).X - DataSet(j).X)^2 + (DataSet(i).Y - DataSet(j).Y)^2)^.5)*Scale_Factor)^2; % R^2. % Pixels converted to micrometers.
			end
			R = Calc_Point_Radius_Of_Curvature([DataSet_Fit(max(1,i-Mn):min(N,i+Mn)).X]',[DataSet_Fit(max(1,i-Mn):min(N,i+Mn)).Y]');
			DataSet(i).Curvature = 1/(R*Scale_Factor);
		end
		% display(Points_Array);
		PL = Calc_Persistence_Length(Points_Array(:,1),Points_Array(:,2),Step_Size);
	else
		PL = -1;
	end
	
	F1 = find([DataSet.Curvature] > -1);
	if(length(F1) > 0)
		MeanR = sum([ [DataSet(F1).Curvature] .* [DataSet_Fit(F1).Step_Length] ]) / sum([DataSet_Fit(F1).Step_Length]);
		MeanR2 = sum([ [DataSet(F1).Curvature].^2 .* [DataSet_Fit(F1).Step_Length] ]) / sum([DataSet_Fit(F1).Step_Length]);
	else
		MeanR = -1;
		MeanR2 = -1;
	end
	
end