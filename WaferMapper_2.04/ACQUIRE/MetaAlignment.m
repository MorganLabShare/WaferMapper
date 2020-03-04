function [transforms,num_inliers,Pos1s,Pos2s,Inliers]=MetaAlignment(points,Options,Files,MatFiles)
%Takes a set of point features across Z sections (currently written to use OPENSurf
%(points is thus a 1xZ cell array)
%taken from the virtual tiff stack located in StackDirectory (currently i read in
%the images so one could display the matches, though it isn't strictly
%necessary for the calculation
%
%from these set of features, it calculates a set of similarity
%tranformations that
if ~exist('Options','var')
    Options.verbose=0;
    Options.pixsize=1.3;
    Options.n_dense=5;
    Options.long_length=15;
    Options.n_long=8;
    Options.Nbest=50;
    Options.dist_thresh=20;
end
if ~isfield(Options,'verbose')
    Options.verbose=0;
end
if ~isfield(Options,'pixelsize')
    Options.pixsize=1.3;
end
if ~isfield(Options,'n_dense')
    Options.n_dense=5;
    %this is the size of the neighborhood with which comparisons
    %will be made.  So section #i will get compared to every
    %section withing #i-n_dense to #i+n_dense neighborhood
end
if ~isfield(Options,'long_length')
    Options.long_length=15;
    %this also adds in comparisons on longer length scales
    %long length is how long this length scale is
end
if ~isfield(Options,'n_long')
    Options.n_long=8;
    % and n_long is how many 'deep' it goes
    % so for long_length=5 and n_long=2
    % then section 15 for example would get compared to
    % sections 5,10,20,and 25.
end
if ~isfield(Options,'Nbest')
    Options.Nbest=50;
    % This specifies that it should find at most the 50 best points of correspondance
    % between any two sections before running ransac to find the
    % set of points amongst those which are best explained by a
    % single rigid transformation
end
if ~isfield(Options,'dist_thresh')
    Options.dist_thresh=20.0; %this is how close in microns
    %the transformed points have to meet their matched points in order
    %to be counted as an inlier
end
if ~isfield(Options,'maxVal')
    Options.maxVal=255.0; %this specifies what the brightest pixel
    %to display in the image is.
end
if ~isfield(Options,'cropBuffer')
    Options.cropBuffer=15.0; %when cropping out regions of overview images that overlap,
    %this is the buffer that is added in order to account for possible inaccuracies in the stage
    
end

theinfo=imfinfo(Files{1}); %pull out the info from the first section
N=theinfo.Height; %this is the Height/number of rows
M=theinfo.Width; %this is the Width/number of columns
Z=length(Files); %this is the number of sections in stack
Zeff=Z; %this is a shortcut to making this work on the first Zeff sections
%useful for debugging


%% Determine what comparisons to make
compare_matrix=zeros(Zeff,Zeff); %initialize the matrix to none

for i=1:Zeff %loop over sections
    max_index=min(i+ Options.n_dense,Zeff); %we only compare sections higher, so must stop at last section
    compare_matrix(i,i:max_index)=1; %compare all the nearby sections within Options.n_dense (accounting for edge)
    max_index=min(i+( Options.long_length* Options.n_long),Zeff); %similar calculation for longer skips
    compare_matrix(i,i: Options.long_length:max_index)=1; %again, all nearby sections using the longer skip period and depth
    compare_matrix(i,i)=0; %make sure that we don't waste time comparing a section to itself
end

%visualize the comparisons that will be done
% figure(3);
% clf;
% imagesc(compare_matrix);

%% loop over all the comparisons

%find the comparisons that we want to do, and get their indices
goodones=find(compare_matrix);

%setup the ransac options
ransacCoef.minPtNum=2;   %for a rigid or similarity transform 2 is the number needed
ransacCoef.iterNum= Options.Nbest; %run through a number of iterations equal
% to the number of points
ransacCoef.thDist= Options.dist_thresh/ Options.pixsize; %should be within 20 microns to be right
ransacCoef.thInlrRatio=.05; %at least 5 percent should be right
ransacCoef.thDet = 0.25; %arbitrary

%cell arrays for saving the results of ransac
Pos1s=cell(size(compare_matrix));
Pos2s=cell(size(compare_matrix));
Inliers=cell(size(compare_matrix));
num_inliers=zeros(size(compare_matrix));
transforms=cell(size(compare_matrix));
%loop over all the good

h1 = figure;
for ind = 1:length(goodones)
    %display progress for user
    disp([ind length(goodones)]);
    %pull out the index of the comparison
    k=goodones(ind);
    %convert it to a pair of subscripts
    [p1,p2]=ind2sub(size(compare_matrix),k);
    if and(exist('MatFiles'),isfield(Options,'PixelRegion'))
        Rows=Options.PixelRegion{1};
        Cols=Options.PixelRegion{2};
        Info1=load(MatFiles{p1},'Info');
        Info2=load(MatFiles{p2},'Info');
        Info1=Info1.Info;
        Info2=Info2.Info;
        
        %define a set of points which are the corners of the images in
        %micron coordinates
        %start with pixels, where 1,1 is at the upper left
        Frame1x=[Cols(1) Cols(2) Cols(2) Cols(1)];
        Frame1y=[Rows(1) Rows(1) Rows(2) Rows(2)];
        %subtract off half the width in pixels so the center is in the
        %middle
        Frame1x=Frame1x-(Info1.ImageHeightInPixels/2);
        Frame1y=Frame1y-(Info1.ImageHeightInPixels/2);
        %Frame 2 is the same at this point in calculation
        Frame2x=Frame1x;
        Frame2y=Frame1y;
        
        %now convert these pixels relative to the center coordinates
        %into micrometers, where positive Y is down, and positive X is
        %to the left
        scale_micron_per_pixel=Info1.FOV_microns/Info1.ImageWidthInPixels;
        Frame1x=-scale_micron_per_pixel*Frame1x+Info1.StageX_Meters*10^6;
        Frame1y=scale_micron_per_pixel*Frame1y+Info1.StageY_Meters*10^6;
        Frame2x=-scale_micron_per_pixel*Frame2x+Info2.StageX_Meters*10^6;
        Frame2y=scale_micron_per_pixel*Frame2y+Info2.StageY_Meters*10^6;
        
        
        %Since we can assume the rectangles are of equal height and
        %width, then the corner which is within the other rectangle
        %is the corner which makes up the corner of the rectnagle which
        %defines the overlapping region.
        F1CornerIsInside_F2=inpolygon(Frame1x,Frame1y,Frame2x,Frame2y);
        F2CornerIsInside_F1=inpolygon(Frame2x,Frame2y,Frame1x,Frame1y);
        if (sum(F1CornerIsInside_F2)>0)
            %then we have overlapping coordinates
            %pull out the coordinates of the corners which define the
            %overlapping rectangle
            F1CornerX=Frame1x(F1CornerIsInside_F2);
            F1CornerY=Frame1y(F1CornerIsInside_F2);
            F2CornerX=Frame2x(F2CornerIsInside_F1);
            F2CornerY=Frame2y(F2CornerIsInside_F1);
            OverlapXv=[F1CornerX F2CornerX F2CornerX F1CornerX];
            OverlapYv=[F1CornerY F1CornerY F2CornerY F2CornerY];
  
            %pull out the coordinates of the points
            points1=points{p1};
            points2=points{p2};
            p1x=[points1(:).x];
            p1y=[points1(:).y];
            p2x=[points2(:).x];
            p2y=[points2(:).y];
            
            figure(3);
            clf;
            scatter(p1x,p1y,'kx');
            
            %convert them to positions in microns
            p1x=-scale_micron_per_pixel*(p1x-(Info1.ImageWidthInPixels/2));
            p1y=scale_micron_per_pixel*(p1y-(Info1.ImageHeightInPixels/2));
            p2x=-scale_micron_per_pixel*(p2x-(Info2.ImageWidthInPixels/2));
            p2y=scale_micron_per_pixel*(p2y-(Info2.ImageHeightInPixels/2));
            p1x=p1x+Info1.StageX_Meters*10^6;
            p1y=p1y+Info1.StageY_Meters*10^6;
            p2x=p2x+Info2.StageX_Meters*10^6;
            p2y=p2y+Info2.StageY_Meters*10^6;
  
            %now lets find which of these poitns are inside the overlapping rectangle
            
            [points_from_1_that_overlap]=inpolygon(p1x,p1y,OverlapXv,OverlapYv);
            [points_from_2_that_overlap]=inpolygon(p2x,p2y,OverlapXv,OverlapYv);
            
            
            figure(5);
            clf;
            patch(Frame1x,Frame1y,'r');
            hold on;
            patch(Frame2x,Frame2y,'g');
            patch(OverlapXv,OverlapYv,'b');
            axis equal;
            scatter(p1x(~points_from_1_that_overlap),p1y(~points_from_1_that_overlap),'kx');
            scatter(p2x(~points_from_2_that_overlap),p2y(~points_from_2_that_overlap),'yx');
            
            set(gca,'Ydir','reverse');
            set(gca,'Xdir','reverse');

            points1=points1(~points_from_1_that_overlap);
            points2=points2(~points_from_2_that_overlap);
        else
            points1=points{p1};
            points2=points{p2};
        end
    end
    % return the Options.Nbest SURF matches between these two sections
    [Pos1,Pos2]=find_best_SURF_match(points1,points2,Options.Nbest);
    
    %now use those correspondances to fit a similarity transformation
    %using ransac.. i call it fit_rigid, so if i could figure out how
    %to fit a rigid rather than similirity transform i would do that.
    %
    %need to transpose list of points to make them  (Y,X)xNbest, and then flipdim to make it (X/Y)xNbest
    
    for t = 1:10
        [f inlierIdx] = ransac1( flipdim(Pos1',1),flipdim(Pos2',1),ransacCoef,@fit_rigid,@EuclideanDistance );
    if isempty(f)
        ransacCoef.thDist = ransacCoef.thDist*2;
        'increasing thDist'
    else
        break
    end
    end
%     if isempty(f)
%        f.ndims_in = 2;
%        f.ndims_out = 2;
%        f.forward_fcn = '@fwd_affine';
%        f.inverse_fcn = '@inv_affine';
%        f.tdata.T = [1 0 0; 0 1 0; 0 0 1];
%        f.tdata.Tinv = [1 0 0; 0 1 0; 0 0 1];
%     end
    
    
    %save the results in the cell arrays
    Pos1s{p1,p2}=Pos1;
    Pos2s{p1,p2}=Pos2;
    Inliers{p1,p2}=inlierIdx;
    num_inliers(p1,p2)=length(inlierIdx);
    transforms{p1,p2}=f;
    
    if Options.verbose
        %to visualize the results
        I1=imread(Files{p1});
        I2=imread(Files{p2});
        % Show both images
        I = zeros([size(I1,1) size(I1,2)*2 size(I1,3)],'double');
        I(:,1:size(I1,2),:)=double(I1)/ Options.maxVal;
        I(:,size(I1,2)+1:size(I1,2)+size(I2,2),:)=double(I2)/ Options.maxVal;
        subplot(2,1,1), imshow(I); hold on;
        % Show the best matches
        plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','-');
        plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','o');
        
        % Warp the image
       I1_warped=imtransform(double(I1)/ Options.maxVal,f,'bicubic','Xdata',[1 size(I2,2)],'Ydata',[1 size(I2,1)]);
        %I1_warped=imwarp(double(I1)/ Options.maxVal,f,'bicubic','Xdata',[1 size(I2,2)],'Ydata',[1 size(I2,1)]);
        I = zeros([size(I1,1) size(I1,2) 3],'double');
        I(:,:,1)=double(I1_warped);
        I(:,:,2)=double(I2)/ Options.maxVal;
        %display the resulting overlap in red/green
        subplot(2,1,2);
        clf;
        imshow(I); hold on;
        pause(.01)
    end
end
close(h1)

end


function tform=fit_similarity(pts1,pts2)
%pts1 is a 2x2 (points by x,y) representing 2 points from image space 1
%pts2 is a 2x2 (points by x,y) representing 2 points from image space 2
%M is the 2x3 Matrix which described the similarity transformation
%which brings these points into correspondance

tform=cp2tform(flipdim(pts1',1),flipdim(pts2',1),'nonreflective similarity');
end

function M=fit_affine(pts1,pts2)
%pts1 is a 3x2 (points by x,y) representing 3 points from image space 1
%pts2 is a 3x2 (points by x,y) representing 3 points from image space 2
%M is the 2x3 Matrix which described the similarity transformation
%which brings these points into correspondance

M=[1 0 0;0 1 0];
end
