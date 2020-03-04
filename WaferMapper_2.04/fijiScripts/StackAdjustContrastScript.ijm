var imp = IJ.getImage();
var n = imp.getStackSize();

for( var i = 0; i < n; ++i) {
    imp.setSlice(i+1);
    IJ.run(imp, "Enhance Contrast", "saturated=0.35 normalize");
}