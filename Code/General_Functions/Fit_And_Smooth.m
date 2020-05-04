function [X_Fit,Y_Fit,Success_Flag] = Fit_And_Smooth(Vx,Vy,SmoothingParameter)
	
	Success_Flag = 1;
	
	Angle1 = atan2d(Vy(end)-Vy(1),Vx(end)-Vx(1)); % The angle of the new x-axis.
	[Xr,Yr] = rotate_vector_origin(Vx,Vy,[Vx(1),Vy(1)],-Angle1); % Rotate vector to avoid repeating x-values.
	
	dx = Xr(2:end) - Xr(1:end-1);
	if(~all(dx <= 0) || ~all(dx >= 0))
		Success_Flag = 0;
		X_Fit = Vx;
		Y_Fit = Vy;
		disp('Oops. X vector not increasing nor decreasing. Cannot smooth.');
		return;
	end
	
	Fit_Object = fit(Xr',Yr','smoothingspline','SmoothingParam',SmoothingParameter);
	Fx = differentiate(Fit_Object,Xr);
	
	Yr_Fit = Fit_Object(Xr)';
	[X_Fit,Y_Fit] = rotate_vector_origin(Xr,Yr_Fit,[Xr(1),Yr(1)],Angle1); % Rotate fitted vector back to original orientation.	
	
	%{
	DataSet_Fit = struct();
	for i=1:length(X_Fit) % Also the length of the 1st (Fx) & 2nd (Fxx) derivatives.
		DataSet_Fit(i).X = X_Fit(i);
		DataSet_Fit(i).Y = Y_Fit(i);
		DataSet_Fit(i).Angle = mod(atand(Fx(i)),360);
		
		if(i < length(Xr))
			DataSet_Fit(i).Step_Length = (( (X_Fit(i)-X_Fit(i+1))^2 + (Y_Fit(i)-Y_Fit(i+1))^2 )^0.5)*Scale_Factor;
		else
			DataSet_Fit(i).Step_Length = DataSet_Fit(i-1).Step_Length;
		end
	end
	%}
	
end