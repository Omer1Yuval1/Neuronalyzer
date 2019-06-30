function Plot_Sliding_Window_Feature(S,Sxy,Feature_Name)
	
	% S is the sliding window struct.
	% Sxy is a struct that contains all neuron points.
	
	Bin_Size_1 = 10;
	Bin_Size_2 = 30;
	
	L_Dorsal = movmean([S.Dorsal_Length],Bin_Size_1);
	L_Ventral = movmean([S.Ventral_Length],Bin_Size_1);
	
	R_Dorsal = movmean([S.Dorsal_Radius],Bin_Size_1);
	R_Ventral = movmean([S.Ventral_Radius],Bin_Size_1);
	
	subplot(2,1,1);
		bar([S.Arc_Length],transpose(L_Dorsal),2.5);
		hold on;
		bar([S.Arc_Length],-transpose(L_Ventral),2.5); % Display ventral values as negative bars.
		ylabel('Length [um]');
		
		yyaxis right;
		plot([S.Arc_Length],R_Dorsal,'-k','LineWidth',3);
		plot([S.Arc_Length],-R_Ventral,'-k','LineWidth',3);
		ylabel('Radius [um]');
		
		xlabel('Position along the Primary Branch [um]');
		% title('Radius within a 20um Sliding Window');
		set(gca,'FontSize',16);
		legend({'Dorsal','Ventral'});
	
	return;
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