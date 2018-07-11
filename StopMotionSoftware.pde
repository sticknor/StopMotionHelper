// import ddf.minim.*;
import processing.video.*;
import java.io.File;

// Change these
String filmName = "filmname"; // NO SPACES, title should show up purple
int cameraSelection = 0;

// STATES
String state;
String CAPTURE = "capture";
String PREVIEW = "preview";
String EDIT = "edit";
boolean onionSkin;

// UI
Capture cam;
Dock dock;

// Will break out into class to be able to load in and crete new films

int filmFrameCount = 0;
int previewFrame = 0;

void setup() {
  size(1062, 800);
  // fullScreen();

  // Initial state
  state = CAPTURE;

  // See if this film already exists
  String [] framesTracked = loadStrings("data/"+filmName+"/"+filmName+".txt");
  // If it does, set the frame counter to the frame recorded
  if (framesTracked != null) { 
    filmFrameCount = int(framesTracked[0]);
  } 
  // Otherwise, start a frame counter and film folder
  else {   
    String[] frame = { "0" };
    saveStrings("data/"+filmName+"/"+filmName+".txt", frame);
  }

  // Initialize a dock
  dock = new Dock();
  
  // Initialize the cameras
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + " " + cameras[i]);
    }
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[cameraSelection]);
    cam.start();
  }
}

void draw() {
  int xShift = (width-1062)/2;
  // Remove any leftover onion skin
  noTint(); 
  if (state == CAPTURE) {
    frameRate(60);
    if (cam.available() == true) { 
      cam.read();
    }
    image(cam, (width-1062)/2, 0, 1062, 600);
    if (onionSkin && filenames.length > 0) {
      PImage skin = loadImage("data/"+filmName+"/frames/"+filenames[filenames.length-1]);
      tint(150, 255, 0, 100);
      image(skin, xShift, 0, 1062, 600);
    }
    fill(255);
    textSize(20);
    text("CAPTURE", xShift+40, 40);
    text("'O' to toggle onion skin", xShift+40, 80);
    text("'ENTER' to preview movie", xShift+40, 120);
    text("'E' to edit frames", xShift+40, 160);
    text("'SPACE' to take picture", xShift+40, 200);
  } else if (state == EDIT) {
    frameRate(60);
    if (filenames.length > 0) {
      PImage frame = loadImage("data/"+filmName+"/frames/"+filenames[previewFrame]);
      image(frame, xShift, 0, 1062, 600);
    }
    fill(255);
    textSize(20);
    text("EDIT", xShift+40, 40);
    text("'E' to exit edit mode", xShift+40, 80);
    text("'Left/Right Arrow Keys' to go through frames", xShift+40, 120);
    text("'DELETE' removes selected frame", xShift+40, 160);
  } else if (state == PREVIEW) {
    frameRate(30);
    if (filenames.length <= previewFrame) {
      togglePreview();
    } else {
      PImage frame = loadImage("data/"+filmName+"/frames/"+filenames[previewFrame]);
      image(frame, xShift, 0, 1062, 600);
      previewFrame++;
      fill(255);
      textSize(20);
      text("PREVIEW", xShift+40, 40);
      text("'ENTER' to exit preview", xShift+40, 80);
    }
  }
}

void takeFrame() {
  cam.save("data/"+filmName+"/frames/"+filmName+nf(filmFrameCount, 10) +".jpg");
  filmFrameCount++;
  String[] frame = { str(filmFrameCount) };
  saveStrings("data/"+filmName+"/"+filmName+".txt", frame);
  dock.framesUpdated();
}

void deleteFrame(int frame) {
  File frameToDelete = new File(dataPath(filmName+"/frames/"+filenames[frame]));
  if (frameToDelete.exists()) { frameToDelete.delete(); }
  if (frame == filenames.length-1) {
    if (filenames.length < framesInDock) {
      indexSelected--;
    }
    previewFrame--;
  }
  dock.framesUpdated();
  if (filenames.length == 0) {
    toggleEdit();
  }
} 

void keyPressed() {
  print(keyCode);
  if (state == CAPTURE && keyCode == 32) {              // SPACE
    takeFrame();
  } else if (filenames.length > 0 && keyCode == 69) {       // E
    toggleEdit();
  } else if (keyCode == ENTER) {    // ENTER
    togglePreview();
  } else if (keyCode == 79) {       // O
    toggleOnionSkin();
  }
  // Editing buttons
  if (state == EDIT) {      
    if (keyCode == 8) {             // DELETE
      deleteFrame(previewFrame);
    } else if (keyCode == LEFT) {   // LEFT ARROW;else if (keyCode == LEFT) {   // LEFT ARROW
      dock.scrollLeft();
    } else if (keyCode == RIGHT) {  // RIGHT ARROW
      dock.scrollRight();
    }
  }
}

void togglePreview() {
  previewFrame = 0;
  if (state == PREVIEW) {
    state = CAPTURE;
  } else {
    state = PREVIEW;
  }
}

void toggleOnionSkin() {
  if (state == CAPTURE) {
    onionSkin = !onionSkin;
  }
}

void toggleEdit() {
  if (state == EDIT) {
    state = CAPTURE;
    dock.editMode();
  } else {
    if (state == CAPTURE);
    state = EDIT;
    dock.editMode();
  }
  dock.drawDock();
}