function Plot_Sliding_Window_Feature_VS_Medial_Distance(S,Sxy,Feature_Name)
	
	Curvature_Min_Max = [0,0.4];
	
	Bin_Size_X = 50;
	Bin_Size_Y = 2.5;
	Max_Radius = 40; % um;
	
	if(0)
		F_D = find([Sxy.In_Dorsal]);
		F_V = find([Sxy.In_Ventral]);
		histogram2([Sxy(F_D).Medial_Position],[Sxy(F_D).Medial_Distance],0:Bin_Size_X:S(end).Arc_Length,0:Bin_Size_Y:Max_Radius,'FaceColor','flat');
		hold on;
		histogram2([Sxy(F_V).Medial_Position],[Sxy(F_V).Medial_Distance],0:Bin_Size_X:S(end).Arc_Length,-Max_Radius:Bin_Size_Y:0,'FaceColor','flat');
	else
		F_DV = find([Sxy.In_Dorsal] | [Sxy.In_Ventral]);
		[N,Xedges,Yedges] = histcounts2([Sxy(F_DV).Medial_Position],[Sxy(F_DV).Medial_Distance],0:Bin_Size_X:S(end).Arc_Length,0:Bin_Size_Y:Max_Radius);
		
		[X,Y] = meshgrid(linspace(Xedges(1),Xedges(2),size(N,2)),linspace(Yedges(1),Yedges(2),size(N,1)));
		surf(X,Y,N);
	end
	
	xlabel('Medial Position [um]');
	ylabel('Medial Distance [um]');
	% title(TL);
	set(gca,'FontSize',16);
	% legend({'Dorsal','Ventral'});
	
	
	figure;
	
	Bin_Size_X = 0.01;
	
	F_D = find([Sxy.In_Dorsal]);
	F_V = find([Sxy.In_Ventral]);
	histogram2([Sxy(F_D).Curvature],[Sxy(F_D).Medial_Distance],Curvature_Min_Max(1):Bin_Size_X:Curvature_Min_Max(2),0:Bin_Size_Y:Max_Radius,'FaceColor','flat');
	hold on;
	histogram2([Sxy(F_V).Curvature],[Sxy(F_V).Medial_Distance],Curvature_Min_Max(1):Bin_Size_X:Curvature_Min_Max(2),0:Bin_Size_Y:Max_Radius,'FaceColor','flat');
	
	xlim(Curvature_Min_Max);
	xlabel('Curvature [1/um]');
	ylabel('Medial Distance [um]');
	% title(TL);
	set(gca,'FontSize',16);
	% legend({'Dorsal','Ventral'});
end