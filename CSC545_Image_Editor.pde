PImage img;           // Original image
PImage editedImg;     // Image being edited
PImage originalImg;   // Backup of the original image
boolean cropping = false;
PGraphics drawingLayer;
boolean isDrawing = false;
float prevX, prevY;
int cropX, cropY, cropW, cropH;
float scaleFactor = 1.0; // Initial scale factor
final float minScaleFactor = 0.1;
final float maxScaleFactor = 5.0;
String filename = "test.jpg";
color currentStrokeColor = color(0); // Default to black
int currentStrokeWeight = 2; 
boolean showHists = false;
//Define arrays for red, green, and blue counts
int[] rCounts = new int[256];  //bins for red histogram
int[] gCounts = new int[256];  //bins for green histogram
int[] bCounts = new int[256];  //bins for blue histogram
int posR = 10, posG = 275, posB = 541; //Left edges of the color histograms in the canvas

void setup() {
  size(800, 600);
  img = loadImage(filename); // Replace with your image file
  if (img == null) {
    println("Error: Image 'test.jpg' not found.");
    exit();
  }
  scaleFactor = max((float)width / img.width, (float)height / img.height);
  editedImg = img.copy();
  originalImg = img.copy(); // Backup of the original image
  imageMode(CORNER);
  drawingLayer = createGraphics(width, height);
  drawingLayer.beginDraw();
  drawingLayer.clear(); // Ensure the drawing layer is transparent
  drawingLayer.endDraw();
  println("Controls:");
  println("1: Start Crop");
  println("2: Reset Scale");
  println("3: Rotate 90° Clockwise");
  println("4: Flip Horizontally");
  println("5: Flip Vertically");
  println("6: Scale Up");
  println("7: Scale Down");
  println("8: Draw Mode");
  println("9: Clear Drawing");
  println("r: Red");
  println("b: Blue");
  println("g: Green");
  println("l: Black");
  println("+: Increase Stroke Weight");
  println("-: Decrease Stroke Weight");
  println("d: Revert to Original Image");
  println("s: Save Edited Image");
  println("w: Change the Image to Grayscale");
  println("h: Stretches images Histogram");
  println("e: Equalizes images Histogram");
  println("f: Display Histogram");
}

void draw() {
  background(255);
  
  float newWidth = editedImg.width * scaleFactor;
  float newHeight = editedImg.height * scaleFactor;

  float offsetX = (width - newWidth) / 2;
  float offsetY = (height - newHeight) / 2;

  imageMode(CORNER);
  image(editedImg, offsetX, offsetY, newWidth, newHeight);
  image(drawingLayer, 0, 0); // Overlay the drawing layer
  
  if (isDrawing && mousePressed) {
    drawingLayer.beginDraw();
    drawingLayer.stroke(currentStrokeColor); // Set drawing color
    drawingLayer.strokeWeight(currentStrokeWeight); // Set stroke weight
    drawingLayer.line(prevX, prevY, mouseX, mouseY); // Draw line
    drawingLayer.endDraw();
  }
  
  prevX = mouseX;
  prevY = mouseY;

  if (cropping) {
    noFill();
    stroke(255, 0, 0);
    rect(cropX, cropY, mouseX - cropX, mouseY - cropY);
  }
  if (showHists) {
    background(0);
    Hist_draw(img);
  }
}

void keyPressed() {
  if (key == '1') {
    // Start cropping
    cropping = true;
    cropX = mouseX;
    cropY = mouseY;
  } else if (key == '2') {
    // Reset scale
     
    scaleFactor = 1.0;
    windowResize(editedImg.width, editedImg.height);
  } else if (key == '3') {
    // Rotate 90° Clockwise
     
    editedImg = rotateImage(editedImg, 90);
    windowResize(editedImg.width, editedImg.height);
  } else if (key == '4') {
    // Flip Horizontally
     
    editedImg = flipImage(editedImg, true);
    windowResize(editedImg.width, editedImg.height);
  } else if (key == '5') {
    // Flip Vertically
     
    editedImg = flipImage(editedImg, false);
    windowResize(editedImg.width, editedImg.height);
  } else if (key == '6') {
    // Scale Up
     
    scaleFactor = min(scaleFactor * 1.1, maxScaleFactor);
  } else if (key == '7') {
    // Scale Down
     
    scaleFactor = max(scaleFactor * 0.9, minScaleFactor);
  } else if (key == '8') {
     
    isDrawing = !isDrawing; // Toggle drawing mode
  } else if (key == '9') {
     
    drawingLayer.beginDraw();
    drawingLayer.clear(); // Clear the drawing layer
    drawingLayer.endDraw();
  } else if (key == 'd' || key == 'D') {
    // Revert to Original Image
     showHists = false;
    editedImg = originalImg.copy();
    scaleFactor = 1.0;
    windowResize(editedImg.width, editedImg.height);
  }else if (key == 'r' || key == 'R') {
     
    currentStrokeColor = color(255, 0, 0); // Red
  } else if (key == 'g' || key == 'G') {
     
    currentStrokeColor = color(0, 255, 0); // Green
  } else if (key == 'b' || key == 'B') {
     
    currentStrokeColor = color(0, 0, 255); // Blue
  } else if (key == '+') {
     
    currentStrokeWeight += 2 ; // Red
  } else if (key == '-')  {
      if (currentStrokeWeight >= 3) {
        currentStrokeWeight -= 2; // Green
      }
  } else if (key == 'l' || key == 'L') {
    currentStrokeColor = color(0); // Black
  } else if (key == 's' || key == 'S') {
    // Create a new graphics context to combine the edited image and the drawing layer
    PGraphics combined = createGraphics(editedImg.width, editedImg.height);
    combined.beginDraw();
    combined.image(editedImg, 0, 0);
    combined.image(drawingLayer, 0, 0);
    combined.endDraw();
    
    // Save the combined image
    combined.save("edited_image.jpg");
    println("Image saved as edited_image.jpg");
  } else if (key == 'w' || key == 'W') {
    editedImg = convertToGrayscale(editedImg);
  }  if (key == 'h' || key == 'H') {
    editedImg = histStretch(img);
    windowResize(editedImg.width, editedImg.height);
  } else if (key == 'E' || key == 'e') {
      editedImg = histEqual(img);
  } else if (key == 'f' || key == 'F') {
    showHists = true;
    background(0);
    Hist_draw(img);
  } 
}

void mouseReleased() {
  if (cropping) {
    cropW = mouseX - cropX;
    cropH = mouseY - cropY;
    // Ensure width and height are positive
    if (cropW < 0) {
      cropX += cropW;
      cropW = -cropW;
    }
    if (cropH < 0) {
      cropY += cropH;
      cropH = -cropH;
    }
    editedImg = editedImg.get(cropX, cropY, cropW, cropH);
    cropping = false;
  }
}

PImage rotateImage(PImage img, float angleDegrees) {
  PGraphics pg = createGraphics(img.height, img.width);
  pg.beginDraw();
  pg.translate(pg.width / 2, pg.height / 2);
  pg.rotate(radians(angleDegrees));
  pg.imageMode(CENTER);
  pg.image(img, 0, 0);
  pg.endDraw();
  return pg.get();
}

PImage flipImage(PImage img, boolean horizontal) {
  PImage flipped = createImage(img.width, img.height, ARGB);
  img.loadPixels();
  flipped.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int srcIndex = x + y * img.width;
      int dstX = horizontal ? img.width - 1 - x : x;
      int dstY = horizontal ? y : img.height - 1 - y;
      int dstIndex = dstX + dstY * img.width;
      flipped.pixels[dstIndex] = img.pixels[srcIndex];
    }
  }
  flipped.updatePixels();
  return flipped;
}

PImage convertToGrayscale(PImage img) {
  PImage newImg = createImage(img.width, img.height, ARGB);
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color p = img.get(x, y);
      
      float r = red(p), g = green(p), b = blue(p);
      float val = 0.299 * r + 0.587 * g + 0.114 * b;
      
      newImg.set(x, y, color(val, val, val));
    }
  }
  
  return newImg;
}

PImage convertToColor(PImage img) {
  PImage colorImg = createImage(img.width, img.height, ARGB);
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      
      color originalColor = originalImg.get(x, y);
      color currentColor = img.get(x,y);
      
      
      
      colorImg.set(x, y, originalColor);
    }
  }
  
  return colorImg;
}

void calcHists(PImage src){
 //this is code taught in class
  for(int i =0; i<rCounts.length; i++){
    rCounts[i] = 0;
    gCounts[i] = 0;
    bCounts[i] = 0;
  }
  
  for(int y=0; y<src.height; y++){
      for(int x=0; x<src.width; x++){
        color c = src.get(x,y);
        int r = int(red(c)), g = int(green(c)), b = int(blue(c));
        rCounts[r]+=1;
        gCounts[g]+=1;
        bCounts[b]+=1;
      }
    }
}

PImage histStretch(PImage src) {
  calcHists(src);
  PImage target = createImage(src.width, src.height, ARGB);
  target.loadPixels();

  float rmin = 0, gmin = 0, bmin = 0, rmax = 0, gmax = 0, bmax = 0;
  float rscale = 1, gscale = 1, bscale = 1;

  // Find min values
  for (int i = 0; i < 256; i++) {
    if (rCounts[i] > 0) {
      rmin = i;
      break;
    }
  }
  for (int i = 0; i < 256; i++) {
    if (gCounts[i] > 0) {
      gmin = i;
      break;
    }
  }
  for (int i = 0; i < 256; i++) {
    if (bCounts[i] > 0) {
      bmin = i;
      break;
    }
  }

  // Find max values
  for (int i = 255; i >= 0; i--) {
    if (rCounts[i] > 0) {
      rmax = i;
      break;
    }
  }
  for (int i = 255; i >= 0; i--) {
    if (gCounts[i] > 0) {
      gmax = i;
      break;
    }
  }
  for (int i = 255; i >= 0; i--) {
    if (bCounts[i] > 0) {
      bmax = i;
      break;
    }
  }

  // Compute scales
  if (rmax > rmin) rscale = 255.0 / (rmax - rmin);
  if (gmax > gmin) gscale = 255.0 / (gmax - gmin);
  if (bmax > bmin) bscale = 255.0 / (bmax - bmin);

  // Apply stretching
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      color c = src.get(x, y);
      int r = constrain((int)((red(c) - rmin) * rscale), 0, 255);
      int g = constrain((int)((green(c) - gmin) * gscale), 0, 255);
      int b = constrain((int)((blue(c) - bmin) * bscale), 0, 255);
      int a = int(alpha(c));
      target.pixels[y * src.width + x] = color(r, g, b, a);
    }
  }

  target.updatePixels();
  return target;
}

PImage histEqual(PImage src) {
  calcHists(src); // calculates the histogram of source
  PImage target = createImage(src.width, src.height, RGB);
  target.loadPixels();
  //arrays to hold cumulative values 
  int[] rCumul = new int[256];
  int[] gCumul = new int[256];
  int[] bCumul = new int[256];
  
  //initialize to start off with correct value
  rCumul[0] = rCounts[0];
  gCumul[0] = gCounts[0];
  bCumul[0] = bCounts[0];
  //add running cumulative totals into our cumul arrays.
  for (int i = 1; i < 256; i++) {
    rCumul[i] = rCumul[i - 1] + rCounts[i];
    gCumul[i] = gCumul[i - 1] + gCounts[i];
    bCumul[i] = bCumul[i - 1] + bCounts[i];
  }
  //total pixels in provided image
  int pixls = src.width * src.height;
  
  //arrays to hold appropriate color value densities
  int[] rDens = new int[256];
  int[] gDens = new int[256];
  int[] bDens = new int[256];
  
  // manipulating value densities with color scale and image size
  for (int i = 0; i < 256; i++) {
    rDens[i] = (rCumul[i] * 255) / pixls;
    gDens[i] = (gCumul[i] * 255) / pixls;
    bDens[i] = (bCumul[i] * 255) / pixls;
  }
 // replacing color values with appropriate colors after manipulating the Dens[]'s
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      color c = src.get(x, y);
      
      int r1 = rDens[(int)red(c)];
      int g1 = gDens[(int)green(c)];
      int b1 = bDens[(int)blue(c)];
      
      r1 = constrain(r1, 0, 255);
      g1 = constrain(g1, 0, 255);
      b1 = constrain(b1, 0, 255);
     
       target.pixels[y* src.width + x] = color(r1,g1,b1);
    }
  }
  target.updatePixels();
  return target;
}

//calculates the histogram
void Hist_calc(PImage im){
   // hist initialization
  for (int i = 0; i < 256; i++) {
    rCounts[i] = 0;
    gCounts[i] = 0;
    bCounts[i] = 0;
  }
    // get histogram for every channel
  for (int i = 0; i < im.pixels.length; i++) {
    color c = im.pixels[i];
    rCounts[int(red(c))]++;
    gCounts[int(green(c))]++;
    bCounts[int(blue(c))]++;
  }
}
//draws the histogram
void Hist_draw (PImage img5) {
  if (img5 == null) img5 = img;

  Hist_calc(img5);  
  
  Hist_draw(rCounts, color(255, 0, 0), posR); // red histogram
  
  Hist_draw(gCounts, color(0, 255, 0), posG); // green histogram
  
  Hist_draw(bCounts, color(0, 0, 255), posB); // blue hisotgarm
}

void Hist_draw(int[] counts, color color1, int x_pos) {
  stroke(color1);
  for (int i = 0; i < 256; i++) {
    // scaling
    line(x_pos + i, height, x_pos + i, height - counts[i] / 100);
  }
}
  
