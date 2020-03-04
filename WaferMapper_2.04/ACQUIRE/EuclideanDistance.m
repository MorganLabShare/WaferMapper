function d=EuclideanDistance(tform,pts1,pts2)
pts1_trans=tformfwd(tform,pts1');
d=sqrt(sum((pts2'-pts1_trans).^2,2))';
