import ij.plugin.PlugIn;
import ij.*;
import ij.io.*;
import java.io.*;


public class StitchWaferMapperMontageDirectoryMultipleDirs_PlugIn implements PlugIn {
	/**
	 * This method gets called by ImageJ / Fiji.
	 *
	 * @param arg can be specified in plugins.config
	 */
	public void run(String arg) {
		
		IJ.log(" ");
		IJ.log("*** START *** START *** START ***");

		DirectoryChooser dc = new DirectoryChooser("Choose first montage directory...");
		String FirstMontageDirectorySrting = dc.getDirectory();
		IJ.log("User choose FirstMontageDirectorySrting: " + FirstMontageDirectorySrting);

		String TempString01 = FirstMontageDirectorySrting.substring(0,FirstMontageDirectorySrting.length()-1); //pulls off the last '\'
		IJ.log("TempString01: " + TempString01);
		String MontageStackDirectoryString = TempString01.substring(0,TempString01.lastIndexOf("\\")+1);
		IJ.log("MontageStackDirectoryString: " + MontageStackDirectoryString);

		String TempString02 = TempString01.substring(TempString01.lastIndexOf("\\")+1,TempString01.length());
		IJ.log("TempString02: " + TempString02);
		String MontageDirPrefixString = TempString02.substring(0, TempString02.lastIndexOf("Sec")+3);
		IJ.log("MontageDirPrefixString: " + MontageDirPrefixString);
		String StartSectionNumberString = TempString02.substring(TempString02.lastIndexOf("Sec")+3, TempString02.lastIndexOf("_"));
		IJ.log("StartSectionNumberString: " + StartSectionNumberString);
		int StartSectionNumber = Integer.parseInt(StartSectionNumberString);

		String MontageDirPostfixString = TempString02.substring(TempString02.lastIndexOf("_"), TempString02.length());
		IJ.log("MontageDirPostfixString: " + MontageDirPostfixString);
		
		String PromptString = "What was the percent overlap?";
		double PercentOverlap = IJ.getNumber(PromptString, 10);
		IJ.log("PercentOverlap = " + PercentOverlap);

		
		for (int SecNum=StartSectionNumber; SecNum<=1000; SecNum++) {
		//for (int SecNum=46; SecNum<=46; SecNum++) {


			//String DirectorySrting = "Z:\\nonexistant\\MontageStack_W10_1_15_2012_01\\w10_Sec" + SecNum + "_Montage";
			String DirectorySrting = MontageStackDirectoryString + MontageDirPrefixString + SecNum + MontageDirPostfixString;


			
			IJ.log(" ");
			IJ.log("************************************************************************************");
			IJ.log("*** START: Dir = " + DirectorySrting + "  ***");
			
			
			//Go through all files in directory until first tile file is found
			File dir = new File(DirectorySrting);
			String[] children = dir.list();
			String filename = "";
			Boolean IsFoundFirstTileFile = false;
			String FileNamePostfix = "";
			Integer MaxRow = 1;
			Integer MaxCol = 1;
			if (children == null) {
			    // Either dir does not exist or is not a directory
			    IJ.log("Either dir does not exist or is not a directory. Quitting...");
			    return;
			} 
			
			for (int i=0; i<children.length; i++) {
				filename = children[i];
				if (filename.startsWith("Tile_r1-c1_") && filename.endsWith(".tif")) {
					if (filename.length() < 30) { // needed so it does not get confused by retake tiles
						IsFoundFirstTileFile = true;
						FileNamePostfix = filename.substring(11,filename.length());
						IJ.log("FileNamePostfix = " + FileNamePostfix);
					}
				}	   
	
				if (filename.startsWith("Tile_r") && filename.endsWith(".tif")) {
					String RowString = filename.substring(6,filename.indexOf("-c"));
					String ColString = filename.substring(filename.indexOf("-c")+2, filename.indexOf("_", filename.indexOf("-c")));
					IJ.log("RowString = " + RowString + ", ColString = " + ColString);
					if (Integer.parseInt( RowString ) > MaxRow) {
						MaxRow = Integer.parseInt( RowString );
					}
					if (Integer.parseInt( ColString ) > MaxCol) {
						MaxCol = Integer.parseInt( ColString );
					}
						
					
	
				}
			}
			
	
			if (IsFoundFirstTileFile) {			
				IJ.log("FileNamePostfix = " + FileNamePostfix);
			} else {
				IJ.log("Could not find first tile file. Quitting... ");
				return;
			}
	
			IJ.log("MaxRow = " + MaxRow + ", MaxCol = " + MaxCol);
	
			//String PromptString = "(rows, cols) = (" + MaxRow + ", " + MaxCol + "). " + "What was the percent overlap?";
			//double PercentOverlap = IJ.getNumber(PromptString, 10);
	
			//IJ.log("PercentOverlap = " + PercentOverlap);
			
	
			//String DirectorySrting = "F:\\JM_YR1C_Data\\TestMontage";
			String CommandString = "Stitch Grid of Images";
			String ParamString_Part1 = "grid_size_x=" + MaxCol + " grid_size_y=" + MaxRow + " overlap=" + PercentOverlap + " "; 
			String ParamString_Part2 = "directory=" + DirectorySrting + " "; 
			String ParamString_Part3 = "file_names=Tile_r{y}-c{x}_" + FileNamePostfix + " "; //_w010_sec1.tif ";
			String ParamString_Part4 = "rgb_order=rgb output_file_name=TileConfiguration.txt ";
			String ParamString_Part5 = "start_x=1 start_y=1 start_i=1 channels_for_registration=[Red, Green and Blue] ";
			String ParamString_Part6 = "fusion_method=[Linear Blending] fusion_alpha=1.50 regression_threshold=0.30 max/avg_displacement_threshold=2.50 "; //"fusion_method=[Linear Blending] fusion_alpha=1.50 regression_threshold=0.30 max/avg_displacement_threshold=2.50 ";
			String ParamString_Part7 = "absolute_displacement_threshold=3.50 compute_overlap"; //"absolute_displacement_threshold=3.50 compute_overlap"; 
			String ParamString = ParamString_Part1 + ParamString_Part2 + ParamString_Part3 + ParamString_Part4 + ParamString_Part5 + ParamString_Part6 + ParamString_Part7;
			IJ.run(CommandString, ParamString);

			//Save the stitched image if you want (otherewise just the coordinate file will be saved for virtual alignment use)
			String FijiStitchedFileName = DirectorySrting + "\\FijiStitched_" + SecNum;
			
			
			IJ.saveAs("tiff", FijiStitchedFileName);

			IJ.log("Closing image...");
			IJ.run("Close All");
		}
	
	}
}