function [Path,Cell_Body_Center] = Get_Cell_Body(im,Path,Parameters1)

	%	1---------2
	%	|	|	------>
	%	4---------3
	
	figure(1), imshow(im);
	set(gca,'YDir','normal');
	
	Scale_Factor = Parameters1(1).General_Parameters(1).Scale_Factor;
	Step_Length = Parameters1(1).Cell_Body(1).Step_Length;
	Rect_Width = Parameters1(1).Cell_Body(1).Rect_Width;
	Rect_Length = Parameters1(1).Cell_Body(1).Rect_Length;
	
	Rotation_Range = Parameters1(1).Auto_Tracing_Parameters(1).Rect_Rotation_Range;
	Rotation_Res = Parameters1(1).Cell_Body(1).Rotation_Res;
	
	% Zoom in:
	figure(1), zoom on;
	waitfor(gcf,'CurrentCharacter',char(32)); % enter=13, space=32.
	zoom reset;
	zoom off;
	
	% Choose a point on the neuron, near the cell body.
	[x1,y1] = ginput(1);
	Cell_Body_Center = round([x1,y1]);
	hold on;
	figure(1), plot(x1,y1,'.r');
	
	arr1 = Rect_Scan(im,[x1 y1],0,Rect_Width,Rect_Length,Step_Length,Rotation_Range,Rotation_Res,Parameters1);
	% Add normalization function.
	arr1 = Choose_Paths(arr1,0,Parameters1);

	arr2 = Rect_Scan(im,[x1 y1],180,Rect_Width,Rect_Length,Step_Length,Rotation_Range,Rotation_Res,Parameters1);
	% Add normalization function. 
	arr2 = Choose_Paths(arr2,180,Parameters1);
	
	Path(1).Rectangle_Index = 1;
	Path(1).Step_Index = 1;
	Path(1).Coordinates = round([x1,y1]);
	Path(1).Angle = arr1(1,1);
	Path(1).Width = Rect_Width*Scale_Factor;
	Path(1).Is_Mapped = 0;
	Path(1).Connection = 0;
	Path(1).Current_Branch_Step_Index = 1;
	
	Path(2).Rectangle_Index = 2;
	Path(2).Step_Index = 1;
	Path(2).Coordinates = round([x1,y1]);
	Path(2).Angle = arr2(1,1);
	Path(2).Width = Rect_Width*Scale_Factor;
	Path(2).Is_Mapped = 0;
	Path(2).Connection = 0;
	Path(2).Current_Branch_Step_Index = 1;
	
end