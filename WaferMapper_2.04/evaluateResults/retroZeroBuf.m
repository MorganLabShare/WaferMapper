TPN = GetMyDir;
TPNb = [TPN 'buffed'];
mkdir(TPNb)

dTPN = dir(TPN); dTPN = dTPN(3:end);

for i = 1:length(dTPN)
    nam = dTPN(i).name;
    
    und = regexp(nam,'_');
    dots = regexp(nam,'.tif');
    badNum = nam(und(end)+1:dots(1)-1);
    if ~isempty(badNum)
        newName = [nam(1:und(end)) zeroBuf(badNum) '.tif'];
    %dos(['rename "' [TPN nam] '" "' [TPN newName] '"']); % (1)
      movefile([TPN nam],[TPNb newName]);  
        
    end
end


