function [  ] = StatusBarMessage( MyStr )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global GuiGlobalsStruct;

set(GuiGlobalsStruct.h_StatusBar_EditBox, 'String', MyStr);


end

