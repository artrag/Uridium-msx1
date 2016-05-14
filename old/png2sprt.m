clear
close all

name = 'uridium_rev7';
[AA,MAP] = imread(['grpx\' name '.png']);

Y = AA>0;


frames = cell(32,64);

k = 0;
h = 0;
for i = 1:size(frames,2)
    for j = 1:16
        frames{j,i} = Y(h+j,k+[1:8]);
    end
    for j=17:32
        frames{j,i} = Y(h+j-16,k+8+[1:8]);
    end
    k = k + 16;
    if (k>=size(Y,2))
        k = 0;
        h=h+16;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save sprite data

fid = fopen(['data_bin\' name '.bin'],'w');
for i=1:size(frames,2)
    for j=1:32
        fwrite(fid,bi2de(frames{j,i},'left-msb'),'uint8');
    end
end
fclose(fid);

system(['miz\MSX-O-Mizer -r data_bin\' [name '.bin'] ' data_miz\' [name '.miz'] ]);

% store collision data for tile tests (only for MS bullets)

Y = Y(17:32,:);

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
    [h minx(h) maxx(h) miny(h) maxy(h)]
    h = h+1;
end

name = 'ms_bllts';

fid = fopen([name '_frm_coll_wind.asm'],'w');
fprintf (fid,[name '_coll_wind:\n']);
for h = 1:size(Y,2)/16
     fprintf (fid,'    defb %d,%d,%d,%d \n',[minx(h) maxx(h)-1 miny(h) maxy(h)-1] );
end
fprintf (fid,'\n');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save sprite data
% 
% fid = fopen([name '.asm'],'w');
% fprintf (fid,[name ':\n']);
% for i=1:size(frames,2)
%     fprintf (fid,[ name '_%d: \n'],i-1);
%     for j=1:32
%         if (j==1)
%             fprintf (fid,'    defb 0x%s,', binaryVectorToHex(frames{j,i}));
%         elseif (j<32)
%             fprintf (fid,'0x%s,', binaryVectorToHex(frames{j,i}));
%         else
%             fprintf (fid,'0x%s\n', binaryVectorToHex(frames{j,i}));
%         end
%     end
%     fprintf (fid,'\n');
% end
% fclose(fid);

% ; xoff			db	0
% ; yoff			db	0
% ; xsize			db	0
% ; ysize			db	0


Y = AA>0;
fid = fopen(['sprite_collision_window.asm'],'w');

text = [ '\n ; xoff			db	0 \n ; yoff			db	0 \n ; xsize		db	0 \n ; ysize		db	0 \n\n'];

fprintf (fid,text);

k = 0;
for j = 1:16:(size(Y,1)-15)
    for i = 1:16:(size(Y,2)-15)

        fprintf (fid,'sprite_%d:\n',k);
        
        T = Y(j:(j+15),i:(i+15));
%         image(T)
%         colormap(MAP)
%         axis equal;
        [~,indx] = find(sum(T));
        [~,indy] = find(sum(T'));
        if (~isempty(indx) && ~isempty(indy))
            fprintf (fid,'    defb %2d,%2d,%2d,%2d \n',min(indx)-1,min(indy)-1,max(indx)-min(indx)+1,max(indy)-min(indy)+1);
        end
        
        
        %pause
        
        k = k+1;
    end
    
end
fclose(fid);
