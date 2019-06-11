function Plot_Sliding_Window_Feature(S,Sxy,Feature_Name)
	
	Bin_Size_1 = 10;
	Bin_Size_2 = 30;
	
	switch Feature_Name
		case 'Length'
			M_Dorsal = movmean([S.Dorsal_Length],Bin_Size_1);
			M_Ventral = movmean([S.Ventral_Length],Bin_Size_1);
			
			YL = 'Length [um]';
			TL = 'Neuronal Length within a 20um Sliding Window';
		case 'Radius'
			M_Dorsal = movmean([S.Dorsal_Radius],Bin_Size_1);
			M_Ventral = movmean([S.Ventral_Radius],Bin_Size_1);
			
			YL = 'Radius [um]';
			TL = 'Radius within a 20um Sliding Window';
		end
	
	subplot(2,1,1);
		bar([S.Arc_Length],transpose(M_Dorsal),2.5);
		hold on;
		bar([S.Arc_Length],-transpose(M_Ventral),2.5); % Display ventral values as negative bars.
		
		xlabel('Position along the Primary Branch [um]');
		ylabel(YL);
		title(TL);
		set(gca,'FontSize',16);
		legend({'Dorsal','Ventral'});
	
	subplot(2,1,2);
		F_D = find([Sxy.In_Dorsal]);
		F_V = find([Sxy.In_Ventral]);
		histogram([Sxy(F_D).Medial_Position],0:Bin_Size_2:S(end).Arc_Length);
		hold on;
		histogram([Sxy(F_V).Medial_Position],0:Bin_Size_2:S(end).Arc_Length);
		
		xlabel('Position along the Primary Branch [um]');
		ylabel('Length [um]');
		% title(TL);
		set(gca,'FontSize',16);
		legend({'Dorsal','Ventral'});
end