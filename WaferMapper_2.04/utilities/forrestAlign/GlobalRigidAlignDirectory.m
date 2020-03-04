function [xpos,ypos,angles,avg_inliers]=GlobalRigidAlignDirectory(Files)

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

avg_inliers=sum(numinliers,1)./sum(goodmatrix,1);
avg_inliers(isnan(avg_inliers))=0;

   