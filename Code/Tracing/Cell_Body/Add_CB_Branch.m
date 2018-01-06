function Workspace1 = Add_CB_Branch(Workspace1,Figure_Handle,H_Ax1)
	
	% assignin('base','Workspace1',Workspace1);
	
	Scale_Factor = Workspace1.User_Input.Scale_Factor;
	R1 = Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Length_Width_Ratio;
	R2 = Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Step_Length_Ratio;
	Rect_Width = Workspace1.Parameters.Cell_Body(1).Rect_Width;
	Rect_Length = Rect_Width*R1;
	% Step_Length = Rect_Width*Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Step_Length_Ratio;
	
	Rotation_Range = Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Rotation_Range;
	Rotation_Res = Workspace1.Parameters.Cell_Body(1).Rotation_Res;
	
	% Zoom in:
		% zoom reset;
		% z = zoom(Figure_Handle);
		% z.Enable = 'on';
		% waitfor(gcf,'CurrentCharacter',char(32)); % enter=13, space=32.
		% zoom reset;
		% zoom off;
	
	% Choose a point on the neuron, near the cell body.
		C = [];
		i = numel(Workspace1.Path);
		
		% set(gcf,'Pointer','arrow');
		[x1,y1] = ginput(1);
		[x2,y2] = ginput(1);
		Angle1 = atan2d(y2-y1,x2-x1);
		
		i = i + 1;
		Workspace1.Path(i).Rectangle_Index = i;
		Workspace1.Path(i).Step_Index = i;
		% Workspace1.Path(i).Coordinates = round([x1,y1]);
		Workspace1.Path(i).Coordinates = [x1,y1];
		Workspace1.Path(i).Angle = mod(Angle1,360);
		Workspace1.Path(i).Is_Mapped = 0;
		Workspace1.Path(i).Connection = 0;
		Workspace1.Path(i).Current_Branch_Step_Index = 1;
		Workspace1.Path(i).Score = 0;
		Workspace1.Path(i).Looped_To_Step = 0;
		
		% Adjust Width:
			Step_Parameters.Step_Coordinates = [x1,y1];
			Step_Parameters.Step_Routes(1,1) = Workspace1.Path(i).Angle;
			Step_Parameters.Rect_Length = Rect_Length;
			Step_Parameters.Branch_Step_Index = 1;
			Step_Parameters.Rect_Width = 4/Scale_Factor;
			W = Adjust_Rect_Width_Rot(Workspace1,Step_Parameters); % W = Adjust_Rect_Width(Workspace1.Image0,Workspace1.Path,Step_Parameters,Workspace1.Parameters);
		
		
		Workspace1.Path(i).Width = W*Scale_Factor;
		Workspace1.Path(i).Rect_Length = Workspace1.Path(i).Width*R1/R2;
	
	% Plot the Rectangle:
		% assignin('base','Workspace1',Workspace1);
		[XV,YV] = Get_Rect_Vector(Workspace1.Path(i).Coordinates,Angle1,W,R1*W,Workspace1.Parameters.Auto_Tracing_Parameters(1).Rect_Rotation_Origin);
		hold on;
		plot(H_Ax1,XV,YV,'g','LineWidth',2);
		plot(H_Ax1,[XV(2),XV(3)],[YV(2),YV(3)],'r','LineWidth',2);
	
end