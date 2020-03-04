% StackDirectory='E:\SEM_Users\Forest\cropped_enh\';
% OutputDirectory='E:\SEM_Users\Forest\cropped_aligned\'

OutputDirectory='E:\SEM_Users\joshm\LGNs1\Processed\Forrest\alignOverviewsLGN_1\';
Files=getOverviewList('E:\SEM_Users\joshm\LGNs1\UTSL_lgns1_manualAlignBackup\');
%% calculate points of interest on each section
Options.init_sample=4;
Options.octaves=3;
Options.tresh=.001;
Options.centerfrac=.5;
points=getSURFpointsfromFiles(Files,Options);
Z=length(points);

%% find relative similarity transforms between sections
% currently using ransac on top 50 matches.. see inside for details  
AlignmentOptions.verbose=0;
[transforms,numinliers,Pos1s,Pos2s,Inliers]=MetaAlignment(points,AlignmentOptions,Files);    

%% extract the relative parameters from the set of transforms
[relscales,relangles,reldx,reldy,goodmatrix]=extract_relative_rigid(transforms,numinliers);

%% use gradient descent to optimize the angles from the relative angles
[angles,angle_err,angle_Esave]=gradient_optimize_linear(relangles,200,.01,goodmatrix);

%% use gradient descent to optimize the xpositions from the relative x shifts
[xpos,xpos_err,xpos_Esave]=gradient_optimize_linear(reldx,200,.01,goodmatrix);

%% use gradient descent to optimize the ypositions from the relative y shifts
[ypos,ypos_err,ypos_Esave]=gradient_optimize_linear(reldy,200,.01,goodmatrix);

%% output the resulting stack given the parameters for these rigid transforms
mkdir(OutputDirectory); %make the directory if it doesn't exist
files=dir([StackDirectory '*.tif']); %list the filenames in the input directory
imagepath=[StackDirectory files(1).name]; %get the full path for section 1
theinfo=imfinfo(imagepath); %pull out the info from section 1
N=theinfo.Height; %this is the Height/number of rows
M=theinfo.Width; %this is the Width/number of columns
matlabpool(8); %start a matlabpool for parallel writing
parfor i=1:Z %parfor loop over sections
   %create the transformation using the rigid transform matrix
   tform=maketform('affine',[cos(angles(i)) sin(angles(i)) 0;-sin(angles(i)) cos(angles(i)) 0;xpos(i) ypos(i) 1]);
   %read in the section image
   data=imread([StackDirectory files(i).name]);
   %transform the image
   data_t=imtransform(data,tform,'Xdata',[1 M],'Ydata',[1 N]);
   %write out the image
   imwrite(data_t,[OutputDirectory files(i).name],'tif');
   %note progress for user
   disp([i Z]);
end
matlabpool CLOSE;%close the matlabpool
   