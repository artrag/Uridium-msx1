function [ret] = outhex(fid,data)

s = dec2hex(fix(data));

if  (data<=255)
    if  (size(s,2) == 1)
        ret = ['00' s 'h'];
    else
        ret = ['0' s 'h'];
    end
else
    if  (size(s,2) == 3)
        ret = ['00' s 'h'];
    else
        ret = ['0' s 'h'];
    end
    
end
        
fwrite(fid,ret);

