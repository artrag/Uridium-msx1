function map_inspect(in,pntud,meta_pnt_table_u,meta_pnt_table_d,Tiles1u,Tiles1d,Tiles2u,Tiles2d,MAP)

[iu,ju] = find(meta_pnt_table_u==in);

[id,jd] = find(meta_pnt_table_d==in);

i=2;
iu = iu(i);ju = ju(i);
id = id(i);jd = jd(i);

if (ju==1 || ju==3)
    t = Tiles1u(in,:);
else
    t = Tiles2u(in,:);
end
ss = col2im(t',[8,8],[8,8],'distinct');
figure;
image(ss);
colormap(MAP);

if (jd==1||jd==3)
    t = Tiles1d(in,:);
else
    t = Tiles2d(in,:);
end
ss = col2im(t',[8,8],[8,8],'distinct');
figure;
image(ss);
colormap(MAP);


i = [iu ; id];
s = zeros(size(pntud));
for n=1:size(i,1)
    s = s+(pntud==i(n));
end

[x,y] = find(s);

Dpntud = pntud;
Dpntud(x,y) = 255;

figure;
t = [pntud;Dpntud];
t = t/max(max(t))*64;
image(t);
axis equal
colormap(gray)

return