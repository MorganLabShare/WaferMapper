function[zstring] = zeroBuf(num,buf)

if ~ischar(num)
    num = num2str(num);
end

if ~exist('buf','var')
    buf = 3;
end

if length(num)>buf
    buf = length(num);
end

zstring(1:buf) = '0';

zstring(end-length(num)+1:end) = num;
