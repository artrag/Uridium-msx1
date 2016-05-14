

clear
close all

TMSMAP = [0,0,0               % 0 Transparent
          0,0,0               % 1 Black           0    0    0
         33,200,66            % 2 Medium green   33  200   66
         94,220,120           % 3 Light green    94  220  120
         84,85,237            % 4 Dark blue      84   85  237
        125,118,252           % 5 Light blue    125  118  252
        212,82,77             % 6 Dark red      212   82   77
        66,235,245            % 7 Cyan           66  235  245
        252,85,84             % 8 Medium red    252   85   84
        255,121,120           % 9 Light red     255  121  120
        212,193,84            % A Dark yellow   212  193   84
        230,206,128           % B Light yellow  230  206  128
        33,176,59             % C Dark green     33  176   59
        201,91,186            % D Magenta       201   91  186
        204,204,204           % E Gray          204  204  204
        255,255,255];         % F White         255  255  255

TMSMAP = TMSMAP/255;

[B,MAP] = imread('grpx\enemytest_red.bmp');

figure;
colormap(MAP);
image(B);
axis equal

[Y,NEWMAP] = imapprox(B,MAP,3,'nodither');

figure;
colormap(NEWMAP);
image(Y);
axis equal


imwrite(Y,NEWMAP,['grpx\enemytest_red_two_col.png'],'png', 'BitDepth',8)


name = 'enemytest_red_two_col';

A=Y;
MAP = NEWMAP; % = imread(['grpx\' name '.png']);

figure
image(A)
colormap(MAP)
axis equal
[N,X] = hist(double(A(:)),16)
[c ii] = sort(N);

Y1 = A==0;
Y2 = A==1;

Y = [Y1;Y2];
figure
image(Y)
colormap(flag)
axis equal

imwrite(Y*16,MAP,['grpx\' name '_shapes.png'],'png', 'BitDepth',8)

Nframes = size(Y,1)*size(Y,2)/256;

frames = cell(32,Nframes);

figure;
k = 0;
h = 0;
for i = 1:size(frames,2)
    for j = 1:16
        frames{j,i} = [dec2hex(bi2de(Y(h+j,k+[1:8]),'left-msb'),2)];
    end
    for j=17:32
        frames{j,i} = [dec2hex(bi2de(Y(h+j-16,k+8+[1:8]),'left-msb'),2)];
    end
    image( [ Y(h+[1:16],k+[1:8]) Y(h+[17:32]-16,k+8+[1:8])]);
    colormap(MAP);
    i
    %pause
    k = k + 16;
    if (k>=size(Y,2))
        k = 0;
        h=h+16;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save sprite data

fid = fopen([name '.asm'],'w');
fprintf (fid,[name ':\n']);
for i=1:size(frames,2)
    fprintf (fid,[ name '_%d \n'],i-1);
    for j=1:32
        fprintf (fid,'    defb 0x%s \n',frames{j,i});
    end
    fprintf (fid,'\n');
end
fclose(fid);
