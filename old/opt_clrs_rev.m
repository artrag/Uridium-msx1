


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% encode in screen 2 even tileset
arry2tile(Tiles1u',MAP);
system('copy /B out.CHR chr_plain1u.bin > logcpy.txt');
system('copy /B out.CLR clr_plain1u.bin > logcpy.txt');
arry2tile(Tiles1d',MAP);
system('copy /B out.CHR chr_plain1d.bin > logcpy.txt');
system('copy /B out.CLR clr_plain1d.bin > logcpy.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% encode in screen 2 odd tileset
arry2tile(Tiles2u',MAP);
system('copy /B out.CHR chr_plain2u.bin > logcpy.txt');
system('copy /B out.CLR clr_plain2u.bin > logcpy.txt');
arry2tile(Tiles2d',MAP);
system('copy /B out.CHR chr_plain2d.bin > logcpy.txt');
system('copy /B out.CLR clr_plain2d.bin > logcpy.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try to share color tables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  process even frame
fid = fopen('chr_plain1u.bin','r');
t = fread(fid,inf,'uint8'); 
chr1u = reshape(t,[8 size(t,1)/8]);
fclose(fid);
fid = fopen('chr_plain1d.bin','r');
t = fread(fid,inf,'uint8');
chr1d = reshape(t,[8 size(t,1)/8]);
fclose(fid);
fid = fopen('clr_plain1u.bin','r');
t = fread(fid,inf,'uint8');
clr1u = reshape(t,[8 size(t,1)/8]);
fclose(fid);
fid = fopen('clr_plain1d.bin','r');
t = fread(fid,inf,'uint8');
clr1d = reshape(t,[8 size(t,1)/8]);
fclose(fid);

if size(Tiles1u,1)<256
    Tiles1u  =  [ Tiles1u ; uint8(ones(256-size(Tiles1u,1),64)*255)];
end
if size(Tiles1d,1)<256
    Tiles1d  =  [ Tiles1d ; uint8(ones(256-size(Tiles1d,1),64)*255)];
end
if size(Tiles2u,1)<256
    Tiles2u  =  [ Tiles2u ; uint8(ones(256-size(Tiles2u,1),64)*255)];
end
if size(Tiles2d,1)<256
    Tiles2d  =  [ Tiles2d ; uint8(ones(256-size(Tiles2d,1),64)*255)];
end

[ newTiles1u,newTiles1d,PCT1,PGT1u,PGT1d ] = opt_clrs( chr1u,chr1d,clr1u,clr1d, Tiles1u,Tiles1d );
