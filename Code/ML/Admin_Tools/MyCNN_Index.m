function [ConvNet,Accuracy_Struct,Testing_Frames,Testing_Classes] = MyCNN_Index(Test_Mode)
    
    tmp = matlab.desktop.editor.getActive;
    cd(fileparts(tmp.Filename));
    
	if isunix
		cd ../../..;
	else
		cd ..\..\..;
	end
	
	addpath(genpath(pwd));
	
	Params_Struct = struct();

	Params_Struct.Frame_Half_Size = 14; % 10 = 21X21 ; 12 = 25X25 ; 15 = 31X31 ; 7 = 15X15.
	Params_Struct.BG_Samples_Num = 20000; % 10,000.
	
	Params_Struct.Conv_Layer_FilterSize = 4; % =[n,n]. The size of the local\sub regions to which the neurons connect in the input.
	Params_Struct.Conv_Layer_MapSize = 8; % Also called: number of neurons.
	Params_Struct.Conv_Layer_Stride = 1;
	
	Params_Struct.Pool_Size = 5;
	Params_Struct.Pool_Stride = 1;
	
	Params_Struct.Num_of_Classes = 2;
	
	[Training_Frames,Training_Classes] = Generate_DataSet(Params_Struct.Frame_Half_Size,Params_Struct.BG_Samples_Num,2,1);
	display(1);
	[Testing_Frames,Testing_Classes] = Generate_DataSet(Params_Struct.Frame_Half_Size,Params_Struct.BG_Samples_Num,2,1);
	display(2);
	
	switch nargin
		case 0
			[ConvNet,Accuracy_Struct] = MyCNN_Core(Training_Frames,Training_Classes,Testing_Frames,Testing_Classes,Params_Struct);
		case 1
			Accuracy_Struct = struct('Parameters',{},'Accuracy',{});
			Test_Vector = 1; % [1:2:11];
			Accuracy_Struct(length(Test_Vector)).Parameters = [];
			for i=1:length(Test_Vector)
				% Params_Struct.Pool_Size = Test_Vector(i);
				[ConvNet,Accuracy] = MyCNN_Core(Training_Frames,Training_Classes,Testing_Frames,Testing_Classes,Params_Struct);
				
				Accuracy_Struct(i).Parameters = Params_Struct;
				Accuracy_Struct(i).Accuracy = Accuracy;
				
				display(i);
			end
	end
end