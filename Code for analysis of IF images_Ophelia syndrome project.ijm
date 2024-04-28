path="/Users/xxxx/";
stack="name_of_tif_stack"
dapi="dapi.tif";
mglur5="mglur5.tif";
cd30="cd30.tif";
control="control.tif";

open(path+stack+".tif")
run("Set Scale...", "distance=3.0769 known=1 unit=micron global");
run("Stack to Images");
selectWindow(stack+"-0001");
saveAs("Tiff", path+dapi);
close(dapi)
selectWindow(stack+"-0002");
saveAs("Tiff", path+mglur5);
close(mglur5)
selectWindow(stack+"-0003");
saveAs("Tiff", path+cd30); 
close(cd30)
selectWindow(stack+"-0004");
saveAs("Tiff", path+control);
close(control)

//creating autofluorescence mask
open(path+control);
selectWindow(control);
run("Enhance Contrast...", "saturated=0.35 normalize");
setAutoThreshold("MaxEntropy dark no-reset");
//setThreshold(114, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");

saveAs("Tiff",path+"af mask.tif");

//cd30 positive cell segmentation
open(path+control);
selectWindow(control);
run("Enhance Contrast...", "saturated=0.35 normalize");
open(path+cd30);
selectWindow(cd30);
run("Enhance Contrast...", "saturated=0.35 normalize");
run("Subtract Background...", "rolling=100");
imageCalculator("Substract create","cd30.tif","control.tif");
run("Enhance Contrast...", "saturated=0.35")
saveAs("Tiff",path+"cd30-control.tif");
run("Convert to Mask");
imageCalculator("Subtract create","cd30-control.tif","af mask.tif");
run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
saveAs("Tiff",path+"cd30 cells mask.tif");
close("cd30-control.tif");
close(cd30);
close(control);


//mglur5 positive cell segmentation
open(path+control);
selectWindow(control);
run("Enhance Contrast...", "saturated=0.35 normalize");
open(path+mglur5);
selectWindow(mglur5);
run("Enhance Contrast...", "saturated=0.35 normalize");
run("Subtract Background...", "rolling=100");
imageCalculator("Substract create","mglur5.tif","control.tif");
run("Enhance Contrast...", "saturated=0.35")
saveAs("Tiff",path+"mglur5-control.tif");
run("Convert to Mask");
imageCalculator("Subtract create","mglur5-control.tif","af mask.tif");
run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
saveAs("Tiff",path+"mglur5 cells mask.tif");
close("mglur5-control.tif");
close(mglur5);
close(control);
close("af mask.tif");

//segmentation of dapi cells
open(path+dapi);
run("Enhance Contrast...", "saturated=0.35 normalize");
run("Gaussian Blur...", "sigma=2");
setOption("ScaleConversions", true);
run("8-bit");
run("Find Maxima...", "prominence=10 output=[Segmented Particles]");
saveAs("Tiff", path+"segmented.tif");
selectWindow("dapi.tif");
close("dapi.tif");
selectWindow("segmented.tif");
run("Analyze Particles...", "size=0.00-500.00 add");
roiManager("Save", path+"RoiSetSegemented.zip");

//create overlay of cd30 and dapi segments
selectWindow("segmented.tif");
run("Convert to Mask");
open(path+"cd30 cells mask.tif");
imageCalculator("Difference create", "cd30 cells mask.tif","segmented.tif");
selectWindow("Result of cd30 cells mask.tif");
saveAs("Tiff", path+"cd30 and dapi segments.tif");
close("cd30 and dapi segments.tif");
close("segmented.tif");

//measure cd30 positive dapi segments
run("Set Measurements...", "area min area_fraction display redirect=[cd30 cells mask.tif] decimal=3");
selectWindow("ROI Manager");
roiManager("Measure");
Table.sort("Max");
saveAs("Results", path+"Resultscd30.csv");
run("Clear Results");
close("cd30 cells mask.tif");

//find overlapping mglur5 and cd30
open(path+"cd30 cells mask.tif");
imageCalculator("And create","cd30 cells mask.tif","mglur5 cells mask.tif");
selectWindow("Result of cd30 cells mask.tif");
saveAs("Tiff", path+"cd30 and mglur5 overlap");
close("cd30 cells mask.tif");
close("mglur5 cells mask.tif")

//measure overlapping cd30 and mglur5 area
open(path+"segmented.tif")
selectWindow("segmented.tif");
run("Convert to Mask");
imageCalculator("Difference create", "cd30 and mglur5 overlap.tif","segmented.tif");
selectWindow("Result of cd30 and mglur5 overlap.tif");
saveAs("Tiff", path+"cd30 and mglur5 overlap segmented.tif");
close("cd30 and mglur5 overlap segmented.tif");
close("segmented.tif");

run("Set Measurements...", "area min area_fraction display redirect=[cd30 and mglur5 overlap.tif] decimal=3");
selectWindow("ROI Manager");
roiManager("Measure");
Table.sort("Max");
saveAs("Results", path+"Resultsoverlap.csv");
run("Clear Results");
close("cd30 and mglur5 overlap.tif");
close("cd30 cells mask-1.tif")
close("ROI Manager");
close("Results")

run("Set Measurements...", "area min area_fraction display decimal=3");





