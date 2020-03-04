load('.\PointsToImage.mat','SectionArray');

for i = 1:length(SectionArray)
%     SectionArray(1).Info
% 
% ans = 
% 
%                       Label: '1'
%                 FOV_microns: 200
%          ImageWidthInPixels: 1024
%         ImageHeightInPixels: 1024
%     DwellTimeInMicroseconds: 1
%               StageX_Meters: 0.096018306910992
%               StageY_Meters: 0.029615350067616
%                     stage_z: 0.025000000372529
%                     stage_t: 0
%                     stage_r: 136
%                     stage_m: 0
%                     ScanRot: 3.298572998046875e+002
%                         Mag: 572
%                          WD: 0.007587402593344

    StageX_Meters = SectionArray(i).Info.StageX_Meters;
    StageY_Meters = SectionArray(i).Info.StageY_Meters;
    ScanRot_Degrees = SectionArray(i).Info.ScanRot;
    
    disp(sprintf('Section# %d, X=%d, Y=%d, ScanRot_Degrees=%d',i,StageX_Meters,StageY_Meters,ScanRot_Degrees));

end