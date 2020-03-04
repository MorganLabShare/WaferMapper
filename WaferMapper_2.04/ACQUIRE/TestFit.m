MyDataX = [];
MyDataY = [];
MyDataZ = [];

n = 1;
for x = 1:5
    for y = 1:5
        MyDataX(n,1) = x;
        MyDataY(n,1) = y;
        MyDataZ(n,1) = 3*x + 5*y;
        
        n = n + 1;
    end
end



MyDataX
MyDataY
MyDataZ


fo = fit( [MyDataX, MyDataY], MyDataZ, 'lowess')