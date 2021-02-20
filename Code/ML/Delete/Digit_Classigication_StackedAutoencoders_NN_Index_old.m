function [deepnet,y,Testing_Frames,Testing_Classes]= Digit_Classigication_StackedAutoencoders_NN_Index()
    
    tmp = matlab.desktop.editor.getActive;
    cd(fileparts(tmp.Filename));
    
	if isunix
		cd ../../..;
	else
		cd ..\..\..;
	end
	
	addpath(genpath(pwd));
	
	Frame_Half_Size = 10; % 10 = 21X21 ; 12 = 25X25 ; 15 = 31X31 ; 7 = 15X15.
	BG_Samples_Num = 20000; % 10,000.
	
	% [Training_Frames,Training_Classes] = Generate_Training_Set3(Frame_Half_Size,BG_Samples_Num);
	[Training_Frames,Training_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,2,2);
	display(1);
	% [Testing_Frames,Testing_Classes] = Generate_Training_Set3(Frame_Half_Size,BG_Samples_Num);
	[Testing_Frames,Testing_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,2,2);
	display(2);
	% [deepnet,y] = CNN_Test3(Training_Frames,Training_Classes,Testing_Frames,Testing_Classes,Frame_Half_Size);
	[deepnet,y] = Digit_Classigication_StackedAutoencoders_NN_Core(Training_Frames,Training_Classes,Testing_Frames,Testing_Classes,Frame_Half_Size);
	
	
end