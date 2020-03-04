function[logBook] = logimageInfo(logBook,FileNameStr);

global GuiGlobalsStruct 


%% Enter into logbook
DataFileNameStr = sprintf('%s.mat',FileNameStr(1:end-4));
if exist(DataFileNameStr,'file')
load(DataFileNameStr);
imInfo = struct2cell(Info);
imInfo = [{FileNameStr}; imInfo];

%load logbook
% bookName = GuiGlobalsStruct.CurrentLogBook ;
% load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])

%Write logBook
logBook.sheets.imageInfo.header = [{'File Name'}; fieldnames(Info)]';
H = size(logBook.sheets.imageInfo.data,1);
logBook.sheets.imageInfo.data(H+1,1:length(imInfo)) = imInfo';
end

% %% Save
%     safeSave([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%     safeSave([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')

