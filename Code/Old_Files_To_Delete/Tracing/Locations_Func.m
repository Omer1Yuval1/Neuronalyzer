function Looped_To_Step = Locations_Func(Locations_Mat,Step_Parameters,Parameters1)
	
	OverLap_Min_Distance = Parameters1.Auto_Tracing_Parameters.OverLap_Min_Distance;
	N = ceil(Parameters1.Auto_Tracing_Parameters.OverLap_Min_Distance/Step_Parameters.Step_Length); % N = 2;
	Pxy = [Step_Parameters.Step_Coordinates(1),Step_Parameters.Step_Coordinates(2)];
	Looped_To_Step = 0;
	
	% Find the Closest point (in Locations_Mat) to the current point:
	D = N*Step_Parameters.Step_Length;
	for y=floor(max(1,Pxy(2)-N*Step_Parameters.Step_Length)): ...
			ceil(min(size(Locations_Mat,1),Pxy(2)+N*Step_Parameters.Step_Length))
		for x=floor(max(1,Pxy(1)-N*Step_Parameters.Step_Length)): ...
				ceil(min(size(Locations_Mat,2),Pxy(1)+Step_Parameters.Step_Length))
			D1 = ((y-Pxy(2))^2+(x-Pxy(1))^2)^0.5;
			if(Locations_Mat(y,x) > 0 && Locations_Mat(y,x) < Step_Parameters.Step_Index-ceil(OverLap_Min_Distance/Step_Parameters.Step_Length) && D1 < D)
				Looped_To_Step = Locations_Mat(y,x);
				D = D1;
			end
		end
	end
	
end