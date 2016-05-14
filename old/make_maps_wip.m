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

[B,MAP] = imread('grpx\New Levels.png');
[C,MAP] = imread('grpx\blocking.png');
[D,MAP] = imread('grpx\destructables2x1.png');
[E,MAP] = imread('grpx\destructables3x2.png');

MAP = MAP(1:16,:);

m = zeros(5,16);

m(1,:) = 1 + [0:15]; % BLUE
m(2,:) = 1 + [	0, 1, 2, 3,12, 2,6, 7, 8,9,10, 4,11,13,14,15]; % GREEN
m(3,:) = 1 + [	0, 1, 2, 3,10,15,4, 5, 9,8, 6, 4,12,13, 5,14]; % YELLOW
%m(3,:) = 1 + [	0, 1, 2, 3,14,15,4, 5, 9,8, 6, 4,12,13, 5,15]; % gray
m(4,:) = 1 + [  0, 1, 2, 3,13,14,6, 7, 8,9,10,15,10, 9,11,15]; % MAGENTA
m(5,:) = 1 + [	0, 1, 2, 3, 6,14,7,15, 8,9,10,15, 3,13,14,15]; % RED

for i=1:5
    name = sprintf ('m%d.asm',i);
    fid = fopen(name,'w');
    fprintf (fid,'   db ');
    fprintf (fid,'%d, ',m(i,1:(end-1))-1);
    fprintf (fid,'%d \n',m(i,end)-1);
    fclose(fid);
    name(end-2:end) = 'png';
    imwrite(B,MAP(m(i,:),:),name);
end

% figure;
% image(B);

% colormap(MAP(m0,:)); 
% input('');
% colormap(MAP(m1,:));
% input('');
% colormap(MAP(m2,:));
% input('');
% colormap(MAP(m3,:));
% input('');
% colormap(MAP(m4,:));
% input('');


% keyboard


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build level data
B(:,1:128) =  0;
A = [];
for i = 1:(size(B,1)/128)
    if (i<=16) 
        A =  [A B((1+(i-1)*128):(i*128),:)];
    end
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
% generate scroll phases

InpTiles_u = cell(nphase,1);
InpTiles_d = cell(nphase,1);

BlockTiles = cell(nphase,1);
Destr2x1_sane = cell(nphase,1);
Destr2x1_dest = cell(nphase,1);
Destr3x2_sane = cell(nphase,1);
Destr3x2_dest = cell(nphase,1);

for i=1:nphase
    t = ((i-1)*xstep+1);
    u = (t+(mapw-1)*8);
    InpTiles_u{i} = im2col(Au(:,t:u),'indexed',[8 8],'distinct');
    InpTiles_d{i} = im2col(Ad(:,t:u),'indexed',[8 8],'distinct');
    
    BlockTiles{i} = im2col(C(:,t:end),'indexed',[8 8],'distinct');
    Destr2x1_sane{i} = im2col(D( 1:32,t:end),'indexed',[8 8],'distinct');
    Destr2x1_dest{i} = im2col(D(33:64,t:end),'indexed',[8 8],'distinct');
    Destr3x2_sane{i} = im2col(E( 1:32,t:end),'indexed',[8 8],'distinct');
    Destr3x2_dest{i} = im2col(E(33:64,t:end),'indexed',[8 8],'distinct');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract tileset from even frames
fprintf(1,' Tiles for phases ');
allTilesu = [];
allTilesd = [];
allBlockTiles = [];
for i=1:2:nphase
    allTilesu = [ allTilesu; InpTiles_u{i}'];
    allTilesd = [ allTilesd; InpTiles_d{i}'];
    allBlockTiles = [allBlockTiles; BlockTiles{i}'];
    fprintf(1,'%d ',i);
end
fprintf(1,' \n');
[Tiles1u,~, ~] = unique(allTilesu,'rows');
[Tiles1d,~, ~] = unique(allTilesd,'rows');
[BlockTiles1,~, ~] = unique(allBlockTiles,'rows');
fprintf(1,' Number of tiles even frames upper bank: %d \n', size (Tiles1u,1));
fprintf(1,' Number of tiles even frames lower bank: %d \n', size (Tiles1d,1));



t = intersect (Tiles1u,Tiles1d,'rows');
uniqueTiles1u = setdiff(Tiles1u,t,'rows');
uniqueTiles1d = setdiff(Tiles1d,t,'rows');
b = intersect (t,BlockTiles1,'rows');
t = setdiff(t,b,'rows');
commonuniqueTiles1 = [b; t ];
% Tiles1u = [commonuniqueTiles1  ; uniqueTiles1u];
% Tiles1d = [commonuniqueTiles1  ; uniqueTiles1d];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract tileset from odd frames
fprintf(1,' Tiles for phases ');
allTilesu = [];
allTilesd = [];
allBlockTiles = [];
for i=2:2:nphase
    allTilesu = [ allTilesu; InpTiles_u{i}'];
    allTilesd = [ allTilesd; InpTiles_d{i}'];
    allBlockTiles = [allBlockTiles; BlockTiles{i}'];
    fprintf(1,'%d ',i);
end
fprintf(1,' \n');
[Tiles2u,~, ~] = unique(allTilesu,'rows');
[Tiles2d,~, ~] = unique(allTilesd,'rows');
[BlockTiles2,~, ~] = unique(allBlockTiles,'rows');
fprintf(1,' Number of tiles odd frames upper bank: %d \n', size (Tiles2u,1));
fprintf(1,' Number of tiles odd frames lowr bank: %d \n', size (Tiles2d,1));

t = intersect (Tiles2u,Tiles2d,'rows');
uniqueTiles2u = setdiff(Tiles2u,t,'rows');
uniqueTiles2d = setdiff(Tiles2d,t,'rows');
b = intersect (t,BlockTiles2,'rows');
t = setdiff(t,b,'rows');
commonuniqueTiles2 = [b; t ];
% Tiles2u = [commonuniqueTiles2 ; uniqueTiles2u];
% Tiles2d = [commonuniqueTiles2 ; uniqueTiles2d];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[chr1c,clr1c] = vdpencode (commonuniqueTiles1,MAP);
[chr1u,chr1d,clr1ud,nTu,nTd] = jointoptimalvdpencode(uniqueTiles1u,uniqueTiles1d,MAP);
uniqueTiles1u = nTu;
uniqueTiles1d = nTd;

fid = fopen('chr1_common.bin','w');fwrite(fid,chr1c,'uint8');fclose(fid);
fid = fopen('clr1_common.bin','w');fwrite(fid,clr1c,'uint8');fclose(fid);
fid = fopen('chr1_up.bin','w');fwrite(fid,chr1u','uint8');fclose(fid);
fid = fopen('chr1_dw.bin','w');fwrite(fid,chr1d','uint8');fclose(fid);
fid = fopen('clr1_ud.bin','w');fwrite(fid,clr1ud','uint8');fclose(fid);

[chr2c,clr2c] = vdpencode (commonuniqueTiles2,MAP);
[chr2u,chr2d,clr2ud,nTu,nTd] = jointoptimalvdpencode(uniqueTiles2u,uniqueTiles2d,MAP);
uniqueTiles2u = nTu;
uniqueTiles2d = nTd;

fid = fopen('chr2_common.bin','w');fwrite(fid,chr2c,'uint8');fclose(fid);
fid = fopen('clr2_common.bin','w');fwrite(fid,clr2c,'uint8');fclose(fid);
fid = fopen('chr2_up.bin','w');fwrite(fid,chr2u','uint8');fclose(fid);
fid = fopen('chr2_dw.bin','w');fwrite(fid,chr2d','uint8');fclose(fid);
fid = fopen('clr2_ud.bin','w');fwrite(fid,clr2ud','uint8');fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remap tilesets

Tiles1u = [commonuniqueTiles1 ; uniqueTiles1u];
Tiles1d = [commonuniqueTiles1 ; uniqueTiles1d];
Tiles2u = [commonuniqueTiles2 ; uniqueTiles2u];
Tiles2d = [commonuniqueTiles2 ; uniqueTiles2d];

fprintf(1,'\n');
fprintf(1,' Number of tiles actually used in even frames: %d \n', size (Tiles1u,1));
fprintf(1,' Number of tiles actually used in odd frames: %d \n', size (Tiles2u,1));


% Byte: #FE (Type of file)
% Word: Begin address of file
% Word: End address of file
% Word: Start address of file

fid = fopen('msx2\Tiles1u.bin','w');t = Tiles1u(:);fwrite(fid,t(1:2:end)+t(2:2:end)*16,'uint8');fclose(fid);
fid = fopen('msx2\Tiles1d.bin','w');t = Tiles1d(:);fwrite(fid,t(1:2:end)+t(2:2:end)*16,'uint8');fclose(fid);
fid = fopen('msx2\Tiles2u.bin','w');t = Tiles2u(:);fwrite(fid,t(1:2:end)+t(2:2:end)*16,'uint8');fclose(fid);
fid = fopen('msx2\Tiles2d.bin','w');t = Tiles2d(:);fwrite(fid,t(1:2:end)+t(2:2:end)*16,'uint8');fclose(fid);

%A = col2im(T,[8 8],[256 192],'distinct')';
%A = blkproc(A,[8 8], @transpose);

t = zeros(256,64); t(1:size(Tiles1u,1),:) = Tiles1u;
s1u = blkproc(1+col2im(t',[8 8],[256 64],'distinct')',[8 8], @transpose);
t = zeros(256,64); t(1:size(Tiles1d,1),:) = Tiles1d;
s1d = blkproc(1+col2im(t',[8 8],[256 64],'distinct')',[8 8], @transpose);
t = zeros(256,64); t(1:size(Tiles2u,1),:) = Tiles2u;
s2u = blkproc(1+col2im(t',[8 8],[256 64],'distinct')',[8 8], @transpose);
t = zeros(256,64); t(1:size(Tiles2d,1),:) = Tiles2d;
s2d = blkproc(1+col2im(t',[8 8],[256 64],'distinct')',[8 8], @transpose);
image([ s1u; s1d; s2u; s2d; ]);
colormap(MAP)
axis equal
imwrite([ s1u; s1d; s2u; s2d; ],MAP,'tileset_in_bitmap.png') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shared color  remapped
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pnt_u = cell(nphase,1);
pnt_d = cell(nphase,1);
block = cell(nphase,1);
D2x1_sane = cell(nphase,1);
D2x1_dest = cell(nphase,1);
D3x2_sane = cell(nphase,1);
D3x2_dest = cell(nphase,1);


for i=1:2:nphase
    [~,LOCB] = ismember(InpTiles_u{i}',Tiles1u,'rows','R2012a');
    pnt_u{i} = reshape(LOCB,maph/2,mapw);
    [~,LOCB] = ismember(InpTiles_d{i}',Tiles1d,'rows','R2012a');
    pnt_d{i} = reshape(LOCB,maph/2,mapw);
    
    [~,LOCBu] = ismember(BlockTiles{i}',Tiles1u,'rows','R2012a');
    [~,LOCBd] = ismember(BlockTiles{i}',Tiles1d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    block{i} = reshape(LOCB,8,32);
    
    [~,LOCBu] = ismember(Destr2x1_sane{i}',Tiles1u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr2x1_sane{i}',Tiles1d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D2x1_sane{i} = reshape(LOCB,4,32);
    
    [~,LOCBu] = ismember(Destr2x1_dest{i}',Tiles1u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr2x1_dest{i}',Tiles1d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D2x1_dest{i} = reshape(LOCB,4,32);
    
    [~,LOCBu] = ismember(Destr3x2_sane{i}',Tiles1u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr3x2_sane{i}',Tiles1d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D3x2_sane{i} = reshape(LOCB,4,32);
    
    [~,LOCBu] = ismember(Destr3x2_dest{i}',Tiles1u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr3x2_dest{i}',Tiles1d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D3x2_dest{i} = reshape(LOCB,4,32);
end

for i=2:2:nphase
    [~,LOCB] = ismember(InpTiles_u{i}',Tiles2u,'rows','R2012a');
    pnt_u{i} = reshape(LOCB,maph/2,mapw);
    [~,LOCB] = ismember(InpTiles_d{i}',Tiles2d,'rows','R2012a');
    pnt_d{i} = reshape(LOCB,maph/2,mapw);
    
    [~,LOCBu] = ismember(BlockTiles{i}',Tiles2u,'rows','R2012a');
    [~,LOCBd] = ismember(BlockTiles{i}',Tiles2d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    block{i} = reshape(LOCB,8,32);
    
    [~,LOCBu] = ismember(Destr2x1_sane{i}',Tiles2u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr2x1_sane{i}',Tiles2d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D2x1_sane{i} = reshape(LOCB,4,32);
    
    [~,LOCBu] = ismember(Destr2x1_dest{i}',Tiles2u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr2x1_dest{i}',Tiles2d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D2x1_dest{i} = reshape(LOCB,4,32);
    
    [~,LOCBu] = ismember(Destr3x2_sane{i}',Tiles2u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr3x2_sane{i}',Tiles2d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D3x2_sane{i} = reshape(LOCB,4,32);
    
    [~,LOCBu] = ismember(Destr3x2_dest{i}',Tiles2u,'rows','R2012a');
    [~,LOCBd] = ismember(Destr3x2_dest{i}',Tiles2d,'rows','R2012a');
    LOCB = bitor(LOCBu',LOCBd');
    D3x2_dest{i} = reshape(LOCB,4,32);
end

% place dummy tiles for transitions not presents in the map
for i=1:nphase
    block{i}(block{i}==0) = 1;
end

%%%%%%%%%%%%%%%%%%%%
% build a vectorial PNT
%
vec_u = zeros(maph*mapw/2,nphase);
vec_d = zeros(maph*mapw/2,nphase);
vec_block = zeros(32*8,nphase);
vec_D2x1_sane = zeros(32*4,nphase);
vec_D2x1_dest = zeros(32*4,nphase);
vec_D3x2_sane = zeros(32*4,nphase);
vec_D3x2_dest = zeros(32*4,nphase);

figure;
for i=1:nphase
    subplot(nphase,1,i);
    vec_u (:,i) = pnt_u{i}(:);
    vec_d (:,i) = pnt_d{i}(:);
    image([pnt_u{i} ;pnt_d{i} ]);
end
figure;
for i=1:nphase
    subplot(nphase,1,i);
    vec_block (:,i) =  block{i}(:);
    image(block{i});
end
figure;
for i=1:nphase
    subplot(nphase,1,i);
    vec_D2x1_sane (:,i) =  D2x1_sane{i}(:);
    vec_D2x1_dest (:,i) =  D2x1_dest{i}(:);
    image([D2x1_sane{i}; D2x1_dest{i}]);
end
figure;
for i=1:nphase
    subplot(nphase,1,i);
    vec_D3x2_sane (:,i) =  D3x2_sane{i}(:);
    vec_D3x2_dest (:,i) =  D3x2_dest{i}(:);
    image([D3x2_sane{i}; D3x2_dest{i}]);
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
figure;
colormap(MAP);
for i=1:2:nphase
    subplot(nphase,1,i);
    C1 = col2im( Tiles1u(block{i},:)',[8 8],[8*8 32*8 ],'distinct');
    C2 = col2im( Tiles1d(block{i},:)',[8 8],[8*8 32*8 ],'distinct');
    image([C1 ;C2 ]);
    axis equal
end
for i=2:2:nphase
    subplot(nphase,1,i);
    C1 = col2im( Tiles2u(block{i},:)',[8 8],[8*8 32*8 ],'distinct');
    C2 = col2im( Tiles2d(block{i},:)',[8 8],[8*8 32*8 ],'distinct');
    image([C1 ;C2 ]);
    axis equal
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate meta level and tables for
% converting meta level to screen tiles at
% each phase
%
% 2x1
vec_D2x1_sane = vec_D2x1_sane(~any(vec_D2x1_sane'==0),:); % remove vector with 0's
vec_D2x1_dest = vec_D2x1_dest(~any(vec_D2x1_dest'==0),:); % remove vector with 0's

uniquevec_D2x1_sane = vec_D2x1_sane(~all(vec_D2x1_sane'==1),:); % remove vector with all 1's
uniquevec_D2x1_dest = vec_D2x1_dest(~all(vec_D2x1_dest'==1),:); % remove vector with all 1's

% 3x2
vec_D3x2_sane = vec_D3x2_sane(~any(vec_D3x2_sane'==0),:); % remove vector with 0's
vec_D3x2_dest = vec_D3x2_dest(~any(vec_D3x2_dest'==0),:); % remove vector with 0's

uniquevec_D3x2_sane = vec_D3x2_sane(~all(vec_D3x2_sane'==1),:); % remove vector with all 1's
uniquevec_D3x2_dest = vec_D3x2_dest(~all(vec_D3x2_dest'==1),:); % remove vector with all 1's

uniquevec_block = unique(vec_block,'rows');

[meta_pnt_table_u,~,~] = unique(vec_u,'rows');
fprintf(1,' \n Number of meta tiles upper bank: %d \n', size(meta_pnt_table_u,1));

[meta_pnt_table_d,~,~] = unique(vec_d,'rows');
fprintf(1,' Number of meta tiles lower bank: %d \n', size(meta_pnt_table_d,1));

allvecs = union(meta_pnt_table_u,meta_pnt_table_d,'rows');

usedvec_block = intersect(uniquevec_block,allvecs,'rows');

nonblock_u = setdiff  (meta_pnt_table_u,usedvec_block,'rows');
nonblock_d = setdiff  (meta_pnt_table_d,usedvec_block,'rows');

nonblock_common = intersect(nonblock_u,nonblock_d,'rows');
unique_u = setdiff  (nonblock_u,nonblock_common,'rows');
unique_d = setdiff  (nonblock_d,nonblock_common,'rows');

non_interact_D2x1_sane = setdiff(nonblock_common       ,uniquevec_D2x1_sane,'rows');
non_interact_D2x1_dest = setdiff(non_interact_D2x1_sane,uniquevec_D2x1_dest,'rows');
non_interact_D3x2_sane = setdiff(non_interact_D2x1_dest,uniquevec_D3x2_sane,'rows');
others_common          = setdiff(non_interact_D3x2_sane,uniquevec_D3x2_dest,'rows');

nonblock_common = [uniquevec_D2x1_sane;uniquevec_D2x1_dest;uniquevec_D3x2_sane;uniquevec_D3x2_dest;others_common];

%% WIP WIP WIP

meta_pnt_table_u = [usedvec_block ; nonblock_common; unique_u];
meta_pnt_table_d = [usedvec_block ; nonblock_common; unique_d];

fprintf(1,' Number of meta tiles upper bank after sorting: %d \n', size(meta_pnt_table_u,1));
fprintf(1,' Number of meta tiles lower bank after sorting: %d \n', size(meta_pnt_table_d,1));

[~,LOCB] = ismember(vec_u,meta_pnt_table_u,'rows');
meta_pnt_u = reshape(LOCB,maph/2,mapw);

[LIA,LOCB] = ismember(vec_d,meta_pnt_table_d,'rows');
meta_pnt_d = reshape(LOCB,maph/2,mapw);

figure;
pntud = [meta_pnt_u ;meta_pnt_d ];
image(pntud);
axis equal


%map_inspect(123,pntud,meta_pnt_table_u,meta_pnt_table_d,Tiles1u,Tiles1d,Tiles2u,Tiles2d,MAP);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute how many matatiles are "solid"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nblock = size(usedvec_block,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save parameters

n_common_tiles1 = size(commonuniqueTiles1,1);
n_common_tiles2 = size(commonuniqueTiles2,1);

fid = fopen('parametrs.asm','w');
fprintf (fid,'LvlWidth:		equ	%d \n',mapw/nlev);
fprintf (fid,'nlev:             equ	%d \n',nlev);
fprintf (fid,'nphase:		equ	%d \n',nphase);
fprintf (fid,'xstep:		equ	%d \n',xstep);
fprintf (fid,'nblock:		equ	%d \n',nblock);

fprintf (fid,'n_common_tiles1:		equ	%d \n',n_common_tiles1);
fprintf (fid,'n_common_tiles2:		equ	%d \n',n_common_tiles2);

n_d2x1 = size(uniquevec_D2x1_sane,1);
n_d3x2 = size(uniquevec_D3x2_sane,1);

fprintf (fid,'n_d2x1:		equ	%d \n',n_d2x1);
fprintf (fid,'n_d3x2:		equ	%d \n',n_d3x2);

fclose(fid);


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
fid = fopen('data_bin\meta_pnt_table_u.bin','w');
t = zeros(256,nphase);
t(1:size(meta_pnt_table_u,1),:) = meta_pnt_table_u;
fwrite(fid,t-1,'uint8');
fclose(fid);
fid = fopen('data_bin\meta_pnt_table_d.bin','w');
t = zeros(256,nphase);
t(1:size(meta_pnt_table_d,1),:) = meta_pnt_table_d;
fwrite(fid,t-1,'uint8');
fclose(fid);


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

system('miz\MSX-O-Mizer -r chr1_common.bin data_miz\chr1_common.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r clr1_common.bin data_miz\clr1_common.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r chr2_common.bin data_miz\chr2_common.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r clr2_common.bin data_miz\clr2_common.miz > logcpy.txt');

system('miz\MSX-O-Mizer -r chr1_up.bin data_miz\chr1_up.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r chr1_dw.bin data_miz\chr1_dw.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r clr1_ud.bin data_miz\clr1_ud.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r chr2_up.bin data_miz\chr2_up.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r chr2_dw.bin data_miz\chr2_dw.miz > logcpy.txt');
system('miz\MSX-O-Mizer -r clr2_ud.bin data_miz\clr2_ud.miz > logcpy.txt');

% system('copy /b  meta_pnt_u.bin +meta_pnt_d.bin meta_pnt.bin');
% system('miz\MSX-O-Mizer -r meta_pnt.bin meta_pnt.miz> logcpy.txt');

system('.\miz\MSX-O-Mizer.exe -r .\data_bin\meta_pnt_table_d.bin .\data_miz\meta_pnt_table_d.miz > logcpy.txt');
system('.\miz\MSX-O-Mizer.exe -r .\data_bin\meta_pnt_table_u.bin .\data_miz\meta_pnt_table_u.miz > logcpy.txt');


for i=1:nlev
    system(['miz\MSX-O-Mizer -r lev_' (dec2hex(i)) '.bin  data_miz\lev_' (dec2hex(i)) '.miz > logcpy.txt' ]);
    system(['move lev_' (dec2hex(i)) '.bin data_bin > logcpy.txt']);
end


system('move chr*.bin data_bin > logcpy.txt');
system('move clr*.bin data_bin > logcpy.txt');

return




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deal with blocking and desctructable blocks
%

% Y = 0-63 ostacoli
% blocking   = unique(im2col(C(1:64,:),'indexed',[8 8],'distinct')','rows');

% Y = 64-95, X = 0-127 distruttibili 3x1 interi (da cercare)
% interact1  = unique(im2col(C(65: 96,1:128),'indexed',[8 8],'distinct')','rows');

% Y = 96-127, X = 0-127 distruttibili 3x1 distrutti (da cercare)
% interact2  = unique(im2col(C(97:128,1:128),'indexed',[8 8],'distinct')','rows');

% Y = 64-95, X = 128-255 distruttibili 3x2 interi (da cercare)
% interact11 = unique(im2col(C(65: 96,129:end),'indexed',[8 8],'distinct')','rows');

% Y = 64-95, X = 128-255 distruttibili 3x2 distrutti(da cercare)
% interact22 = unique(im2col(C(97:128,129:end),'indexed',[8 8],'distinct')','rows');


% blocking  = blocking(3:end,:);
% interact1 = interact1(3:end,:);
% interact2 = interact2(3:end,:);
% interact11 = interact11(3:end,:);
% interact22 = interact22(3:end,:);

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

% % flag_array = ones(256,1)*255;

%permutemetatile

% [~,LOCu] = ismember(blocking,Tiles1u,'rows','R2012a');
% [~,LOCd] = ismember(blocking,Tiles1d,'rows','R2012a');

% [~,ju] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jd] = ismember(LOCd,meta_pnt_table_d(:,1));

% [ju jd]

% flag_array(ju) = flag_array(ju) - 1;
% flag_array(jd) = flag_array(jd) - 2;

% fid = fopen('blocktiles.asm','w');
% fprintf (fid,'n_block_up: equ	%d \n',length(ju));
% fprintf (fid,'block_up: \n');
% fprintf (fid,'	db	%d \n',ju-1);
% fprintf (fid,'n_block_dwn: equ	%d \n',length(jd));
% fprintf (fid,'block_dwn: \n');
% fprintf (fid,'	db	%d \n',jd-1);

% [~,LOCu] = ismember(interact1,Tiles1u,'rows','R2012a');
% [~,LOCd] = ismember(interact1,Tiles1d,'rows','R2012a');
% [~,ju] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jd] = ismember(LOCd,meta_pnt_table_d(:,1));

% [i,j] = find(meta_pnt_u==ju);
% ju = [meta_pnt_u(i(1),j(1)-1) ju];

% [i,j] = find(meta_pnt_d==jd);
% jd = [meta_pnt_d(i(1),j(1)-1) jd];


% [~,LOCu] = ismember(interact2,Tiles1u,'rows','R2012a');
% [~,LOCd] = ismember(interact2,Tiles1d,'rows','R2012a');
% [~,jju] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jjd] = ismember(LOCd,meta_pnt_table_d(:,1));

% [i,j] = find(meta_pnt_u==jju);
% jju = [meta_pnt_u(i(1),j(1)-1) jju];

% [i,j] = find(meta_pnt_d==jjd);
% jjd = [meta_pnt_d(i(1),j(1)-1) jjd];

%%%%%%%%%%%%%%%%%%%%%
% process 3x2 items!!
%

% [~,LOCu] = ismember(interact11,Tiles1u,'rows','R2012a');
% [~,LOCd] = ismember(interact11,Tiles1d,'rows','R2012a');
% [~,j11u] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,j11d] = ismember(LOCd,meta_pnt_table_d(:,1));


% [i,j] = find(meta_pnt_u==j11u(1));
% i = i(1); j = j(1);
% j11u = [meta_pnt_u(i,j-1); j11u(1) ;  meta_pnt_u(i,j+1); meta_pnt_u(i+1,j-1); meta_pnt_u(i+1,j);  meta_pnt_u(i+1,j+1)];

% [i,j] = find(meta_pnt_d==j11d(1));
% i = i(1); j = j(1);
% j11d = [meta_pnt_d(i,j-1); j11d(1) ;  meta_pnt_d(i,j+1); meta_pnt_d(i+1,j-1); meta_pnt_d(i+1,j);  meta_pnt_d(i+1,j+1)];


% flag_array(ju) = flag_array(ju) - 4;
% flag_array(jd) = flag_array(jd) - 8;

% [~,LOCu] = ismember(interact22,Tiles1u,'rows','R2012a');
% [~,LOCd] = ismember(interact22,Tiles1d,'rows','R2012a');
% [~,jj22u] = ismember(LOCu,meta_pnt_table_u(:,1));
% [~,jj22d] = ismember(LOCd,meta_pnt_table_d(:,1));

% [i,j] = find(meta_pnt_u==jj22u(1));
% i = i(1); j = j(1);
% jj22u = [meta_pnt_u(i,j-1); jj22u(1) ;  meta_pnt_u(i,j+1); meta_pnt_u(i+1,j-1); meta_pnt_u(i+1,j);  meta_pnt_u(i+1,j+1)];

% [i,j] = find(meta_pnt_d==jj22d(1));
% i = i(1); j = j(1);
% jj22d = [meta_pnt_d(i,j-1); jj22d(1) ;  meta_pnt_d(i,j+1); meta_pnt_d(i+1,j-1); meta_pnt_d(i+1,j);  meta_pnt_d(i+1,j+1)];


% fprintf (fid,'n_interact_up: equ	%d \n',length(ju));
% fprintf (fid,'n_interact_dwn: equ	%d \n',length(jd));
% 
% fprintf (fid,'interact_up: \n');
% fprintf (fid,'	db	%d \n',ju-1);

% fprintf (fid,'interact_2x2_up: \n');
% fprintf (fid,'	db	%d \n',j11u-1);

% fprintf (fid,'interact_distr_up: \n');
% fprintf (fid,'	db	%d \n',jju-1);

% fprintf (fid,'interact_distr_2x2_up: \n');
% fprintf (fid,'	db	%d \n',jj22u-1);


% fprintf (fid,'interact_dwn: \n');
% fprintf (fid,'	db	%d \n',jd-1);
% 
% fprintf (fid,'interact_2x2_dwn: \n');
% fprintf (fid,'	db	%d \n',j11d-1);

% fprintf (fid,'interact_distr_dwn: \n');
% fprintf (fid,'	db	%d \n',jjd-1);

% fprintf (fid,'interact_distr_2x2_dwn: \n');
% fprintf (fid,'	db	%d \n',jj22d-1);

% fclose(fid);

% fid = fopen('flag_array.asm','w');
% fprintf (fid,'	db	%d \n',flag_array);
% fclose(fid);

% figure
% colormap(MAP);
% axis equal;

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

% !make.bat

