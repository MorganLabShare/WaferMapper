IsFound = false;
for RowNum = 1:3
    for ColNum = 1:5
        if (RowNum == 1) && (ColNum == 2)
            IsFound = true;
            break; 
        end
    end
    if IsFound
        break;
    end
end

disp(sprintf('RowNum = %d, ColNum = %d', RowNum, ColNum));