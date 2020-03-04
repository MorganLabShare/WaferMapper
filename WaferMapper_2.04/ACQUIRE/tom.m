template = .2*ones(11); % Make light gray plus on dark gray background
template(6,3:9) = .6;   
template(3:9,6) = .6;
BW = template > 0.5;      % Make white plus on black background
figure, imshow(BW), figure, imshow(template)
% Make new image that offsets the template
offsetTemplate = .2*ones(21); 
offset = [10 10];  % Shift by 3 rows, 5 columns
offsetTemplate( (1:size(template,1))+offset(1),...
                (1:size(template,2))+offset(2) ) = template;
figure, imshow(offsetTemplate)
    
% Cross-correlate BW and offsetTemplate to recover offset  
cc = normxcorr2(BW,offsetTemplate); 
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1))
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ]
isequal(corr_offset,offset) % 1 means offset was recovered