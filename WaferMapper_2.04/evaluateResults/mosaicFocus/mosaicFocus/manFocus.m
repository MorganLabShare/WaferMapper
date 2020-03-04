wif = GetMyWafer;
sid = wif.secID;
colormap gray(256)
xs = wif.imfinfo(1).Height;
q = 0;
maxRes = 600;

brightness = 0;
contrast = 1;
button = 1;
t = 1;tNew = 1;
isize = 400;
maxSize = wif.imfinfo(1).Height;
subReg = [round(xs/2 - isize/2) round(xs/2 - isize/2) + isize-1];
subRegX = subReg; subRegY = subReg;
waffer = 1;
strip = 1;
section = 3;
targ = find((sid(:,1) == waffer)& (sid(:,2) == strip) & (sid(:,3)== section));
secNam = wif.secNam{targ};
maxSec = length(wif.secNam);
while ~q







    numTile = length(wif.sec(targ).tile);
    good = zeros(1,numTile); rate = good;
    I = 255-imread(wif.sec(targ).tile{t},'PixelRegion',{subRegY,subRegX});
    image(I)

    subSamp = imread([wif.dir(1:end-1) 'shaped\subsamp\' wif.secNam{targ} '.tif']);
    downSamp = imread([wif.dir(1:end-1) 'shaped\downsamp\' wif.secNam{targ} '.tif']);
    qualSamp = imread([wif.dir(1:end-1) 'shaped\quality\' wif.secNam{targ} '.tif']);

    subplot(2,3,1)
    image(downSamp)
    subplot(2,3,4)
    image(qualSamp)*100
    hold on
    scatter(2,4)
    hold off
%     ylim([0 max(rc(:,1))+1]);
%     xlim([0 max(rc(:,2))+1]);

    subplot(2,3,[2 3 5 6])
    image(I)


    inp = 'e';
    if strcmp(inp,'e') | strcmp(inp,'rl')
        'editing...'


        escapeRequest = 0;

        while ~escapeRequest
            xax = get(gca,'xlim'); yax = get(gca,'ylim'); %update axis vars
            %[mx my button] = ginput;
            pts = getLine;pause(.01)
            rc = wif.sec(targ).rc;
            if isstruct(pts) %was there a keypress?
                key = lower(pts.Key)
                changeC = 0;
                if strcmp(key,'w'),      subRegY = subRegY - size(I,1)/5; readI = 1;
                elseif strcmp(key,'s'),  subRegY = subRegY + size(I,1)/5; readI = 1;
                elseif strcmp(key,'a'),  subRegX = subRegX - size(I,2)/5; readI = 1;
                elseif strcmp(key,'d'),  subRegX = subRegX + size(I,2)/5; readI = 1;
                elseif strcmp(key,'q') | strcmp(key,'leftbracket'), %zoom out
                    mY = mean(subRegY); dif =diff(subRegY);
                    subRegY = round([mY-dif mY+dif]);
                    mX = mean(subRegX); dif =diff(subRegX);
                    subRegX = round([mX-dif mX+dif]);
                    readI = 1;
                elseif strcmp(key,'e') | strcmp(key,'rightbracket'), %zoom out
                    mY = mean(subRegY); dif =diff(subRegY);
                    subRegY = round([mY-dif/2.5 mY+dif/4]);
                    mX = mean(subRegX); dif =diff(subRegX);
                    subRegX = round([mX-dif/2.5 mX+dif/4]);
                    readI = 1;
                elseif strcmp(key,'c'),subRegX = subReg; subRegY = subReg; readI = 1;
                elseif strcmp(key,'f')
                    [c r] = ginput(1)
                    c = round(c + .5); r = round(r + .5);
                    t = find((rc(:,1) ==4)&(rc(:,2)==c))
                elseif strcmp(key,'tab'),escapeRequest = 1;
                elseif strcmp(key,'downarrow'), brightness = brightness - 10;
                elseif strcmp(key,'uparrow'), brightness = brightness + 10;
                elseif strcmp(key,'rightarrow'), contrast = contrast + .25;
                elseif strcmp(key,'leftarrow'), contrast = contrast - .25;
                elseif strcmp(key,'z'),targ = targ-1;
                    if targ<1;targ = 1; end;   readI = 1; readS = 1;
                    rc = wif.sec(targ).rc;
                elseif strcmp(key,'x'),targ = targ+1;
                    if targ>maxSec, targ = maxSec; end; readI = 1; readS = 1;
                    rc = wif.sec(targ).rc;
                elseif strcmp(key,'space'), good(t) = 1;'good', t = t+1; readI = 1;
                elseif strcmp(key,'shift'), good(t) = 2;'bad',t = t+1; readI = 1;

                elseif ~isempty(str2num(key))
                    rate(t) = str2num(key); t = t+1; readI = 1;
                elseif strcmp(key,'tab'),escapeRequest = 1;
                elseif strcmp(key,'capslock') | strcmp(key,'control') ,'saving'
                    save([wif.dir 'good.mat'],'good')
                    save([wif.dir 'rate.mat'],'rate')

                else

                end

                if  readI
                    qualSamp = imread([wif.dir(1:end-1) 'shaped\quality\' wif.secNam{targ} '.tif']);
                    subplot(2,3,4),image(qualSamp),hold on
                    scatter(wif.sec(targ).rc(t,2),wif.sec(targ).rc(t,1));
                    pause(.01)
                    hold off

                    ylim([0 max(rc(:,1))+1]);
                    xlim([0 max(rc(:,2))+1]);
                    subplot(2,3,[2 3 5 6])

                    if t<1,t=1;end
                    if t> numTile, t = numTile;end
                    subRegY = round(subRegY);subRegX = round(subRegX);
                    if subRegY(1)<0; subRegY = subRegY-subRegY(1)+1;   end
                    if subRegX(1)<0; subRegX = subRegX-subRegX(1)+1;   end
                    if subRegY(2)>maxSize; subRegY = subRegY+(maxSize - subRegY(2));   end
                    if subRegX(2)>maxSize; subRegX = subRegX+(maxSize - subRegX(2));   end
                    if diff(subRegY)>maxSize; subRegY(1) = 1; subRegX(1)=1; end


                    rsize = diff(subRegY);
                    if rsize>maxRes
                        useRegY = [subRegY(1) fix(rsize/maxRes)+1 subRegY(2)];
                        useRegX = [subRegX(1) fix(rsize/maxRes)+1 subRegX(2)];
                    else
                        useRegY = subRegY; useRegX = subRegX;
                    end
                    I = 255-imread(wif.sec(targ).tile{t},'PixelRegion',{useRegY,useRegX});
                    readI = 0;
                end

                xax = get(gca,'xlim'); yax = get(gca,'ylim');
                image((I + brightness) * contrast)
                %xlim([xax]);  ylim([yax]);
                pause(.01)

            else
                butt = get(gcf, 'SelectionType')
                pts
                if strcmp(butt,'open')

                elseif strcmp(butt,'normal')
                    button = 1;
                elseif strcmp(butt,'extend')
                    button = 3;
                elseif strcmp(butt,'alt')
                    button = 3;
                else
                    error('MATLAB:ginput:InvalidSelection', 'Invalid mouse selection.')
                end
                button
                %% Respond to buttons
                if button == 2 %return to keyboard
                    escapeRequest = 1;
                elseif button == 1 %change colors
                    t = t-1
                elseif button==3 %edit labels
                    t = t+1
                end
                if t<1,t=1;end
                if t> numTile, t = numTile;end
                                    rsize = diff(subRegY);
                if rsize>maxRes
                    useRegY = [subRegY(1) fix(rsize/maxRes)+1 subRegY(2)];
                    useRegX = [subRegX(1) fix(rsize/maxRes)+1 subRegX(2)];
                else
                    useRegY = subRegY; useRegX = subRegX;
                end

                subplot(2,3,4),image(qualSamp),hold on
                scatter(wif.sec(targ).rc(t,2),wif.sec(targ).rc(t,1));
                pause(.01)
                hold off
                ylim([0 max(rc(:,1))+1]);
                xlim([0 max(rc(:,2))+1]);
                subplot(2,3,[2 3 5 6])

                I = 255-imread(wif.sec(targ).tile{t},'PixelRegion',{useRegY,useRegX});
                image((I + brightness) * contrast ) %.3 sec

                %xlim([xax]);  ylim([yax]);
                pause(.01)

                %}

            end
        end
    end
end



