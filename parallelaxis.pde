Table data;
float maxValue;
float minValue;
float average;

int plotMarginLeft = 40;
int plotMarginRight = 40;
int plotMarginBottom = 20;
int plotMarginTop = 20;
int axisHeight = 20;

int plotLeft, plotRight, plotWidth;
int plotTop, plotBottom, plotHeight;
int plotMiddle;
int axisTop, axisBottom;

ArrayList<float[]> dataPoints;

// array that coincides with data points to indicate if points are selected
ArrayList<Boolean> pointSelected;
int numSelected = 0;
float selectedAvg;

PFont plotFont;
int selectedColumn = 0;// MPG column in cars.csv


// dragging selection stuff
float[] dragStart;
float[] dragEnd;
boolean dragging = false;

// Color configurations
color notSelectedColor = color(255, 0, 80, 100);
color selectedColor = color(0, 0, 255, 100);

void setup() {
  size(150, 800);
  data = loadTable("cars.csv", "header");
  
  // layout the plot boundaries
  plotLeft = plotMarginLeft;
  plotRight = width - plotMarginRight;
  plotWidth = plotRight - plotLeft;
  plotTop = plotMarginTop;
  plotBottom = height - plotMarginBottom - axisHeight;
  plotHeight = plotBottom - plotTop;
  plotMiddle = plotTop + (plotWidth/ 2);
  
  // layout the axis boundaries
  axisTop = plotLeft;
  axisBottom = axisTop - axisHeight;
  axisHeight = axisBottom - axisTop;
    
  // setup the plot font
  plotFont = createFont("Arial", 12);
  textFont(plotFont);
  
  findMinMax(selectedColumn);
  println("data minimum = " + minValue + " data maximum = " + maxValue + " average = " + average);
  
    // calculate the data points for the values
  calculateDataPoints(selectedColumn);
  
}

void draw() {
  background(200);  
  // show the plot area as a white rectangle
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotLeft, plotTop, plotRight, plotBottom);
    
  drawAxes(selectedColumn);
  
  // draw data points
  stroke(notSelectedColor);
  strokeWeight(3);
  drawDataPoints(selectedColumn);
  
  //show Column at top for navagation
  frame.setTitle("Column = " + (data.getColumnTitle(selectedColumn)));
  
  for (int i = 0; i < data.getRowCount(); i++) {
     // get the current point
     float[] point = dataPoints.get(i);
     
     // set the point line color based on whether it is selected or not
     if (pointSelected.get(i)) {
       stroke(selectedColor);  
     } else {
       stroke(notSelectedColor);
     }
     line(plotRight, point[1], plotLeft, point[1]);
     ellipse(point[0], point[1], 6, 6);
       
  }
  
  // draw the drag rectangle if we are currently dragging
  if (dragging) {
    stroke(0);
    rectMode(CORNERS);
    rect(dragStart[0], dragStart[1], dragEnd[0], dragEnd[1]);
  }
   mouseRollover(selectedColumn);
}

void findMinMax(int col) {
  float sum = 0; 
   // find the minimum and maximum data values for the selected column  
  for (int i = 0; i < data.getRowCount(); i++) {
    // get the current value
    float dataValue = data.getFloat(i, col); 
    if (Float.isNaN(dataValue)){
      continue;
    }
    if (i == 0) {
      // if the first data element, we need to set min and max to that value
      minValue = maxValue = dataValue;
    } else {
      // we need to test the data value and update the min and max values accordingly
      if (dataValue < minValue) {
        minValue = dataValue;
      }
      if (dataValue > maxValue) {
        maxValue = dataValue;
      }
    }
    sum += dataValue;
  }
  average= (sum)/(data.getRowCount());
}

void calculateDataPoints(int col) {
  dataPoints = new ArrayList<float[]>();
  pointSelected = new ArrayList<Boolean>();
  for (int row = 0; row < data.getRowCount(); row++) {
    float dataValue = data.getFloat(row, col);
    float x = plotMiddle;

    //float jitter_y = random(14);
    float y = map(dataValue, minValue, maxValue, plotTop, plotBottom);// + jitter_y;
    dataPoints.add(new float[] {x, y});
    pointSelected.add(false);
  } 
}

void drawAxes(int col) {
  float plotAvg = map(average, minValue, maxValue, plotTop, plotBottom);
  float plotSelectedAvg = map(selectedAvg, minValue, maxValue, plotTop, plotBottom);
  // draw the axis line
  stroke(0);
  strokeWeight(1);
  line(axisTop, plotTop, axisBottom, plotTop);
  line(axisTop, plotBottom, axisBottom, plotBottom);
  line(axisTop, plotTop, axisTop, plotBottom);
  line(axisTop, plotAvg, axisBottom, plotAvg); 
  
  // draw the text labels for the min and max values
  fill(0);
  textAlign(CENTER, TOP);
  text(maxValue, axisBottom, plotBottom);
  text(minValue, axisBottom, plotTop);
  text(average, axisBottom, plotAvg);
  
  line(axisTop, plotSelectedAvg, axisBottom, plotSelectedAvg); 
  text(selectedAvg, axisBottom, plotSelectedAvg);

}

void drawDataPoints(int col) {
  noFill();
  for (int row = 0; row < dataPoints.size(); row++) {
    float[] point = dataPoints.get(row);
    line(plotRight, point[1], plotLeft, point[1]);
    ellipse(point[0], point[1], 6, 6);
  }  
}

void mouseRollover(int col) { //use mouseMoved
 for (int row = 0; row < data.getRowCount(); row++) {
    float dataValue = data.getFloat(row, col);
    float x = plotMiddle;
    float y = map(dataValue, minValue, maxValue, plotTop, plotBottom);
//  only check y value and that mouseX is within plot (not margins)    
//    if(dist(x,y,mouseX,mouseY) < 8) {
    if ((abs(y - mouseY) < 8) && (plotLeft < mouseX) && (mouseX < plotRight)) {
      fill(0);
      textAlign(CENTER);
      text(dataValue, mouseX, mouseY);
    }
  }
}

void keyPressed() {
  if (key == '[') {
    selectedColumn--;
    if (selectedColumn < 0) {
      selectedColumn = data.getColumnCount() - 1;
    }
    
    //println( "[ key pressed! Current Column = " +selectedColumn);
  } else if (key == ']') {
    selectedColumn++;
    if (selectedColumn == data.getColumnCount()) {
      selectedColumn = 0;
    }
    //println( "] key pressed! Current Column = " +selectedColumn);
  } else {
    selectedColumn = selectedColumn;
  }
  
  findMinMax(selectedColumn);
  println("data minimum = " + minValue + " data maximum = " + maxValue + " average = " + average);
  
    // calculate the data points for the values
  calculateDataPoints(selectedColumn);
}

boolean dragRectangleContainsPoint(float point[]) {
  
  // First we have to determine the left, right, bottom, top.
  // If we don't do this, and the drag start is left or below the
  // drag end, the test will fail.  Try it.
  float dragRectLeft = min(dragStart[0], dragEnd[0]);
  float dragRectRight = max(dragStart[0], dragEnd[0]);
  float dragRectTop = min(dragStart[1], dragEnd[1]);
  float dragRectBottom = max(dragStart[1], dragEnd[1]);
  
  // simple test for inclusion in the rectangle
  // note the limits are inclusive (Java rectangle tests omit the right and bottom)
  if (point[0] >= dragRectLeft  && point[0] <= dragRectRight &&
      point[1] >= dragRectTop && point[1] <= dragRectBottom) {
        return true;
  }
  
  // not in the rectangle
  return false;
}

void setSelectedPoints(int col) {
  // First clear the selected points flags
  pointSelected.clear();
  numSelected = 0;
  float selectedSum = 0;
  // loop through the points array list and test for inclusion in the drag
  // rectangle.  The return value from the test function becomes the new
  // flag to indicate the point is selected.
  for (int i = 0; i < data.getRowCount(); i++) {
    boolean selected = dragRectangleContainsPoint(dataPoints.get(i));
    pointSelected.add(selected);
    if (selected) {
      numSelected++;
      selectedSum += data.getFloat(i, col);
    }
    //float selectedPlotSum = map(selectedSum,minValue, maxValue, plotLeft, plotRight);
    //selectedAvg = selectedPlotSum/numSelected;
    
    selectedAvg = selectedSum/numSelected;
  } 
  
  //println("selected sum= " + selectedSum + " , selected average= " + selectedAvg);

} 

// When the mouse is pressed we set the start and end drag rectangle corners to 
// the mouse x, y location.
void mousePressed() {
  dragStart = new float[2];
  dragStart[0] = plotLeft;
  dragStart[1] = mouseY;
  dragEnd = new float[2];
  dragEnd[0] = plotRight;
  dragEnd[1] = mouseY; 
}

// When the mouse is dragged, update the mouse end position and then we
// call a method to set all points inside the drag rectangle bounds. 
void mouseDragged() {
  dragging = true;
  dragEnd[0] = plotRight;
  dragEnd[1] = mouseY;
  
  setSelectedPoints(selectedColumn);
}

// When the mouse is released, clear the mouse dragging flag.
// Other things could happen in this function to make the selection final
// for example you may update the average of the points.  
void mouseReleased() {
  dragging = false;
  println("selected average= " + selectedAvg);
}
