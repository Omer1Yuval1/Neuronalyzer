function [Path,Cell_Body_Center] = Get_Cell_Body_Multiple(im,Path,Parameters1)
	
	%	1---------2
	%	|	|	------>
	%	4---------3
	
	figure(1), imshow(im);
	set(gca,'YDir','normal');
	
	Scale_Factor = Parameters1(1).General_Parameters(1).Scale_Factor;
	Step_Length = Parameters1(1).Cell_Body(1).Step_Length;
	% Rect_Width = 2/Scale_Factor; % Parameters1(1).Cell_Body(1).Rect_Width;
	Rect_Length = Parameters1(1).Cell_Body(1).Rect_Length;
	
	Rotation_Range = Parameters1(1).Auto_Tracing_Parameters(1).Rect_Rotation_Range;
	Rotation_Res = Parameters1(1).Cell_Body(1).Rotation_Res;
	
	% Zoom in:
	figure(1), zoom on;
	waitfor(gcf,'CurrentCharacter',char(32)); % enter=13, space=32.
	zoom reset;
	zoom off;
	
	% Choose a point on the neuron, near the cell body.
	figure(1);
	hold on;
	C = [];
	i = 0;
	Step1 = 0;
	while 1
		GK = getkey;
		if(GK == 13) % Enter.
			[x1,y1] = ginput(1);
			[x2,y2] = ginput(1);
			Angle1 = atan2d(y2-y1,x2-x1);
			C(:,end+1) = [x1 ; y1];
			
			i = i + 1;
			Path(i).Rectangle_Index = i;
			Path(i).Step_Index = i;
			Path(i).Coordinates = round([x1,y1]);
			Path(i).Angle = mod(Angle1,360);
			% Path(i).Angle = arr1(1,1);
			
			Path(i).Is_Mapped = 0;
			Path(i).Connection = 0;
			Path(i).Current_Branch_Step_Index = 1;
			Path(i).Rect_Length = Step_Length*Scale_Factor;
			Path(i).Score = 0;
			
			Step_Parameters.Step_Coordinates = Path(i).Coordinates;
			% Step_Parameters.Previous_Angle = Path(i).Angle;
			Step_Parameters.Step_Routes(1,1) = Path(i).Angle;
			Step_Parameters.Rect_Length = Path(i).Rect_Length;
			Step_Parameters.Branch_Step_Index = 1;	
			
			% W = Adjust_Rect_Width(im,Path,Step_Parameters,Parameters1);
			W = Adjust_Rect_Width_Rot(im,Path,Step_Parameters,Parameters1);
			Path(i).Width = W*Scale_Factor;
			
			plot(x1,y1,'.r');
		elseif(GK == 27) % Escape.
			break;
		end
	end
	
	Cell_Body_Center = [mean(C(1,:)) mean(C(2,:))];
	
end