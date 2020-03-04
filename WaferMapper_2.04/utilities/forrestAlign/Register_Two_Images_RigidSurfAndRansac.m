function [XOffsetInPixels,YOffsetInPixels,AngleRotationInDegrees,FigureOfMerit]=Register_Two_Images_RigidSurfAndRansac(I1,I2,Options)
%finds the best rigid alignment taking I1 and tranforming it onto I2
%where I1 and I2 are both NxM matrices representing two images
%Options is an optional structure containing the following options and
%defaults
% Options.verbose=0; %whether to produce a verbose output for debugging
% Options.showresult=0; %show the resulting matched transformation and the points
% Options.init_sample=4; %how much to downsample image initially
% Options.octaves=3; %how many octaves of upsampling to try
% Options.tresh=.001; %what threshold to use (lower for more features, raise for fewer)
% Options.Nbest=50; %Run ransac on the top Nbest matching features between the images (cannot be more than the number of features found in I1)
% Options.Niters=Options.Nbest; %How many iterations to run ransac (default to the maximum number of correspondances)
% Options.dist_thresh=.05*(size(I2,1)+size(I2,2))/2; %how close (in pixels) does a correspondance have to be in order to be counted as an inlier by ransac (default to .05 the width of the image)
% Options.thInlrRatio=.1; %minimum percentage of matching features needed to be inliers in order for a match to be found, default 10%.
%
%Returns: 
%XOffsetInPixels:the number of pixels in X to offset I1 in pixels to match I2
%YOffsetInPixels:the number of pixels in Y to offset I1 in pixels to match I2
%AngleRotationInDegrees: the number of degrees to rotate I1 to match I2
%(rotate first then translate).
%FigureOfMerit: a figure of merit which describes how good the
%correspondance is.  This is currently set to be the number of inliers
%found after ransac (note should be evaluated relative to Options.Nbest.

    if ~exist('Options','var')
        Options.verbose=0; %whether to produce a verbose output for debugging
        Options.showresult=0; %show the resulting matched transformation and the points
        Options.init_sample=4; %how many times to downsample image initially
        Options.octaves=3; %how many octaves of upsampling to try
        Options.tresh=.001; %what threshold to use (lower for more features, raise for fewer)
        Options.Nbest=50; %Run ransac on the top Nbest matching features between the images (cannot be more than the number of features found in I1)
        Options.Niters=Options.Nbest; %How many iterations to run ransac (default to the maximum number of correspondances)
        Options.dist_thresh=.05*(size(I2,1)+size(I2,2))/2; %how close (in pixels) does a correspondance have to be in order to be counted as an inlier by ransac (default to .05 the width of the image)
        Options.thInlrRatio=.1; %minimum percentage of matching features needed to be inliers in order for a match to be found, default 10%.
    end

    if ~isfield(Options,'showresult')
        Options.showresult=0; %show the resulting matched transformation and the points
    end
    if ~isfield(Options,'verbose')
        Options.verbose=0;  %whether to produce a verbose output for debugging
    end
    if ~isfield(Options,'init_sample')
        Options.init_sample=4; %how much to downsample image initially
    end
    if ~isfield(Options,'octaves')
        Options.octaves=3; %how many octaves of upsampling to try
    end
    if ~isfield(Options,'tresh')
        Options.tresh=.001; %what threshold to use (lower for more features, raise for fewer)
    end
    if ~isfield(Options,'Nbest')
        Options.Nbest=50; %Run ransac on the top Nbest matching features between the images
    end
    if ~isfield(Options,'Niters')
        Options.Niters=Options.Nbest; %How many iterations to run ransac (default to the maximum number of correspondances)
    end
    if ~isfield(Options,'dist_thresh')
        Options.dist_thresh=.05*(size(I2,1)+size(I2,2))/2; %how close (in pixels) does a correspondance have to be in order to be counted as an inlier by ransac (default to .05 the average dimension of I2)
    end
    if ~isfield(Options,'thInlrRatio');
        Options.thInlrRatio=.1; %minimum percentage of matching features needed to be inliers in order for a match to be found, default 10%.
    end

    %get the features from the two images
    p1=OpenSurf(I1,Options);
    p2=OpenSurf(I2,Options);

    %find the best Options.Nbest matching correspondances for the features in I1
    %matched up to each feature in I2
    [Pos1,Pos2]=find_best_SURF_match(p1,p2,Options.Nbest);

    %setup ransac Options
    ransacCoef.minPtNum=2;   %for a rigid or similarity transform 2 is the number needed
    ransacCoef.iterNum= Options.Niters; %run through this many iterations of ransac
    ransacCoef.thDist= Options.dist_thresh; %should be within this many pixels to be inlier
    ransacCoef.thInlrRatio= Options.thInlrRatio; %at least this percent should be right to count as a match

    %run ransac algorithm, f is a tform structure, and inlierIdx is the set of
    %indices that denote which points within Pos1/Pos2 were found to be inliers
    %need to transpose list of points to make them  (Y,X)xNbest, and then flipdim to make it (X/Y)xNbest
    [f inlierIdx] = ransac1( flipdim(Pos1',1),flipdim(Pos2',1),ransacCoef,@fit_rigid,@EuclideanDistance );
    FigureOfMerit=length(inlierIdx);
    
    %extract the angle,scalefactor,and x/y shifts from the tform structure
    if length(inlierIdx)>4
        M=f.tdata.T; %pull out the transformation matrix
        R=M(1:2,1:2); %this is the 2x2 part of the matrix which gives the rotation/scale factor
        relscale=sqrt(det(R));%the scale factor is the sqrt of the determinant
        R=R/sqrt(det(R)); %remove the scale factor component from the matix, it is now a rotation matrix
        relangle=atan2(R(1,2),R(1,1)); %the angle can be calculated from the top row of rotation matrix
        AngleRotationInDegrees=relangle*180/pi; %convert from radians to degrees
        XOffsetInPixels=M(3,1)/relscale; %this is the offset is x, need to divide by scale factor to get what it would have been without scaling
        YOffsetInPixels=M(3,2)/relscale;
    else
        AngleRotationInDegrees=0; %convert from radians to degrees
        XOffsetInPixels=0; %this is the offset is x, need to divide by scale factor to get what it would have been without scaling
        YOffsetInPixels=0;
    end
    
    %plot out the results if asked for
    if Options.showresult
        maxval1=double(max(I1(:)));
        maxval2=double(max(I2(:)));
        
        % Show both images
        I = zeros([size(I1,1) size(I1,2)*2 size(I1,3)],'double');
        I(:,1:size(I1,2),:)=double(I1)/maxval1;
        I(:,size(I1,2)+1:size(I1,2)+size(I2,2),:)=double(I2)/maxval2;
        figure, imshow(I); hold on;
        % Show the best matches
        plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','-');
        plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','o');

        % Warp the image
        I1_warped=imtransform(double(I1)/maxval1,f,'bicubic','Xdata',[1 size(I2,2)],'Ydata',[1 size(I2,1)]);
        I = zeros([size(I1,1) size(I1,2) 3],'double');
        I(:,:,1)=double(I1_warped);
        I(:,:,2)=double(I2)/maxval2;
        %display the resulting overlap in red/green
        figure;
        imshow(I);

    end
end

function [Pos1,Pos2]=find_best_SURF_match(Ipts1,Ipts2,Npts)
    if ~exist('Npts','var')
        Npts=30;
    end

    D1 = reshape([Ipts1.descriptor],64,[]);
    D2 = reshape([Ipts2.descriptor],64,[]);

    % Find the best matches
    err=zeros(1,length(Ipts1));
    cor1=1:length(Ipts1);
    cor2=zeros(1,length(Ipts1));
    for i=1:length(Ipts1),
        distance=sum((D2-repmat(D1(:,i),[1 length(Ipts2)])).^2,1);
        [err(i),cor2(i)]=min(distance);
    end

    % Sort matches on vector distance
    [err, ind]=sort(err);
    cor1=cor1(ind);
    cor2=cor2(ind);

    % Make vectors with the coordinates of the best matches
    Pos1=[[Ipts1(cor1).y]',[Ipts1(cor1).x]'];
    Pos2=[[Ipts2(cor2).y]',[Ipts2(cor2).x]'];
    if size(Pos1,1)>Npts
        Pos1=Pos1(1:Npts,:);
        Pos2=Pos2(1:Npts,:);
    end
end

function tform=fit_rigid(pts1,pts2)
    %pts1 is a 2x2 (points by x,y) representing 2 points from image space 1
    %pts2 is a 2x2 (points by x,y) representing 2 points from image space 2
    %M is the 2x3 matrix which describes the rigid transformation which brings
    %these points into correspondance
    tform=cp2tform(flipdim(pts1',1),flipdim(pts2',1),'nonreflective similarity');

end

function d=EuclideanDistance(tform,pts1,pts2)

    pts1_trans=tformfwd(tform,pts1');
    d=sqrt(sum((pts2'-pts1_trans).^2,2))';

end

