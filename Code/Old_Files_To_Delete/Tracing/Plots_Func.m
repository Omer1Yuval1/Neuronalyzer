function Plots_Func(Step_Parameters,Peaks_Scores,Parameters1)
	
	MPD = Parameters1.Auto_Tracing_Parameters.Step_Min_Peak_Distance;
	MPP = Parameters1.Auto_Tracing_Parameters.Step_Min_Peak_Prominence;
	
	% Rectangles Scores:
	% if(1)
		% figure(2);
		% clf(2);
		% hold on;
		% plot(Step_Parameters.Curve_Fit(:,1),Step_Parameters.Curve_Fit(:,2),'.r','MarkerSize',20);
		% findpeaks(Step_Parameters.Curve_Fit(:,2),Step_Parameters.Curve_Fit(:,1),'MinPeakProminence',MPP,'MinPeakDistance',MPD,'Annotate','extents'); % 'WidthReference','halfheight'.
		% % plot([-180 180],[min(Step_Parameters.Curve_Fit(:,1)) min(Step_Parameters.Curve_Fit(:,2))],'r');
		% if(~isempty(Step_Parameters.Step_Routes))
			% plot(Step_Parameters.Step_Routes(:,1)-Step_Parameters.Previous_Angle,Step_Parameters.Step_Routes(:,2),'*r','MarkerSize',15);
			% % plot(Step_Parameters.Step_Routes(:,1),Step_Parameters.Step_Routes(:,2),'*r','MarkerSize',15);
			% % plot(Step_Parameters.Step_Routes(:,3),Step_Parameters.Step_Routes(:,2),'*r','MarkerSize',15);
		% else
			% clf(2);
		% end
		% xlim([-180 180]);
		% % axis([-180 180 0 255]);
		% % axis([-180 180 0 1.1]);
		% % title('?','FontSize',20);
		% set(gca,'FontSize',24);
		% xlabel('Rectangle Angle (degrees)','FontSize',24);
		% ylabel('Average pixel value','FontSize',24);
		% hold off;
	% end
	
	% Vertex Trial:
	if(1 && isfield(Peaks_Scores,'Paths'))
	% if(1 && isfield(Peaks_Scores,'Paths'))
		figure(3);
		clf(3);
		hold on;
		for i=1:numel(Peaks_Scores)
			if(size(Peaks_Scores(i).Paths,1) > 1)
				% figure(1), plot(Peaks_Scores(i).Origin(1),Peaks_Scores(i).Origin(2),'o','MarkerSize',5,'MarkerFaceColor',[1 0 1]);
				figure(3), plot(Peaks_Scores(i).Index,Peaks_Scores(i).Score,'o','MarkerSize',10,'MarkerFaceColor',[1 0 1]);
			else
				figure(3), plot(Peaks_Scores(i).Index,Peaks_Scores(i).Score,'o','MarkerSize',10,'MarkerFaceColor',[0 0 0]);
			end
		end
		hold off;
		xlabel('Step Index','FontSize',20);
		ylabel('Step Score','FontSize',20);
	end		
	
end