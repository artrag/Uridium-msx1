function [Y,chr,clr] = arry2tile(NewTiles,MAP)

INP = col2im(NewTiles,[8,8],[size(NewTiles,2)*8,8],'distinct');
X  = ind2rgb(INP,MAP);

imwrite(X,'imp.png');

X = uint8(fix(X*255));

MXL = bitand(size(X,2), 255);
MXH = fix(size(X,2)/256);

MYL = bitand(size(X,1), 255);
MYH = fix(size(X,1)/256);

MAXX = size(X,2);
MAXY = size(X,1);

fid = fopen('out.raw','wb') ;

fwrite(fid,72,'uint8');

fwrite(fid,MXL,'uint8');
fwrite(fid,MXH,'uint8');
fwrite(fid,MYL,'uint8');
fwrite(fid,MYH,'uint8');

for y=1:MAXY
    for x=1:MAXX
    	fwrite(fid,X(y,x,:),'uint8');
    end	
end

fclose(fid);
 		
system('bmp2tile\bmp2tile.exe out.raw   > logbmp2tile.txt');
% system('bmp2tile\bmp2tile.exe out.raw -nod  > logbmp2tile.txt');

fid = fopen('outdata.raw','rb');
Y = uint8(fread(fid,inf,'uint8'));
fclose(fid);

YY = shiftdim(reshape(Y,3,MAXX,MAXY),1);

Y = uint8(zeros(MAXY,MAXX,3));

for k=1:3
	Y(:,:,k) = YY(:,:,k)';
end

Y = im2col(rgb2ind(Y,MAP),[8 8 ],'distinct');


fid = fopen('out.CHR','rb');
chr = uint8(fread(fid,inf,'uint8'));
fclose(fid);

fid = fopen('out.CLR','rb');
clr = uint8(fread(fid,inf,'uint8'));
fclose(fid);

