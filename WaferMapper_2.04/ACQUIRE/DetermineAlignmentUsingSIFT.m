function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] = DetermineAlignmentUsingSIFT(ReferenceImage, ImageToAlign)
% %Remember you must run this once during the Matlab session
% if exist('MIJ','class') == 0
%     MIJ.start('C:\fiji-win32-20091014\Fiji.app');
% end

%Note these temp folders must be empty
%first create two temp folders in the system temp folder which is stored in the matlab variable 'tempdir'
TempSourceDir = sprintf('%sTempSourceFolder\\', tempdir);
if exist(TempSourceDir, 'dir')
    [success, message, messageid] = rmdir(TempSourceDir, 's'); %make sure all previous is deleted
    if ~success
        disp(sprintf('Could not rmdir() on directory: %s', TempSourceDir));
        ldsjfklsjd
    end
end
[success, message, messageid] = mkdir(tempdir, 'TempSourceFolder');
if ~success
    disp(sprintf('Could not make directory: %s', TempSourceDir));
    ldsjfklsjd
end


TempTargetDir = sprintf('%sTempTargetFolder\\', tempdir);
if exist(TempTargetDir, 'dir')
    [success, message, messageid] = rmdir(TempTargetDir, 's'); %make sure all previous is deleted
    if ~success
        disp(sprintf('Could not rmdir() on directory: %s', TempTargetDir));
        ldsjfklsjd
    end
end
[success, message, messageid] = mkdir(tempdir, 'TempTargetFolder');
if ~success
    disp(sprintf('Could not make directory: %s', TempSourceDir));
    ldsjfklsjd
end

transf_dir = TempTargetDir;


sprintf('%s\\Image1.tif',TempSourceDir);

%[SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,MODE)
Image1FileName = sprintf('%sImage1.tif',TempSourceDir);
imwrite(ReferenceImage, Image1FileName, 'tif');
% [success, message, messageid] = copyfile(ReferenceImageFileName, Image1FileName);
% if success == 0
%     fprintf('Could not copy %s to %s',ReferenceImageFileName, TempSourceDir);
%     disp(' ');
%     lksffksdjfklds
% end

Image2FileName = sprintf('%sImage2.tif',TempSourceDir);
imwrite(ImageToAlign, Image2FileName, 'tif');
% [success, message, messageid] = copyfile(ImageToAlignFileName, Image2FileName);
% if success == 0
%     fprintf('Could not copy %s to %s',ImageToAlignFileName, TempSourceDir);
%     disp(' ');
%     sjfkldsfkjs
% end

reference_name = 'Image1.tif';

%INFO = IMFINFO(FILENAME,FMT)
Image1_info = imfinfo(Image1FileName, 'tif');
Image2_info = imfinfo(Image2FileName, 'tif');

if (Image1_info.Width ~= Image2_info.Width) || (Image1_info.Height ~= Image2_info.Height)
    disp('ERROR. Images must be same size.');
    lsdjfikdsjf
end

%Perform SIFT alignment by calling imagej plugin register_virtual_stack
source_dir = TempSourceDir;
target_dir = TempTargetDir;
transf_dir = TempTargetDir;
reference_name = 'Image1.tif';
p = javaObject('register_virtual_stack.Register_Virtual_Stack_MT$Param');
use_shrinking_constraint = 0;
register_virtual_stack.Register_Virtual_Stack_MT.exec(source_dir, target_dir, transf_dir, reference_name, p, use_shrinking_constraint);
ij.IJ.doCommand('Close'); %This closes the window that the above created

AlignedImage2FileName = sprintf('%sImage2.tif',TempTargetDir);
AlignedImage2_info = imfinfo(AlignedImage2FileName, 'tif');


XMLTransformFileName = sprintf('%sImage2.xml',TempTargetDir);
domnode = xmlread(XMLTransformFileName);
allListItems = domnode.getElementsByTagName('iict_transform');
ThisListItem = allListItems.item(0);
DataJavaString = ThisListItem.getAttribute('data');
DataString = char(DataJavaString)
[AngleOffsetStrInRadians, RemainderOfString] = strtok(DataString);
[XOffsetStr, YOffsetStr] = strtok(RemainderOfString);
AngleOffsetInDegrees = (180/pi)*str2double(AngleOffsetStrInRadians);
YOffset = str2double(YOffsetStr);
XOffset = -str2double(XOffsetStr);

MyStr = sprintf('XOffset = %0.5g, YOffset = %0.5g, AngleOffsetInDegrees = %0.5g', XOffset, YOffset, AngleOffsetInDegrees);
disp(MyStr);



%Compensate for canvas size increase and fact that orgin of transform above
%is bottom corner instead of image center
w = Image2_info.Width;
h = Image2_info.Height;
cos_theta = cos((pi/180)*AngleOffsetInDegrees);
sin_theta = sin((pi/180)*AngleOffsetInDegrees);

%Calculate predicted shift of origin (bottom left) from rotation alone
XOffsetFromRotationAlone = -(w/2) + (w/2)*cos_theta + (h/2)*sin_theta;
YOffsetFromRotationAlone = -(h/2) - (w/2)*sin_theta + (h/2)*cos_theta;

XOffset = XOffset - YOffsetFromRotationAlone; %??? This seems to work but it is very wierd math having to do with reversing order of transforms
YOffset = YOffset + XOffsetFromRotationAlone; %??? ''

MyStr = sprintf('XOffset = %0.5g, YOffset = %0.5g, AngleOffsetInDegrees = %0.5g', XOffset, YOffset, AngleOffsetInDegrees);
disp(MyStr);


XOffset_temp = XOffset*cos_theta - YOffset*sin_theta;
YOffset_temp = XOffset*sin_theta + YOffset*cos_theta;

MyStr = sprintf('XOffset_temp = %0.5g, YOffset_temp = %0.5g, AngleOffsetInDegrees = %0.5g', XOffset_temp, YOffset_temp, AngleOffsetInDegrees);
disp(MyStr);



XOffsetOfNewInPixels = round(XOffset_temp);
YOffsetOfNewInPixels = round(YOffset_temp);
AngleOffsetOfNewInDegrees = AngleOffsetInDegrees;

end

