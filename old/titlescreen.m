

clear
close all

name = 'manta_pic6';
[X,MAP] = imread(['grpx\' name '.png']);


X1 = X(1:64,:);
A1 = im2col(X1,[8 8],'distinct')';
[Tiles1,I1, J1] = unique(A1,'rows');

X2 = X(65:128,:);
A2 = im2col(X2,[8 8],'distinct')';
[Tiles2,I2, J2] = unique(A2,'rows');

X3 = X(129:192,:);
A3 = im2col(X3,[8 8],'distinct')';
[Tiles3,I3, J3] = unique(A3,'rows');

Image1 = Tiles1(J1,:);
Image2 = Tiles2(J2,:);
Image3 = Tiles3(J3,:);

x1 = col2im(Image1',[8 8],[64 256],'distinct');
x2 = col2im(Image2',[8 8],[64 256],'distinct');
x3 = col2im(Image3',[8 8],[64 256],'distinct');

x = [x1;x2;x3];
image(x);
colormap(MAP)

arry2tile(im2col(X',[8 8],'distinct'),MAP);
system('copy /B out.CHR+out.CLR data_bin\manta_chr_clr.bin > logcpy.txt');
!miz\MSX-O-Mizer.exe  -r data_bin\manta_chr_clr.bin data_miz\manta_chr_clr.bin.miz

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% encode in screen 2 even tileset
arry2tile(Tiles1',MAP);
system('copy /B out.CHR manta1_chr.bin > logcpy.txt');
system('copy /B out.CLR manta1_clr.bin > logcpy.txt');
!miz\MSX-O-Mizer.exe  -r manta1_chr.bin miz\manta1_chr.bin.miz
!miz\MSX-O-Mizer.exe  -r manta1_clr.bin miz\manta1_clr.bin.miz

arry2tile(Tiles2',MAP);
system('copy /B out.CHR manta2_chr.bin > logcpy.txt');
system('copy /B out.CLR manta2_clr.bin > logcpy.txt');
!miz\MSX-O-Mizer.exe  -r manta2_chr.bin miz\manta2_chr.bin.miz
!miz\MSX-O-Mizer.exe  -r manta2_clr.bin miz\manta2_clr.bin.miz

arry2tile(Tiles3',MAP);
system('copy /B out.CHR manta3_chr.bin > logcpy.txt');
system('copy /B out.CLR manta3_clr.bin > logcpy.txt');
!miz\MSX-O-Mizer.exe  -r manta3_chr.bin miz\manta3_chr.bin.miz
!miz\MSX-O-Mizer.exe  -r manta3_clr.bin miz\manta3_clr.bin.miz


J = [J1; J2; J3];
fid = fopen('manta_pnt.bin','w');
fwrite(fid,J-1);
fclose(fid);
!miz\MSX-O-Mizer.exe  -r manta_pnt.bin miz\manta_pnt.bin.miz

!copy /B manta1_chr.bin+manta2_chr.bin+manta3_chr.bin+manta1_clr.bin+manta2_clr.bin+manta3_clr.bin+manta_pnt.bin manta.bin
!miz\MSX-O-Mizer.exe  -r manta.bin miz\manta.bin.miz


