function tform=fit_rigid(pts1,pts2)
%pts1 is a 2x2 (points by x,y) representing 2 points from image space 1
%pts2 is a 2x2 (points by x,y) representing 2 points from image space 2
%M is the 2x3 matrix which describes the rigid transformation which brings
%these points into correspondance
if nargin ~= 2
	    error('Missing parameters');
end

    %if there is only 1 correspondance, then assume translation
    if (size(pts1,1)==1)
        R=[1 0;1 0];
        t=pts2-pts1;
    else
        
        pts1=pts1';
        pts2=pts2';

        centroid_1 = mean(pts1,1);
        centroid_2 = mean(pts2,1);

        N = size(pts1,1);

        x=(pts1-repmat(centroid_1,N,1))';
        y=(pts2-repmat(centroid_2,N,1))';

        %H = (pts1 - repmat(centroid_1, N, 1))' * (pts2 - repmat(centroid_2, N, 1));
        H=x*y';

        [U,S,V] = svd(H);

        R = V*U';

        if det(R) < 0
            V(:,2) =-V(:,2);
            R = V*U';

        end

        t = -R*centroid_1' + centroid_2';
    end
    T=zeros(3,3);
    T(1:2,1:2)=R';
    T(3,1:2)=t';
    T(3,3)=1;
    tform=maketform('affine',T);
    
    %tform=cp2tform(flipdim(pts1,1),flipdim(pts2,1),'nonreflective similarity');
%     determinant=getDeterminantOfAffineTransform(tform);
%     if and(abs(sqrt(determinant)-1)<.25,size(pts1,1)>10)
%         tform.tdata.T
%         tform2.tdata.T
%     end
%     
  
   
    
        

