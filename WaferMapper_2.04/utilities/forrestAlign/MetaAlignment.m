function [transforms,num_inliers,Pos1s,Pos2s,Inliers]=MetaAlignment(points,Options,Files)
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
    figure(3);
    clf;
    imagesc(compare_matrix);

    %% loop over all the comparisons
    
    %find the comparisons that we want to do, and get their indices
    goodones=find(compare_matrix);
    
    %setup the ransac options
    ransacCoef.minPtNum=2;   %for a rigid or similarity transform 2 is the number needed
    ransacCoef.iterNum= Options.Nbest; %run through a number of iterations equal
                                       % to the number of points
    ransacCoef.thDist= Options.dist_thresh/ Options.pixsize; %should be within 20 microns to be right
    ransacCoef.thInlrRatio=.05; %at least 5 percent should be right
 
    %cell arrays for saving the results of ransac
    Pos1s=cell(size(compare_matrix));
    Pos2s=cell(size(compare_matrix));
    Inliers=cell(size(compare_matrix));
    num_inliers=zeros(size(compare_matrix));
    transforms=cell(size(compare_matrix));
    %loop over all the good
    for ind = 1:length(goodones)
        %display progress for user
        disp([ind length(goodones)]);
        %pull out the index of the comparison
        k=goodones(ind);
        %convert it to a pair of subscripts
        [p1,p2]=ind2sub(size(compare_matrix),k);
        % return the Options.Nbest SURF matches between these two sections
        [Pos1,Pos2]=find_best_SURF_match(points{p1},points{p2},Options.Nbest);
        
        %now use those correspondances to fit a similarity transformation
        %using ransac.. i call it fit_rigid, so if i could figure out how
        %to fit a rigid rather than similirity transform i would do that.
        %
        %need to transpose list of points to make them  (Y,X)xNbest, and then flipdim to make it (X/Y)xNbest 
        [f inlierIdx] = ransac1( flipdim(Pos1',1),flipdim(Pos2',1),ransacCoef,@fit_rigid,@EuclideanDistance );
        
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
            I(:,1:size(I1,2),:)=double(I1)/maxval;
            I(:,size(I1,2)+1:size(I1,2)+size(I2,2),:)=double(I2)/maxval;
            figure, imshow(I); hold on;
            % Show the best matches
            plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','-');
            plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','o');
            
            % Warp the image
            I1_warped=imtransform(double(I1)/maxval,f,'bicubic','Xdata',[1 size(I2,2)],'Ydata',[1 size(I2,1)]);
            I = zeros([size(I1,1) size(I1,2) 3],'double');
            I(:,:,1)=double(I1_warped);
            I(:,:,2)=double(I2)/maxval;
            %display the resulting overlap in red/green
            figure(8);
            clf;
            imshow(I); hold on;
            pause;
        end
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
function M=fit_similarity(pts1,pts2)
    %pts1 is a 2x2 (points by x,y) representing 2 points from image space 1
    %pts2 is a 2x2 (points by x,y) representing 2 points from image space 2
    %M is the 2x3 Matrix which described the similarity transformation
    %which brings these points into correspondance
    
    M=[1 0 0;0 1 0];
end

function M=fit_affine(pts1,pts2)
    %pts1 is a 3x2 (points by x,y) representing 3 points from image space 1
    %pts2 is a 3x2 (points by x,y) representing 3 points from image space 2
    %M is the 2x3 Matrix which described the similarity transformation
    %which brings these points into correspondance

     M=[1 0 0;0 1 0];
end

function d=EuclideanDistance(tform,pts1,pts2)
    
    pts1_trans=tformfwd(tform,pts1');
    d=sqrt(sum((pts2'-pts1_trans).^2,2))';

end