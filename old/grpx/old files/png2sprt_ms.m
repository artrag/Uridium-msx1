clear
close all

name = 'ms_demo';
[A,MAP] = imread(['grpx\' name '.png']);
Y15 = A==15;
Y15 = Y15([1:16 33:48 65:80 97:112],:);

Y7 = A==7;
Y7 = Y7([1:16 33:48 65:80 97:112],:);

Y1 = A==1;
Y1 = Y1(16+[1:16 33:48 65:80 97:112],:);

Y = [Y15;Y7;Y1];
figure
image(Y)
colormap(flag)

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
