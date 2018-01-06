function [Peaks_Scores,Stop1,Max_Score_Step_Num] = Probe_Vertex_Area(Workspace1,Step_Parameters,Locations_Mat)
	
	% TODO: I'm calculating the 1st step of each trial - twice!
	% TODO: improve efficiency.
	% This step came from Step1 and must have at least 2 routes (because of the 'if' condition in Trace1).
	
	% Rect_Length = Step_Parameters.Rect_Length;
	
	Stop1 = 0;
	
	Peaks_Scores = struct('Index',{},'Score',{},'Origin',{},'Paths',{});
	n1 = round(2*Workspace1.Parameters.Auto_Tracing_Parameters.Trial_Steps_Num);
	Peaks_Scores(n1).Index = n1; % TODO: this is problematic since I don't know if the junction is the 1st or last or somewhere in the middle so I don't know the probing "radii".
	
	% 1st trial step:
	pi1 = 1;
	Max_Score_Step_Num = 1;
	Peaks_Scores(1).Index = 1;
	
	% D1P = abs(Step_Parameters.Step_Routes(1,1)-Step_Parameters.Previous_Angle);
	% M1P = min(D1P,360-D1P);
	% S2 = max([Step_Parameters.Step_Routes(2:end,2)]);
	% Peaks_Scores(1).Score = S2*exp(M1P)/100; % Take the best score for 2+ routes and prefer situations in which the angle difference between the main and the previous routes is big.
	Peaks_Scores(1).Score = max([Step_Parameters.Step_Routes(2:end,2)]); % This step came from Step1 and must have at least 2 routes (because of the 'if' condition in Trace1.
	
	Max_Score = Peaks_Scores(1).Score;
	Peaks_Scores(1).Origin = Step_Parameters.Step_Coordinates; % Rectangles origin coordinates [X Y].
	Peaks_Scores(1).Paths = Step_Parameters.Step_Routes;
	
	Step_Parameters.Previous_Angle = Step_Parameters.Step_Routes(1,1); % X
	
	for i=2:n1 % For each trial step.		
		Step_Parameters.Step_Coordinates = [Step_Parameters.Step_Coordinates(1)+Step_Parameters.Step_Length*cosd(Step_Parameters.Previous_Angle) Step_Parameters.Step_Coordinates(2)+Step_Parameters.Step_Length*sind(Step_Parameters.Previous_Angle)]; % New Origin. Translation of the previous point one step (Step_Parameters.Step_Length) forward (without rotation).
		
		Step_Parameters = Step1(Workspace1,Step_Parameters,Locations_Mat);
		
		% Calculate the step's score based on the peaks' properties.
		% TODO: Use and compare (between steps) the distance between the peaks.
		if(Step_Parameters.Stop_Flag ~= 0) % If a stopping condition in Step1 is met, the trial ends. || isempty(Step_Parameters.Step_Routes)
			Stop1 = Step_Parameters.Stop_Flag;
			break; % Stop the trial.
		else
			% Go straight (using the previous step angle).
			Step_Parameters.Previous_Angle = Step_Parameters.Step_Routes(1,1); % X % Update the step's angle variable.
			if(size(Step_Parameters.Step_Routes,1) > 1) % If there are at least 2 peaks.
				% TODO: do not use 'Peaks_Scores1'. just assign the value directly to 'Peaks_Scores'.
				Peaks_Scores1 = max([Step_Parameters.Step_Routes(2:end,2)]); % The step's score is the score of the highest peak (besides the primary peak).
			elseif(size(Step_Parameters.Step_Routes,1) == 1) % If there's 1 peak.
				Peaks_Scores1 = 0;
			end
		end
		
		pi1 = pi1 + 1;
		Peaks_Scores(i).Index = pi1;
		Peaks_Scores(i).Score = Peaks_Scores1;
		if(Peaks_Scores(i).Score > Max_Score)
			Max_Score = Peaks_Scores(i).Score;
			Max_Score_Step_Num = pi1;
		end
		Peaks_Scores(i).Origin = Step_Parameters.Step_Coordinates; % Origin's coordinates.
		Peaks_Scores(i).Paths = Step_Parameters.Step_Routes;
		% Peaks_Scores(i).Fitted_Data = Step_Parameters.Curve_Fit;
		
		if(pi1 >= Workspace1.Parameters.Auto_Tracing_Parameters.Trial_Steps_Num && Max_Score_Step_Num < pi1) % If the trial is in a step >= Workspace1.Parameters.Auto_Tracing_Parameters.Trial_Steps_Num (< n1) and the best score is not in the n-th step, break. Continue only if the best score is the n-th step.
			break;
		end
	end
	
	Peaks_Scores = Peaks_Scores(1:pi1);
	
	for i=1:numel(Peaks_Scores)
		if(i ~= Max_Score_Step_Num) % If not the optimal step (= highest score = vertex center),
			Peaks_Scores(i).Paths = Peaks_Scores(i).Paths(1,:); % Delete all secondary routes.
		end
	end
	
end