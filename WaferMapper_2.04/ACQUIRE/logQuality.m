function[logBook] = logQuality(logBook,tiles,qual,retake)

if ~exist('retake','var')
    retake = 0;
end


global GuiGlobalsStruct

% bookName = GuiGlobalsStruct.CurrentLogBook ;
% load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])


qsettings = {tiles};
qsettings{2} = retake;
qsettings = [qsettings'; struct2cell(qual)];

H = size(logBook.sheets.quality.data,1);
logBook.sheets.quality.data(H + 1:H +size(qsettings,2),1:size(qsettings,1))= qsettings';


if isempty(logBook.sheets.quality.header)
    qheader = {'filenames' 'retake'};
    qheader = [qheader fieldnames(qual)'];
    logBook.sheets.quality.header = qheader;
end

% 
%     safeSave([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%     safeSave([GuiGlobalsStruct.TempImagesDirectory 'logBooks\' bookName '.mat'],'logBook')