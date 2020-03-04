function PixelRegion=DefinePixelRegionFromCenterFrac(imagepath,center_frac)

theinfo=imfinfo(imagepath);
N=theinfo.Height;
M=theinfo.Width;
centerX=M/2;
centerY=N/2;
Cols=round([centerX-(center_frac*M/2) centerX+(center_frac*M/2)]);
Rows=round([centerY-(center_frac*N/2) centerY+(center_frac*N/2)]);
PixelRegion={Rows,Cols};
