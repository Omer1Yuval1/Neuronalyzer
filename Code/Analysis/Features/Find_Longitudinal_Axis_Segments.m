function Find_Longitudinal_Axis_Segments(Workspace,Cxy)
	
	% List CB vertices:
	F1 = find([Workspace.Vertices.Order] < 0);
	
	S = struct('Branch_index',{},'Segments',{},'Vertices',{});
	
	for i=1:length(F1) % For each CB vertex (also CB branch).
		while % Trace the branch until a termination condition is met.
			
		end
	end
end