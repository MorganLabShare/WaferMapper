
%%Analyze section from log Book
%[TFN TPN ] = GetMyFile

bookDir = 'Z:\joshm\LGNs1\rawMontages\LogBooks\';
bookName = 'LogBook_w053';

load([bookDir bookName '.mat'])

%% Read Quality into midQual
logBook.sheets.quality.header;
imageNames = logBook.sheets.quality.data(:,1);
findSec = regexp(imageNames,'_sec');
clear secNames
for i = 1:length(imageNames)
    secNames(i) = str2num(imageNames{i}(findSec{i}+4:findSec{i}+6));
end

Qualities = cell2mat(logBook.sheets.quality.data(:,3));

sections = unique(secNames);

for i = 1:max(sections)
    
    quals = Qualities(secNames == i);
    if isempty(quals)
        midQual(i) = 0;
    else
        midQual(i) = median(quals);
    end
    
end
    

%% REad IBSC

secNames  =str2num(cat(1,logBook.sheets.IBSC.data{:,1}));
yoff = cat(1,logBook.sheets.IBSC.data{:,2});    
xoff = cat(1,logBook.sheets.IBSC.data{:,3});  
distOff = sqrt(yoff.^2 + xoff.^2);
angles = cat(1,logBook.sheets.IBSC.data{:,4});
merit =  cat(1,logBook.sheets.IBSC.data{:,5});

[uSec lastOcc] = unique(secNames,'last');

offSets(uSec) = distOff(lastOcc); 
offAngle(uSec) = angles(lastOcc);
secMerit(uSec) = merit(lastOcc);



%% Get times

imageTimes = cat(1,logBook.sheets.imageConditions.data{:,32});
imageNames = logBook.sheets.imageConditions.data(:,1);
findSec = regexp(imageNames,'_sec');
clear secNames
for i = 1:length(imageNames)
    secNames(i) = str2num(imageNames{i}(findSec{i}+4:findSec{i}+6));
end

numTimes = datenum(imageTimes);
for i = 1:max(secNames)
    secTimes = numTimes(secNames == i);
    if length(secTimes)>1
        minDif = min(secTimes(2:end)-secTimes(1:end-1));
        maxDif = max(secTimes) - min(secTimes);
        secTileTime(i) = maxDif + minDif;
        startTime{i} = datestr(min(secTimes));
        startTimeNum(i) = min(secTimes);
        
        preTimes  = numTimes-min(secTimes);
        preTimes(preTimes>=0) = -10;
        timeSinceLast(i) = max(preTimes)*-1;
        
        
    else
        secDuration(i) = 0;
        startTime{i} = datestr(secTimes);
        startTimeNum(i) = 0;
    end
end

secTileTime = secTileTime * 24 * 60;
timeSinceLast = timeSinceLast * 24 * 60;
secDuration = secTileTime + timeSinceLast;

%% Get Current
imageNames = cat(1,logBook.sheets.specimenCurrent.data(:,1));
imageCurrents = logBook.sheets.specimenCurrent.data(:,2:end);
findSec = regexp(imageNames,'_sec');
clear secNames
for i = 1:length(imageNames)
    secNames(i) = str2num(imageNames{i}(findSec{i}+4:findSec{i}+6));
end


[uSec lastOcc] = unique(secNames,'last');

for i = 1:max(uSec)
    targ = find(uSec==i);
    if isempty(targ)
        midCurrent(i) = 0;
    else
        currents = cat(1,imageCurrents{targ,:});
        midCurrent(i) = median(currents)*1000000000;
    end
end

useSecName = secNames;


%% secName, time, midQual, offSets, offAngle, sec Merit, current timing

[sorted sortStart] = sort(startTimeNum,'ascend') ;
listSecs = 1:max(useSecName);
secDat(1:max(useSecName),1) = num2cell(listSecs(sortStart))';
secDat(:,2) = startTime(sortStart);
secDat(:,3) = num2cell(midQual(sortStart));
secDat(:,4) = num2cell(secDuration(sortStart));
secDat(:,5) = num2cell(midCurrent(sortStart));
secDat(:,6) = num2cell(offSets(sortStart));
secDat(:,7) = num2cell(offAngle(sortStart));
secDat(:,8) = num2cell(secMerit(sortStart));


secHeader = {'Section' 'Start' 'midQuality' 'Duration' 'Current' 'IBSC xy' 'IBSC angle' 'IBSC merit'};

logBook.sheets.secSum.header = secHeader;
logBook.sheets.secSum.data = secDat;


%% Set up excel

bookFileNameXLS =[bookDir bookName '.xls'];

sheets = fieldnames(logBook.sheets);

%% write structure into excel file
for i = 1:length(sheets)
    sheets{i}
    sheet = getfield(logBook.sheets,sheets{i});
    startRange = 1;
    if isfield(sheet,'header')
        rangeStr = ['A1:A' num2str(length(sheet.header))];
        [s message] = xlswrite(bookFileNameXLS,sheet.header',sheets{i},rangeStr);
        %copyfile(bookFileName,bookFileName);
        startRange = startRange + 1;
    end
    if length(sheet.data)>0
        rangeStr = [ ind2ExcelCol(startRange ) '1:'...
            ind2ExcelCol(startRange + size(sheet.data,1)-1)  num2str(size(sheet.data,2))];
        
        [s message] = xlswrite(bookFileNameXLS,sheet.data',sheets{i},rangeStr);
        
    end
end


%[success message messageID] = copyfile(bookFileNameUTSL,bookFileName)

toc
