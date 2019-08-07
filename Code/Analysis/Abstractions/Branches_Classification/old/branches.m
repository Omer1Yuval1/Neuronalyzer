function [Wi] = branches(Workspace,NN_Threshold,Length_Threshold)
    
	tmp = matlab.desktop.editor.getActive;
	cd(fileparts(tmp.Filename));
	addpath(genpath(pwd));
    
	Curvature_Threshold = 1;
   
    for i = 1:numel(Workspace)
        
        Wi = Workspace(i).Workspace; % Just copying the i-th DB in order NOT to add the BW to the main DB.
        [Im_Rows,Im_Cols] = size(Workspace(i).Workspace.Image0);
        Wi.Im_BW = zeros(Im_Rows,Im_Cols);
        Wi.Im_BW(Workspace(1).Workspace.NN_Probabilities >= NN_Threshold) = 1;
        
        Wi = Vertices_Analysis_Index(Wi);
		Wi = Match_Vertex_Rects_To_Segments(Wi); % Note: this algorithm is included in 'Connect_Vertices.m'.
        
        Wi = add_length(Wi);
        
        assignin('base','Wi',Wi);
        
        Wi = Reduce_Connectivity(Wi,Length_Threshold);
        
        Wi.Branches = construct_branches(Wi,Curvature_Threshold);
		
		Wi = Classify_Branches(Wi);
    end

end