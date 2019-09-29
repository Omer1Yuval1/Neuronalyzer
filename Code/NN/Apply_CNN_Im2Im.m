function ImP = Apply_CNN_Im2Im(My_CNN,Im0)
	
	% This function gets a trained neural My_CNNwork and a grayscale image and produces a matrix of probabilities.
	% Each pixel in the output matrix contains the probability of the corresponding pixel in the grayscale image of being
	% a neuron pixel or a non-neuron pixel.
	
	% profile on;
	
	FHS = 10; % Frame Half Size.
	FS = (2*FHS) + 1; % Frame Size.
	
	Im0 = rescale(im2double(Im0(:,:,1)));
	
	[Rows1,Cols1] = size(Im0);
	ImP = zeros(Rows1,Cols1); % CNN Output.
	
	figure('WindowState','maximized');
	Path1 = 'D:\Dropbox (Technion Dropbox)\Omer Yuval\Neuronalizer\Neuronalizer Paper\Figures\Figure 2\CNN\Sample_Denoised_Windows';
	ii = 0;
	
	% % % Make sure the FHS is smaller than half the image min(dimensions).
	for r=1+FHS:FS:Rows1-FHS % For each row (without the margins).
		for c=1+FHS:FS:Cols1-FHS % For each col (without the margins).			
			
			dx = c-FHS:c+FHS;
			dy = r-FHS:r+FHS;
			Frame_In = Im0(dy,dx);
			
			% if(std(Frame_In(:))) % If the std of all pixels in the frame > 0.
			if(std(Frame_In(:)) > 0.2) % 0.2
				Frame_Out = predict(My_CNN,Frame_In);
				ImP(dy,dx) = Frame_Out;
				
				ii = ii + 1;
                hold on;
                imshow([Frame_In,ones(FS,2),Frame_Out]);
                % waitforbuttonpress;
                export_fig([Path1,filesep,num2str(ii),'.tif'],'-tif',gca);
			end
		end
		if(ii == 100)
			break;
		end
	end
end