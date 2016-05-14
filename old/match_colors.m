
function [k,cu,cd] = match_colors(chu,clu,chd,cld)
  

% chu = [ 15 15  12 12 2   13 8  0];
% clu = [ 81 81  81 81 81  81 81 17];
% chd = [176 208 32 10 160 16 96 80];
% cld = [ 81 81  81 81 81  81 81 81];
% 

 cu = chu;
 cd = chd;
 k  = clu;
 
 for i = 1:8
     
     cu(i) = chu(i);
     if	(chu(i) == 255)
         t1 = uint8(uint8(0:15) + bitand(clu(i),240));
         t2 = uint8(uint8(0:15)*16 + bitand(clu(i),240)/16);
     elseif (chu(i) == 0)
         t1 = uint8(uint8(0:15)*16 + bitand(clu(i),15));
         t2 = uint8(uint8(0:15) + bitand(clu(i),15)*16);
     else
         t1 = clu(i);
         t2 = [];
     end
         
     cd(i) = chd(i);
     if	(chd(i) == 255)
         s1 = uint8(uint8(0:15) + bitand(cld(i),240));
         s2 = uint8(uint8(0:15)*16 + bitand(cld(i),240)/16);
     elseif (chd(i) == 0)
         s1 = uint8(uint8(0:15)*16 + bitand(cld(i),15));
         s2 = uint8(uint8(0:15) + bitand(cld(i),15)*16);
     else
         s1 = cld(i);
         s2 = [];
     end
     
     m11 = intersect (t1,s1);
     m12 = intersect (t1,s2);
     m21 = intersect (t2,s1);
     m22 = intersect (t2,s2);
     
     if ~isempty(m11)
         k(i) = min(m11);
         
     elseif ~isempty(m12)
         k(i)  = min(m12);
         cd(i) = ~cd(i);
         
     elseif ~isempty(m21)
         k(i)  = min(m21);
         cu(i) = ~cu(i);
         
     elseif ~isempty(m22)
         k(i)  = min(m22);
         cu(i) = ~cu(i);
         cd(i) = ~cd(i);
         
     else
         k = [];
         return
     end
 end
 
  
     
     
     