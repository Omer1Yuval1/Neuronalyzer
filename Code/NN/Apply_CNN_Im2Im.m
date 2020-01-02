function ImP = Apply_CNN_Im2Im(My_CNN,Im0)
	
	% TODO:
		% the loop goes over each unique window and classifies it. This is problematic because a pixel may be classified differently in different windows.
	
	% This function gets a trained neural My_CNNwork and a grayscale image and produces a matrix of probabilities.
	% Each pixel in the output matrix contains the probability of the corresponding pixel in the grayscale image of being
	% a neuron pixel or a non-neuron pixel.
	
	% profile on;
	
	STD_Threshold = 0; % 0.05; % 0.1.
	Save_Patches = 0;
	
	FHS = 10; % Frame Half Size.
	FS = (2*FHS) + 1; % Frame Size.
	
	% Im0 = rescale(Im0(:,:,1),0,1,'InputMin',0,'InputMax',255);
	Im0 = rescale(im2double(Im0(:,:,1)));
	
	[Rows1,Cols1] = size(Im0);
	ImP = zeros(Rows1,Cols1); % CNN Output.
	ImD = zeros(Rows1,Cols1); % Corresponding matrix that contains the value to divide each pixel value to get the average.
	
	if(Save_Patches)
		figure('WindowState','maximized');
		Path1 = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\Neuronalizer Paper\Figures\Figure 2\CNN\Sample_Denoised_Windows';
		ii = 0;
	end
	
	% % % Make sure the FHS is smaller than half the image min(dimensions).
	% for r=1+FHS:FS:Rows1-FHS % For each row (without the margins).
		% for c=1+FHS:FS:Cols1-FHS % For each col (without the margins).
	for r=1+FHS:1:Rows1-FHS % For each row (without the margins).
		for c=1+FHS:1:Cols1-FHS % For each col (without the margins).
			dx = c-FHS:c+FHS;
			dy = r-FHS:r+FHS;
			Frame_In = Im0(dy,dx);
			
			% if(std(Frame_In(:))) % If the std of all pixels in the frame > 0.
			if(std(Frame_In(:)) > STD_Threshold)
				Frame_Out = predict(My_CNN,Frame_In);
				
				ImP(dy,dx) = ImP(dy,dx) + Frame_Out;
				
				ImD(dy,dx) = ImD(dy,dx) + 1;
				
				%{
				if(Save_Patches)
					ii = ii + 1;
					hold on;
					imshow([Frame_In,ones(FS,2),Frame_Out]);
					waitforbuttonpress;
					% export_fig([Path1,filesep,num2str(ii),'.tif'],'-tif',gca);
				end
				%}
			end
		end
		% if(Save_Patches && ii == 100)
		% 	break;
		% end
	end
	
	ImP = ImP ./ ImD;
	
	%
	% % Im = Workspace(10).Workspace.Image0;
	% %ImP = Apply_CNN_Im2Im(My_CNN,Im0);
	% I = imtile({Im0,ImP});
	% imshow(I);
	% % imshow(Workspace(10).Workspace.Im_BW);
	%}
end