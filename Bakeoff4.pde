import java.util.ArrayList;
import java.util.Collections;


// Booleans to turn features on and off with true and false

//Professor Harrison's original features:
boolean originalDirectionButtons = false;

//Our Own New Features
boolean followingMouse = false;
boolean blueSelectionBorder = false;
boolean blueResizingSquares = false;
boolean centerConnection = false;

//New Features - Iteration 2
boolean scrollWheelControl = true;
boolean resetSquareAfterSubmission = true;

int trialCount = 10; //this will be set higher for the bakeoff
final float screenPPI = 126;//what is the Pixels Per Inch of the screen you are using

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float windowPadding = 0; //some padding from the sides of window, set later
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500; //global variable for the X position of the logo
float logoY = 500; //global variable for the Y position of the logo
float logoS = 50f; //global variable for the Size position of the logo
float logoR = 0; //global variable for the Rotation position of the logo

//Variables for new features
float originalLogoX = 500;
float originalLogoY = 500;
float originalLogoS = 50f;
float originalLogoR = 0;

// Scroll wheel positions and dimensions
float scrollWheelStartY = 20;
float scrollWheelSpacing = 50;
float scrollWheelWidth = 300;
float scrollWheelHeight = 35;
float scrollWheelX = 20;

// Submit button dimensions
float submitButtonWidth = 150;
float submitButtonHeight = 40;
float submitButtonX = scrollWheelX + scrollWheelWidth + 30;
float submitButtonY = scrollWheelStartY + (scrollWheelSpacing * 1.5f);

// Min and max values for each axis
float minX, maxX, minY, maxY;
float minZ = inchToPix(0.25f);
float maxZ = inchToPix(4f);
float minR = 0;
float maxR = 360;

PFont smallFont;
PFont largeFont;
PFont mediumFont;

private class Destination
{
  float x = 0; //the X position of this destination square
  float y = 0; //the Y position of this destination square
  float s = 0; //the Size position of this destination square
  float r = 0;//the Rotation position of this destination square
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1200, 800);
  rectMode(CENTER);
  largeFont = createFont("Arial", inchToPix(.3f)); //sets the font to Arial that is 0.3" tall
  mediumFont = createFont("Arial", inchToPix(.15f)); //sets the font to Arial that is 0.15" tall
  smallFont = createFont("Arial", inchToPix(.1f)); //sets the font to Arial that is 0.1" tall

  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards

  //Don't change this!
  windowPadding = inchToPix(2f); //stops destination squares generating with centers/corners outside this area

  // Set min and max for X and Y based on window padding
  minX = windowPadding;
  maxX = width - windowPadding;
  minY = windowPadding;
  maxY = height - windowPadding;

  //create a bunch of random destination squares. Don't change this!
  for (int i=0; i<trialCount; i++)
  {
    Destination d = new Destination();
    d.x = random(windowPadding, width-windowPadding); //set a random x with some padding
    d.y = random(windowPadding, height-windowPadding); //set a random y with some padding
    d.r = random(0, 360); //random rotation between 0 and 360
    d.s = inchToPix((float)random(1, 12)/4.0f); //increasing size from 0.25" up to 3.0"
    destinations.add(d);
    println("created destination with values: " + d.x + "," + d.y + "," + d.r + "," + d.s);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}

void draw() {
  background(40); //background is dark grey. Can't change this.
  noStroke();

  //next two lines are just for testing if your PPI is set correctly. It should be 1x1" on your screen if correct. This can be removed for the Bakeoff.
  fill(200, 200, 200);
  rect(width/2, height/2, inchToPix(1f), inchToPix(1f));

  fill(200);
  textFont(largeFont);
  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.r)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.s, d.s);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoR)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoS, logoS);
  fill(255);
  textFont(smallFont);
  text("LOGO", 0, 0);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  textFont(largeFont);
  scaffoldControlLogic(); //you are going to want to replace this!

  fill(255);
  textFont(largeFont);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, height - inchToPix(.5f));
}

// Helper function to draw a progress bar style slider
void drawSlider(String label, float currentValue, float targetValue, float minValue, float maxValue, float yPos) {
  rectMode(CORNER);
  textAlign(LEFT);

  // Calculate fill percentage for current value
  float currentPercent = (currentValue - minValue) / (maxValue - minValue);
  float targetPercent = (targetValue - minValue) / (maxValue - minValue);

  // Draw background (empty part)
  fill(60, 60, 60);
  noStroke();
  rect(scrollWheelX, yPos, scrollWheelWidth, scrollWheelHeight, 5);

  // Draw filled part (blue progress bar)
  fill(80, 120, 200);
  rect(scrollWheelX, yPos, scrollWheelWidth * currentPercent, scrollWheelHeight, 5);

  // Draw target indicator (red line)
  stroke(255, 0, 0);
  strokeWeight(3);
  float targetX = scrollWheelX + scrollWheelWidth * targetPercent;
  line(targetX, yPos, targetX, yPos + scrollWheelHeight);

  // Draw label and current value
  fill(255);
  noStroke();
  textFont(smallFont);
  text(label + ": " + nf(currentValue, 0, 1), scrollWheelX + 5, yPos + 23);

  // Check if current value is close enough to target
  boolean isClose = false;
  if (label.equals("X") || label.equals("Y")) {
    isClose = abs(currentValue - targetValue) < inchToPix(.03f);
  } else if (label.equals("Z")) {
    isClose = abs(currentValue - targetValue) < inchToPix(.06f);
  } else if (label.equals("R")) {
    isClose = calculateDifferenceBetweenAngles(currentValue, targetValue) <= 3;
  }

  // Draw target value on the right - green if close, red if not
  if (isClose) {
    fill(0, 255, 0);
  } else {
    fill(255, 0, 0);
  }
  textAlign(RIGHT);
  text("Target: " + nf(targetValue, 0, 1), scrollWheelX + scrollWheelWidth - 5, yPos + 23);

  rectMode(CENTER);
  textAlign(CENTER);
}

// Helper function to check if we're close enough to submit
boolean isReadyToSubmit() {
  Destination d = destinations.get(trialIndex);
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f);
  boolean closeRotation = calculateDifferenceBetweenAngles(d.r, logoR)<=5;
  boolean closeSize = abs(d.s - logoS)<inchToPix(.1f);
  return closeDist && closeRotation && closeSize;
}

//my example design for control, which is a terrible design
void scaffoldControlLogic()
{
  Destination d = destinations.get(trialIndex);

  if (blueSelectionBorder) {
    stroke(77, 119, 255);
    strokeWeight(3);
    line(logoX-logoS/2, logoY-logoS/2, logoX+logoS/2, logoY-logoS/2);
    line(logoX-logoS/2, logoY-logoS/2, logoX-logoS/2, logoY+logoS/2);
    line(logoX+logoS/2, logoY+logoS/2, logoX-logoS/2, logoY+logoS/2);
    line(logoX+logoS/2, logoY+logoS/2, logoX+logoS/2, logoY-logoS/2);
  }

  if (blueSelectionBorder == false && blueResizingSquares) {
    fill(77, 119, 255);
    float topRightX = logoX+logoS/2+1;
    float topRightY = logoY-logoS/2+1;
    rect(logoX+logoS/2, logoY-logoS/2, 8, 8);
    rect(logoX-logoS/2, logoY-logoS/2, 8, 8);
    rect(logoX+logoS/2, logoY+logoS/2, 8, 9);
    rect(logoX-logoS/2, logoY+logoS/2, 8, 8);

    if (mousePressed && dist(mouseX, mouseY, logoX+logoS/2+1, logoY-logoS/2+1) < 30) {
      float centerX = logoX;
      float centerY = logoY;

      float newSize = dist(mouseX, mouseY, centerX, centerY) * sqrt(2);

      logoS = newSize;
    }
  }

  if (followingMouse && blueSelectionBorder == true) {
    logoX = mouseX;
    logoY = mouseY;
  }

  if (centerConnection) {
    stroke(100);
    line(logoX, logoY, d.x, d.y);
  }

  if (originalDirectionButtons) {
    //upper left corner, rotate counterclockwise
    text("CCW", inchToPix(.4f), inchToPix(.4f));
    if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
      logoR--;

    //upper right corner, rotate clockwise
    text("CW", width-inchToPix(.4f), inchToPix(.4f));
    if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
      logoR++;

    //lower left corner, decrease Z
    text("-", inchToPix(.4f), height-inchToPix(.4f));
    if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
      logoS = constrain(logoS-inchToPix(.02f), inchToPix(0.25f), inchToPix(4f)); //leave min and max alone!

    //lower right corner, increase Z
    text("+", width-inchToPix(.4f), height-inchToPix(.4f));
    if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
      logoS = constrain(logoS+inchToPix(.02f), inchToPix(0.25f), inchToPix(4f)); //leave min and max alone!

    //left middle, move left
    text("left", inchToPix(.4f), height/2);
    if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
      logoX-=inchToPix(.02f);

    text("right", width-inchToPix(.4f), height/2);
    if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
      logoX+=inchToPix(.02f);

    text("up", width/2, inchToPix(.4f));
    if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
      logoY-=inchToPix(.02f);

    text("down", width/2, height-inchToPix(.4f));
    if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
      logoY+=inchToPix(.02f);
  }

  // Draw scroll wheels as progress bars
  if (scrollWheelControl) {
    float xScrollY = scrollWheelStartY;
    float yScrollY = scrollWheelStartY + scrollWheelSpacing;
    float zScrollY = scrollWheelStartY + scrollWheelSpacing * 2;
    float rScrollY = scrollWheelStartY + scrollWheelSpacing * 3;

    drawSlider("X", logoX, d.x, minX, maxX, xScrollY);
    drawSlider("Y", logoY, d.y, minY, maxY, yScrollY);
    drawSlider("Z", logoS, d.s, minZ, maxZ, zScrollY);
    drawSlider("R", logoR, d.r, minR, maxR, rScrollY);

    // Draw submit button - green if ready, red if not
    rectMode(CORNER);
    boolean ready = isReadyToSubmit();
    boolean hovering = mouseX >= submitButtonX && mouseX <= submitButtonX + submitButtonWidth &&
      mouseY >= submitButtonY && mouseY <= submitButtonY + submitButtonHeight;

    if (ready) {
      if (hovering) {
        fill(0, 255, 0, 220);
      } else {
        fill(0, 200, 0, 200);
      }
    } else {
      if (hovering) {
        fill(255, 0, 0, 220);
      } else {
        fill(200, 0, 0, 200);
      }
    }

    noStroke();
    rect(submitButtonX, submitButtonY, submitButtonWidth, submitButtonHeight, 8);

    fill(255);
    textAlign(CENTER);
    textFont(mediumFont);
    text("SUBMIT", submitButtonX + submitButtonWidth/2, submitButtonY + submitButtonHeight/2 + 8);

    rectMode(CENTER);
  }
}

void mousePressed()
{
  Destination d = destinations.get(trialIndex);
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }

  // Check if clicking on scroll wheels - click to set value directly
  if (scrollWheelControl) {
    float xScrollY = scrollWheelStartY;
    float yScrollY = scrollWheelStartY + scrollWheelSpacing;
    float zScrollY = scrollWheelStartY + scrollWheelSpacing * 2;
    float rScrollY = scrollWheelStartY + scrollWheelSpacing * 3;

    if (mouseX >= scrollWheelX && mouseX <= scrollWheelX + scrollWheelWidth) {
      float clickPercent = (mouseX - scrollWheelX) / scrollWheelWidth;

      if (mouseY >= xScrollY && mouseY <= xScrollY + scrollWheelHeight) {
        logoX = minX + (maxX - minX) * clickPercent;
      } else if (mouseY >= yScrollY && mouseY <= yScrollY + scrollWheelHeight) {
        logoY = minY + (maxY - minY) * clickPercent;
      } else if (mouseY >= zScrollY && mouseY <= zScrollY + scrollWheelHeight) {
        logoS = constrain(minZ + (maxZ - minZ) * clickPercent, minZ, maxZ);
      } else if (mouseY >= rScrollY && mouseY <= rScrollY + scrollWheelHeight) {
        logoR = minR + (maxR - minR) * clickPercent;
      }
    }
  }

  if (blueSelectionBorder == true) {
    if (d.x-d.s/2+4 < mouseX && mouseX < d.x+d.s/2-4
      && d.y-d.s/2 < mouseY && mouseY < d.y+d.s/2) // we are clicking in bounds of destination sq
    {
      blueSelectionBorder = false;
    }
  } else {
    if (logoX-logoS/2+3 < mouseX && mouseX < logoX+logoS/2-3
      && logoY-logoS/2+3 < mouseY && mouseY < logoY+logoS/2-3) {
      blueSelectionBorder = true;
    }
  }
}

void mouseReleased()
{
  // Check if user clicked the submit button
  if (scrollWheelControl && mouseX >= submitButtonX && mouseX <= submitButtonX + submitButtonWidth &&
    mouseY >= submitButtonY && mouseY <= submitButtonY + submitButtonHeight)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (resetSquareAfterSubmission) {
      logoX = originalLogoX;
      logoY = originalLogoY;
      logoS = originalLogoS;
      logoR = originalLogoR;
    }

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }

  // Also check for original submit button (center of screen)
  if (!scrollWheelControl && dist(width/2, height/2, mouseX, mouseY)<inchToPix(1f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (resetSquareAfterSubmission) {
      logoX = originalLogoX;
      logoY = originalLogoY;
      logoS = originalLogoS;
      logoR = originalLogoR;
    }

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.r, logoR)<=5;
  boolean closeSize = abs(d.s - logoS)<inchToPix(.1f); //has to be within +-0.1"

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.r, logoR)+")");
  println("Close Enough Size: " +  closeSize + " (logo Z = " + d.s + ", destination Z = " + logoS +")");
  println("Close enough all: " + (closeDist && closeRotation && closeSize));

  return closeDist && closeRotation && closeSize;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
