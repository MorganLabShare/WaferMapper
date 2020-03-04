function[Lstr] = ind2ExcelCol(ind)
%% ind 2 excel col

combos = 0;
for letters = 1:1000
    covered(letters) = combos;
    combos = combos + 26^(letters);
    
    if combos>=ind
        break
    end
end

L = ind - covered(letters)-1;
for i = 1:letters
    Lmag = 26^(letters-i);
    let = fix(L/Lmag);
    Lstr(i) = char(let+65);
    L = rem(L,Lmag);
    
end