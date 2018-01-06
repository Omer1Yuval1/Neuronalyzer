function paths = Choose_Paths(Step_Parameters,Parameters1)
	
	% Curve Fitting:
	fitobject = fit(Step_Parameters.Step_Routes(:,3),Step_Parameters.Step_Routes(:,2),'smoothingspline','SmoothingParam',Parameters1.Auto_Tracing_Parameters.Step_Smoothing_Parameter);
	% fitobject = fit(Step_Parameters.Step_Routes(:,3)-Step_Parameters.Previous_Angle,Step_Parameters.Step_Routes(:,2),'smoothingspline','SmoothingParam',Parameters1.Auto_Tracing_Parameters.Step_Smoothing_Parameter);
	% xvf = linspace(min(Step_Parameters.Step_Routes(:,3)),max(Step_Parameters.Step_Routes(:,3)),1000)-Step_Parameters.Previous_Angle;
	xvf = linspace(min(Step_Parameters.Step_Routes(:,3)),max(Step_Parameters.Step_Routes(:,3)),1000);
	yvf = fitobject(xvf);
	
	[yp,xp,pw,pp] = findpeaks(yvf,xvf,'SortStr','descend','MinPeakProminence',Parameters1.Auto_Tracing_Parameters.Step_Min_Peak_Prominence,'MinPeakDistance',Parameters1.Auto_Tracing_Parameters.Step_Min_Peak_Distance);
	
	if(0)
		figure(2);
		clf(2);
		plot(xvf-Step_Parameters.Previous_Angle,yvf,'LineWidth',5);
		hold on;
		plot(Step_Parameters.Step_Routes(:,3)-Step_Parameters.Previous_Angle,Step_Parameters.Step_Routes(:,2),'.k','MarkerSize',34);
		hold on;
		findpeaks(yvf,xvf-Step_Parameters.Previous_Angle,'SortStr','descend','MinPeakProminence',Parameters1.Auto_Tracing_Parameters.Step_Min_Peak_Prominence,'MinPeakDistance',Parameters1.Auto_Tracing_Parameters.Step_Min_Peak_Distance); % ,'Annotate','extents');
		% hold on;
		% plot(xp,yp,'.r','MarkerSize',20);
		
		set(gca,'FontSize',34,'XTick',-180:60:180)
		xlabel('Angle (degrees)','FontSize',34);
		ylabel('Normalized Score','FontSize',34);
		xlim([-180,180]);
	end
	
	paths = [];
	if(length(xp) > 0) % If the peaks array is not empty.
		paths(:,1) = xp; % Angle (global axis).
		paths(:,2) = yp; % Mean pixel value.
		paths(:,3) = min(abs(mod(xp,360)-Step_Parameters.Previous_Angle),360-abs(mod(xp,360)-Step_Parameters.Previous_Angle)); % The minimum angle difference from the previous main rectangle\route.
		paths(:,4) = pw; % Peak width.
		paths(:,5) = pp; % Peak Prominence.
		paths = sortrows(paths,3); % Sort the paths such that the first path has the most similar orientation relative to the previous step.
	end
end