function[loaded] = safeload(fileName,varName,repeats)

fileName = ' X:\joshm\LGNs1\UTSL_lgns1\AlignedTargetListsDirectory\checkCurrentPosition.mat'
loadstr = ['S = load(''' ,fileName,''',''' ''')']


if ~exist('repeats','var')
    repeats = 5;
end


for r = 1 : repeats
    success = 1;
    try
        evalin('caller',savestr)
    catch err
        success = 0;
    end
    if success
        break
    end
    pause(.1)
end