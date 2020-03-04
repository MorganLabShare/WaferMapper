function[] = copyLogBook(SPN,targetDirs);

bookSource = [SPN 'logBooks\'];
disp(' ')
if exist(bookSource,'dir')
    
    
    bookDir = dir(bookSource); bookDir = bookDir(3:end);
    sortDates = datenum(cat(1,bookDir.date));
    newest = find(sortDates == max(sortDates),1);
    
    if ~isempty(newest)
        newBook = bookDir(newest).name;
        
        source = [bookSource newBook];
        
        for i = 1: length(targetDirs)
            TPN = targetDirs{i};
            if ~exist([TPN 'logBooks'],'dir')
                mkdir([TPN 'logBooks'])
            end
            dest = [TPN 'logBooks\' newBook];
            
            status = 0;
            for i = 1:3
                status = copyfile(source,dest);
                if status ~= 0  %make sure copy succeded
                    disp(['book ' newBook ' copied to ' TPN])
                    break
                end
                pause(1)
            end
            
        end %run all target directories
    end %if there is a log file
end %if there is a log folder