

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = dir('frames_bin\*.bin');
NF = size(x,1);

q = zeros(NF,768);
d = zeros(NF,768);

for i=1:NF
    n = [ 'frames_bin\' x(i).name ];
    fid = fopen(n,'rb');
    a = fread(fid,'uint8')';
    q(i,:) = a;
    fclose (fid);    
end

n = 'frames.bin';
fid = fopen(n,'wb');
for i=1:NF
    fwrite(fid,q(i,:),'uint8');            
end
fclose (fid);    


!MSX-O-Mizer\msx-o-mizer.exe -r frames.bin frames.bin.miz
