function [Vc,Vc_Dist,Vc_Max] = Reconstruct_Curvature(Workspace,m,M,MinD,MaxD,Plot_01)
	
	% if(nargin == 1)
		% m = 0; % 0.03. % It seems that that the interesting range is within [0.03,0.07]. This excludes the turn points of terminal tertiary segments.
		% M = 0.1; % 0.05.
		% MinD = 25;
		% MaxD = 45;
	% end
	
	Scale_Factor = Workspace.User_Input.Scale_Factor;
	Distance_Func = @(x0,y0,x,y) ( (x-x0).^2 + (y-y0).^2).^(.5);
	
	Min_Eval_Points = 5;
	XYC = zeros(0,3);
	Vc_Max = [];
	for s=1:numel(Workspace.Segments)
		if(numel(Workspace.Segments(s).Rectangles) > Min_Eval_Points)
			X = [Workspace.Segments(s).Rectangles.X];
			Y = [Workspace.Segments(s).Rectangles.Y];
			
			[~,SxS,SyS,xx,Cxy] = Get_Segment_Curvature(X,Y);
			Cxy = Cxy ./ Scale_Factor; % Pixels to Micrometers.
			
			Dr = zeros(length(xx),1); % zeros(numel(Workspace.Segments(s).Rectangles),1);
			for r=1:length(xx) % 1:numel(Workspace.Segments(s).Rectangles)
				Dr(r) = Find_Medial_Distance([X(xx(r)),Y(xx(r))],Workspace.Medial_Axis,Workspace.User_Input.Scale_Factor);
			end
			
			if(length(find(Cxy < 0)))
				% disp(1);
            end
            
			% XYC = [XYC ; [X' , Y' , Cxy' , Dr]];
			XYC = [XYC ; [SxS' , SyS' , Cxy' , Dr]];
            
			if(~isempty(m))
				Cxy = Cxy(Cxy >= m & Cxy <= M);
			end
			
            if(~isempty(Cxy))
                Vc_Max(end+1) = max(Cxy);
				% disp(Cxy);
            end
        end
	end
	% assignin('base','XYC0',XYC);
	
	% Scale:
	% XYC(:,3) = XYC(:,3) .* (1./Scale_Factor); % Pixels to Micrometers.	
	% Vc_Max = Vc_Max .* (1./Scale_Factor);
	
	% Filter by curvature (thresholds are in um):
		% TODO: max curvaure should be filtered differently).
	if(~isempty(m))
		XYC = XYC(XYC(:,3) >= m & XYC(:,3) <= M,:);
	end
	Vc = XYC(:,3); % Enhanced ([m,M]) Curvature.
	% Vc_Root = Vc .^(.5); % Root Curvature. Cxy = Cxy .^2;
	
	if(~isempty(MinD))
		% Filter by distance from medial axis:
		F = find(XYC(:,4) >= MinD & XYC(:,4) <= MaxD);
		XYC = XYC(F,:);
		% Vc_Root_Dist = Vc_Root(F);
	end
	Vc_Dist = XYC(:,3);
	
	if(Plot_01)
		Colors = rescale(Vc_Dist); % Colors = rescale(XYC(:,3));
		
		Colors = [Colors,0.*Colors,1-Colors];
		% figure;
		% imshow(Workspace.Image0);
		hold on;
		scatter(XYC(:,1),XYC(:,2),50,Colors,'filled');
	end
	
	function D = Find_Medial_Distance(Cxy,XY_Med,Scale_Factor)
		Dm = Distance_Func(XY_Med(:,1),XY_Med(:,2),Cxy(1),Cxy(2));
		f1 = find(Dm == min(Dm));
		Medial_Distance = Dm(f1(1)); % Minimal distance of the vertex center of the medial axis (= distance along the Y' axis).
		D = Medial_Distance.*Scale_Factor;
	end
	
end