// Kamyar Esmaeili Pourfarhangi 20191201
// Pre-Processing: Step 1
// This macro reads Keyence-Captured Raw CODEX images, selects the image with the best focus
// 		and saves the images in a working directory with intuitive naming.  
//---------------------------------------------------------------------------------------------
// Required Pluggin:
// Find Focused Slices: https://sites.google.com/site/qingzongtseng/find-focus
//---------------------------------------------------------------------------------------------
// Required input:
// CycleNum: Number of cycles in the dataset to be processed. User will have the oportunity to 
// 		enter this value after running the code.
// MIAcol: Number of columns in the MIA. User will have the opportunity to enter this value a-
//		fter running the code.
// MIArow: Number of Rows in the MIA. User will have the opportunity to enter this value after
//		running the code.
// Channels: The number of fluorescent channels used during the data acquisition. Akoya's lat-
// 		est protocol uses 4 channels of DAPI/488/555/647 or DAPI/488/647/750. 
// Zsec: The number of Z slices imaged at each FOV 
// ColorCapture: IF the Keyence microsocpe software is set by the user to acquire channels in 
//		any color other than gray, the software saves the image in the form of RGB. Openning 
//		the RGB image in imageJ opens a stack of three images in Red, Green and Blue channels 
//		respectively. Processing RGB raw images has an extra step in which only one relative 
// 		channel from the three images will be selected for the downstream analysis. Therefore
// 		here, the user is asked to specify whether images are captured in RGB format or not. 
//---------------------------------------------------------------------------------------------
Dialog.create("Dataset Info");
Dialog.addNumber("CycleNum:", 2,0,3, "Number of Cycles");
Dialog.addNumber("MIAcol:", 7,0,3, "Number of Columns in the MIA");
Dialog.addNumber("MIArow:", 8,0,3, "Number of Rows in the MIA");
Dialog.addNumber("Channels:", 3,0,3, "Number of fluorescent channels");
Dialog.addNumber("Zsec:", 15,0,3, "Number of Z slices imaged at each FOV");
Dialog.addCheckbox("Raw Images Are in RGB", false);
Dialog.addCheckbox("Batchmode processing", false);
Dialog.show();
CycleNum = Dialog.getNumber();
MIAcol = Dialog.getNumber();
MIArow = Dialog.getNumber();;
Channels = Dialog.getNumber();
Zsec = Dialog.getNumber();
ColorCapture = Dialog.getCheckbox();
BatchMode = Dialog.getCheckbox();
// Selecting working directory: (Recommended) A folder in the same directory where raw images 
//		are stored.
showMessage("Select Working Directory");
WorkingDIR=getDirectory("Choose a Directory");

// Starting the Process
setBatchMode(BatchMode);
for (c = 1; c <= CycleNum; c++) {									// loop through cycles
	showMessage("Brows the Directory of Cycle"+c);
	CycleDir = getDirectory("Choose a Directory");
    for (mia = 1; mia <= (MIAcol*MIArow); mia++) {					// loop through FOVs
    	for (ch = 1; ch <= Channels; ch++) {						// loop through fluorescent channels
    			for (z = 1; z <= Zsec; z++) {						// loop through z slices
    				openimage(CycleDir,mia,z,ch);
    				if (ColorCapture==true) {
						Color2Gray(ch);
					}
    			}
    			TempName="Cycle"+c+"_FOV"+mia+"_CH"+ch;
    			run("Images to Stack", "name=Z"+TempName+" title=[] use");
    			//---------------------------- Selecting the best focus and saving it in FX
				FZ=BestFocusFinder(WorkingDIR+"log.txt");
				//---------------------------- Saving the channel image with the best focus
				selectWindow("Z"+TempName);
				close();
				openimage(CycleDir,mia,FZ,ch);
				if (ColorCapture==true) {
					Color2Gray(ch);
				}
				TempName="Cycle"+c+"_FOV"+mia+"_CH"+ch;
    			saveAs("Tiff", WorkingDIR+TempName);
    			close();
    			//----------------------------
    	}
    	//---------------------------- Saving a stack image of 4 channels per FOV with the best focus
    	for (i = 1; i <=Channels; i++) {
    	open(WorkingDIR+"Cycle"+c+"_FOV"+mia+"_CH"+i+".tif");
    	}
    	FOVname="Cycle"+c+"_FOV"+mia;
    	run("Images to Stack", "name="+FOVname+" title=[] use");
    	saveAs("Tiff", WorkingDIR+FOVname);
    	close();
    }
}
//---------------------------------------------------------------------------------------------
// Functions:
//
// This function opens the images given their directory, FOV column and row in the MIA, Z slice
//		 number and channel
function openimage(DIR,MIAnum,Znum,CH) {
	ImageName=""+DIR+"1_";
	// MIAnum
	if (MIAnum<10) {
		ImageName=ImageName+"0000"+MIAnum;
	}
	if (MIAnum>9 && MIAnum<100) {
		ImageName=ImageName+"000"+MIAnum;
	}
	if (MIAnum>99) {
		ImageName=ImageName+"00"+MIAnum;
	}
	// Znum
	if (Znum<10) {
		ImageName=ImageName+"_Z00"+Znum;
	}
	if (Znum>9) {
		ImageName=ImageName+"_Z0"+Znum;
	}
	// CH
	ImageName=ImageName+"_CH"+CH+".tif";
	open(ImageName);
}

// This function reads the best focus slice number from the log file and saves it in "x"
function BestFocusFinder(Path) {
	print("\\Clear");
    run("Find focused slices", "select=99.9 variance=0.000 edge select_only verbose");
    close();
    selectWindow("Log");
	saveAs("Text", WorkingDIR+"log.txt");
	print("\\Clear");
	filestring=File.openAsString(Path); 
	rows=split(filestring, "\n"); 
	x=newArray(rows.length); 
	y=rows.length;
	for(i=1; i<rows.length; i++){ 
		columns=split(rows[i],"\t"); 
		x=parseInt(columns[0]);  
	} 
	return x
}

// This function converts the RGB images into Gray scale images
function Color2Gray(Channel) {
	imagename = getTitle();
	rename("Temp");
	if (Channel==1) {
		run("Duplicate...", "title="+imagename+" duplicate channels=3");
		run("Grays");
		selectWindow("Temp");
		close();
	}
	if (Channel==2) {
		run("Duplicate...", "title="+imagename+" duplicate channels=2");
		run("Grays");
		selectWindow("Temp");
		close();
	}
	if (Channel==3) {
		run("Duplicate...", "title="+imagename+" duplicate channels=1");
		run("Grays");
		selectWindow("Temp");
		close();
	}
	if (Channel==4) {
		run("Duplicate...", "title="+imagename+" duplicate channels=2");
		run("Grays");
		selectWindow("Temp");
		close();
	}
}




