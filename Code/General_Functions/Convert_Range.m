function Output_Vector = Convert_Range(Input_Vector,Input_Range,Output_Range);
	
	% Demo - Assigin a color to each value in the range [0,1] using a 64-color colormap,
	% and a maximum value of 0.9:
		% Input_Vector = rand(1,10);
		% ColorMap1 = jet;
		% for i=1:length(Input_Vector)
			% Output_Vector = Convert_Range(Input_Vector(i),[0,.9],[1,64]);
			% Output_Vector = min(64,round(Output_Vector)); % Round and make sure the output number is not higher than the maximum in the new range.
			% Color1 = ColorMap1(Output_Vector,:); % Get the color of the i-th value.
		% end
	
	
	Output_Vector = ((Input_Vector - Input_Range(1)) / (Input_Range(2) - Input_Range(1))) .* ...
					(Output_Range(2) - Output_Range(1)) + Output_Range(1);
	
end