

for(SecNum = 1; SecNum <= 2; ++SecNum) {

	SecNumStr = "" + (1000 + SecNum);
	SecNumStr = substring(SecNumStr,1,4);
	print("SecNumStr: " + SecNumStr);

	

	//FileName = "Z:\\Max_Retina_Images\\TestFolder\\FijiStitched_" + SecNum + ".tif";
	FileName = "E:\\SEM_Users\\joshm\\Cortex_UTSL\\Processed\\TestNames\\FijiStitched_" + SecNumStr + ".tif";
	print("Opening: " + FileName);
	
	open(FileName);
	run("Canvas Size...", "width=16000 height=16000 position=Center zero");
	//SaveAsFileName = "Z:\\Max_Retina_Images\\TargetFolder\\FijiStitched_ExpandedCanvas_" + SecNum + ".tif";
	SaveAsFileName = "E:\\SEM_Users\\joshm\\Cortex_UTSL\\Processed\\TestNames\\FijiStitched_ExpandedCanvas_" + SecNumStr + ".tif";
	
	print("Saving: " + SaveAsFileName);
	saveAs("Tiff", SaveAsFileName);

	close();
	
	
}