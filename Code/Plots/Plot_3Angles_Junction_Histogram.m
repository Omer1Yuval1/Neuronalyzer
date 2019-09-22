function Plot_3Angles_Junction_Histogram(V,BinSize,Title1)
	
	XL = [0,250];
	
	V = sort(V).*180./pi;
	F = find([V(1,:)] < 0 | [V(2,:)] < 0 | [V(3,:)] < 0);
	V(:,F) = [];
	V = V';
	
	disp(length(F));
	
	% C1 = (V(:,1)-120).*(V(:,2)-120).*(V(:,3)-120);
	
	edges = 0:BinSize:360; % linspace(0,360,360-BinSize);
	
	% fh1 = figure;
	histogram(V(:,1),edges,'Normalization','pdf','FaceColor',[0.8,0,0],'FaceAlpha',.5);
	hold on;
	histogram(V(:,2),edges,'Normalization','pdf','FaceColor',[0,0.8,0],'FaceAlpha',.5);
	histogram(V(:,3),edges,'Normalization','pdf','FaceColor',[0,0,0.8],'FaceAlpha',.5);
	
	xlim(XL);
	
	xlabel(['Angle (',char(176),')']);
	ylabel('Count');
	title(Title1);
	set(gca,'FontSize',18);
	
	[f1,xi1] = ksdensity(V(:,1));
	[f2,xi2] = ksdensity(V(:,2));
	[f3,xi3] = ksdensity(V(:,3));
	
	[~,locs1] = max(f1);
	[~,locs2] = max(f2);
	[~,locs3] = max(f3);
	
	Am1 = xi1(locs1);
	Am2 = xi2(locs2);
	Am3 = xi3(locs3);
	
	disp([Am1,Am2,Am3]);
	
	V1 = [0,120,240 ; 0,90,180 ; 0,60,120 ; 0,110,250 ; 0,130,230];
	V2 = 18:.1:22; % 0:.1:25; % 0:50; % 15:25;
    Angles_Labels = [{'0,120,240'} , {'0,90,180'} , {'0,60,120'} , {'0,110,250'} , {'0,130,230'}];
    % V3 = zeors(size(V1,1) , );
	I = [];
	Vp = 0;
	P_Vals = zeros(size(V1,1),length(V2));
	for i=1:size(V1,1)
		for j=1:length(V2)
			[f_monte,xi_monte,a_monte] = randomJunction(V1(i,:),V2(j),size(V,1)); % numel(X)*1. 100000.
			
			[h1,p1,k1] = kstest2(V(:,1),a_monte(:,1));
			P_Vals(i,j) = p1;
            % V3(end+1,1:3) = [i , V2(j) , p1];
			if(p1 > Vp)
				Vp = p1;
				I = [i,j];
			end
		end
	end
	disp(['Angles: ',num2str(V1(I(1),:)) , ' ; Noise: ',num2str(V2(I(2)))]);
	
	if(0)
		figure; hold on;
		for i=1:size(V1,1)
			plot(V2,P_Vals(i,:),'LineWidth',3);
		end
		legend([{'0,120,240'} , {'0,90,180'} , {'0,60,120'} , {'0,110,250'} , {'0,130,230'}],'FontSize',22);
		figure(1); % Set the focus back to the main figure.
    elseif(1)
        figure;
        bar3(V2,P_Vals');
        set(gca,'XTickLabels',Angles_Labels);
        ylabel('Noise');
        xlabel('Angles (degrees)');
        zlabel('P-Value');
        ylim([V2(1),V2(end)]);
        figure(1); % Set the focus back to the main figure.
	end
	
	[f_monte, xi_monte, a_monte] = randomJunction([0,120,240],20,size(V,1)); % numel(X)*1. 100000.
	% [f_monte, xi_monte, a_monte] = randomJunction([0 90 180],20,100000); % numel(X)*1
	% [f_monte, xi_monte, a_monte] = randomJunction([0 90 180],2,numel(X));
	% [f_monte, xi_monte, a_monte] = randomJunction([0 90 180],10);
	
	hold on;
	plot(xi_monte(:,1),f_monte(:,1),'LineWidth',4,'Color',[0.8,0,0,.9]);
	plot(xi_monte(:,2),f_monte(:,2),'LineWidth',4,'Color',[0,0.8,0,0.9]);
	plot(xi_monte(:,3),f_monte(:,3),'LineWidth',4,'Color',[0,0,0.8,0.9]);

	% [h1,p1,k1] = kstest2(V(:,1),V(:,1));
	
	[h1,p1,k1] = kstest2(V(:,1),a_monte(:,1));
	[h2,p2,k2] = kstest2(V(:,2),a_monte(:,2));
	[h3,p3,k3] = kstest2(V(:,3),a_monte(:,3));

	disp([h1 h2 h3]);
	disp([p1 p2 p3]);
	
	function [f,xi,a] = randomJunction(guess_theta,noise_var,Njunc)
		
		plot_flag = false;
		
		% Njunc = 200000;
		
		switch nargin
			case 0
				guess_theta = [0 120 240];
				% guess_theta = [0 90 180];
				noise_var=20;
			case 1
				noise_var=20;
		end
		
		% theta_uniform = 2*pi*rand(Njunc,3);
		
		% additive noise
		theta_noise = randn(Njunc,3)*noise_var;
		% rotation of the entire set
		theta_rot = 360*rand(Njunc,1);
		% baseline+additivenoise+rotation
		theta = theta_rot+repmat(guess_theta,Njunc,1)+ theta_noise;
		
		theta = mod(theta,360);
		
		x = cosd(theta);
		y = sind(theta);
		
		u = [x(:,1) y(:,1) zeros(Njunc,1)];
		v = [x(:,2) y(:,2) zeros(Njunc,1)];
		w = [x(:,3) y(:,3) zeros(Njunc,1)];
		
		a1 = 180/pi*atan2(vecnorm(cross(u,v),2,2),dot(u,v,2));
		a2 = 180/pi*atan2(vecnorm(cross(u,w),2,2),dot(u,w,2));
		a3 = 180/pi*atan2(vecnorm(cross(v,w),2,2),dot(v,w,2));
		a = [a1 a2 a3];
		
		a = sort(a,2);
		a(:,3) = 360-(a(:,1)+a(:,2));
		
		edges = linspace(0,360,200);
		
		if(plot_flag)
			figure;
			histogram(a(:,1),edges);
			hold on;
			histogram(a(:,2),edges);
			histogram(a(:,3),edges);
			% plotJuncs();
			title(guess_theta)
		end
		
		[f1,xi1] = ksdensity(a(:,1));
		[f2,xi2] = ksdensity(a(:,2));
		[f3,xi3] = ksdensity(a(:,3));
		
		f = [f1' f2' f3'];
		xi = [xi1' xi2' xi3'];
	end
end