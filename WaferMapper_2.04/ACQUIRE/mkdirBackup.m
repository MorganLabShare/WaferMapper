function[success,message,messageid]  = mkdirBackup(dirPath)

if exist(dirPath,'dir')
    newDir = sprintf('%s_%12.0f',dirPath(1:end-1),datenum(datetime)*10^6);
    movefile(dirPath,newDir);
    [success,message,messageid] = mkdir(dirPath);

else
    [success,message,messageid] = mkdir(dirPath);
end