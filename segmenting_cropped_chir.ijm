// PARAMETERS

// Gaussian Blur Parameters
// voxel size (xyz): (0.64, 0.64, 2.209)
sigma_x = 6.0;
sigma_y = 6.0;
sigma_z = 1.74;

// Background Subtraction Parameters
background_546 = 460.6
background_647 = 480.6

// Thresholds used for masking
threshold_488 = 300.0
threshold_546 = 800.0
threshold_647 = 800.0


// format image name
var fullName = getTitle();
var end = indexOf(fullName, ".tif");
var imageName = substring(fullName, 0, end);
print(imageName);

// Split channels
run("Split Channels");

// 546 background subtraction
selectImage(2);
image_1 = getTitle();
run("Duplicate...", "title=546 duplicate");
run("Subtract...", "value=background_546 stack");

// 546 Gaussian Blur
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
Ext.CLIJ2_push(image_1);
Ext.CLIJ2_gaussianBlur3D(image_1, image_2, sigma_x, sigma_y, sigma_z);
Ext.CLIJ2_release(image_1);
Ext.CLIJ2_pull(image_2);
Ext.CLIJ2_release(image_2);
rename("fgf8_blurred");
Ext.CLIJ2_clear();

// 647 background subtraction
selectImage(1);
image_1 = getTitle();
run("Duplicate...", "title=647 duplicate");
run("Subtract...", "value=background_647 stack");

// 647 Gaussian Blur
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
Ext.CLIJ2_push(image_1);
Ext.CLIJ2_gaussianBlur3D(image_1, image_2, sigma_x, sigma_y, sigma_z);
Ext.CLIJ2_release(image_1);
Ext.CLIJ2_pull(image_2);
Ext.CLIJ2_release(image_2);
rename("axin2_blurred");
Ext.CLIJ2_clear();

// 488 Gaussian Blur
selectImage(3);
image_1 = getTitle();
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_push(image_1);
Ext.CLIJ2_gaussianBlur3D(image_1, image_2, sigma_x, sigma_y, sigma_z);
Ext.CLIJ2_release(image_1);
Ext.CLIJ2_pull(image_2);
Ext.CLIJ2_release(image_2);
rename("gfp_blurred");
Ext.CLIJ2_clear();

// threshold 488, isolate mask of blood
selectWindow("gfp_blurred");
setThreshold(threshold_488, 1000000000000000000000000000000.0000);
run("Convert to Mask", "method=Default background=Dark black");
rename("blood mask");

// threshold 546, isolate mask of fgf8 domain
selectWindow("fgf8_blurred");
setThreshold(threshold_546, 1000000000000000000000000000000.0000);
run("Convert to Mask", "method=Default background=Dark black");
rename("fgf8 mask");

// threshold 647, isolate mask of 647 domain
selectWindow("axin2_blurred");
setThreshold(threshold_647, 1000000000000000000000000000000.0000);
run("Convert to Mask", "method=Default background=Dark black");
rename("axin2 mask");

// subtract the blood from fgf8
imageCalculator("Subtract create stack","fgf8 mask","blood mask");
selectWindow("Result of fgf8 mask");
run("Keep Largest Region");
rename("Fgf8minusblood");
run("Duplicate...", "title=mask duplicate");

//save a multi-channel image for checking
imagePath = "Y:/People/current/Giacomo/HCR/chir experiment/time course 4 30-07-2021/masks/";
run("16-bit");
run("Find Edges", "stack");
run("Merge Channels...", "c1=546 c2=mask create keep");
saveAs("tif", imagePath+"Fgf8-"+imageName);

// subtract the blood from axin2
imageCalculator("Subtract create stack","axin2 mask","blood mask");
selectWindow("Result of axin2 mask");
run("Keep Largest Region");
rename("Axin2minusblood");
run("Duplicate...", "title=mask2 duplicate");

//save a multi-channel image for checking
run("16-bit");
run("Find Edges", "stack");
run("Merge Channels...", "c1=647 c2=mask2 create keep");
saveAs("tif", imagePath+"Axin2-"+imageName);

// add masks to 3D manager
run("3D Manager");
selectWindow("Fgf8minusblood");
Ext.Manager3D_AddImage();
selectWindow("Axin2minusblood");
Ext.Manager3D_AddImage();

imagePath = "Y:/People/current/Giacomo/HCR/chir experiment/time course 4 30-07-2021/results/";

// make measurements and save them for 546
Ext.Manager3D_Select(0);
Ext.Manager3D_DeselectAll();
selectWindow("546");
Ext.Manager3D_Select(0);
Ext.Manager3D_Quantif();
Ext.Manager3D_SaveResult("Q",imagePath+"546-"+imageName+".csv");
Ext.Manager3D_CloseResult("Q");

// make measurements and save them for 647
Ext.Manager3D_DeselectAll();
selectWindow("647");
Ext.Manager3D_Select(1);
Ext.Manager3D_Quantif();
Ext.Manager3D_SaveResult("Q",imagePath+"647-"+imageName+".csv");
Ext.Manager3D_CloseResult("Q");

// close 3d roi manager and close all images 
Ext.Manager3D_Select(0);
Ext.Manager3D_Delete();
Ext.Manager3D_Select(1);
Ext.Manager3D_Delete();
run("Close All");
