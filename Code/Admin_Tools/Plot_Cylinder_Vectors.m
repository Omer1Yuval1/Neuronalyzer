a = 45;
b = 45;

xyz0 = [0,0,1];
xyz0_p = [0,0,0];

xyz1 = [cosd(0),sind(0),1]; % The length of this vector is 1.
xyz1_p = [cosd(0),sind(0),0]; % The length of this vector is 1.

xyz2 = [cosd(90),sind(90),1]; % The length of this vector is 1.
xyz2_p = [cosd(90),sind(90),0]; % The length of this vector is 1.

xyz3 = [cosd(a),sind(a),1-tand(b)]; % tand(b) = L3 ./ 1. L3 is the distance from the XY plane. 1 is the is length of the projected vector onto the XY plane.
xyz3_p = [cosd(a),sind(a),0];

disp('Blue - before & after:');
disp([atan2d(norm(cross(xyz1-xyz0,xyz3-xyz0)),dot(xyz1-xyz0,xyz3-xyz0)) , atan2d(norm(cross(xyz1_p-xyz0_p,xyz3_p-xyz0_p)),dot(xyz1_p,xyz3_p-xyz0_p))]);

% disp('Black - before & after:');
% xyz4 = [cosd(45),sind(45),1];
% xyz4_p = [cosd(45),sind(45),0];
% [atan2d(norm(cross(xyz1,xyz4)),dot(xyz1,xyz4)) , atan2d(norm(cross(xyz1,xyz4)),dot(xyz1,xyz4))]


figure;
W1 = 3;

% First plot the real branches:
plot3([xyz0(1),xyz1(1)],[xyz0(2),xyz1(2)],[xyz0(3),xyz1(3)],'r','LineWidth',W1);
hold on;
plot3([xyz0(1),xyz2(1)],[xyz0(2),xyz2(2)],[xyz0(3),xyz2(3)],'g','LineWidth',W1);
plot3([xyz0(1),xyz3(1)],[xyz0(2),xyz3(2)],[xyz0(3),xyz3(3)],'b','LineWidth',W1);
% plot3([xyz0(1),xyz4(1)],[xyz0(2),xyz4(2)],[xyz0(3),xyz4(3)]+1,'k','LineWidth',W1);

% Then plot the projected branches:
plot3([xyz0_p(1),xyz1_p(1)],[xyz0_p(2),xyz1_p(2)],[xyz0_p(3),xyz1_p(3)],'--r','LineWidth',W1);
hold on;
plot3([xyz0_p(1),xyz2_p(1)],[xyz0_p(2),xyz2_p(2)],[xyz0_p(3),xyz2_p(3)],'--g','LineWidth',W1);
plot3([xyz0_p(1),xyz3_p(1)],[xyz0_p(2),xyz3_p(2)],[xyz0_p(3),xyz3_p(3)],'--b','LineWidth',W1);
% plot3([xyz0_p(1),xyz4(1)],[xyz0_p(2),xyz4(2)],[xyz0_p(3),xyz4(3)],'--k','LineWidth',W1/2);

view([14.02,57.52]);
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');

%
xyz0 = [0,0,1];
xyz0_p = [0,0,0];
Va = 0:1:90;
Vb = 0:5:90;
figure;
for j=1:length(Vb)
    Vxy = zeros(length(Va),2);
    for i=1:length(Va)
        xyz1 = [cosd(0),sind(0),1];
        xyz1_p = [cosd(0),sind(0),0];

        xyz3 = [cosd(Va(i)),sind(Va(i)),1-tand(Vb(j))];
        xyz3_p = [cosd(Va(i)),sind(Va(i)),0];

        Vxy(i,:) = [atan2d(norm(cross(xyz1-xyz0,xyz3-xyz0)),dot(xyz1-xyz0,xyz3-xyz0)),atan2d(norm(cross(xyz1_p-xyz0_p,xyz3_p-xyz0_p)),dot(xyz1_p,xyz3_p-xyz0_p))];
        % disp(Vxy(i,:);
    end
	
	subplot(131);
    hold on;
    plot(Va,abs(Vxy(:,2)-Vxy(:,1))); % The a (xy) angle as a function of actual-projected angle difference.
    
    subplot(132);
    hold on;
    plot(Vb(j).*ones(length(Va),1),abs(Vxy(:,2)-Vxy(:,1))); % The b (xy-z) angle as a function of actual-projected angle difference.
    
    subplot(133);
    hold on;
    plot(Vxy(:,1),Vxy(:,2)); % The correlation between the actual angle and the prjected angle.
end

subplot(131);
xlabel('XY Plane Angle (degrees)');
ylabel('Actual-Projected Angle difference (degrees)');
xlim([0,90]);
grid on;
axis square;

subplot(132);
xlabel('XY-Z Angle (degrees)');
ylabel('Actual-Projected Angle difference (degrees)');
xlim([0,90]);
grid on;
axis square;

subplot(133);
xlabel('Actual Angle (degrees)');
ylabel('Projected Angle (degrees)');
xlim([0,90]);
grid on;
axis square;
%}