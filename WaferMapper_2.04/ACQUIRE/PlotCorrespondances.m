function PlotCorrespondances(I1,I2,Pos1,Pos2,inlierIdx)

I = zeros([size(I1,1) size(I1,2)*2 size(I1,3)],'double');
I(:,1:size(I1,2),:)=double(I1);
I(:,size(I1,2)+1:size(I1,2)+size(I2,2),:)=double(I2);
I=I/max(I(:));
imshow(I);
hold on;
line([size(I1,2) size(I1,2)],[1 size(I1,1)]);
plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','-');
plot([Pos1(inlierIdx,2) Pos2(inlierIdx,2)+size(I1,2)]',[Pos1(inlierIdx,1) Pos2(inlierIdx,1)]','o');
    