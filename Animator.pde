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

public static final int SINGLE = 101;
public static final int MIRROR = 102;
public static final int LAKE = 103;
public static final int INDIA = 104;

int bgColor = 0;

ArrayList<Object[]> points = new ArrayList<Object[]>();
ArrayList<String> forwardLoop;
ArrayList<String> backwardLoop;
boolean forwardLoopOn;
boolean backwardLoopOn;
int mode;
boolean layerMode;
boolean traceMode;
float brushSize = 5;
color pen = color(255);
PImage image;
PImage bg;
PImage img;
PImage layerFrame;
PImage traceFrame;

void setup(){
  size(1080, 1080);
  //fullScreen();
  background(bgColor);
  setLastFrame("frame", "png");
  mode = SINGLE;
}

void draw(){
  
}

void mouseDragged(){
  PVector p = new PVector(mouseX, mouseY);
  Object[] arr = new Object[4];
  arr[0] = p;
  arr[1] = pen;
  arr[2] = brushSize;
  arr[3] = mode;
  points.add(arr);
  drawPoint(p, pen);
}

void createFrames(){
  File f = new File(savePath("lastFrame.png"));
  if(f.exists()){
    tint(255, 255);
    PImage p = loadImage(savePath("lastFrame.png"));
    image(p, 0, 0);
  }else{
    background(bgColor);
  }
  for(Object[] pv : points){
    createFrame(pv, points.indexOf(pv));
  }
  println("all frames created");
  forwardLoopOn = false;
  println("Forward loop OFF");
  backwardLoopOn = false;
  println("Backward loop OFF");
  
}

void createFrame(Object[] pv, int i){
  brushSize = (float)pv[2];
  PVector p = (PVector)pv[0];
  mode = (int) pv[3];
  drawPoint(p, (color) pv[1]);
  if(i%20 == 0){
    saveIncremental("frame", "png");
  }
}

void drawPoint(PVector p, color pen){
  stroke(pen);
  fill(pen);
  switch(mode){
    case SINGLE:
    ellipse(p.x, p.y, brushSize/3, brushSize/3);
    break;
    case MIRROR:
    ellipse(p.x, p.y, brushSize/3, brushSize/3);
    ellipse(width - p.x, p.y, brushSize/3, brushSize/3);
    break;
  case LAKE:
    ellipse(p.x, p.y, brushSize/3, brushSize/3);
    ellipse(p.x, height - p.y, brushSize/3, brushSize/3);
    break;
  case INDIA:
    ellipse(p.x, p.y, brushSize/3, brushSize/3);
    ellipse(p.x, height - p.y, brushSize/3, brushSize/3);
    ellipse(width - p.x, height - p.y, brushSize/3, brushSize/3);
    ellipse(width - p.x, p.y, brushSize/3, brushSize/3);
    break;
    default:
    println("ERROR - DEFAULT MODE: " + mode + " @drawPoint()");
  }
}

void setBg(){
  saveFrame(savePath("bg.png"));
  bg = loadImage("bg.png");
}

void next(){
  if(traceMode){
    background(bgColor);
    if(layerMode && layerFrame != null){
      imageMode(CENTER);
      image(layerFrame, width / 2, height / 2);
      imageMode(CORNER);
    }
    for(Object[] pv: points){
      brushSize = (float)pv[2];
      PVector p = (PVector)pv[0];
      drawPoint(p, (color) pv[1]);
    }
  }
  saveIncremental("frame", "png");
  saveFrame(savePath("lastFrame.png"));
  tint(255, 200);
  if(layerFrame == null && traceFrame == null){
    bg = loadImage("bg.png");
    if(bg != null){
      image(bg, 0, 0);
    }
  }else if(layerFrame != null && traceFrame == null){
    imageMode(CENTER);
    image(layerFrame, width / 2, height / 2);
    imageMode(CORNER);
  }else if(traceFrame != null && layerFrame == null){
    println("trace no layer");
    imageMode(CENTER);
    image(traceFrame, width / 2, height / 2);
    imageMode(CORNER);
  }else{
    imageMode(CENTER);
    traceFrame.mask(layerFrame);
    image(traceFrame, width / 2, height / 2);
    imageMode(CORNER);
  }
  points = new ArrayList<Object[]>();
}

void saveIncremental(String prefix,String extension) {
  int savecnt=0;
  boolean ok=false;
  String filename="";
  File f;
  
  while(!ok) {
    filename = prefix;  
    filename += getFileNumberPrefix(savecnt);
    filename += savecnt + "." +extension;
    f=new File(savePath(filename));
    if(!f.exists()) ok=true; // File doesn't exist
    savecnt++;
  }
  if(traceMode){
    File trace = new File(sketchPath() + "/trace/" + filename);
    if(trace.exists()){
      traceFrame = loadImage(sketchPath() + "/trace/" + filename);
    }else{
      traceFrame = null;
    }
  }
  if(layerMode){
      File layer = new File(sketchPath() + "/layer/"+filename);
      if(layer.exists()){
        layerFrame = loadImage(layer.getPath());
      }else{
        layerFrame = null;
      }
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

void setNewLayer(){
  println("setNewLayer");
  String foldername = "layer";
  File layerZero = new File(sketchPath() + "/"+ foldername + "/");
  if(layerZero.exists()){
    println("layerZero exists");
    int savecnt = 0;
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
  int savecnt = 0; 
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
   if(f != null && f.exists()){
     println("Opening "+filename);
     img = loadImage(f.getName());
     image(img, 0, 0);
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
  if(forwardLoop == null || forwardLoop.size() < 1){
    println("nothing in forwardLoop");
    return;
  }
  ArrayList<String> newLoop = new ArrayList<String>();
  String lastFilename = forwardLoop.get(forwardLoop.size() - 1).substring(5, 9);
  int lastN = parseInt(lastFilename);
  String firstFilename = forwardLoop.get(0).substring(5, 9);
  int firstN = parseInt(firstFilename);
  int diff = lastN - firstN;
  println("FIRST FRAME: " + firstFilename);
  println("LAST FRAME: " + lastFilename);
  println("DIFF: " + diff);
  for(String s : forwardLoop){
    println("loop file name: " + s);
    String oldFilename = s;
    String n = oldFilename.substring(5, 9);
    int fileNumber = parseInt(n);
    fileNumber += diff + 1;
    String newFilename = "frame";
    newFilename += getFileNumberPrefix(fileNumber);
    newFilename += fileNumber;
    println("FILE NUMBER: " + fileNumber);
    newFilename += ".png";
    println("NEW FILE NAME: " + newFilename);
    
    copyFrame(new File(savePath(s)), new File(savePath(newFilename)));
    newLoop.add(newFilename);
  }
  forwardLoop = newLoop;
  tint(255, 255);
  image(loadImage(forwardLoop.get(forwardLoop.size() -1 )), 0, 0);
  println("finished renderForwardLoop");
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
  println("Forward loop OFF");
  if(backwardLoop == null || backwardLoop.size() < 1){
    println("nothing in forwardLoop");
    return;
  }
  ArrayList<String> newLoop = new ArrayList<String>();
  String lastFilename = backwardLoop.get(backwardLoop.size() - 1).substring(5, 9);
  int lastN = parseInt(lastFilename);
  String firstFilename = backwardLoop.get(0).substring(5, 9);
  int firstN = parseInt(firstFilename);
  int diff = lastN - firstN;
  println("FIRST FRAME: " + firstFilename);
  println("LAST FRAME: " + lastFilename);
  println("DIFF: " + diff);
  for(String s : backwardLoop){
    println("loop file name: " + s);
    String oldFilename = s;
    String n = oldFilename.substring(5, 9);
    int fileNumber = parseInt(n);
    fileNumber += diff + 1;
    String newFilename = "frame";
    newFilename += getFileNumberPrefix(fileNumber);
    newFilename += fileNumber;
    println("FILE NUMBER: " + fileNumber);
    newFilename += ".png";
    println("NEW FILE NAME: " + newFilename);
    
    copyFrame(new File(savePath(s)), new File(savePath(newFilename)));
    newLoop.add(newFilename);
  }
  backwardLoop = newLoop;
  tint(255, 255);
  image(loadImage(backwardLoop.get(backwardLoop.size() -1 )), 0, 0);
  println("finished renderBackwardLoop");
}

void fileSelected(File file){
  img = loadImage(file.getName());
  println(file.getName());
  image(img, 0, 0);
}


String getFileNumberPrefix(int fileNumber){
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
  OutputStream os = createOutput(next);;
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
       image(bg, 0, 0);
     }else if(traceMode && traceFrame != null){
       image(traceFrame, 0, 0);
     }else{
       background(bgColor);
     }
  }else{
     layerMode = true;
     boolean ok = false;
     int savecnt = 0;
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
       layerFrame = loadImage(layer.getPath());
       image(layerFrame, 0, 0);
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
      image(bg, 0, 0);
    }else if(layerMode && layerFrame != null){
      image(layerFrame, 0, 0);
    }else{
      background(bgColor);
    }
  }else{
    traceMode = true;
    boolean ok = false;
    int savecnt = 0;
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
      traceFrame = loadImage(trace.getPath());
      image(traceFrame, 0, 0);
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
*  1 - 7 = size
*  x = wipe background
*  s = single line
*  m = mirrored line
*  l = lake (horizontal mirror) line
*  i = india (mandala) line
*  c = layer mode ON / OFF
*  r = red, g = green, b = blue, y = yellow, w = white, 9 = shade,
*  n / ctrl = next
*  o = open file
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
     pen = color(255, 200);
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
   brushSize = 20;
 }else if(key == '5'){
   brushSize = 30;
 }else if(key == '6'){
   brushSize = 45;
 }else if(key == '7'){
   brushSize = 60;
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
 }else if(key == 'a'){
   setNewLayer();
 }else if(key == 'r'){
    pen = color(185, 70, 70, 200);
    println("PEN = RED");
 }else if(key == 'b'){
    pen = color(120, 210, 230, 200);
    println("PEN = BLUE");
 }else if(key == 'g'){
   pen = color(70, 185, 70, 200);
   println("PEN = GREEN");
 }else if(key == '9'){
   pen = color(0, 50);
   println("PEN = SHADE");
 }else if(key == 'w'){
   pen = color(255, 200);
   println("PEN = WHITE");
 }else if(key == 'y'){
   pen = color(255, 255, 100, 200);
   println("PEN = YELLOW");
 }else if(key == '['){
   pen -= color(1, 1, 1);
 }else if(key == ']'){
   pen += color(1, 1, 1);
 }else if(key == 'n' || keyCode == CONTROL){
   next();
 }else if(key == 'o'){
   selectInput("Choose File", "fileSelected"); 
 }else if(key == 'k'){
   if(bgColor == 0){
     bgColor = 255;
   }else{
     bgColor = 0;
   }
 }else{
    println(key); 
 }
}
