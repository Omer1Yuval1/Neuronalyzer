function [Mean_Pixel_Value,Values_Vector] = Get_Rect_Score(im,Rect1)
	
	% Input: an image and a vector of coordinates of a rectangle in the form of NX2 [x y].
	% Outputs:
		% Mean_Pixel_Value is the mean pixels value inside the rectangle.
		% Values_Vector is vector of the values of these pixels.
	
	% Ion = InRect(im,Rect1);
	% [Ion Values_Vector] = InRect(im,Rect1);
	Values_Vector = InRect(im,Rect1);
	
	if(isempty(Values_Vector))
		Values_Vector = 0;
	end
	Mean_Pixel_Value = mean(Values_Vector);
	
end