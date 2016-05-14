close all

x = dir('bins\*.bin');
nfiles = size(x,1);

unc_siz = zeros(nfiles,1);

for i=1:nfiles
    i
    disp (x(i).name);
    name = [ 'bins\' x(i).name];

    copyfile(name,'temp.bin');
    
   !C:\HT-Z80\msxdev08\Mizer\MSX-O-Mizer.exe -r temp.bin temp.cmp
    
    name = [ x(i).name '.miz'];

    movefile('temp.cmp',name);

end

!del temp.*
!del *.cmp

