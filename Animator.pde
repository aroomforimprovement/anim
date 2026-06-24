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

final color PEN_WHITE = color(255, 200);
final color PEN_TRANSPARENT = color(255, 10);
final color PEN_BLACK = color(0);
final color PEN_SHADE = color(0, 10);
final color PEN_GREY = color(150, 10);
final color PEN_RED = color(185, 70, 70, 10);
final color PEN_BLUE = color(120, 210, 230, 10);
final color PEN_GREEN = color(30, 145, 30, 10);
final color PEN_YELLOW = color(255, 255, 100, 10);
final color PEN_PURPLE = color(221, 211, 255, 10);
final color PEN_ORANGE = color(60, 47, 0, 10);
final color PEN_BROWN = color(223, 183, 60, 10);

enum DrawMode {
  SINGLE, MIRROR, LAKE, INDIA
}

int bgColor = 0;

ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> bgPoints = new ArrayList<Point>();
ArrayList<String> forwardLoop = new ArrayList<String>();
ArrayList<String> backwardLoop = new ArrayList<String>();
boolean forwardLoopOn;
boolean backwardLoopOn;
DrawMode mode;
boolean layerMode;
boolean traceMode;
boolean traceOverMode;
float brushSize = 5;
color pen = color(255);
PImage image;
PImage bg;
PImage img;
PImage layerFrame;
PImage traceFrame;

class Point {
  PVector pos;
  color pen;
  float size;
  DrawMode mode;
  
  Point(PVector pos, color pen, float size, DrawMode mode){
    this.pos = pos;
    this.pen = pen;
    this.size = size;
    this.mode = mode;
  }
  
  Point clone(){
    return new Point(pos.copy(), pen, size, mode);
  }
}

void setup(){
  //size(1080, 1080);
  fullScreen();
  background(bgColor);
  setLastFrame("frame", "png");
  mode = DrawMode.SINGLE;
}

void draw(){
  
}

void mouseDragged(){
  Point point = new Point(new PVector(mouseX, mouseY), pen, brushSize, mode);
  points.add(point);
  drawPoint(point);
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

void createFrame(Point pv, int i){
  drawPoint(pv);
  if(i%20 == 0){
    saveIncremental("frame", "png");
  }
}

void drawPoint(Point point){
  stroke(point.pen);
  fill(point.pen);
  ellipse(point.pos.x, point.pos.y, point.size/3, point.size/3);
  switch(point.mode){
    case SINGLE:
    //already done
    break;
    case MIRROR:
    
    ellipse(width - point.pos.x, point.pos.y, point.size/3, point.size/3);
    break;
  case LAKE:
    ellipse(point.pos.x, height - point.pos.y, point.size/3, point.size/3);
    break;
  case INDIA:
    ellipse(point.pos.x, height - point.pos.y, point.size/3, point.size/3);
    ellipse(width - point.pos.x, height - point.pos.y, point.size/3, point.size/3);
    ellipse(width - point.pos.x, point.pos.y, point.size/3, point.size/3);
    break;
    default:
    println("ERROR - DEFAULT MODE: " + point.mode + " @drawPoint()");
  }
}

void drawImageCentered(PImage img){
  if(img == null) return;
  imageMode(CENTER);
  image(img, width/2, height/2);
  imageMode(CORNER);
}

void setBg(){
  
  bgPoints = new ArrayList<Point>();
  for(Point point : points){
    bgPoints.add(point.clone());
  }
  saveBgData();
  saveFrame(savePath("bg.png"));
  bg = loadImage("bg.png");
}

void saveBgData(){
  PrintWriter output = createWriter("bg.txt");
  for(Point pv: bgPoints){
    output.println(pv.pos + "|" + pv.pen + "|" + pv.size + "|" + pv.mode.name());
  }
  output.flush();
  output.close();
}

void drawBgFromData(){
  if(bgPoints != null && bgPoints.size() > 0){
     //use point list
   for(Point point : bgPoints){
     drawPoint(point);
   }
  }else{
    //try file
    File f = new File(sketchPath("bg.txt"));
    if(f.exists()){
      bgPoints = new ArrayList<Point>();
      String[] lines = loadStrings("bg.txt");
      for(String s : lines){
        String[] p = s.split("\\|");
        for(String thisString : p){println(thisString);}
        p[0] = p[0].replace("[ ", "").replace(" ]", "");
        String[] coS = p[0].split(",");
        float[] coords = new float[2];
        for(int i = 0; i < coS.length-1; i++){coords[i] = float(coS[i]);}
        PVector pv = new PVector(coords[0], coords[1]);
        color c = color(int(p[1]));
        float size = float(p[2]);
        DrawMode m = DrawMode.valueOf(p[3]);
    Point point = new Point(pv, c, size, m);
    bgPoints.add(point);
        drawPoint(point);
    }
  }
  }
  
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
    for(Point pv: points){
      drawPoint(pv);
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
      for(Point pv: points){
        drawPoint(pv);
      }
      //tint(255);
    }
    drawImageCentered(traceFrame);
    drawBgFromData();
    
  }else{
    drawImageCentered(traceFrame);
    drawImageCentered(layerFrame);
    drawBgFromData();
  }
  points.clear();
}

void saveIncremental(String prefix,String extension) {
  int savecnt = findNextFreeFrameIndex(prefix, extension);
  String filename = frameName(savecnt, prefix, extension);
  
  int traceCnt = savecnt+1;
  //int traceCnt = max(2, savecnt);
  
  if(traceMode){
    String traceName = frameName(traceCnt, prefix, extension);
    File trace = new File(sketchPath() + "/trace/" + traceName);
    traceFrame = trace.exists() ? loadImage(trace.getPath()) : null;
  }
  if(layerMode){
    String layerName = frameName(traceCnt, prefix, extension);
    File layer = new File(sketchPath() + "/layer/" + layerName);
    layerFrame = layer.exists() ? loadImage(layer.getPath()) : null;
    }
  println("Saving "+filename);
  saveFrame(savePath(filename));
  
  if(forwardLoopOn){
    forwardLoop.add(filename);
  }
  if(backwardLoopOn){
    backwardLoop.add(filename);
  }
  
}

String frameName(int index, String prefix, String extension){
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

void setNewLayer(){
  println("setNewLayer");
  String foldername = "layer";
  File layerZero = new File(sketchPath() + "/"+ foldername + "/");
  if(layerZero.exists()){
    println("layerZero exists");
    int savecnt = 1;
    boolean ok = false;
    while(!ok){
      foldername += getFileNumberPrefix(savecnt);
      foldername += savecnt;
      println("foldername: " + foldername);
      File fo = new File(sketchPath() + "/"+ foldername + "/");
      if(!fo.exists()){
        ok = true;
        foldername = "layer" + getFileNumberPrefix(savecnt) + savecnt;
        layerZero.renameTo(new File(sketchPath() + "/" + foldername + "/"));
      }
      savecnt++;
      
    }
    
  }
  File newLayerFolder = new File(sketchPath() + "/layer/");
    newLayerFolder.mkdir();
    File path = new File(sketchPath());
    File[] files = path.listFiles();
    for(int i = 0; i < files.length; i++){
      println(i);
      if(files[i].getName().indexOf("png") > 0){
        println("png found");
        files[i].renameTo(new File(newLayerFolder.getPath() + "/" + files[i].getName()));
      }
    }
}


void setLastFrame(String prefix, String extension){
  int savecnt = 1; 
  boolean ok = false;
  String filename = "";
   File f = null;
   while(!ok){
     filename = prefix;
     if(savecnt < 10){
       filename+="000";
     }else if(savecnt < 100){
       filename += "00";
     }else if(savecnt < 1000){
       filename += "0";
     }
     
     filename+=""+savecnt+"."+extension;
     f = new File(savePath(filename));
     
     if(f.exists()){
       savecnt++;
     }else if(savecnt < 1 && !f.exists()){
       ok = true;
     }else{
       if(savecnt > 0){
         println("Trying to Open "+filename);
         ok = true;
       }
     }
   }
   savecnt--;
   if(savecnt < 10){
       prefix+="000";
     }else if(savecnt < 100){
       prefix += "00";
     }else if(savecnt < 1000){
       prefix += "0"; 
     }
   f = new File(savePath(prefix+savecnt+"."+extension));
   
   println(f.getName());
   if(f.exists()){
     println("Opening "+filename);
     img = loadImage(f.getName());
     drawImageCentered(img);
   }
}

void startForwardLoop(){
  println("startForwardLoop");
  forwardLoop.clear();
  forwardLoopOn = true;
}

void renderForwardLoop(){
  println("renderForwardLoop");
  forwardLoopOn = false;
  println("Forward loop OFF");
  if(forwardLoop == null || forwardLoop.size() < 1){
    println("nothing in forwardLoop");
    return;
  }
  forwardLoop = getRenderedLoop(forwardLoop);
  tint(255, 255);
  drawImageCentered(loadImage(forwardLoop.get(forwardLoop.size() -1 )));
  println("finished renderForwardLoop");
}


void startBackwardLoop(){
  backwardLoop.clear();
  backwardLoopOn = true;
}

void renderBackwardLoop(){
  println("renderBackwardLoop");
  backwardLoopOn = false;
  println("Backward loop OFF");
  if(backwardLoop == null || backwardLoop.size() < 1){
    println("nothing in backwardLoop");
    return;
  }
  backwardLoop = getRenderedLoop(backwardLoop);
  tint(255, 255);
  drawImageCentered(loadImage(backwardLoop.get(backwardLoop.size() -1 )));
  println("finished renderBackwardLoop");
}

ArrayList<String> getRenderedLoop(ArrayList<String> loop){
  ArrayList<String> newLoop = new ArrayList<String>();
  String lastFilename = loop.get(loop.size() -1).substring(5, 9);
  int lastN = parseInt(lastFilename);
  String firstFilename = loop.get(0).substring(5, 9);
  int firstN = parseInt(firstFilename);
  int diff = lastN - firstN;
  for(String s: loop){
    String oldFilename = s;
    String n = oldFilename.substring(5, 9);
    int fileNumber = parseInt(n);
    fileNumber += diff+1;
    String newFilename = "frame";
    newFilename += getFileNumberPrefix(fileNumber);
    newFilename += fileNumber;
    newFilename += ".png";
    copyFrame(new File(savePath(s)), new File(savePath(newFilename)));
    newLoop.add(newFilename);
  }
  return newLoop;
}

void fileSelected(File file){
  img = loadImage(file.getName());
  println(file.getName());
  drawImageCentered(img);
}


String getFileNumberPrefix(int fileNumber){
  //return String.format("%04d", fileNumber);
  if(fileNumber < 10){
      return "000";
    }else if(fileNumber < 100){
      return "00";
    }else if(fileNumber < 1000){
      return "0";
    }
    return "";
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

private void setLayerMode(){
  println("setLayerMode");
  if(layerMode){
     layerMode = false;
     if(!traceMode && bg != null){
       drawImageCentered(bg);
     }else if(traceMode && traceFrame != null){
       tint(255, 160);
       drawImageCentered(traceFrame);
     }else{
       background(bgColor);
     }
  }else{
     layerMode = true;
     boolean ok = false;
     int savecnt = 1;
     String filename = "";
     File f;
     while(!ok){
       filename = "frame";
       filename += getFileNumberPrefix(savecnt);
       filename += savecnt + ".png";
       f = new File(savePath(filename));
       if(!f.exists()) ok = true;
       savecnt++;
     }
     File layer = new File(sketchPath() + "/layer/" + filename);
     if(layer.exists()){
       if(traceMode){
         tint(255, 160);
       }
       layerFrame = loadImage(layer.getPath());
       drawImageCentered(layerFrame);
     }else{
       layerFrame = null;
     }
  }
}

private void setTraceMode(){
  println("setTraceMode");
  if(traceMode){
    traceMode = false;
    if(!layerMode && bg != null){
      drawImageCentered(bg);
    }else if(layerMode && layerFrame != null){
      tint(255, 160);
      drawImageCentered(layerFrame);
    }else{
      background(bgColor);
    }
  }else{
    traceMode = true;
    boolean ok = false;
    int savecnt = 1;
    String filename = "";
    File f;
    while(!ok){
      filename = "frame";
      filename += getFileNumberPrefix(savecnt);
      filename += savecnt + ".png";
      f = new File(savePath(filename));
      if(!f.exists()) ok = true;
      savecnt++;
    }
    File trace = new File(sketchPath() + "/trace/" + filename);
    if(trace.exists()){
      if(layerMode){
        tint(255, 160);
      }
      traceFrame = loadImage(trace.getPath());
      drawImageCentered(traceFrame);
      stroke(bgColor, 100);
      fill(bgColor, 100);
      rect(0, 0, width, height);
    }else{
      traceFrame = null;
    }
  }
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
void handleSizeKeys(){
  switch(key){
    case '1':
      brushSize = 5;
      break;
    case '2':
      brushSize = 10;
      break;
    case '3':
      brushSize = 15;
      break;
    case '4':
      brushSize = 30;
      break;
    case '5':
      brushSize = 45;
      break;
    case '6':
      brushSize = 60;
      break;
    case '7':
      brushSize += 20;
  }
}

void handleColorKeys(){
  switch(key){
    case 'w':
      pen = PEN_WHITE;
      break;
    case 'z':
      pen = PEN_TRANSPARENT;
      break;
    case '0':
      pen = PEN_BLACK;
      break;
    case '9':
      pen = PEN_SHADE;
      break;
    case 'h':
      pen = PEN_GREY;
      break;
    case 'r':
      pen = PEN_RED;
      break;
    case 'b':
      pen = PEN_BLUE;
      break;
    case 'g':
      pen = PEN_GREEN;
      break;
    case 'y':
      pen = PEN_YELLOW;
      break;
    case 'p':
      pen = PEN_PURPLE;
      break;
    case 'o':
      pen = PEN_ORANGE;
      break;
    case 'u':
      pen = PEN_BROWN;
      break;
    
  }
}

void handleRenderKeys(){
  switch(keyCode){
    case ENTER:
      createFrames();
      break;
    case SHIFT:
      setBg();
      break;
    case CONTROL:
      next();
      break;
    case LEFT:
      startForwardLoop();
      break;
    case RIGHT:
      renderForwardLoop();
      break;
    case UP:
      startBackwardLoop();
      break;
    case DOWN:
      renderBackwardLoop();
      break;
  }
}

void handleModeKeys(){
  switch(key){
    case 's':
      mode = DrawMode.SINGLE;
      break;
    case 'm':
      mode = DrawMode.MIRROR;
      break;
    case 'l':
      mode = DrawMode.LAKE;
      break;
    case 'i':
      mode = DrawMode.INDIA;
      break;
    case 't':
      setTraceMode();
      break;
    case 'c':
      setLayerMode();
      break;
    case 'q':
      traceOverMode = !traceOverMode;
      break;
    case 'k':
      if(bgColor == 0){
        bgColor = 255;
      }else{
        bgColor = 0;
      }
      break;   
  }
}


void keyPressed(){
  handleSizeKeys();
  handleColorKeys();
  handleRenderKeys();
  handleModeKeys();
}
