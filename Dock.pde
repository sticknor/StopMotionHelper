File folder;
String [] filenames = {};
Boolean frameSelected = false;
String [] limitedSet;
int framesInDock = 5;
int indexSelected = framesInDock-1;
boolean editMode = false;

class Dock {
  Dock() {
    print(filmName);
    folder = new java.io.File(sketchPath("data/"+filmName+"/frames/"));
    filenames = folder.list();
    if (filenames == null) return;
    StringList filteredFilenames = new StringList();
    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames[i];
      if (filename.endsWith(".jpg")) {
        filteredFilenames.append(filename);
      }
    }
    filenames = filteredFilenames.array();
    this.selectFramesToDraw();
    this.drawDock();
  }

  void drawDock() {
    int x = 0;
    int y = height - 200;
    int w = width; 
    int h = 200;
    noTint();
    noStroke();
    fill(0);
    rect(x, y, w, h);
    // Draw the frames
    for (int i = 0; i < limitedSet.length; i++) {
      PImage frame = loadImage("data/"+filmName+"/frames/"+limitedSet[i]);
      // In edit mode, if the frame drawn is the one selected for editing
      if (state == EDIT && limitedSet[i] == filenames[previewFrame]) {
        stroke(255, 0, 0);
        strokeWeight(10);
        rect((x+20)+(((w-20)/framesInDock)*i), y+20, (w-40)/framesInDock-20, h-40);
        noStroke();
      }  
      image(frame, (x+20)+(((w-20)/framesInDock)*i), y+20, (w-40)/framesInDock-20, h-40);
    }
  }
  
  void editMode() {
    editMode = state == EDIT;
    previewFrame = filenames.length-1;
    indexSelected = framesInDock-1;
    this.selectFramesToDraw();
  }
  
  void selectFramesToDraw() {
    // Choose which frames to draw, and which one of those will be selected
    if (state == EDIT) {
        if (framesInDock >= filenames.length) {
          limitedSet = filenames;
          if (indexSelected > filenames.length-1) { indexSelected = filenames.length-1; }
        } else {
          if (indexSelected == framesInDock-1) {
            limitedSet = subset(filenames, previewFrame-(framesInDock-1), framesInDock);
          } else if (indexSelected == 0) {
            limitedSet = subset(filenames, previewFrame, framesInDock);
          } else {
            if ((previewFrame - indexSelected + framesInDock) >= filenames.length-2) {
              indexSelected++;
              limitedSet = subset(filenames, previewFrame-indexSelected, framesInDock);
            } else {
              limitedSet = subset(filenames, previewFrame-indexSelected, framesInDock);
            }
          }
        }
     } else {
      if (filenames.length < framesInDock) {
         limitedSet = filenames;
         if (indexSelected > filenames.length-1) { indexSelected = filenames.length-1; }
      } else {
        limitedSet = subset(filenames, filenames.length - framesInDock, framesInDock);
      }
    }
    this.drawDock();
  }
  
  void framesUpdated() {
    filenames = folder.list();
    if (filenames == null) return;
    StringList filteredFilenames = new StringList();
    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames[i];
      if (filename.endsWith(".jpg")) { filteredFilenames.append(filename); }
    }
    filenames = filteredFilenames.array();
    selectFramesToDraw();
  }
  
  void scrollLeft() {
    if (previewFrame > 0 ) { 
      previewFrame--;
      if (indexSelected != 0) {
        indexSelected--;
        this.drawDock();
      } else {
        this.selectFramesToDraw();      
      }
    }
  }
  
  void scrollRight() {
    if (previewFrame < filenames.length - 1 ) { 
      previewFrame++; 
      if (indexSelected < framesInDock - 1) {
        indexSelected++;
        this.drawDock();
      } else {
        this.selectFramesToDraw();
      }
    }
   }
}
