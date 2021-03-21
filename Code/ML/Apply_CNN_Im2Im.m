function [C,Im_Label] = Apply_CNN_Im2Im(My_CNN,Im)
		
	% This function gets a trained neural My_CNNwork and a grayscale image and produces a matrix of probabilities.
	% Each pixel in the output matrix contains the probability of the corresponding pixel in the grayscale image of being
	% a neuron pixel or a non-neuron pixel.
	
	% Run examples:
		% BW = Apply_PVD_CNN_Im2Im(PVD_CNN,Im);
	
    % Enhance image:
        % Im1 = uint8(255 * mat2gray(rescale(Im,0,1,'InputMin',0,'InputMax',50)));
	
	Save_Patches = 0;
	
	S = PVD_CNN_Params();
	
    Transparency = 0.3; % 0.3.
    CM = lines(7);
    CM([1,2],:) = CM([1,7],:);
    Im_Label = [];
    
	FS = My_CNN.Layers(1).InputSize(1); % Frame Size.
	FHS = round(FS ./ 2); % Frame Half Size.
	dF = FS; % round(FS ./ 2); % FS;
	
    Im = Im(:,:,1);
	% Im = S.Input_Image_Func(Im);
	[Rows1,Cols1] = size(Im);
	% Binary_Image = false(size(Im));
    C = categorical(false(size(Im)),0,'BG');
	
	ImP = zeros(size(Im)); % CNN Output.
	ImD = zeros(size(Im)); % Corresponding matrix that contains the value to divide each pixel value to get the average.
	
	if(Save_Patches)
		figure('WindowState','maximized');
		Path1 = './';
		ii = 0;
	end
	
	% % % Make sure the FHS is smaller than half the image min(dimensions).
	for r=1+FHS:dF:Rows1-FHS % For each row (without the margins).
		for c=1+FHS:dF:Cols1-FHS % For each col (without the margins).
			dx = c + (-FHS:(FHS-1));
			dy = r + (-FHS:(FHS-1));
			In = Im(dy,dx);
			
			if(S.Sample_In_Func(S.Input_Image_Func(In)))
				
                C(dy,dx) = semanticseg(In,My_CNN);
				
				if(Save_Patches)
					ii = ii + 1;
					hold on;
					imshow([Frame_In,ones(FS,2),Frame_Out]);
					waitforbuttonpress;
					% export_fig([Path1,filesep,num2str(ii),'.tif'],'-tif',gca);
				end
			end
		end
		if(Save_Patches && ii == 100)
			break;
		end
    end
    
    % Im_Label = labeloverlay(Im,C,'Colormap',CM(2,:),'Transparency',Transparency,'IncludedLabels',["Neuron"]);
	
	%
	% % Im = Workspace(10).Workspace.Image0;
	% %ImP = Apply_CNN_Im2Im(My_CNN,Im);
	% I = imtile({Im,ImP});
	% imshow(I);
	% % imshow(Workspace(10).Workspace.Im_BW);
	%}
    
    %{
    for i=1:numel(Project)
        disp(i);
        Im = Project(i).Info.Files(1).Raw_Image;
        [Binary_Image,ImP,Im_Label] = Apply_PVD_CNN_Im2Im(PVD_CNN,Im);
        imwrite(Im,['E:\Omer\Neuronalyzer\Resources\CNN\Test\',num2str(i),'_In.png']);
        imwrite(Binary_Image,['E:\Omer\Neuronalyzer\Resources\CNN\Test\',num2str(i),'_Out.png']);
        
        imwrite(Im_Label,['E:\Omer\Neuronalyzer\Resources\CNN\Test\',num2str(i),'_Im_Label.png']);
        
        ImRGB = im2uint8(zeros([size(Im),3]));
        ImRGB(:,:,3) = Im;
        ImRGB(:,:,1) = im2uint8(Binary_Image);
        imwrite(ImRGB,['E:\Omer\Neuronalyzer\Resources\CNN\Test\',num2str(i),'_In+Out.png']);
    end
    
    
    
		set(gca,'position',[0,0,1,1]); axis tight; set(gcf,'InnerPosition',[50,50,size(Im,2)./2.5,size(Im,1)./2.5]);
    %}
    
    %{
    
    C((Binary_Image == 1 & C == "BG") | (Binary_Image == 0 & C == "Neuron")) = "non-neuron";
    
    Im_Labels = labeloverlay(Im,C,'Colormap',CM([1,2,3],:),'Transparency',0.3,'IncludedLabels',["Neuron","non-neuron"]);
    imshow(Im_Labels);
    set(gca,'position',[0,0,1,1]); axis tight; set(gcf,'InnerPosition',[50,50,size(Im,2)./2.5,size(Im,1)./2.5]);
    %}
end