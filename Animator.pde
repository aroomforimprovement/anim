/*
*  To create a layer, make a folder next to the pde file called 'layer' and turn on layer mode
*
*  ENTER = createFrames
*  SHIFT = setBg
*  ALT = WHITE / BLACK
*  LEFT = start forward loop
*  RIGHT = render forward loop
*  UP = start backward loop
*  DOWN = render backward loop
*  0 = black
*  1 - 7 = size
*  x = wipe background
*  s = single line
*  m = mirrored line
*  l = lake (horizontal mirror) line
*  i = india (mandala) line
*  c = layer mode ON / OFF
*  t = trace mode ON / OFF
*  r = red, g = green, b = blue, y = yellow, w = white, 9 = shade,
*  n / ctrl = next
*  o = open file
*  [ / ] = lighter / darker
*  a = New Layer
*/

class Stroke {
	PVector pos;
	color pen;
	float size;
	int mode;

	Stroke(PVector pos, color pen, float size, int mode){
		this.pos = pos;
		this.pen = pen;
		this.size = size;
		this.mode = mode;
	}

	Stroke(Stroke other){
		this.pos = other.pos.copy();
		this.pen = other.pen;
		this.size = other.size;
		this.mode = other.mode;
	}

	String serialise() {
    	return pos.x + "," + pos.y + "|" + (int)pen + "|" + size + "|" + mode;
  	}

  	static Stroke fromString(String line) {
    	String[] parts = split(line, '|');
    	String[] coordParts = split(parts[0], ',');

	    float x = float(trim(coordParts[0]));
    	float y = float(trim(coordParts[1]));
    	PVector pos = new PVector(x, y);

    	color c = color(int(parts[1]));
    	float size = float(parts[2]);
    	int mode = int(parts[3]);

    	return new Stroke(pos, c, size, mode);
  	}
}

public static final int SINGLE = 101;
public static final int MIRROR = 102;
public static final int LAKE = 103;
public static final int INDIA = 104;

int bgColor = 0;

ArrayList<Stroke> points = new ArrayList<Stroke>();
ArrayList<Stroke> bgPoints = new ArrayList<Stroke>();
ArrayList<String> forwardLoop;
ArrayList<String> backwardLoop;
boolean forwardLoopOn;
boolean backwardLoopOn;
int mode;
boolean layerMode;
boolean traceMode;
boolean traceOverMode;
float brushSize = 5;
color pen = color(255);
Image bg;
PImage img;
PImage layerFrame;
PImage traceFrame;

void setup(){
  //size(1080, 1080);
  fullScreen();
  background(bgColor);
  setLastFrame("frame", "png");
  mode = SINGLE;
}

void draw(){
  
}

void mouseDragged(){
  PVector p = new PVector(mouseX, mouseY);
  Stroke stroke = new Stroke(p, pen, brushSize, mode);
  points.add(stroke);
  drawStroke(stroke);
}

void createFrames(){
  File f = new File(savePath("lastFrame.png"));
  if(f.exists()){
    tint(255, 255);
    PImage p = loadImage(savePath("lastFrame.png"));
	drawImageCentered(p);
  }else{
    background(bgColor);
  }
  for(int i = 0; i < points.size(); i++){
    createFrame(points.get(i), i);
  }
  println("all frames created");
  forwardLoopOn = false;
  println("Forward loop OFF");
  backwardLoopOn = false;
  println("Backward loop OFF");
  
}

void createFrame(Stroke pv, int i){
  drawStroke(pv);
  if(i%20 == 0){
    saveIncremental("frame", "png");
  }
}

void drawStroke(Stroke s){
	drawPoint(s.pos, s.pen, s.mode, s.size);
}

void drawPoint(PVector p, color pen, int mode, float brushSize){
  stroke(pen);
  fill(pen);
  float d = brushSize / 3;
  ellipse(p.x, p.y, d, d);
  switch(mode){
    case SINGLE:
    //stroke drawn outside switch
    break;
    case MIRROR:
    ellipse(width - p.x, p.y, d, d);
    break;
  case LAKE:
    ellipse(p.x, height - p.y, d, d);
    break;
  case INDIA:
    ellipse(p.x, height - p.y, d, d);
    ellipse(width - p.x, height - p.y, d, d);
    ellipse(width - p.x, p.y, d, d);
    break;
    default:
    println("ERROR - DEFAULT MODE: " + mode + " @drawPoint()");
  }
}

void setBg(){
  
  bgPoints = new ArrayList<Stroke>();
  for(Stroke stroke : points){
    bgPoints.add(new Stroke(stroke));
  }
  saveBgData();
  saveFrame(savePath("bg.png"));
  bg = loadImage("bg.png");
}

void saveBgData(){
  PrintWriter output = createWriter("bg.txt");
  for(Stroke stroke: bgPoints){
    output.println(stroke.serialise());
  }
  output.flush();
  output.close();
}

void drawBgFromData(){
  if (bgPoints != null && bgPoints.size() > 0) {
    for (Stroke stroke : bgPoints) {
      drawStroke(stroke);
    }
  } else {
    File f = new File(sketchPath("bg.txt"));
    if (f.exists()) {
      bgPoints = new ArrayList<Stroke>();
      String[] lines = loadStrings("bg.txt");
      for (String s : lines) {
        Stroke strk = Stroke.fromString(s);
        bgPoints.add(strk);
        drawStroke(strk);
      }
    }
  }
}

void drawImageCentered(PImage img){
	imageMode(CENTER);
	image(img, width / 2, height / 2);
	imageMode(CORNER);
}

void next(){
  if(traceMode){
    if(!traceOverMode){
      background(bgColor);
    }
    if(layerMode && layerFrame != null){
      tint(255, 255);
	  drawImageCentered(layerFrame);
    }
    drawBgFromData();
    for(Stroke pv: points){
      drawStroke(pv);
    }
  }
  
  saveIncremental("frame", "png");
  saveFrame(savePath("lastFrame.png"));
  tint(255, 160);
  if(layerFrame == null && traceFrame == null){
    bg = loadImage("bg.png");
    if(bg != null){
	  drawImageCentered(bg);
    }else{
      fill(bgColor, 200);
      stroke(bgColor, 200);
      rect(0, 0, width, height);
    }
  }else if(layerFrame != null && traceFrame == null){
	drawImageCentered(layerFrame);
    drawBgFromData();
  }else if(traceFrame != null && layerFrame == null){
    if(traceOverMode){
      tint(255);
      background(bgColor);
      tint(255, 160);
      for(Stroke pv: points){
		drawStroke(pv);
      }
      //tint(255);
    }
	drawImageCentered(traceFrame);
    drawBgFromData();    
  }else{
    imageMode(CENTER);
    //traceFrame.mask(layerFrame);
    tint(255, 160);
    image(traceFrame, width / 2, height / 2);
    tint(255, 160);
    image(layerFrame, width / 2, height / 2);
    imageMode(CORNER);
    drawBgFromData();
  }
  points = new ArrayList<Stroke>();
}

String frameName(int index, String prefix, String extension) {
  return prefix + nf(index, 4) + "." + extension;
}

int findNextFreeFrameIndex(String prefix, String extension){
	int i = 1;
	while(true){
		String filename = frameName(i, prefix, extension);
		File f = new File(savePath(filename));
		if(!f.exists()){
			return i;
		}
		i++;
	}
}

void saveIncremental(String prefix, String extension) {
  int savecnt = findNextFreeFrameIndex(prefix, extension);
  String filename = frameName(savecnt, prefix, extension);
  
  int traceCnt = max(2, savecnt);  

  if (traceMode) {
    String traceName = frameName(traceCnt, prefix, extension);
    File trace = new File(sketchPath() + "/trace/" + traceName);
    traceFrame = trace.exists() ? loadImage(trace.getPath()) : null;
  }

  if (layerMode) {
    String layerName = frameName(traceCnt, prefix, extension);
    File layer = new File(sketchPath() + "/layer/" + layerName);
    layerFrame = layer.exists() ? loadImage(layer.getPath()) : null;
  }

  println("Saving " + filename);
  saveFrame(savePath(filename));

  if (forwardLoopOn) forwardLoop.add(filename);
  if (backwardLoopOn) backwardLoop.add(filename);
}


void setNewLayer(){
  println("setNewLayer");
  String baseName = "layer";
  File layerZero = new File(sketchPath() + "/" + baseName + "/");
  if (layerZero.exists()) {
    int savecnt = 1;
    while (true) {
      String candidate = baseName + nf(savecnt, 4);
      println("foldername: " + candidate);
      File fo = new File(sketchPath() + "/" + candidate + "/");
      if (!fo.exists()) {
        // rename the existing 'layer' folder
        layerZero.renameTo(fo);
        break;
      }
      savecnt++;
    }
  }

  // create a fresh 'layer' folder
  File newLayerFolder = new File(sketchPath() + "/layer/");
  newLayerFolder.mkdir();

  // move existing pngs into new layer folder
  File path = new File(sketchPath());
  File[] files = path.listFiles();
  for (int i = 0; i < files.length; i++) {
    if (files[i].getName().endsWith(".png")) {
      files[i].renameTo(new File(newLayerFolder.getPath() + "/" + files[i].getName()));
    }
  }
}


void setLastFrame(String prefix, String extension) {
  int nextIndex = findNextFreeFrameIndex(prefix, extension);
  int lastIndex = nextIndex - 1;

  if (lastIndex < 1) {
    println("No previous frame found.");
    return;
  }

  String filename = frameName(lastIndex, prefix, extension);
  File f = new File(savePath(filename));

  println(f.getName());
  if (f.exists()) {
    println("Opening " + filename);
    // use the name so it loads from the sketch folder
    img = loadImage(f.getName());
    drawImageCentered(img);
  }
}

void startForwardLoop(){
  println("startForwardLoop");
  forwardLoop = new ArrayList<String>();
  forwardLoopOn = true;
  
}

void renderForwardLoop(){
  println("renderForwardLoop");
  forwardLoopOn = false;
  println("Forward loop OFF");
  forwardLoop = renderLoop(forwardLoop);
}

void startBackwardLoop(){
  println("startBackwardLoop");
  backwardLoop = new ArrayList<String>();
  backwardLoopOn = true;
  println("Backward Loop ON");
}

void renderBackwardLoop(){
  println("renderBackwardLoop");
  backwardLoopOn = false;
  println("Backward loop OFF");
  backwardLoop = renderLoop(backwardLoop);
}


ArrayList<String> renderLoop(ArrayList<String> loop){
	if(loop == null || loop.size() < 1){
    println("nothing in forwardLoop");
    return loop;
  }
  ArrayList<String> newLoop = new ArrayList<String>();
  String lastFilename = loop.get(loop.size() - 1).substring(5, 9);
  int lastN = parseInt(lastFilename);
  String firstFilename = loop.get(0).substring(5, 9);
  int firstN = parseInt(firstFilename);
  int diff = lastN - firstN;
  println("FIRST FRAME: " + firstFilename);
  println("LAST FRAME: " + lastFilename);
  println("DIFF: " + diff);
  for(String s : loop){
    println("loop file name: " + s);
    String oldFilename = s;
    String n = oldFilename.substring(5, 9);
    int fileNumber = parseInt(n);
    fileNumber += diff + 1;
	String newFilename = frameName(fileNumber, "frame", "png");    
    println("NEW FILE NAME: " + newFilename);
    
    copyFrame(new File(savePath(s)), new File(savePath(newFilename)));
    newLoop.add(newFilename);
  }
  tint(255, 255);
  PImage last = loadImage(savePath(loop.get(loop.size() -1)));
  if(last != null){
	drawImageCentered(last);
  }
  println("finished renderLoop");
  return newLoop;
}

void fileSelected(File file){
  if(file == null){
	return;
  }
  img = loadImage(file.getAbsolutePath());
  println(file.getAbsolutePath());
  drawImageCentered(img);
}

private static void copyFrame(File orig, File next){
  InputStream is = createInput(orig);
  OutputStream os = createOutput(next);
  byte[] buffer = new byte[1024];
  int length;
  try{
  while((length = is.read(buffer)) > 0){
    os.write(buffer, 0, length);
  }
  }catch(IOException e){
    e.printStackTrace();
  }finally{
   try{
     if(is != null){
      is.close();
     }
     if(os != null){
      os.close();
     }
   }catch(IOException e){
     e.printStackTrace();
   }
  }
}

private void setLayerMode() {
  println("setLayerMode");

  if (layerMode) {
    // turning OFF
    layerMode = false;

    if (!traceMode && bg != null) {
      drawImageCentered(bg);
    } else if (traceMode && traceFrame != null) {
      tint(255, 160);
      drawImageCentered(traceFrame);
    } else {
      background(bgColor);
    }

  } else {
    // turning ON
    layerMode = true;

    int nextIndex = findNextFreeFrameIndex("frame", "png");
    String filename = frameName(nextIndex, "frame", "png");

    File layer = new File(sketchPath() + "/layer/" + filename);
    if (layer.exists()) {
      if (traceMode) {
        tint(255, 160);
      }
      layerFrame = loadImage(layer.getPath());
      drawImageCentered(layerFrame);
    } else {
      layerFrame = null;
    }
  }
}

private void setTraceMode() {
  println("setTraceMode");

  if (traceMode) {
    // turning OFF
    traceMode = false;

    if (!layerMode && bg != null) {
      drawImageCentered(bg);
    } else if (layerMode && layerFrame != null) {
      tint(255, 160);
      drawImageCentered(layerFrame);
    } else {
      background(bgColor);
    }

  } else {
    // turning ON
    traceMode = true;

    int nextIndex = findNextFreeFrameIndex("frame", "png");
    String filename = frameName(nextIndex, "frame", "png");

    File trace = new File(sketchPath() + "/trace/" + filename);
    if (trace.exists()) {
      if (layerMode) {
        tint(255, 160);
      }
      traceFrame = loadImage(trace.getPath());
      drawImageCentered(traceFrame);

      stroke(bgColor, 100);
      fill(bgColor, 100);
      rect(0, 0, width, height);
    } else {
      traceFrame = null;
    }
  }
}

void incrementColour(char key){
  float r = red(pen);
  float g = green(pen);
  float b = blue(pen);

  if (key == '[') {
    r = max(0, r - 5);
    g = max(0, g - 5);
    b = max(0, b - 5);
  } else if (key == ']') {
    r = min(255, r + 5);
    g = min(255, g + 5);
    b = min(255, b + 5);
  }
  pen = color(r, g, b, alpha(pen));
}

/*
*  ENTER = createFrames
*  SHIFT = setBg
*  ALT = WHITE / BLACK
*  LEFT = start forward loop
*  RIGHT = render forward loop
*  UP = start backward loop
*  DOWN = render backward loop
*  0 = black
*  1 - 6 = size
*  7 = size++
*  x = wipe background
*  s = single line
*  m = mirrored line
*  l = lake (horizontal mirror) line
*  i = india (mandala) line
*  c = layer mode ON / OFF
*  t = trace mode ON / OFF
*  q = trace over mode ON / OFF
*  r = red, g = green, b = blue, y = yellow, w = white, 9 = shade,
*  z = transparent, p = purple, u = brown, o = orange, h = grey, u = brown
*  n / ctrl = next
*  a = setNewLayer
*  ////!!!!o = open file
*  [ / ] = lighter / darker
*/
void keyPressed(){
 if(keyCode == ENTER){
   //setBg();
   createFrames();
 }
 if(keyCode == SHIFT){
   println("Set Background");
   setBg();
 }
 if(keyCode == ALT){
   if(pen == color(0) || pen == color(0, 200)){
     pen = color(255, 160);
     println("PEN = WHITE");
   }else{
      pen = color(0, 200); 
      println("PEN = BLACK");
   }
 }
 if(keyCode == LEFT){
   startForwardLoop();
 }
 if(keyCode == RIGHT){
   renderForwardLoop();
 }
 if(keyCode == UP){
   startBackwardLoop();
 }
 if(keyCode == DOWN){
   renderBackwardLoop();
 }
 if(key == '0'){
   pen = color(0);
   println("PEN = BLACK");
 }else  if(key == '1'){
   brushSize = 5;
 }else if(key == '2'){
   brushSize = 10;
 }else if(key == '3'){
   brushSize = 15;
 }else if(key == '4'){
   brushSize = 30;
 }else if(key == '5'){
   brushSize = 45;
 }else if(key == '6'){
   brushSize = 60;
 }else if(key == '7'){
   brushSize += 20;
 }else if(key == 'x'){
   background(bgColor);
 }else if(key == 's'){
   mode = SINGLE;
 }else if(key == 'm'){
   mode = MIRROR;
 }else if(key == 'l'){
   mode = LAKE;
 }else if(key == 'i'){
   mode = INDIA;
 }else if(key == 'c'){
   setLayerMode();
 }else if(key == 't'){
   setTraceMode();
 }else if(key == 'q'){
   traceOverMode = !traceOverMode;
 }else if(key == 'a'){
   setNewLayer();
 }else if(key == 'r'){
    pen = color(185, 70, 70, 10);
    println("PEN = RED");
 }else if(key == 'b'){
    pen = color(120, 210, 230, 10);
    println("PEN = BLUE");
 }else if(key == 'g'){
   pen = color(30, 145, 30, 10);
   println("PEN = GREEN");
 }else if(key == '9'){
   pen = color(0, 10);
   println("PEN = SHADE");
 }else if(key == 'w'){
   pen = color(255, 200);
   println("PEN = WHITE");
 }else if(key == 'y'){
   pen = color(255, 255, 100, 10);
   println("PEN = YELLOW");
 }else if(key == 'p'){
   println("PEN = PURPLE");
   pen = color(221, 211, 255, 10);
 }else if(key == 'o'){
   println("PEN = ORANGE");
   pen = color(60, 47, 0, 10);
 }else if(key == 'h'){
   println("PEN = GREY");
   pen = color(150, 10);
 }else if(key == 'u'){
   println("PEN = BROWN");
   pen = color(223, 183, 60, 50);
 }else if(key == 'z'){
   println("PEN = TRANS");
   pen = color(255, 10);
 }else if(key == '[' || key == ']'){
    incrementColour(key);   
 }else if(key == 'n' || keyCode == CONTROL){
   next();
 //}else if(key == 'o'){
 //  selectInput("Choose File", "fileSelected"); 
 }else if(key == 'k'){
   if(bgColor == 0){
     bgColor = 255;
   }else{
     bgColor = 0;
   }
 }else{
    println(key); 
    println(keyCode);
 }
}
