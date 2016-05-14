clear
close all

name = 'ms_demo';

[A,MAP] = imread(['grpx\' name '.png']);
A = A(129:144,:);
figure
image(A)
colormap(MAP)
axis equal
[N,X] = hist(double(A(:)),16)
[c ii] = sort(N);

Y1 = A==ii(13)-1;
Y2 = A==ii(14)-1;
Y3 = A==ii(15)-1;

Y = [Y1;Y2;Y3];
figure
image(Y)
colormap(flag)
axis equal

name = 'ms_expl';

imwrite(Y*16,MAP,['grpx\' name '_shapes.png'],'png', 'BitDepth',8)

Nframes = size(Y,1)/16*16;

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
