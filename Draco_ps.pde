import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.OpenStreetMap.*;
import de.fhpotsdam.unfolding.marker.SimpleLinesMarker;

// Begin UI stuff
ArrayList<Button> buttons = new ArrayList<Button>();

final int STEP_BACK = 0;
final int PLAY = 1;
final int PAUSE = 2;
final int STEP_FORW = 3;

int mode = PLAY;
int locationIndex = 0;

ArrayList<Location> locations = new ArrayList<Location>();

SimpleLinesMarker marker;;

abstract class Button {
  protected int w,h,x,y;
  protected color c;
  public Button(int width, int height, int x, int y) {
    w = width;
    h = height;
    this.x = x;
    this.y = y;
    c = color(255);
    
    buttons.add(this);
  }
  
  public int getX() {return x;}
  public int getY() {return y;}
  public int getW() {return w;}
  public int getH() {return h;}
  
  public void setFill(color c) {
    this.c = c;
  }
  
  public void draw() {
    fill(c);
    rect(x,y,w,h);
  }
  
  protected abstract void clickedOn();
}

abstract class StdButton extends Button {
  public StdButton(int x, int y) {
    super(48,48,x,y);
  }
  
  protected abstract void clickedOn();
}

class Backward extends StdButton {
  public Backward(int x, int y) {
    super(x, y);
  }
  
  public void draw() {
    super.draw();
    fill(0);
    rect(x+8,y+12,8,y+h-24);
    triangle(x+w-8,y+12,x+w-24,y+24,x+w-8,y+w-12);
    triangle(x+w-20,y+12,x+w-36,y+24,x+w-20,y+w-12);
  }
  
  protected void clickedOn() {
    mode = STEP_BACK;
    decLocIndex();
  }
}

class Play extends StdButton {
  public Play(int x, int y) {
    super(x, y);
  }
  
  public void draw() {
    super.draw();
    fill(0);
    triangle(x+14,y+8,x+w-10,y+24,x+14,y+w-8);
  }
  
  protected void clickedOn() {
    mode = PLAY;
    locationIndex = locations.size();
    updateMarker();
  }
}

class Pause extends StdButton {
  public Pause(int x, int y) {
    super(x, y);
  }
  
  public void draw() {
    super.draw();
    fill(0);
    rect(x+12,y+10,10,28);
    rect(x+28,y+10,10,28);
  }
  
  protected void clickedOn() {
    mode = PAUSE;
  }
}

class Forward extends StdButton {
  public Forward(int x, int y) {
    super(x, y);
  }
  
  public void draw() {
    super.draw();
    fill(0);
    rect(x+30,y+12,8,y+h-24);
    triangle(x+6,y+12,x+w-22,y+24,x+6,y+w-12);
    triangle(x+18,y+12,x+w-10,y+24,x+18,y+w-12);
  }
  
  protected void clickedOn() {
    mode = STEP_FORW;
    incLocIndex();
  }
}

UnfoldingMap map;
Button bw = new Backward(0,0),play = new Play(48,0),pause = new Pause(96,0),fw = new Forward(144,0);

// End UI stuff

// need to stop copying whole location list every time...
void decLocIndex() {
  if (locationIndex <= 0) return;
  
  --locationIndex;
  updateMarker();
}

void incLocIndex() {
  if (locationIndex >= locations.size()) return;
  
  ++locationIndex;
  updateMarker();
}

void updateMarker() {
  marker = new SimpleLinesMarker();
  for (int i = 0; i < locationIndex; ++i) {
    Location l = locations.get(i);
    marker.addLocation(l.getLat(), l.getLon());
  }
}

void fetch() {
  synchronized (locations) {
    double lat = 0.0;// get lat, could be float
    double lng = 0.0; // get long, could be float

    Location l = new Location(lat, lng);
//    locations.add(l);

    if (mode == PLAY)
      incLocIndex();
  }
}

void setup() {
  size(1200, 675);
  map = new UnfoldingMap(this, new OpenStreetMapProvider());
  MapUtils.createDefaultEventDispatcher(this, map);

// test code. Creates fake coords. Uncomment to witness 5:30AM magic
//  for (double i = 0; i < 50; ++i) {
//    locations.add(new Location(i,i));
//  }
  updateMarker();
}

void draw() {
  clear();
  map.draw();
  bw.draw();
  play.draw();
  pause.draw();
  fw.draw();

//  if (frameCount % 30 == 0) // creates thread twice a second. 60 fps refresh rate. Adjust if needed at all
    thread("fetch"); // might lag due to update rate of ~60/s

  map.getMarkers().clear();
  marker.setColor(color(255,110,12));
  marker.setStrokeWeight(3);
  map.addMarkers(marker);
}

// TODO add keys for stepping back and forward
// clicking too fast (double click) makes map zoom in...
void mouseClicked(MouseEvent e) {
  for (int i = 0; i < buttons.size(); ++i) {
    int x = e.getX();
    int y = e.getY();
    Button b = buttons.get(i);

    if (b.getX() <= x && x <= b.getX() + b.getW() &&
        b.getY() <= y && y <= b.getY() + b.getH()) {
      b.clickedOn();
    }
    
    
  }
}

