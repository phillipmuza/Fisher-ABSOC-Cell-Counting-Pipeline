//Author: Phillip Muza
//Date: 07.11.22
//Macro to reslice CCFv3 reference.nrrd and annotation.nrrd files to dorsal hippocampal images ready for brain slice registration

run("Reslice [/]...", "output=25.000 start=Left rotate avoid");

//run("Brightness/Contrast...");
makeRectangle(274, 55, 42, 27); //LUT strange, you need to draw an ROI and auto contrast 
run("Enhance Contrast", "saturated=0.35");

//Slice to dorsal hippocampus section
run("Slice Keeper", "first=248 last=309 increment=1");

