function Segments = Classify_PVD_Segment(W)
	% function c = Classify_PVD_Segment(Sx,Sy,Sc,Is_Terminal)
	
	% Sx and Sy are vectors of segment coordinates.
	% Sc is a vector containing Menorah classes corresponding to segment coordinates.
	
	Threshold_3 = 0.2;
	Threshold_4 = 0.3;
	Min_Segment_Length = 10; % um. 
	
	Segments = W.Segments;
	V12 = reshape([Segments.Vertices],2,[]);
	
	% Step 1:
	for s=1:numel(Segments)
		f = find([W.All_Points.Segment_Index] == Segments(s).Segment_Index);
		
		if(~isempty(f))
			% Sx = [W.All_Points(f).X];
			% Sy = [W.All_Points(f).Y];
			Sc = [W.All_Points(f).Class];
			Segments(s).Class = Step_1(Sc); % W.Segments(s).Terminal
			% Segments(s).Class = mode([W.All_Points(f).Class]);
        else
            Segments(s).Class = nan;
        end
	end
	
	% Step 2:
	%
	for s=1:numel(Segments)
		if(isnan(Segments(s).Terminal))
			Segments(s).Class = nan;
		else
			Segments(s).Class = Step_2(Segments,s,V12);
		end
	end
	%}
	
	% Step 3:
	for s=1:numel(Segments)
		f = find([W.All_Points.Segment_Index] == Segments(s).Segment_Index);
		
		if(~isempty(f)) %  && Segments(s).Class == 4)
			if(W.All_Points(f(1)).Vertex_Order == 1 && W.All_Points(f(end)).Vertex_Order ~= 1)
				Sc = fliplr([W.All_Points(f).Class]); % Flip so that the tip is at the end.
			else
				Sc = [W.All_Points(f).Class];
			end
			Segments(s).Class = Step_3(Segments,s,Sc,Threshold_3,Threshold_4);
		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	function cc = Step_1(Sc)
		cc = mode(Sc);
	end
	
	function cc = Step_2(Segments,s,V12) % Ectopic.
		
		cc = Segments(s).Class;
		if(Segments(s).Terminal && cc ~= 4 && Segments(s).Length < Min_Segment_Length) % && Segments(s).Class < 3)
			% ff = find( (ismember(V12(1,:),Segments(s).Vertices) | ismember(V12(2,:),Segments(s).Vertices)) & [Segments.Segment_Index] ~= Segments(s).Segment_Index);
			% if(length(unique([Segments(ff).Class]) > 1)); % If the other segments on this vertex are from different classes.
			cc = 5;
		end
	end
	
	function cc = Step_3(Segments,s,Sc,Threshold_3,Threshold_4)
		Lp = length(Sc(~isnan(Sc))); % Number of classified points.
		Lp_H = max(1,round(Lp./2));
		
		L4 = length(find(Sc == 4)) ./ Lp;
		L3 = length(find(Sc == 3)) ./ Lp;
		L3_H1 = length(find(Sc(1:Lp_H) == 3)) ./ Lp;
		L3_H2 = length(find(Sc(Lp_H:end) == 3)) ./ Lp;
		L4_H1 = length(find(Sc(1:Lp_H) == 4)) ./ Lp;
		L4_H2 = length(find(Sc(Lp_H:end) == 4)) ./ Lp;
		
		cc = Segments(s).Class;
		if(L3 >= Threshold_3 && L4 >= Threshold_4) % if(Segments(s).Class == 4).
			if( (Segments(s).Terminal && L3_H1 > L4_H1 && L3_H2 < L4_H2) ) %  || (~Segments(s).Terminal && (L3_H1 > L4_H2 || L4_H1 > L3_H2)) )
				cc = 3.5;
			end
		end
	end
end