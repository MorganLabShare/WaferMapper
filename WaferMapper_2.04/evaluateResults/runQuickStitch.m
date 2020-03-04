
APN = 'G:\joshm\testMon3\';

dAPN = dir(APN); dAPN= dAPN(3:end);
stitchDir = 'G:\joshm\testMon3\quickStitched\';
if ~exist(stitchDir)
    mkdir(stitchDir);
end


c = 0;
for i = 1:length(dAPN)
    nam = dAPN(i).name;
    
    firstI = 1;
    if dAPN(i).isdir
        if length(nam)>10
            if strcmp(nam(end-6:end),'Montage')
                c = c+1;
                    [I sStats] = quickStitchSub([APN nam '\']);
                    stitchName = [nam(1:end-7) '.tif'];
                    
                        [ys xs cs] = size(I);
                    if firstI
                        firstI = 0;
                        bys = round(ys * 1.1); 
                        bxs =round(xs * 1.1);
                        bigI = zeros(bys,bxs,3,'uint8');
                    end
                    bigI = bigI * 0;
                    rightSide = min(bxs,xs);
                    lowSide = min(bys,ys);
                    bigI(1:lowSide,1:rightSide,:) = I(1:lowSide,1:rightSide,:);
                    imwrite(bigI,[stitchDir stitchName],'Compression','none')
                    stitchStats(c).stats=sStats;
                    stitchStats(c).section = stitchName;
                    save([stitchDir 'stitchStats.mat'],'stitchStats');
            end
        end
    end
    
end