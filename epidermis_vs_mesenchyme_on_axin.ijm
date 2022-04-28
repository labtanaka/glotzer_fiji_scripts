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
threshold_488 = 270.0
threshold_546 = 600.0
threshold_647 = 700.0

// format image name
fullName = getTitle();
end = indexOf(fullName, ".tif");
imageName = substring(fullName, 0, end);
print(imageName);

// Split channels
run("Split Channels");

// 647 background subtraction
selectImage(1);
image_1 = getTitle();
run("Duplicate...", "title=647 duplicate");
run("Subtract...", "value=background_647 stack"); // background subtraction

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

// 488 Gaussian Blur
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
selectImage(3);
image_1 = getTitle();
Ext.CLIJ2_push(image_1);
Ext.CLIJ2_gaussianBlur3D(image_1, image_2, sigma_x, sigma_y, sigma_z);
Ext.CLIJ2_release(image_1);
Ext.CLIJ2_pull(image_2);
Ext.CLIJ2_release(image_2);
rename("gfp_blurred");
Ext.CLIJ2_clear();

// 647 threshold, make mask, keep largest region and fill holes
selectWindow("axin2_blurred");
setThreshold(threshold_647, 1000000000000000000000000000000.0000);
run("Convert to Mask", "method=Default background=Dark black");
run("Keep Largest Region");
run("3D Fill Holes");
rename("axin2 mask");

// 488 threshold, make mask
selectWindow("gfp_blurred");
setThreshold(threshold_488, 1000000000000000000000000000000.0000);
run("Convert to Mask", "method=Default background=Dark black");
rename("blood mask");

// 546 threshold, make mask, keep largest region and fill holes
selectWindow("fgf8_blurred");
setThreshold(threshold_546, 1000000000000000000000000000000.0000);
run("Convert to Mask", "method=Default background=Dark black");
run("Keep Largest Region");
run("3D Fill Holes");
rename("fgf8 mask");


// subtract the blood for fgf8 to isolate mesenchyme
imageCalculator("Subtract create stack","fgf8 mask","blood mask");
selectWindow("Result of fgf8 mask");
rename("mesenchyme");

// subtract the blood for axin2
imageCalculator("Subtract create stack","axin2 mask","blood mask");
selectWindow("Result of axin2 mask");
rename("Axin2minusblood");

//subtract 546 mesenchyme from dapi to isolate the epidermis
imageCalculator("Subtract create stack","Axin2minusblood","mesenchyme");
selectWindow("Result of Axin2minusblood");
rename("epidermis");

//save a multi-channel image for checking
imagePath = "Y:/People/current/Giacomo/HCR/chir experiment/time course 4 30-07-2021/masks/";
run("Duplicate...", "title=mask duplicate");
run("16-bit");
run("Find Edges", "stack");
run("Merge Channels...", "c1=647 c2=mask create keep");
saveAs("tif", imagePath+"on axin epidermis-"+imageName);

// add masks to 3D manager
run("3D Manager");
selectWindow("mesenchyme");
Ext.Manager3D_AddImage();
selectWindow("epidermis");
Ext.Manager3D_AddImage();

imagePath = "Y:/People/current/Giacomo/HCR/chir experiment/time course 4 30-07-2021/results/";

// make measurements and save them for 546
Ext.Manager3D_Select(0);
Ext.Manager3D_DeselectAll();
selectWindow("647");
Ext.Manager3D_Select(0);
Ext.Manager3D_Quantif();
Ext.Manager3D_SaveResult("Q",imagePath+"on axin mes-"+imageName+".csv");
Ext.Manager3D_CloseResult("Q");

// make measurements and save them for 647
Ext.Manager3D_DeselectAll();
selectWindow("647");
Ext.Manager3D_Select(1);
Ext.Manager3D_Quantif();
Ext.Manager3D_SaveResult("Q",imagePath+"on axin epi-"+imageName+".csv");
Ext.Manager3D_CloseResult("Q");

// close 3d roi manager and close all images 
Ext.Manager3D_Select(0);
Ext.Manager3D_Delete();
Ext.Manager3D_Select(1);
Ext.Manager3D_Delete();
run("Close All");
