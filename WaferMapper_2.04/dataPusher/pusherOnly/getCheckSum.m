function[a] = getCheckSum(fileName,md5path)

s=sprintf('%c%s%s\t%s\n','!',md5path,'\md5.exe -n -otempmd5.txt',fileName);
eval(s);
a=textread('tempmd5.txt','%s');

