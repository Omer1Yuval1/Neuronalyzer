function Length = GetSegmentLength(Rectangles,Scale_Factor)
    
	if isempty(Rectangles) % In case the Rectangle field is empty, set length to -1.
        Length = -1;
    else 
       Length = sum([Rectangles.Length]) * Scale_Factor;        
    end
end