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
        255,255,255];          % F White         255  255  255

TMSMAP = TMSMAP/255;


[B,MAP] = imread('grpx\uri0_rev2.png');
%[B,MAP] = imread('grpx\c64test.bmp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build level data
%B(:,1:128) =  0;
A = [];
for i = 1:(size(B,1)/128)
    A =  [A B((1+(i-1)*128):(i*128),:)];
end
Au = A(1:64,:);
Ad = A(65:128,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Palette
MAP = TMSMAP;
fid = fopen('palette.dat','w');
for i = 1:16
    fwrite(fid,fix(MAP(i,:)*255),'uint8');
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters

nlev = size(A,2)/size(B,2);
xstep = 2;
nphase = 8/xstep;
mapw = fix(size(A,2)/8);
maph = fix(size(A,1)/8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save parameters

fid = fopen('parametrs.asm','w');
fprintf (fid,'LvlWidth:		equ	%d \n',mapw/nlev);
fprintf (fid,'nlev:             equ	%d \n',nlev);
fprintf (fid,'nphase:		equ	%d \n',nphase);
fprintf (fid,'xstep:		equ	%d \n',xstep);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate scroll phases

InpTiles_u = cell(nphase,1);
InpTiles_d = cell(nphase,1);

for i=1:nphase
    t = ((i-1)*xstep+1);
    u = (t+(mapw-1)*8);
    InpTiles_u{i} = im2col(Au(:,t:u),'indexed',[8 8],'distinct');
    InpTiles_d{i} = im2col(Ad(:,t:u),'indexed',[8 8],'distinct');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract tileset from even frames
fprintf(1,' Tiles for phases ');
allTiles1 = [];
allTiles2 = [];
for i=1:2:nphase
    allTiles1 = [ allTiles1; InpTiles_u{i}'];
    allTiles2 = [ allTiles2; InpTiles_d{i}'];    
    fprintf(1,'%d ',i);
end
fprintf(1,' \n');
[Tiles1u,~, ~] = unique(allTiles1,'rows');
[Tiles1d,~, ~] = unique(allTiles2,'rows');
fprintf(1,' Number of tiles even frames upper bank: %d \n', size (Tiles1u,1));
fprintf(1,' Number of tiles even frames lowr bank: %d \n', size (Tiles1d,1));

% size(Tiles1u)
% size(Tiles1d)

t = intersect (Tiles1u,Tiles1d,'rows');
u = setdiff(Tiles1u,t,'rows');
v = setdiff(Tiles1d,t,'rows');
Tiles1u = [t ; u];
Tiles1d = [t ; v];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract tileset from odd frames
fprintf(1,' Tiles for phases ');
allTiles1 = [];
allTiles2 = [];
for i=2:2:nphase
    allTiles1 = [ allTiles1; InpTiles_u{i}'];
    allTiles2 = [ allTiles2; InpTiles_d{i}'];    
    fprintf(1,'%d ',i);
end
fprintf(1,' \n');
[Tiles2u,~, ~] = unique(allTiles1,'rows');
[Tiles2d,~, ~] = unique(allTiles2,'rows');
fprintf(1,' Number of tiles odd frames upper bank: %d \n', size (Tiles2u,1));
fprintf(1,' Number of tiles odd frames lowr bank: %d \n', size (Tiles2d,1));

t = intersect (Tiles2u,Tiles2d,'rows');
u = setdiff(Tiles2u,t,'rows');
v = setdiff(Tiles2d,t,'rows');
Tiles2u = [t ; u];
Tiles2d = [t ; v];

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

pc = find(all(PCT1'==0));

free1 = pc;

fprintf(1,' Number of free colors - even frames : %d \n', size(pc,2));
fprintf(1,' Number of used colors - even frames : %d \n', size(find(any(PCT1')),2));
fprintf(1,' Number of used shapes - even frames upper bank: %d \n', size(find(any(PGT1u')),2));
fprintf(1,' Number of used shapes - even frames lower bank: %d \n', size(find(any(PGT1d')),2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add manually fixed stars
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PCT1(256,:) = [ 5*16 7*16 5*16 0 0 0 0 0 ];
PGT1u(256,:) = [ 2 7 2 0 0 0 0 0 ];
PGT1d(256,:) = [ 2 7 2 0 0 0 0 0 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% color shared in even frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tiles1u = newTiles1u;
Tiles1d = newTiles1d;

% encode even tileset
fid = fopen('chr_plain1u.bin','w');
fwrite(fid,PGT1u','uint8');
fclose(fid);
fid = fopen('chr_plain1d.bin','w');
fwrite(fid,PGT1d','uint8');
fclose(fid);
fid = fopen('clr_plain1.bin','w');
fwrite(fid,PCT1','uint8');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  process odd frame
fid = fopen('chr_plain2u.bin','r');
t = fread(fid,inf,'uint8');
chr2u = reshape(t,[8 size(t,1)/8]);
fclose(fid);
fid = fopen('chr_plain2d.bin','r');
t = fread(fid,inf,'uint8');
chr2d = reshape(t,[8 size(t,1)/8]);
fclose(fid);
fid = fopen('clr_plain2u.bin','r');
t = fread(fid,inf,'uint8');
clr2u = reshape(t,[8 size(t,1)/8]);
fclose(fid);
fid = fopen('clr_plain2d.bin','r');
t = fread(fid,inf,'uint8');
clr2d = reshape(t,[8 size(t,1)/8]);
fclose(fid);

[ newTiles2u,newTiles2d,PCT2,PGT2u,PGT2d ] = opt_clrs( chr2u,chr2d,clr2u,clr2d, Tiles2u,Tiles2d );

pc = find(all(PCT2'==0));

free2 = pc;

fprintf(1,' Number of free colors - odd frames : %d \n', size(pc,2));
fprintf(1,' Number of used colors - odd frames : %d \n', size(find(any(PCT2')),2));
fprintf(1,' Number of used shapes - odd frames upper bank: %d \n', size(find(any(PGT2u')),2));
fprintf(1,' Number of used shapes - odd frames lower bank: %d \n', size(find(any(PGT2d')),2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add manually fixed stars
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
PCT2(256,:) = PCT1(256,:);
PGT2u(256,:) = PGT1u(256,:);
PGT2d(256,:) = PGT1d(256,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% color shared in odd frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tiles2u = newTiles2u;
Tiles2d = newTiles2d;

% encode odd tileset
fid = fopen('chr_plain2u.bin','w');
fwrite(fid,PGT2u','uint8');
fclose(fid);
fid = fopen('chr_plain2d.bin','w');
fwrite(fid,PGT2d','uint8');
fclose(fid);
fid = fopen('clr_plain2.bin','w');
fwrite(fid,PCT2','uint8');
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shared color  remapped
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pnt_u = cell(nphase,1);
pnt_d = cell(nphase,1);

for i=1:2:nphase
    [~,LOCB] = ismember(InpTiles_u{i}',Tiles1u,'rows','R2012a');    
    pnt_u{i} = reshape(LOCB,maph/2,mapw);
    [~,LOCB] = ismember(InpTiles_d{i}',Tiles1d,'rows','R2012a');
    pnt_d{i} = reshape(LOCB,maph/2,mapw);
end

for i=2:2:nphase
    [~,LOCB] = ismember(InpTiles_u{i}',Tiles2u,'rows','R2012a');    
    pnt_u{i} = reshape(LOCB,maph/2,mapw);
    [~,LOCB] = ismember(InpTiles_d{i}',Tiles2d,'rows','R2012a');
	pnt_d{i} = reshape(LOCB,maph/2,mapw);
end

%%%%%%%%%%%%%%%%%%%%
% build a vectorial PNT
%
vec_u = zeros(maph*mapw/2,nphase);
vec_d = zeros(maph*mapw/2,nphase);
figure;
for i=1:nphase
    subplot(nphase,1,i);
    vec_u (:,i) = pnt_u{i}(:);
    vec_d (:,i) = pnt_d{i}(:);
    image([pnt_u{i} ;pnt_d{i} ]);
end

%%%%%%%%%%%%%%%%%%%%
% test 1: rebuild nphase images from the pnt's
%

figure;
colormap(MAP);
for i=1:2:nphase
    subplot(nphase,1,i);
    C1 = col2im( Tiles1u(pnt_u{i},:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    C2 = col2im( Tiles1d(pnt_d{i},:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    image([C1 ;C2 ]);
end
for i=2:2:nphase
    subplot(nphase,1,i);
    C1 = col2im( Tiles2u(pnt_u{i},:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    C2 = col2im( Tiles2d(pnt_d{i},:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    image([C1 ;C2 ]);
end

%
%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate meta level and tables for 
% converting meta level to screen tiles at 
% each phase

[meta_pnt_table_u,~,~] = unique(vec_u,'rows');
fprintf(1,' \n Number of meta tiles upper bank: %d \n', size(meta_pnt_table_u,1));

[meta_pnt_table_d,~,~] = unique(vec_d,'rows');
fprintf(1,' Number of meta tiles lower bank: %d \n', size(meta_pnt_table_d,1));

a = intersect(meta_pnt_table_u,meta_pnt_table_d,'rows');
b = setdiff  (meta_pnt_table_u,meta_pnt_table_d,'rows');
c = setdiff  (meta_pnt_table_d,meta_pnt_table_u,'rows');

meta_pnt_table_u = [a ; b];
meta_pnt_table_d = [a ; c];

[~,LOCB] = ismember(vec_u,meta_pnt_table_u,'rows');    
meta_pnt_u = reshape(LOCB,maph/2,mapw);

[LIA,LOCB] = ismember(vec_d,meta_pnt_table_d,'rows');    
meta_pnt_d = reshape(LOCB,maph/2,mapw);

figure;
pntud = [meta_pnt_u ;meta_pnt_d ];
image(pntud);
pntud = pntud -1;

%%%%%%%%%%%%%%%%%%%%
% test 2
% rebuild phases from the meta_pnt_u

figure;
colormap(MAP);
axis equal;

for i=1:2:nphase
    Cu = col2im( Tiles1u(meta_pnt_table_u(meta_pnt_u(:),i),:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    Cd = col2im( Tiles1d(meta_pnt_table_d(meta_pnt_d(:),i),:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    subplot(nphase,1,i);image([Cu ;Cd ]);axis equal;

    Cu = col2im( Tiles2u(meta_pnt_table_u(meta_pnt_u(:),i+1),:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    Cd = col2im( Tiles2d(meta_pnt_table_d(meta_pnt_d(:),i+1),:)',[8 8],[maph/2*8 mapw*8 ],'distinct');
    subplot(nphase,1,i+1);image([Cu ;Cd ]);axis equal;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save all data

% table from meta_pnt to pnt in nphases (up & down)
% size n_transitions x nphases
fid = fopen('data_bin\meta_pnt_table_u_ms.bin','w');
t = zeros(256,nphase); t(1:size(meta_pnt_table_u,1),:) = meta_pnt_table_u;
fwrite(fid,t-1,'uint8');
fclose(fid);
fid = fopen('data_bin\meta_pnt_table_d_ms.bin','w');
t = zeros(256,nphase); t(1:size(meta_pnt_table_d,1),:) = meta_pnt_table_d;
fwrite(fid,t-1,'uint8');
fclose(fid);

!meta_miz.bat
 
% level data:  meta_pnt (up & down)
% size mapw x maph/2
% fid = fopen('meta_pnt_u.bin','w');
% fwrite(fid,meta_pnt_u'-1,'uint8');
% fclose(fid);
% fid = fopen('meta_pnt_d.bin','w');
% fwrite(fid,meta_pnt_d'-1,'uint8');
% fclose(fid);

!del clr_plain1u.bin
!del clr_plain1d.bin
!del clr_plain2u.bin
!del clr_plain2d.bin

mw = mapw/nlev;
for i=1:nlev 
    j = fix( (i-1)*mw + (1:mw));
    t = meta_pnt_u(:,j);
    fid = fopen(['lev_' dec2hex(i) '.bin'],'w');
    fwrite(fid,t'-1,'uint8');
    t = meta_pnt_d(:,j);
    fwrite(fid,t'-1,'uint8');
    fclose(fid);
end    

system('miz\MSX-O-Mizer -r chr_plain1u.bin data_miz\chr_plain1u_ms.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r chr_plain1d.bin data_miz\chr_plain1d_ms.miz > logcpy.txt');

system('miz\MSX-O-Mizer -r chr_plain2u.bin data_miz\chr_plain2u_ms.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r chr_plain2d.bin data_miz\chr_plain2d_ms.miz > logcpy.txt');

system('miz\MSX-O-Mizer -r clr_plain1.bin data_miz\clr_plain1_ms.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r clr_plain2.bin data_miz\clr_plain2_ms.miz > logcpy.txt');


system(['.\miz\MSX-O-Mizer.exe -r .\data_bin\meta_pnt_table_d_ms.bin .\data_miz\meta_pnt_table_d_ms.miz ']);
system(['.\miz\MSX-O-Mizer.exe -r .\data_bin\meta_pnt_table_u_ms.bin .\data_miz\meta_pnt_table_u_ms.miz']);


% system('copy /b  meta_pnt_u.bin +meta_pnt_d.bin meta_pnt.bin');
% system('miz\MSX-O-Mizer -r meta_pnt.bin meta_pnt.miz> logcpy.txt');


for i=1:nlev 
    system(['miz\MSX-O-Mizer -r lev_' (dec2hex(i)) '.bin  data_miz\lev_' (dec2hex(i)) '.miz > logcpy.txt' ]);
    system(['move lev_' (dec2hex(i)) '.bin data_bin > logcpy.txt']);
end

system(['copy data_miz\lev_1.miz data_miz\lev_ms.miz > logcpy.txt']);

system('move chr_plain*.bin data_bin > logcpy.txt');
system('move clr_plain*.bin data_bin > logcpy.txt');


!make.bat
% return
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % deal with blocking and desctructable blocks
% %
% 
% blocking   = unique(im2col(C(1:64,:),'indexed',[8 8],'distinct')','rows');  % Y = 0-63 ostacoli
% 
% interact1  = unique(im2col(C(65: 96,1:128),'indexed',[8 8],'distinct')','rows'); % Y = 64-95, X = 0-127 distruttibili 3x1 interi (da cercare)
% interact2  = unique(im2col(C(97:128,1:128),'indexed',[8 8],'distinct')','rows'); % Y = 96-127, X = 0-127 distruttibili 3x1 distrutti (da cercare)
% 
% interact11 = unique(im2col(C(65: 96,129:end),'indexed',[8 8],'distinct')','rows'); % Y = 64-95, X = 128-255 distruttibili 3x2 interi (da cercare)
% interact22 = unique(im2col(C(97:128,129:end),'indexed',[8 8],'distinct')','rows'); % Y = 64-95, X = 128-255 distruttibili 3x2 distrutti(da cercare)
% 
% 
% blocking  = blocking(3:end,:);
% interact1 = interact1(3:end,:);
% interact2 = interact2(3:end,:);
% interact11 = interact11(3:end,:);
% interact22 = interact22(3:end,:);
% 
% figure
% subplot(1,5,1)
% image(col2im(blocking',[8 8],[8*size(blocking,1) 8],'distinct'))
% axis equal
% subplot(1,5,2)
% image(col2im(interact1',[8 8],[8*size(interact1,1) 8],'distinct'))
% axis equal
% colormap(MAP)
% subplot(1,5,3)
% image(col2im(interact2',[8 8],[8*size(interact2,1) 8],'distinct'))
% axis equal
% colormap(MAP)
% subplot(1,5,4)
% image(col2im(interact11',[8 8],[8*size(interact11,1) 8],'distinct'))
% axis equal
% colormap(MAP)
% subplot(1,5,5)
% image(col2im(interact22',[8 8],[8*size(interact22,1) 8],'distinct'))
% axis equal
% colormap(MAP)
% 
% % flag_array = ones(256,1)*255;
% 
% %permutemetatile
% 
% [~,LOCu] = ismember(blocking,Tiles1u,'rows','R2012a');    
% [~,LOCd] = ismember(blocking,Tiles1d,'rows','R2012a');
% 
% [~,ju] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jd] = ismember(LOCd,meta_pnt_table_d(:,1));
% 
% [ju jd]
% 
% % flag_array(ju) = flag_array(ju) - 1;
% % flag_array(jd) = flag_array(jd) - 2;
% 
% fid = fopen('blocktiles.asm','w');
% fprintf (fid,'n_block_up: equ	%d \n',length(ju));
% fprintf (fid,'block_up: \n');
% fprintf (fid,'	db	%d \n',ju-1);
% fprintf (fid,'n_block_dwn: equ	%d \n',length(jd));
% fprintf (fid,'block_dwn: \n');
% fprintf (fid,'	db	%d \n',jd-1);
% 
% [~,LOCu] = ismember(interact1,Tiles1u,'rows','R2012a');    
% [~,LOCd] = ismember(interact1,Tiles1d,'rows','R2012a');
% [~,ju] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jd] = ismember(LOCd,meta_pnt_table_d(:,1));
% 
% [i,j] = find(meta_pnt_u==ju);
% ju = [meta_pnt_u(i(1),j(1)-1) ju]; 
% 
% [i,j] = find(meta_pnt_d==jd);
% jd = [meta_pnt_d(i(1),j(1)-1) jd]; 
% 
% 
% [~,LOCu] = ismember(interact2,Tiles1u,'rows','R2012a');    
% [~,LOCd] = ismember(interact2,Tiles1d,'rows','R2012a');
% [~,jju] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jjd] = ismember(LOCd,meta_pnt_table_d(:,1));
% 
% [i,j] = find(meta_pnt_u==jju);
% jju = [meta_pnt_u(i(1),j(1)-1) jju]; 
% 
% [i,j] = find(meta_pnt_d==jjd);
% jjd = [meta_pnt_d(i(1),j(1)-1) jjd]; 
% 
% %%%%%%%%%%%%%%%%%%%%%
% % process 3x2 items!!
% %
% 
% [~,LOCu] = ismember(interact11,Tiles1u,'rows','R2012a');    
% [~,LOCd] = ismember(interact11,Tiles1d,'rows','R2012a');
% [~,j11u] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,j11d] = ismember(LOCd,meta_pnt_table_d(:,1)); 
% 
% 
% [i,j] = find(meta_pnt_u==j11u(1));
% i = i(1); j = j(1);
% j11u = [meta_pnt_u(i,j-1); j11u(1) ;  meta_pnt_u(i,j+1); meta_pnt_u(i+1,j-1); meta_pnt_u(i+1,j);  meta_pnt_u(i+1,j+1)];
%  
% [i,j] = find(meta_pnt_d==j11d(1));
% i = i(1); j = j(1);
% j11d = [meta_pnt_d(i,j-1); j11d(1) ;  meta_pnt_d(i,j+1); meta_pnt_d(i+1,j-1); meta_pnt_d(i+1,j);  meta_pnt_d(i+1,j+1)];
%  
% 
% % flag_array(ju) = flag_array(ju) - 4;
% % flag_array(jd) = flag_array(jd) - 8;
% 
% [~,LOCu] = ismember(interact22,Tiles1u,'rows','R2012a');    
% [~,LOCd] = ismember(interact22,Tiles1d,'rows','R2012a');
% [~,jj22u] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jj22d] = ismember(LOCd,meta_pnt_table_d(:,1));
% 
% [i,j] = find(meta_pnt_u==jj22u(1));
% i = i(1); j = j(1);
% jj22u = [meta_pnt_u(i,j-1); jj22u(1) ;  meta_pnt_u(i,j+1); meta_pnt_u(i+1,j-1); meta_pnt_u(i+1,j);  meta_pnt_u(i+1,j+1)];
%  
% [i,j] = find(meta_pnt_d==jj22d(1));
% i = i(1); j = j(1);
% jj22d = [meta_pnt_d(i,j-1); jj22d(1) ;  meta_pnt_d(i,j+1); meta_pnt_d(i+1,j-1); meta_pnt_d(i+1,j);  meta_pnt_d(i+1,j+1)];
% 
% 
% fprintf (fid,'n_interact_up: equ	%d \n',length(ju));
% fprintf (fid,'n_interact_dwn: equ	%d \n',length(jd));
% 
% fprintf (fid,'interact_up: \n');
% fprintf (fid,'	db	%d \n',ju-1);
% 
% fprintf (fid,'interact_2x2_up: \n');
% fprintf (fid,'	db	%d \n',j11u-1);
% 
% fprintf (fid,'interact_distr_up: \n');
% fprintf (fid,'	db	%d \n',jju-1);
% 
% fprintf (fid,'interact_distr_2x2_up: \n');
% fprintf (fid,'	db	%d \n',jj22u-1);
% 
% 
% fprintf (fid,'interact_dwn: \n');
% fprintf (fid,'	db	%d \n',jd-1);
% 
% fprintf (fid,'interact_2x2_dwn: \n');
% fprintf (fid,'	db	%d \n',j11d-1);
% 
% fprintf (fid,'interact_distr_dwn: \n');
% fprintf (fid,'	db	%d \n',jjd-1);
% 
% fprintf (fid,'interact_distr_2x2_dwn: \n');
% fprintf (fid,'	db	%d \n',jj22d-1);
% 
% fclose(fid);
% 
% % fid = fopen('flag_array.asm','w');
% % fprintf (fid,'	db	%d \n',flag_array);
% % fclose(fid);
% 
% figure
% colormap(MAP);
% axis equal;
% 
% t = [];
% for i=1:size(meta_pnt_table_u,1)
%     t1 = col2im( Tiles1u(meta_pnt_table_u(i,1),:)',[8 8],[8 8 ],'distinct');
%     t2 = col2im( Tiles2u(meta_pnt_table_u(i,2),:)',[8 8],[8 8 ],'distinct');
%     t3 = col2im( Tiles1u(meta_pnt_table_u(i,3),:)',[8 8],[8 8 ],'distinct');
%     t4 = col2im( Tiles2u(meta_pnt_table_u(i,4),:)',[8 8],[8 8 ],'distinct');
%     t = [t [t1 ; t2; t3; t4 ]];
%     subplot(2,1,1);
%     image(t);
%     axis equal;
% end
% s = [];
% for i=1:size(meta_pnt_table_d,1)
%     s1 = col2im( Tiles1d(meta_pnt_table_d(i,1),:)',[8 8],[8 8 ],'distinct');
%     s2 = col2im( Tiles2d(meta_pnt_table_d(i,2),:)',[8 8],[8 8 ],'distinct');
%     s3 = col2im( Tiles1d(meta_pnt_table_d(i,3),:)',[8 8],[8 8 ],'distinct');
%     s4 = col2im( Tiles2d(meta_pnt_table_d(i,4),:)',[8 8],[8 8 ],'distinct');
%     s = [s [s1 ; s2; s3; s4 ]];
%     subplot(2,1,2);
%     image(s);
%     axis equal;
% end
% 
% !make.bat

