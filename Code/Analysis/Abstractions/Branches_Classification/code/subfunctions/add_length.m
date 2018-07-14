function [Workspace] = add_length(Workspace)
    
     [Im_Rows,Im_Cols] = size(Workspace.Image0);
    
    for i = 1:numel(Workspace.Segments)
        [y,x] = ind2sub([Im_Rows, Im_Cols], Workspace.Segments(i).Skeleton_Linear_Coordinates);
        Workspace.Segments(i).Skel_X = x;
        Workspace.Segments(i).Skel_Y = y;
        Length = 0;
        for j = 1:length(x)-1
            Length = Length + sqrt((x(j+1) - x(j))^2 + (y(j+1) - y(j))^2);
        end
        Workspace.Segments(i).Length = Length *(Workspace.User_Input.Scale_Factor);
    end
end