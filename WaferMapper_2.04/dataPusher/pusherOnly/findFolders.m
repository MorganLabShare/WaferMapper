function[listF] = findFolders(F)

%% Add folder to list
if nargin == 0 
    F = GetMyDir;
end
    F = F(1:length(F)-1);
    listF = {F};



checked = 0;
while sum(~checked)
    check = find(~checked,1);
    checked(check) = 1;
    if isempty(find(listF{check} == '.'))        
    newDir = dir(listF{check});
    if length(newDir)>2
        newDir = newDir(3:length(newDir));
        newFolders = {newDir([newDir.isdir]).name};
        for i = 1:length(newFolders);
            listF{length(listF)+1,1} = [listF{check} '\' newFolders{i}];
            checked(length(listF)) = 0;
            [listF{check} '\' newFolders{i}];
        end
    end %if folder not empty
    end % if not a '.' folder
end