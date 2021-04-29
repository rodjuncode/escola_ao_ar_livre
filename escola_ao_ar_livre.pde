import processing.svg.*;

final Integer OFFWHITE = color(255,243.245);
final Integer PINK = color(250,171,237);
final Integer RED = color(255,88,70);
final Integer BLUE = color(72,66,155);
final Integer GREEN = color(35,96,78);
final Integer WHITE = color(255);
final Integer BLACK = color(0);

int cellSize = 20;
boolean isSelecting = false;
boolean showGrid = true;
HashMap<Integer,Integer[]> palette = new HashMap<Integer,Integer[]>();
int backgroundColor = 0;
int logoColor = 0;

PVector selectBegin, selectEnd;
PShape logoHorizontal,logoVertical,logoHorizontalReduced,logoVerticalReduced,logoStretched,droppedLogo;
PVector logoPadding = new PVector(0,0);

void setup() {
  size(1600,800);
  // load logo versions
  logoHorizontal = loadShape("assets/logo-horizontal.svg");
  logoHorizontal.disableStyle();
  logoVertical = loadShape("assets/logo-vertical.svg");
  logoVertical.disableStyle();
  logoVerticalReduced = loadShape("assets/logo-vertical-reduced.svg");
  logoVerticalReduced.disableStyle();  
  logoHorizontalReduced = loadShape("assets/logo-horizontal-reduced.svg");
  logoHorizontalReduced.disableStyle();
  logoStretched = loadShape("assets/logo-stretched.svg");
  logoStretched.disableStyle();
  
  // load palette
  palette.put(OFFWHITE, new Integer[]{ PINK, RED, BLUE, GREEN }); // off white
  palette.put(PINK, new Integer[]{ OFFWHITE, BLUE, GREEN }); // pink
  palette.put(RED, new Integer[]{ OFFWHITE, BLUE, GREEN }); // red
  palette.put(BLUE, new Integer[]{ OFFWHITE, PINK, RED }); // blue
  palette.put(GREEN, new Integer[]{ OFFWHITE, PINK, RED }); // green
}


void draw() {
  background((int) palette.keySet().toArray()[backgroundColor]);
  if (showGrid) {
    showGrid();
  }
  
  if (isSelecting) {
    updateSelectedArea();
    updateSelectedInfo();
    updateLogo();
  } else {
    if (droppedLogo != null) {
      dropLogo();
    }
  }
}

void dropLogo() {
    push();
    noStroke();
    fill(palette.get(palette.keySet().toArray()[backgroundColor])[logoColor]);
    shape(droppedLogo,selectBegin.x,selectBegin.y,selectEnd.x-selectBegin.x,(selectEnd.x-selectBegin.x)*droppedLogo.height/droppedLogo.width);
    pop();
}

void showGrid() {
  push();
  noFill();
  strokeWeight(0.1);
  stroke(0);
  for (int i = 0; i < width; i += cellSize) {
    line(i,0,i,height);  
  }
  for (int i = 0; i < height; i += cellSize) {
    line(0,i,width,i);  
  }  
  pop();
}

void mousePressed() {
  startSelection();
}

void mouseReleased() {
  endSelection();
}

void startSelection() {
  isSelecting = true;  
  selectBegin = new PVector(ceil(mouseX/cellSize)*cellSize,ceil(mouseY/cellSize)*cellSize);
}

void endSelection() {
  isSelecting = false;  
  selectEnd = new PVector(mouseX,mouseY);
}

void updateSelectedArea() {
  selectEnd = new PVector(ceil(mouseX/cellSize)*cellSize,ceil(mouseY/cellSize)*cellSize);
  push();
  noFill();
  stroke(0);
  rect(selectBegin.x,
        selectBegin.y,
        selectEnd.x-selectBegin.x,
        selectEnd.y-selectBegin.y);
  pop();
}

void updateSelectedInfo() {
  String dimensionDescription = str(selectEnd.x-selectBegin.x) + "x" + str(selectEnd.y-selectBegin.y);
  push();
  fill(0);
  rect(selectBegin.x,selectBegin.y,textWidth(dimensionDescription)+10,15);
  textSize(10);
  fill(255);
  text(str(selectEnd.x-selectBegin.x) + "x" + str(selectEnd.y-selectBegin.y),selectBegin.x+5,selectBegin.y+12);
  pop();
}

void updateLogo() {
  float ratio = (selectEnd.x-selectBegin.x)/(selectEnd.y-selectBegin.y);
  PShape logo;
  if (ratio < 1) {
    if (selectEnd.x-selectBegin.x < 100) {
      logo = logoVerticalReduced;
      logoPadding.x = (selectEnd.x-selectBegin.x)/10;
      logoPadding.y = (selectEnd.x-selectBegin.x)/10;
    } else {
      logo = logoVertical;
      logoPadding.x = (selectEnd.x-selectBegin.x)/10;
      logoPadding.y = (selectEnd.x-selectBegin.x)/10;
    }
  } else if (ratio > 4) {
    logo = logoStretched;
    logoPadding.x = ((selectEnd.x-selectBegin.x)*logo.height/logo.width)/6;
    logoPadding.y = ((selectEnd.x-selectBegin.x)*logo.height/logo.width)/6;
  } else if (selectEnd.x-selectBegin.x < 200){
    logo = logoHorizontalReduced;
    logoPadding.x = (selectEnd.x-selectBegin.x)/15;
    logoPadding.y = (selectEnd.x-selectBegin.x)/15;
  } else {
    logo = logoHorizontal;
    logoPadding.x = (selectEnd.x-selectBegin.x)/20;
    logoPadding.y = (selectEnd.x-selectBegin.x)/20;
  }
  push();
  noFill();
  stroke(0);
  shape(logo,selectBegin.x,selectBegin.y,selectEnd.x-selectBegin.x,(selectEnd.x-selectBegin.x)*logo.height/logo.width);
  pop();
  droppedLogo = logo;
  println(ratio);
}

void keyPressed() {
  if (key == 'g') {
    showGrid = !showGrid;  
  }
  if (key == ']') {
    cellSize += 10;
    if (cellSize > height) {
      cellSize = height;  
    }
  }
  if (key == '[') {
    cellSize -= 10;  
    if (cellSize < 10) {
      cellSize = 10;
    }
  }
  if (key == ' ') {
    backgroundColor++;
    if (backgroundColor > palette.size() - 1) {
      backgroundColor = 0;
    }
    logoColor = 0;
  }
  if (keyCode == ENTER) {
    logoColor++;
    if (logoColor > palette.get(palette.keySet().toArray()[backgroundColor]).length - 1) {
      logoColor = 0;
    }
  }
  if (key == 's') {
    save();
  }    
}

void save() {
  if (droppedLogo != null) {
    PGraphics svg = createGraphics(ceil(selectEnd.x-selectBegin.x+logoPadding.x*2),ceil(((selectEnd.x-selectBegin.x)*droppedLogo.height/droppedLogo.width)+logoPadding.y*2),SVG,"logo.svg");
    svg.beginDraw();
    svg.noStroke();    
    println((int) palette.keySet().toArray()[backgroundColor]);
    svg.fill((int) palette.keySet().toArray()[backgroundColor]);
    svg.rect(0,0,svg.width,svg.height);
    svg.fill(palette.get(palette.keySet().toArray()[backgroundColor])[logoColor]);
    svg.shape(droppedLogo,logoPadding.x,logoPadding.y,ceil(selectEnd.x-selectBegin.x),ceil((selectEnd.x-selectBegin.x)*droppedLogo.height/droppedLogo.width));
    svg.dispose();
    svg.endDraw();
  }
}
