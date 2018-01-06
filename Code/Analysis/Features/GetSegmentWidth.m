function Width = GetSegmentWidth(Rectangles,Scale_Factor)
    
	if isempty(Rectangles) % In case the Rectangle field is empty, set width to -1.
        Width = -1;
    else
       Width = mean([Rectangles.Width]) * Scale_Factor;
    end
end