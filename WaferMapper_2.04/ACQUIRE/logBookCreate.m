function[logBook] = logBookCreate()

%%Create a log book for microscope, image and waffer mapper information
%%Save to both UTSL main directory and image target directory

global GuiGlobalsStruct;

%make book name
if ~exist([GuiGlobalsStruct.UTSLDirectory '\logBooks\']);
    mkdir([GuiGlobalsStruct.UTSLDirectory '\logBooks\']);
end
if ~exist([GuiGlobalsStruct.TempImagesDirectory '\logBooks\']);
    mkdir([GuiGlobalsStruct.TempImagesDirectory '\logBooks\']);
end
bookName = ['LogBook_' GuiGlobalsStruct.WaferName]
bookName(bookName == ' ') = '_';
bookName(bookName == ':') = '-';
GuiGlobalsStruct.CurrentLogBook = bookName;

if exist([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat']);
    load([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat']);
    'Writing to previous logbook'
else
    
    
    %% make book headers
    logBook.sheets.quality.header = {};
    logBook.sheets.status.header = {'Microscope Status'};
    logBook.sheets.IBSC.header = {'section' 'StageX_Microns_Offset' 'StageY_Microns_Offset' ' AngleOffsetOfNewInDegrees' ' FigureOfMerit' 'XOffsetOfNewInPixels' ' YOffsetOfNewInPixels'};
    
    %% scope conditions
    logBook.sheets.scopeConditions.header{1} =   'AP_ACTUALKV';
    logBook.sheets.scopeConditions.header{2} =   'AP_ACTUALCURRENT';
    logBook.sheets.scopeConditions.header{3} =   'AP_GUNSHIFT_X';
    logBook.sheets.scopeConditions.header{4} =   'AP_GUNSHIFT_Y';
    logBook.sheets.scopeConditions.header{5} =   'AP_GUNTILT_X';
    logBook.sheets.scopeConditions.header{6} =   'AP_GUNTILT_Y';
    logBook.sheets.scopeConditions.header{7} =   'AP_GUNALIGN_X';
    logBook.sheets.scopeConditions.header{8} =   'AP_GUNALIGN_Y';
    logBook.sheets.scopeConditions.header{9} =   'AP_EXTCURRENT';
    logBook.sheets.scopeConditions.header{10} =   'AP_MANUALEXT';
    logBook.sheets.scopeConditions.header{11} =   'AP_MANUALKV';
    logBook.sheets.scopeConditions.header{12} =   'AP_FILAMENT_AGE';
    
    %%Beam
    logBook.sheets.scopeConditions.header{13} =   'AP_BEAMSHIFT_X';
    logBook.sheets.scopeConditions.header{14} =   'AP_BEAMSHIFT_Y';
    logBook.sheets.scopeConditions.header{15} =   'AP_BEAM_OFFSET_X';
    logBook.sheets.scopeConditions.header{16} =   'AP_BEAM_OFFSET_Y';
    
    %%APERATURE
    logBook.sheets.scopeConditions.header{17} =   'AP_APERTURESIZE';
    logBook.sheets.scopeConditions.header{18} =   'AP_APERTURE_ALIGN_X';
    logBook.sheets.scopeConditions.header{19} =   'AP_APERTURE_ALIGN_Y';
    logBook.sheets.scopeConditions.header{20} =   'AP_APERTUREPOSN_X';
    logBook.sheets.scopeConditions.header{21} =   'AP_APERTUREPOSN_Y';
    
    %%VACUUM
    logBook.sheets.scopeConditions.header{22} =   'AP_SYSTEM_VAC';
    logBook.sheets.scopeConditions.header{23} =   'AP_COLUMN_VAC';
    logBook.sheets.scopeConditions.header{24} =   'AP_CHAMBER_PRESSURE';
    
    %%GENERAL
    logBook.sheets.scopeConditions.header{25} =  'SV_USER_NAME';
    
    
    %% image conditions
    logBook.sheets.imageConditions.header{1} =   ('Image Name');
    
    logBook.sheets.imageConditions.header{2} =   ('AP_BRIGHTNESS');
    logBook.sheets.imageConditions.header{3} =   ('AP_CONTRAST');
    logBook.sheets.imageConditions.header{4} =   ('AP_MAG');
    logBook.sheets.imageConditions.header{5} =   ('AP_WD');
    logBook.sheets.imageConditions.header{6} =   ('AP_SPOT');
    logBook.sheets.imageConditions.header{7} =   ('AP_PIXEL_SIZE');
    logBook.sheets.imageConditions.header{8} =   ('AP_SCM');
    logBook.sheets.imageConditions.header{9} =   ('AP_SPOTSIZE')
    logBook.sheets.imageConditions.header{10} =   ('AP_IPROBE');
    logBook.sheets.imageConditions.header{11} =   ('AP_STIG_X');
    logBook.sheets.imageConditions.header{12} =   ('AP_STIG_Y');
    logBook.sheets.imageConditions.header{13} =   ('AP_ZOOM_FACTOR');
    logBook.sheets.imageConditions.header{14} =   ('AP_TILT_ANGLE');
    
    %SCANNING
    logBook.sheets.imageConditions.header{15} =   ('AP_SCANROTATION');
    logBook.sheets.imageConditions.header{16} =   ('AP_PIXEL_SIZE');
    logBook.sheets.imageConditions.header{17} =   ('AP_FRAME_TIME');
    logBook.sheets.imageConditions.header{18} =   ('AP_FRAME_AVERAGE_COUNT');
    logBook.sheets.imageConditions.header{19} =   ('AP_FRAME_iNT_COUNT');
    logBook.sheets.imageConditions.header{20} =   ('AP_NR_COEFF');
    logBook.sheets.imageConditions.header{21} =   ('AP_WIDTH');
    logBook.sheets.imageConditions.header{22} =   ('AP_HEIGHT');
    
    %STAGE
    logBook.sheets.imageConditions.header{23} =   ('AP_STAGE_AT_X');
    logBook.sheets.imageConditions.header{24} =   ('AP_STAGE_AT_Y');
    logBook.sheets.imageConditions.header{25} =   ('AP_STAGE_AT_Z');
    logBook.sheets.imageConditions.header{26} =   ('AP_STAGE_AT_R');
    logBook.sheets.imageConditions.header{27} =   ('AP_STAGE_AT_T');
    
    %DIGITAL PARAMETERS
    logBook.sheets.imageConditions.header{28} =   ('DP_NOISE_REDUCTION');
    logBook.sheets.imageConditions.header{29} =   ('DP_DETECTOR_CHANNEL');
    logBook.sheets.imageConditions.header{30} =   ('DP_DETECTOR_TYPE');
    logBook.sheets.imageConditions.header{31} =   ('AP_ACTUALCURRENT');
    logBook.sheets.imageConditions.header{32} =   ('Date,Time');
    logBook.sheets.imageConditions.header{33} =   ('AP_EXTCURRENT');


    %%  WaferMapper headers
    
    
    
    %%Make Data fields
    logBook.sheets.imageInfo.data = {};
    logBook.sheets.imageConditions.data = {};
    logBook.sheets.scopeConditions.data = {};
    logBook.sheets.status.data = {};
    logBook.sheets.WaferMapper.data = {};
    logBook.sheets.specimenCurrent.data = {};
    logBook.sheets.quality.data = {};
    logBook.sheets.IBSC.data = {};
    
%     %save book
%     try
%         save([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%     catch err
%         err
%     end
%     try
%         save([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')
%     catch err
%         err
%     end
end %if no book exists already

%{

Additional parameters to log
DOF vs Crossover
Stage Settling time
Autotune
FocusAmplitude/speed
Quality
%}
