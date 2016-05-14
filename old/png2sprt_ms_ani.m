clear
close all

name = 'ms_demo';
[X,MAP] = imread(['grpx\' name '.png']);

A = [X(1:32,:)  X(33:64,:)  X(65:96,:) X(97:128,:)];
figure
image(A)
axis equal
colormap(MAP)

B = X(129:144,:);

Y11 = (B==11); %  11    10     6
Y10 = (B==10);
Y6  = (B==6 );

Z = [Y11;Y10;Y6];
figure
image(Z)
axis equal
colormap(flag)

Frames = im2col(A,[32 16],'distinct');

[C,IA,IC] = unique(Frames','rows');


%%%%%%%%%%%%%%%%%%%%%%

%CC = C(IC,:)';
CC = C';
A = col2im( CC,[32 16],[32 size(CC,2)*16],'distinct');

[LIA,LOCB] = ismember(Frames',C,'rows');

figure
image(A)
axis equal
colormap(MAP)
%%%%%%%%%%%%%%%%%%%%%%
% return

IC = [ LOCB; ((1+max(LOCB)):(16+max(LOCB)))'];

fid = fopen([name '_ani.asm'],'w');
fprintf (fid,[name '_ani:\n']);
fprintf (fid,'    defb %d \n',IC-1);
fclose(fid);


Y15 = (A==15);
Y7  = (A==7 );
Y1  = (A==1 );

W = [Y15(1:16,:);Y7(1:16,:);Y1(17:32,:)];
Y = [W Z];
figure
image(Y)
axis equal
colormap(flag)

imwrite(Y*16,MAP,['grpx\' name '_shapes.png'],'png', 'BitDepth',8)


%%%%%%%%%%%%%%%%%%%%%%


Nframes = size(Y,1)/16*size(Y,2)/16;

frames = cell(32,Nframes);

k = 0;
h = 0;

for i = 1:size(frames,2)
    for j = 1:16
        frames{j,i} = [dec2hex(bi2de(Y(h+j,k+[1:8]),'left-msb'),2)];
    end
    for j=17:32
        frames{j,i} = [dec2hex(bi2de(Y(h+j-16,k+8+[1:8]),'left-msb'),2)];
    end
    i
%     image( [ Y(h+[1:16],k+[1:8]) Y(h+[17:32]-16,k+8+[1:8])]);
%     axis equal
%     colormap(MAP);
%     pause
    h = h + 16;
    if (h>=size(Y,1))
        h = 0;
        k=k+16;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save sprite data

fid = fopen([name '_frm.asm'],'w');
fprintf (fid,[name ':\n']);
for i=1:size(frames,2)
    fprintf (fid,[ name '_%d \n'],i-1);
    for j=1:32
        fprintf (fid,'    defb 0x%s \n',frames{j,i});
    end
    fprintf (fid,'\n');
end
fclose(fid);

% salvare in binario qui
fid = fopen([name '_frm.bin'],'w');
for i=1:size(frames,2)
    for j=1:32
        fwrite (fid,hex2dec(frames{j,i}));
    end
end
fclose(fid);

!miz\MSX-O-Mizer.exe  -r ms_demo_frm.bin miz\ms_demo_frm.bin.miz


Y = Y1(17:32,:);

minx = zeros(size(Y,2),1);
maxx = zeros(size(Y,2),1);
miny = zeros(size(Y,2),1);
maxy = zeros(size(Y,2),1);

h = 1;
for k = 1:16:size(Y,2)
    
    A = Y(:,k:(k+15));
       
    for x = 1:16
        if any(A(:,x))
            minx(h) = x;
            break;
        end
    end
    for x = 16:-1:1
        if any(A(:,x))
            maxx(h) = x;
            break;
        end
    end
    for x = 1:16
        if any(A(x,:))
            miny(h) = x;
            break;
        end
    end
    for x = 16:-1:1
        if any(A(x,:))
            maxy(h) = x;
            break;
        end
    end
    %[h minx(h) maxx(h) miny(h) maxy(h)]
    h = h+1;
end

fid = fopen([name '_frm_coll_wind.asm'],'w');
fprintf (fid,[name '_coll_wind:\n']);
for h = 1:size(Y,2)/16
     fprintf (fid,'    defb %d,%d,%d,%d \n',[minx(h) maxx(h)-1 miny(h) maxy(h)-1] );
end
fprintf (fid,'\n');
fclose(fid);
