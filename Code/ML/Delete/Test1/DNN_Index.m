function y = DNN_Index()
	
	if isunix
		cd ../..;
	else
		cd ..\..;
	end
	
	addpath(genpath(pwd));
	
	Frame_Half_Size = 10; % 21X21.
	
	[Training_Frames,Training_Classes] = Generate_Training_Set(Frame_Half_Size);
	display(1);
	[Testing_Frames,Testing_Classes] = Generate_Testing_Set(Frame_Half_Size);
	display(2);
	y = CNN_Test(Training_Frames,Training_Classes,Testing_Frames,Testing_Classes,Frame_Half_Size);
	
	
end