function [X,Y] = Generate_DataSet(Frame_Half_Size)
	
	DataSet_MaxSize = 10^6;
	
	X = zeros(2*Frame_Half_Size+1,2*Frame_Half_Size+1,1,DataSet_MaxSize);
	Y = zeros(2*Frame_Half_Size+1,2*Frame_Half_Size+1,1,DataSet_MaxSize);
	
	File1 = uigetfile('*.mat','Select Training Set');
	W = load(File1,'Workspace');
	W = W.Workspace;
	
	ii = 0;
	for w=1:numel(W) % For each worksapce (=image).
		
		[Rows1,Cols1] = size(W(w).Workspace.Image0);
		
		% % % Make sure the Frame_Half_Size is smaller than half the image min(dimensions).
		for r=1+Frame_Half_Size:Rows1-Frame_Half_Size % For each row (without the margins).
			for c=1+Frame_Half_Size:Cols1-Frame_Half_Size % For each col (without the margins).			
				
				dx = c-Frame_Half_Size:c+Frame_Half_Size;
				dy = r-Frame_Half_Size:r+Frame_Half_Size;
				Frame_In = double(W(w).Workspace.Image0(dy,dx));
				Frame_Out = double(W(w).Workspace.Im_BW(dy,dx));
				
				% if(std(Frame_In(:))) % If the std of all pixels in the frame > 0.
				if(any(Frame_Out(:))) % If at least one pixel in the response is 1. This is done to allow the network to focus on regions that contain a signal.
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
				end
            end
            if(ii > 10^6)
                break;
            end
		end
	end
	X = X(:,:,1,1:ii);
	Y = Y(:,:,1,1:ii);
end