import java.util.ArrayList;
import java.util.Collections;


// Booleans to turn features on and off with true and false

//Professor Harrison's original features:
boolean originalDirectionButtons = true;
boolean originalSubmit = true;


//Our Own New Features
boolean followingMouse = false;
boolean blueSelectionBorder = false;
boolean blueResizingSquares = false;
boolean pointToDestination = false;
boolean greenSuccessVisual = false;
boolean submitWhenCorrect = false;
boolean isDragging = false;
int draggingCorner = -1;

int trialCount = 10; //this will be set higher for the bakeoff
final float screenPPI = 126; //what is the Pixels Per Inch of the screen you are using 

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

PFont smallFont;
PFont largeFont;

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
  smallFont = createFont("Arial", inchToPix(.1f)); //sets the font to Arial that is 0.3" tall
  
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //Don't change this! 
  windowPadding = inchToPix(2f); //stops destination squares generating with centers/corners outside this area

  //create a bunch of random destination squares. Don't change this!
  for (int i=0; i<trialCount; i++) 
  {
    Destination d = new Destination();
    d.x = random(windowPadding, width-windowPadding); //set a random x with some padding
    d.y = random(windowPadding, height-windowPadding); //set a random y with some padding
    d.r = random(0, 360); //random rotation between 0 and 360
    d.s = inchToPix((float)random(1,12)/4.0f); //increasing size from 0.25" up to 3.0" 
    destinations.add(d);
    println("created destination with values: " + d.x + "," + d.y + "," + d.r + "," + d.s);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}

void draw() {
  background(40); //background is dark grey. Can't change this.
  noStroke();
  
  //next two lines are just for testing if your PPI is set correctly. It should be 1x1" on your screen if correct. This can be removed for the Bakeoff.
  fill(200,200,200);
  rect(width/2,height/2, inchToPix(1f), inchToPix(1f)); 
  
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
  for (int i=trialIndex; i<trialCount && i<destinations.size(); i++) // reduces over time
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
  if (greenSuccessVisual) {
    if (checkForSuccess()) {
      fill(0, 153, 0, 192);
    } else {
      fill(60, 60, 192, 192);
    }
  } else {
    fill(60, 60, 192, 192);
  }
  rect(0, 0, logoS, logoS);
  fill(255);
  textFont(smallFont);
  text("LOGO",0,0);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  textFont(largeFont);
  scaffoldControlLogic(); //you are going to want to replace this!
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//my example design for control, which is a terrible design
void scaffoldControlLogic()
{
  if (trialIndex >= destinations.size()) return;
  Destination d = destinations.get(trialIndex);
  
  float angleRad = radians(logoR); // angle in radians
  float halfSize = logoS/2; 
  float trX = logoX + halfSize * cos(angleRad - PI/4) * sqrt(2); // x coord of top right corner
  float trY = logoY + halfSize * sin(angleRad - PI/4) * sqrt(2);
  float tlX = logoX + halfSize * cos(angleRad - 3*PI/4) * sqrt(2);
  float tlY = logoY + halfSize * sin(angleRad - 3*PI/4) * sqrt(2);
  float brX = logoX + halfSize * cos(angleRad + PI/4) * sqrt(2);
  float brY = logoY + halfSize * sin(angleRad + PI/4) * sqrt(2);
  float blX = logoX + halfSize * cos(angleRad + 3*PI/4) * sqrt(2);
  float blY = logoY + halfSize * sin(angleRad + 3*PI/4) * sqrt(2);
  
  if (blueSelectionBorder) {
    stroke(77, 119, 255);
    strokeWeight(3);
    line(tlX, tlY, trX, trY);
    line(tlX, tlY, blX, blY);
    line(brX, brY, trX, trY);
    line(brX, brY, blX, blY);
    //line(logoX-logoS/2, logoY-logoS/2, logoX-logoS/2, logoY+logoS/2);
    //line(logoX+logoS/2, logoY+logoS/2, logoX-logoS/2, logoY+logoS/2);
    //line(logoX+logoS/2, logoY+logoS/2, logoX+logoS/2, logoY-logoS/2);
  }
  
  if (blueSelectionBorder == false && blueResizingSquares) {
    
    fill(77, 119, 255);
    rect(trX, trY, 8, 8);
    rect(tlX, tlY, 8, 8);
    rect(brX, brY, 8, 8);
    rect(blX, blY, 8, 8);
  }
  
  if (followingMouse && blueSelectionBorder == true) {
    logoX = mouseX;
    logoY = mouseY;
  }
  
  //if (pointToDestination) { // not working
  //  stroke(255, 0, 0);
  //  int signX = 1;
  //  int signY = 1;
  //  if (d.x-logoX > 0) {
  //    signX = 1;
  //  } else {
  //    signX = -1;
  //  }
  //  if (d.y-logoY > 0) {
  //    signY = 1;
  //  } else {
  //    signY = -1;
  //  }
  //  line(logoX, logoY, d.x - signX*20, d.y - signY*20);
  //}
  
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
  if (submitWhenCorrect) {
    if (checkForSuccess() && mousePressed == false) {
      if (userDone==false && !checkForSuccess())
        errorCount++;
  
      trialIndex++; //and move on to next trial
  
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
    }
  }
}
 
void mouseDragged() 
  {
  if (trialIndex >= destinations.size()) return;
  if (blueResizingSquares && isDragging && draggingCorner >= 0) {
    float centerX = logoX;
    float centerY = logoY;
    float newSize = dist(mouseX, mouseY, centerX, centerY) * sqrt(2);
    logoS = newSize;
    
    double dx = mouseX - logoX;
    double dy = mouseY - logoY;
    float mouseAngle = (float) Math.toDegrees(Math.atan2(dy, dx));
    logoR = mouseAngle + 45;
  }
}

void mousePressed()
{
  if (trialIndex >= destinations.size()) return;
  Destination d = destinations.get(trialIndex);
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  if (blueSelectionBorder == true) {
    if (d.x-d.s/2 < mouseX && mouseX < d.x+d.s/2
      && d.y-d.s/2 < mouseY && mouseY < d.y+d.s/2) // we are clicking in bounds of destination sq
    {
      blueSelectionBorder = false;
      return;
    }
  } else {
    if (logoX-logoS/2+3 < mouseX && mouseX < logoX+logoS/2-3 
        && logoY-logoS/2+3 < mouseY && mouseY < logoY+logoS/2-3) {
      blueSelectionBorder = true;
      return;
    }
  }
  
  if (blueResizingSquares && blueSelectionBorder == false) {
    float angleRad = radians(logoR);
    float halfSize = logoS/2; 
    float trX = logoX + halfSize * cos(angleRad - PI/4) * sqrt(2);
    float trY = logoY + halfSize * sin(angleRad - PI/4) * sqrt(2);
    float tlX = logoX + halfSize * cos(angleRad - 3*PI/4) * sqrt(2);
    float tlY = logoY + halfSize * sin(angleRad - 3*PI/4) * sqrt(2);
    float brX = logoX + halfSize * cos(angleRad + PI/4) * sqrt(2);
    float brY = logoY + halfSize * sin(angleRad + PI/4) * sqrt(2);
    float blX = logoX + halfSize * cos(angleRad + 3*PI/4) * sqrt(2);
    float blY = logoY + halfSize * sin(angleRad + 3*PI/4) * sqrt(2);
    
    if (dist(mouseX, mouseY, tlX, tlY) < 10) {
      isDragging = true;
      draggingCorner = 0;
      return;
    } else if (dist(mouseX, mouseY, trX, trY) < 10) {
      isDragging = true;
      draggingCorner = 1;
      return;
    } else if (dist(mouseX, mouseY, blX, blY) < 10) {
      isDragging = true;
      draggingCorner = 2;
      return;
    } else if (dist(mouseX, mouseY, brX, brY) < 10) {
      isDragging = true;
      draggingCorner = 3;
      return;
    }
  }
  

  
}

void mouseReleased()
{
  if (trialIndex >= destinations.size()) return;
  isDragging = false;
  draggingCorner = -1;
  
  Destination d = destinations.get(trialIndex);  
  
  if (originalSubmit) {
    //check to see if user clicked middle of screen within 1 inches, which this code uses as a submit button. This is a terrible design you should probably replace.
    if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(1f))
    {
      if (userDone==false && !checkForSuccess())
        errorCount++;
  
      trialIndex++; //and move on to next trial
  
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
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
