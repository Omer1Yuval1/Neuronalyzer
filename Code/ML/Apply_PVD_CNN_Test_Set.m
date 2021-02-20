function Apply_PVD_CNN_Test_Set(My_CNN)
	
    % This function gets a trained neural My_CNNwork and a grayscale image and produces a matrix of probabilities.
	% Each pixel in the output matrix contains the probability of the corresponding pixel in the grayscale image of being
	% a neuron pixel or a non-neuron pixel.
	
	% Run examples:
		% Apply_PVD_CNN_Im2Im(PVD_CNN);
	
	S = PVD_CNN_Params();
	Training_Mode = 1;
    Transparency = 0.3;
	
	
	rng('default'); % Reset the random seed.
	
	if(Training_Mode == 1) % Training locally.
		Train_Dir_Input_Old = S.Train_Dir_Input;
		Train_Dir_Output_Old = S.Train_Dir_Output;
		
		Mat_File_Dir = S.Main_Dir;
		
	elseif(Training_Mode == 2)
		Mat_File_Dir = S.HPC_Path;
	end
	
	% Mat_File_Dir = 'E:\Omer\Neuronalizer\Resources\CNN\Results\x5000_x10\';
	% Mat_File_Dir = 'E:\Omer\Neuronalizer\Resources\CNN\Results\x10000_x2\';
	
	T_Set = load([Mat_File_Dir,'T_Set_1'],'T_Set');
	T_Set = T_Set.T_Set;
	
	if(Training_Mode == 1)
		T_Set.Input = strrep(T_Set.Input,Train_Dir_Input_Old,S.Save_Dir_Input);
		
		if(S.Im2Im)
			T_Set.Output = strrep(T_Set.Output,Train_Dir_Output_Old,S.Save_Dir_Output);
		end
	end
	
	I_Set = randperm(size(T_Set,1)); % Random unique permutation of all rows in T_Set.
	I_Threshold = round(S.Test_Set_Ratio .* size(T_Set,1)); % Last index of test set (+1 is the first of the training set).
	
	I_Test = I_Set(1:I_Threshold); % Test set indices.
	I_Ttrain = I_Set((I_Threshold+1):end); % Training set indices.
	
	% Test_Set = T_Set(I_Test,:);
	%% Test_Set = T_Set(I_Ttrain,:);
    Test_Set = T_Set; % Just use all samples as the test set. 
	
    CM = lines(7);
    CM = CM([1,7],:);
    
	H = figure('WindowState','Maximized');
	for i=1:size(Test_Set,1)
		clf(H);
        
        [~,File_Name,~] = fileparts(T_Set{i,1}{:});
        Full_Path = [S.Save_Dir_Test_Set_Path,File_Name];
		
		In = imread(Test_Set{i,1}{:});
		Im_Annotation = logical(imread(Test_Set{i,2}{:}));
		A = labeloverlay(In,Im_Annotation,'Colormap',CM(1,:),'Transparency',Transparency);
		
		[Out0,~] = semanticseg(In,My_CNN);
		Out = false(size(Out0));
		Out(Out0 == 'Neuron') = true;
		B = labeloverlay(In,Out,'Colormap',CM(2,:),'Transparency',Transparency);
		
        if(0) % Save Figure;
            subplot(1,3,1); imshow(In); title('Raw Image'); set(gca,'FontSize',18);

            subplot(1,3,2); imshow(A); title('Annotation (Ground Truth)'); set(gca,'FontSize',18);

            subplot(1,3,3); imshow(B); title('Prediction'); set(gca,'FontSize',18);
            % subplot(1,3,3); imshow(Out); title('Prediction');
            
            if(1)
                [~,File_Name,~] = fileparts(T_Set{i,1}{:});
                print(H,[S.Save_Dir_Test_Set_Path,File_Name,'.png'],'-dpng');
                pause(0.1);
            end
        elseif(1) % Save images.
            imwrite(In,[Full_Path,'_In.png']);
            imwrite(B,[Full_Path,'_Out.png']);
        else
            waitforbuttonpress;
        end
	end
end