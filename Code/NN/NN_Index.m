function [Net,y,Test_Frames,Test_Classes]= NN_Index(Architecture,layers)
    
    tmp = matlab.desktop.editor.getActive;
    cd(fileparts(tmp.Filename));
	
	addpath(genpath(pwd));
	
	Frame_Half_Size = 10; % 10 = 21X21 ; 12 = 25X25 ; 15 = 31X31 ; 7 = 15X15.
	BG_Samples_Num = 200000; % 10,000.
	
	switch Architecture
		case 'Autoencoders_NN'
			Image_MAT = 2;
			XY_Cell_Cols = 2;
			% NN_Fun_Name = str2func('Autoencoders_NN');
			[Training_Frames,Training_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Training Set Successfully Generated!');
			[Test_Frames,Test_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Test Set Successfully Generated!');
			[Net,y] = Autoencoders_NN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
		case 'Simple_CNN'
			Image_MAT = 2;
			XY_Cell_Cols = 1;
			% NN_Fun_Name = str2func('Simple_CNN');
			[Training_Frames,Training_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Training Set Successfully Generated!');
			[Test_Frames,Test_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Test Set Successfully Generated!');
			[Net,y] = Simple_CNN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
		case 'HiddenX3_CNN'
			Image_MAT = 1;
			XY_Cell_Cols = 1;
			% NN_Fun_Name = str2func('HiddenX3_CNN');
			[Training_Frames,Training_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Training Set Successfully Generated!');
			[Test_Frames,Test_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Test Set Successfully Generated!');
			[Net,y] = HiddenX3_CNN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
		case 'CNN_CCRCCRP_X3'
			Image_MAT = 1;
			XY_Cell_Cols = 1;
			% NN_Fun_Name = str2func('HiddenX3_CNN');
			[Training_Frames,Training_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Training Set Successfully Generated!');
			[Test_Frames,Test_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Test Set Successfully Generated!');
			[Net,y] = CNN_CCRCCRP_X3(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
		case 'CascadeForwardNet_NN'
			Image_MAT = 1;
			XY_Cell_Cols = 2;
			% NN_Fun_Name = str2func('CascadeForwardNet_NN');
			[Training_Frames,Training_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Training Set Successfully Generated!');
			[Test_Frames,Test_Classes] = Generate_DataSet(Frame_Half_Size,BG_Samples_Num,Image_MAT,XY_Cell_Cols);
			display('Test Set Successfully Generated!');
			[Net,y] = CascadeForwardNet_NN(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
	end
	% [Net,y] = NN_Fun_Name(Training_Frames,Training_Classes,Test_Frames,Test_Classes,Frame_Half_Size);
end