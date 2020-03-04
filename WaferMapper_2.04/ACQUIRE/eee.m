LowA = GuiGlobalsStruct.SubImageForAreaToMatch<15;
HighA = GuiGlobalsStruct.SubImageForAreaToMatch>240;

D = LowA + HighA;
E = double(~D).*double(GuiGlobalsStruct.SubImageForAreaToMatch);
figure
imshow(uint8(E));