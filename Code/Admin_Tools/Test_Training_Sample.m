[Sy,Sx] = size(Im1);
d = 10;
% ImBW = zeros
figure(1);
imshow(Im1);
hold on;

for x=d+1:Sx-d
    for y=d+1:Sy-d
        B = Im1(y-d:y+d,x-d:x+d);
        % disp(std2(B));
        if( std2(B) > 10 )
            % disp(1);
            plot(x,y,'.r');
            hold on;
        end
    end
end