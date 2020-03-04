clear all
logFile = 'C:\Users\joshm\GoogleDriveJMDataWatcher\Google Drive\logBooks\LogBook_w042.mat'
%logFile = 'C:\Users\joshm\Documents\MyWork\logBooks\LogBook_w042.mat'
load(logFile);
pause(1)    
load(logFile);

%% Time
tileNams = cat(1,logBook.sheets.imageConditions.data{:,1});
tileTimes = cat(1,logBook.sheets.imageConditions.data{:,32});
secPos = regexp(tileNams(1,:),'_sec');
secs = str2num(tileNams(:,secPos+4:secPos+6));
uSecs = unique(secs);
tileNumTimes = datenum(tileTimes);
for i = 1:length(uSecs)
    sec = uSecs(i);
   secNumTimes = tileNumTimes(secs == sec);
   startTimes(i) = min(secNumTimes);
end

durations = (startTimes(2:end)-startTimes(1:end-1))*24 * 60;
% [sortedTimes sortOrder] = sort(startTimes,'ascend');
% durations = durations(sortOrder)


%% Quality
tileNams2 = cat(1,logBook.sheets.quality.data{:,1});
tileQual = cat(1,logBook.sheets.quality.data{:,3});

%% IBSC
secNams3 = cat(1,logBook.sheets.IBSC.data{:,1});
secMerit = cat(1,logBook.sheets.IBSC.data{:,5});
secMaxShift = max(abs([cat(1,logBook.sheets.IBSC.data{:,2}) cat(1,logBook.sheets.IBSC.data{:,3})]),[],2);

%% Current
secNames4 = cat(1,logBook.sheets.specimenCurrent.data{:,1});
for i = 1:size(logBook.sheets.specimenCurrent.data,1)
    secCurrents(i) = max(cat(1,logBook.sheets.specimenCurrent.data{i,2:end}))*1000000000;
end

%% progress

prog = logBook.waferProgress;
sectionsLeft = sum(logBook.waferProgress.do);
%% Report
checkTime = datestr(clock);
lastTime = tileTimes(end,:);
disp(' ')
disp(' ')
disp(' ')
minutesSinceLast = (datenum(checkTime) - datenum(lastTime))*24*60;
disp(sprintf('Updated %.1f minutes ago.',minutesSinceLast))
lastQuals = round(tileQual(end-min(length(tileQual),15)+1:end)');
disp(['Last quals: ' num2str(lastQuals)])
lastSec = secs(end);
disp(['Last section: ' num2str(lastSec)])
lastMerit = secMerit(end - min(length(secMerit),10)+1:end)';
disp(['Last Merits: ' sprintf('%0.2f  ', lastMerit')])
lastShift = abs(secMaxShift(end - min(length(secMaxShift),10)+1:end))';
disp(['Last Shift : ' sprintf('%.1f  ', lastShift)])
lastCurrent = secCurrents(end-min(length(secCurrents),10):end);
disp(['Last currents were ' sprintf('%.3f ',lastCurrent) ])
lastDurations = durations(end - min(length(durations),10)+1:end);
disp(['Last durations: ' sprintf('%.1f ', lastDurations)]);
hoursLeft =( median(lastDurations) * sectionsLeft)/60;
disp(['Hours Left: ' num2str(hoursLeft)])



