function [X,Y] = Generate_DataSet(Frame_Half_Size)
	
	Save_Sample_As_Image = 0;
	D = 'D:\Omer\Neuronalizer\Resources\CNN\Input_Samples';
	
	BW_Min_Neuron_Pixels = 20; % 5.
	DataSet_MaxSize = 10^6;
	Num_Per_Image = 10000; % [5000,25000].
	
	X = zeros(2*Frame_Half_Size+1,2*Frame_Half_Size+1,1,DataSet_MaxSize);
	Y = zeros(2*Frame_Half_Size+1,2*Frame_Half_Size+1,1,DataSet_MaxSize);
	
	File1 = uigetfile('*.mat','Select Training Set');
	W = load(File1,'Workspace');
	W = W.Workspace;
	
	ii = 0;
	for w=1:numel(W) % For each worksapce (=image).
		
		[Rows1,Cols1] = size(W(w).Workspace.Image0);
		Im = rescale(im2double(W(w).Workspace.Image0(:,:,1)));
		Im_BW = im2double(W(w).Workspace.Im_BW);
        
		% Randomize pixel indices:
		Xr = 1+Frame_Half_Size:Cols1-Frame_Half_Size;
		Yr = 1+Frame_Half_Size:Rows1-Frame_Half_Size;
		XYr = combvec(Xr,Yr); % All pixel coordinates (exluding the margins).
		p = randperm(size(XYr,2));
		XYr = XYr(:,p);
		
		% % % Make sure the Frame_Half_Size is smaller than half the image min(dimensions).
		for r=XYr(2,:)
            for c=XYr(1,:)
				
				dx = c-Frame_Half_Size:c+Frame_Half_Size;
				dy = r-Frame_Half_Size:r+Frame_Half_Size;
				Frame_In = Im(dy,dx);
				Frame_Out = Im_BW(dy,dx);
				
				% if(std(Frame_In(:))) % If the std of all pixels in the frame > 0.
				if(sum(Frame_Out(:)) > BW_Min_Neuron_Pixels) % If at least one pixel in the response is 1. This is done to allow the network to focus on regions that contain a signal.
					ii = ii + 1;
					
					X(:,:,1,ii) = Frame_In;
					Y(:,:,1,ii) = Frame_Out;
					
					%{
					imshow(imtile({Frame_In,Frame_Out}));
					waitforbuttonpress;
					hold on;
					%}
					
					if(Save_Sample_As_Image)
						imwrite(Frame_In,[D,filesep,num2str(ii),'.tif']);
					end
					
					%{
					for Roti=[0,90,180,270] % Rotate 3 times in 90 degrees (both the original and the mirror image).
						
						% Rotated Roti degrees:
						ii = ii + 1;
						X(:,:,1,ii) = imrotate(Frame_In,Roti);
						Y(:,:,1,ii) = imrotate(Frame_Out,Roti);
						
						% Flipped and rotated Roti degrees:
						ii = ii + 1;
						X(:,:,1,ii) = imrotate(fliplr(Frame_In),Roti);
						Y(:,:,1,ii) = imrotate(fliplr(Frame_Out),Roti);
					end
					%}
				end
				if(ii >= w*Num_Per_Image)
					break;
				end
            end
            if(ii >= w*Num_Per_Image)
				break;
            end
		end
		disp([w,ii]);
	end
	X = X(:,:,1,1:ii);
	Y = Y(:,:,1,1:ii);
end