function Workspace1 = Analyze1(Workspace1)
	
	Workspace1 = Steps_Vertices_Segments(Workspace1);
	Workspace1 = Branches_Orders_Index(Workspace1);
	Workspace1 = Vertex_Shape1(Workspace1); % Assign each vertex with its angles (angles of segments pointing out).
	
	% assignin('base','Workspace1',Workspace1);
end