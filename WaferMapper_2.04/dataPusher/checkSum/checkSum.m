md5path='D:\users\sejoel\matlab\md5\';

switch(nargin)
case 0,
    error('Too few arguements for MD5');
case 1
    s=sprintf('%c%s%s\t%s\n','!',md5path,'md5.exe -n -otempmd5.txt',varargin{1});
    eval(s);
    a=textread('tempmd5.txt','%s');