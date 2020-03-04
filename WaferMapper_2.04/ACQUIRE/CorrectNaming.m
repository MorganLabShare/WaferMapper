

for i = 1:94

    DataFileNameStr = sprintf('Y:\\Hayworth\\MasterUTSLDirectory\\CortexUTSL004\\Wafer006\\SectionOverviewsDirectory\\SectionOverview_%s.mat',...
        num2str(i));
    
    MyStr = sprintf('Correcting file: %s', DataFileNameStr);
    disp(MyStr);
    load(DataFileNameStr, 'SectionOveriewInfo');
    
    Info = SectionOveriewInfo;
    
    save(DataFileNameStr, 'Info');
    
end