
// This macro only runs on Fiji ImageJ (I guess :-D)\
// Lucia Doyle & Aaron Wieland HafenCity University Hamburg
// last edited 08.01.2022
// Updated

// What did the last update do?
//  

// Copyright (C) (not needed yet)

// This work is licensed under (not needed yet)

// Whenever this plugin is used in their original or modified versions, we would appreciate if it was cited as: \
// ???


//requires("1.43l");

//clears Fiji imageJ in order to start the process

	run("Clear Results");


// Step 1: Load the image

	Dialog.create("Choose an image");
	Dialog.addMessage("Select the image to be processed");
	Dialog.show();
	
	path_inputfile = File.openDialog("Select a File");
	open(path_inputfile);
	close("\\Others");


 //Normally the scale is read out the meta data, if not the user has to enter it manually.

	//run("Set Scale...");

//For scanned images this line automatically sets the scale:
	
	run("Set Scale...", "distance=28 known=1000 unit=nm");
	

// Step 2: Sample Info

	getDateAndTime(yyyy,mm,dw,dd,h,m,s,ms);

	mm=mm+1;

	date=""+dd+"/"+mm+"/"+yyyy;

	Dialog.create("Enter the sample info");
	Dialog.addString("Sample Name:", "name", 10);
	Dialog.addString("Sample Date:", date);
	//Dialog.addNumber("Min cell area:", 0.00001, 6, "10", "cm^2");
	//Dialog.addNumber("Max cell area:", 0.0001, 6, "10", "cm^2");
	Dialog.addString("Notes:", " ");
	Dialog.show;
	
	name=Dialog.getString();
	date=Dialog.getString();
	//min=Dialog.getNumber();
	//max=Dialog.getNumber();
	notes=Dialog.getString();

	print("+ Sample:, ", name);
	print("+ Date:, ", date);
	//print("Min cell area:,", min);
	//print("Min cell area:,", max);
	print("+ Notes:, ", notes);
	print("");

// Step 3: Choose a Directory

	Dialog.create("Directory");
	Dialog.addMessage("Select the directory");
	Dialog.show();

	dir = getDirectory("Step 3: Choose a Directory to save the Results");
	dirr=dir+name;
	//File.makeDirectory(dirr);

	
// Step 4: selecting the area of interest

// The user selects an area of interest (ROI)

// The image analysis will be conducted only within the selcted area. 
// The area of the ROI needs to be measured, stored and reported, 
// so that the number of cells measured is related to the area of the micrograph 

	// Select dimensions for auto area
	
	setTool("rectangle");
	waitForUser("Draw area of interest.\nClick 'OK' when done");
	run("Crop");


	width = getWidth;
	height = getHeight;
	getPixelSize(unit, pw, ph, pd);

	print("Size: " + width*pw+"x"+height*ph+" " + unit);
	area = width*pw*height*ph
	print(area+" square " + unit)
  
// Step 5: Start Trainable Weka Segmentation\

	run("Trainable Weka Segmentation");


// Step 6: Choose the classifier

//load the classifier and data according to the dialog


	Dialog.create("Segmentation classifier");
	Dialog.addMessage("Select the classifier");
	Dialog.show();

//Sets the directory to the classifier to load it
	
	path_classiefier = File.openDialog("Select a File");
	call("trainableSegmentation.Weka_Segmentation.loadClassifier",path_classiefier);
	close("\\Others");


// Step 7: Get the probability maps

	call("trainableSegmentation.Weka_Segmentation.getProbability");
	run("Slice Remover", "first=1 last=3 increment=2");

	


// Step 8: Thresholding
	
	selectWindow("Probability maps");
	run("8-bit");
	run("Threshold...");
	setAutoThreshold("Default dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");

//dirt = dir + "Probability maps.tif"
//saveAs("Tiff", dirt);
//selectWindow("Probability maps");


// Step 8: Analyze Particles

// Before we run analyze particles, we need to set the measurements required 
// -> Set measurements: Area, Shape descriptors, Fit elipse, Add to overlay

	//run("Set Measurements...", "area fit shape display add redirect=None decimal=1");
	
	run("Analyze Particles...", "size=10000-1200000 show=[Bare Outlines] display include summarize");
	run("Summarize");
	dirp = dirr+"\\particles.jpg"
	saveAs("jpeg", dirp);

	dirt=dirr+"\\"+name+"log.txt";
	dirre=dirr+"\\"+name+"results.csv";

	selectWindow("Log");
	saveAs("Text", dirt);
	selectWindow("Results");
	saveAs("Measurements", dirre);



