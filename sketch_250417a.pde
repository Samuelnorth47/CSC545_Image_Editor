PImage img;           // Original image
PImage editedImg;     // Image being edited
PImage originalImg;   // Backup of the original image
boolean cropping = false;
int cropX, cropY, cropW, cropH;
float scaleFactor = 1.0; // Initial scale factor
final float minScaleFactor = 0.1;
final float maxScaleFactor = 5.0;

void setup() {
  size(800, 600);
  img = loadImage("test.jpg"); // Replace with your image file
  scaleFactor = max((float)width / img.width, (float)height / img.height);
  editedImg = img.copy();
  originalImg = img.copy(); // Backup of the original image
  imageMode(CORNER);
  println("Controls:");
  println("1: Start Crop");
  println("2: Reset Scale");
  println("3: Rotate 90° Clockwise");
  println("4: Flip Horizontally");
  println("5: Flip Vertically");
  println("6: Scale Up");
  println("7: Scale Down");
  println("r: Revert to Original Image");
  println("s: Save Edited Image");
}


void draw() {
  background(255);
  
  float newWidth = editedImg.width * scaleFactor;
  float newHeight = editedImg.height * scaleFactor;

  float offsetX = (width - newWidth) / 2;
  float offsetY = (height - newHeight) / 2;

  imageMode(CORNER);
  image(editedImg, offsetX, offsetY, newWidth, newHeight);

  if (cropping) {
    noFill();
    stroke(255, 0, 0);
    rect(cropX, cropY, mouseX - cropX, mouseY - cropY);
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
  } else if (key == '3') {
    // Rotate 90° Clockwise
    editedImg = rotateImage(editedImg, 90);
  } else if (key == '4') {
    // Flip Horizontally
    editedImg = flipImage(editedImg, true);
  } else if (key == '5') {
    // Flip Vertically
    editedImg = flipImage(editedImg, false);
  } else if (key == '6') {
    // Scale Up
    scaleFactor = min(scaleFactor * 1.1, maxScaleFactor);
  } else if (key == '7') {
    // Scale Down
    scaleFactor = max(scaleFactor * 0.9, minScaleFactor);
  } else if (key == 'r' || key == 'R') {
    // Revert to Original Image
    editedImg = originalImg.copy();
    scaleFactor = 1.0;
  } else if (key == 's' || key == 'S') {
    // Save Edited Image
    editedImg.save("edited_image.jpg");
    println("Image saved as edited_image.jpg");
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
