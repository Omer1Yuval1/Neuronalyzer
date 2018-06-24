function Test_NN(NN_Object,NN_Threshold,NN_Name)
	
	[Files_List,PathName] = uigetfile({'*.tif';'*.jpg'},'Please Choose a Set of Images.','MultiSelect','on');
	mkdir([PathName,'Test_Result_',NN_Name]);
	cd([PathName,'Test_Result_',NN_Name]);
	N = length(Files_List);
	Multiple_NN_WaitBar = waitbar(0,['Tracing In Progress (0/',num2str(N),')']);
	assignin('base','Files_List',Files_List);
	for f=1:numel(Files_List) % For each file (image\neuron).
	
		Image0 = flipud(imread(strcat(PathName,Files_List{f})));
		Image0 = Image0(:,:,1); % Choose the 1st channel in case it's a pseudo RGB.
		
		NN_Probabilities = Apply_Trained_Network(NN_Object,Image0);
		
		[Im_Rows,Im_Cols] = size(Image0);
		Im_BW = zeros(Im_Rows,Im_Cols);
		Im_BW(find(NN_Probabilities >= NN_Threshold)) = 1;
		
		imwrite(Image0,[Files_List{f}(1:end-4),'_0',Files_List{f}(end-3:end)]);
		imwrite(NN_Probabilities,[Files_List{f}(1:end-4),'_1',Files_List{f}(end-3:end)]);
		imwrite(Im_BW,[Files_List{f}(1:end-4),'_2',Files_List{f}(end-3:end)]);
		
		waitbar(f/N,Multiple_NN_WaitBar,['Tracing In Progress (',num2str(f),'/',num2str(N),')']);
		
	end
	delete(Multiple_NN_WaitBar);
end