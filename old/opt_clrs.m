function [ nTu,nTd,PCT,PGTu,PGTd ] = opt_clrs( chu,chd,clu,cld, Ttu,Ttd )

chu = uint8(chu);
chd = uint8(chd);

clu = uint8(clu);
cld = uint8(cld);

Tu = uint8(Ttu');
Td = uint8(Ttd');


[s,i] = sort(sum(chu));
chu = chu(:,i);
clu = clu(:,i);
Tu = Tu(:,i);

i = find(s);
for k=i
    for j=1:8
    if bitand(clu(j,k),15) == 0
        clu(j,k) = bitand(clu(j,k),240) + 1;
    elseif bitand(clu(j,k),240) == 0
        clu(j,k) = bitand(clu(j,k),15) + 16;
    end
    end
end


[s,i] = sort(sum(chd));
chd = chd(:,i);
cld = cld(:,i);
Td = Td(:,i);

i = find(s);
for k=i
    for j=1:8
    if bitand(cld(j,k),15) == 0
        cld(j,k) = bitand(cld(j,k),240) + 1;
    elseif bitand(cld(j,k),240) == 0
        cld(j,k) = bitand(cld(j,k),15) + 16;
    end
    end
end

setmax = 1:size(chu,2);
setmin = 1:size(chd,2);

k = 1;
PCT  = uint8(zeros(8,256));
PGTu = uint8(zeros(8,256));
PGTd = uint8(zeros(8,256));
nTu = uint8(zeros(size(Tu)));
nTd = uint8(zeros(size(Td)));

for x = 1:size(chu,2)
    for y = setmin
        
        [t cu cd] = match_colors(chu(:,x),clu(:,x),chd(:,y),cld(:,y));

        if ~isempty(t)
            setmin = setdiff(setmin ,y);
            setmax = setdiff(setmax ,x);
            PCT(:,k) = t;
            PGTu(:,k) = cu;
            PGTd(:,k) = cd;
            nTu(:,k) = Tu(:,x);
            nTd(:,k) = Td(:,y);
            k = k+1;
            break;
        end
    end
end

for x = setmax
    PCT(:,k)  = clu(:,x);
    PGTu(:,k) = chu(:,x);
    PGTd(:,k) = [ 129,66,36,24,24,36,66,129 ];
    nTu(:,k) = Tu(:,x);
    k = k+1;
end
for y = setmin
    PCT(:,k)  = cld(:,y);
    PGTd(:,k) = chd(:,y);
    PGTu(:,k) = [ 129,66,36,24,24,36,66,129 ];
    nTd(:,k) = Td(:,y);
    k = k+1;
end
        
nTu = nTu';
nTd = nTd';
PCT = PCT';
PGTu = PGTu';
PGTd = PGTd';


