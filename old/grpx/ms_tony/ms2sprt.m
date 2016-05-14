clear
close all

name = 'mainship';
nframe = 46;
MS  = cell(nframe,1);
MSS = cell(nframe,1);
for i=1:nframe
    [A,MAP] = imread([name sprintf('%.2d',i-1) '.png']);
    MS{i}=A;
    [A,MAP] = imread([name sprintf(' shadow%.2d',i-1) '.png']);
    MSS{i}=A;
end
F = []
for i=1:nframe
    F = [F [MS{i} ; MSS{i}]];
end
image(F);
colormap(MAP);
axis equal;

imwrite(ind2rgb(F,MAP),[name '.png'],'png');


name = 'ms_demo';
[A,MAP] = imread(['grpx\' name '.png']);

Y = [A==15;A==7;A==1]*15;
image(Y);
colormap(MAP);

imwrite(ind2rgb(Y,MAP),[name '.png'],'png');

return

