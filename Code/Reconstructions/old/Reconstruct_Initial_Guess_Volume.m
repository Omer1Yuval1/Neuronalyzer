function Im_Trace = Reconstruct_Initial_Guess_Volume(Workspace1)
	
	if(isempty(Workspace1.BW_Reconstruction))
		msgbox('This image does not have a trace yet. Apply a trained neural network to get and initial guess, or load a binary image');
	else
		imshow(Workspace1.BW_Reconstruction);
		% set(gca,'YDir','normal');
	end
end