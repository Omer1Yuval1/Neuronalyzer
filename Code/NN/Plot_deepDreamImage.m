function Plot_deepDreamImage()
	
	Save_Predictions = 0;
	
	D = dir('D:\Omer\Neuronalizer\Resources\CNN\Input_Samples\Good');
	D(find([D.isdir])) = [];
	
	File1 = load('D:\Omer\Neuronalizer\Resources\CNN\Runs\7.mat','My_CNN');
	My_CNN = File1.My_CNN;
	
	% Layers = {'conv_1','conv_2','conv_3','conv_4','conv_5'};
	Channel_Num = 64;
	Channels = 1:25;
	% Layers{2}
	
	%{
	figure(1);
	I = deepDreamImage(My_CNN,'conv_8',Channels,'PyramidLevels',1,'Verbose',0); % 8,9
	I = imtile(I);
	imshow(I);
	%}
	
	%{
	figure(2);
	for i=1:numel(D)
		Im_In = imread([D(i).folder,filesep,D(i).name]);
		Im_In = im2double(Im_In);
		
		Im_Out = predict(My_CNN,Im_In);
		
		I = imtile({Im_In,Im_Out});
		if(Save_Predictions)
			imwrite(I,[D(i).folder,filesep,'Out',filesep,D(i).name(1:end-4),'_Out.tif']);
		end
		
		I_All(:,:,i) = I;
	end
	I_All = imtile(I_All,'BorderSize',[2,2],'BackgroundColor','w');
	imshow(I_All);
	%}
	
	figure(3);
	I = [];
	for i=1:10 % :numel(D)
		
		Im_In = imread([D(i).folder,filesep,D(i).name]);
		Im_In = im2double(Im_In);
		
		I1 = activations(My_CNN,Im_In,'imageinput');
		I1 = mat2gray(I1);
		I2(:,:,1) = I1(:,:,1); % First channel only.
		
		for l=2:10
			I1 = activations(My_CNN,Im_In,['conv_',num2str(2*l)]);
			I1 = mat2gray(I1);
			I2(:,:,l) = I1(:,:,1); % First channel only.
		end
		
		I1 = activations(My_CNN,Im_In,'regressionoutput');
		I1 = mat2gray(I1);
		I2(:,:,11) = I1(:,:,1); % First channel only.
		
		I(:,:,i) = imtile(I2,'GridSize',[1,11]); % I = imtile(mat2gray(act1),'GridSize',[sqrt(Channel_Num),sqrt(Channel_Num)]);
	end
	I = imtile(I,'GridSize',[10,1],'BorderSize',[1,1],'BackgroundColor','w');
	imshow(I);
	%}
end