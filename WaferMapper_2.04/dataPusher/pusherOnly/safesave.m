function[success] = safesave(fileName,varName,repeats)


savestr = ['save(''' ,fileName,''',''',varName ''')'];


if ~exist('repeats','var')
    repeats = 5;
end


for r = 1 : repeats
    success = 1;
    try
        evalin('caller',savestr);
    catch err
        success = 0;
    end
    if success
        break
    end
    pause(.1)
end

if success
    disp(['Saved ' varName ' to ' fileName])
else
    disp(['Failed to save ' varName ' to ' fileName])
end