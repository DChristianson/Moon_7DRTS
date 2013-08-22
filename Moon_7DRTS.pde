import javax.media.opengl.GL2;
import java.util.*;
import java.nio.*;

float[] projMatrix;
float[] mvMatrix;

// graphics
int SIZEOF_FLOAT = 4;
int SIZEOF_INT = 4;

PGraphicsOpenGL pgl;
boolean showBounds = false;
boolean showContactRadius = false;

boolean gameOver = false;
Camera gamecam;
long lastMillis = -1;

// playfield
Moon moon;
Radio radio;

// actors
Buggy buggy;
List<Actor> miners;
List<Actor> bases;
List<Actor> blocks;
List<Actor> outposts;

void setup() {
  
  size(800, 450, P3D);
  pgl = (PGraphicsOpenGL) g;
  projMatrix = new float[16];
  mvMatrix = new float[16];
  
  // be able to see the whole playfield
  
  perspective(pgl.cameraFOV, pgl.cameraAspect, pgl.cameraNear, 10000);
  
  moon = new Moon();
  moon.setup();
  
  radio = new Radio();
  radio.setup();
  
  //  one base at center of moon
  bases = new ArrayList();
  Base base = new Base();
  base.setup();
  base.place(moon.getCenter());
  bases.add(base);
  
  blocks = new ArrayList();
  {
     // no blocks to start 
  }

  // a few outposts
  outposts = new ArrayList();
  {
    Outpost outpost = new Outpost();
    outpost.setup();
    outpost.place(moon.getQ1());
    outposts.add(outpost);
  }
  {
    Outpost outpost = new Outpost();
    outpost.setup();
    outpost.place(moon.getQ3());
    outposts.add(outpost);
  }
  {
    Outpost outpost = new Outpost();
    outpost.setup();
    outpost.place(moon.getQ4());
    outposts.add(outpost);
  }
    
  buggy = new Buggy();
  buggy.setup();
  buggy.place(somewhereNextTo((Actor)bases.get(0)));

  miners = new ArrayList();
  Miner miner = new Miner();
  miner.setup();
  miner.place(new PVector(moon.getCenter().x + 500, 0, moon.getQ2().z - 500));
  miner.mine(new PVector(moon.getCenter().x, 0, moon.getQ2().z), 500);
  miners.add(miner);

  gamecam = new Camera();
  gamecam.setup();
  gamecam.follow(buggy);
  
}

void keyPressed(){
  // steer buggy
  switch(keyCode) {
    case UP:
      buggy.accelerate();
      break;
    case DOWN:
      buggy.brake();
      break;
    case RIGHT:
      buggy.steerRight();
      break;
    case LEFT:
      buggy.steerLeft();
      break;
  }
  // debugging
  switch(key) {
    case 'b':
      showBounds = !showBounds;
      break;
    case 'c':
      showContactRadius = !showContactRadius;
      break;
  }
}

void keyReleased(){
  switch(keyCode){
    case UP:
    case DOWN:
      buggy.coast();
      break;
    case RIGHT:
      buggy.steerNeutral();
      break;
  }
}

public void update(float deltaTime) {
  
  // update all object positions
  
  buggy.update(deltaTime);
  
  for (int i = 0; i < miners.size(); i++) {
    ((GameObject)miners.get(i)).update(deltaTime);
  } 
  
  for (int i = 0; i < blocks.size(); i++) {
    ((GameObject)blocks.get(i)).update(deltaTime);
  } 
  
  for (int i = 0; i < outposts.size(); i++) {
    ((GameObject)outposts.get(i)).update(deltaTime);
  } 
  
  for (int i = 0; i < bases.size(); i++) {
    ((GameObject)bases.get(i)).update(deltaTime);
  } 
  
  gamecam.update(deltaTime);
  radio.update(deltaTime);
  
}

public void draw() {
  
  // if game over reset
  if (gameOver) {
    return;
  }

  // get timing
  long nextMillis = millis();
  long deltaMillis = nextMillis - lastMillis;
  float deltaTime = lastMillis > 0 ? (float) deltaMillis / 1000 : 0;
  lastMillis = nextMillis;
  
  // run sim
  update(deltaTime);
  
  // collide buggy with blocks
  
  for (final Iterator<Actor> it = blocks.iterator(); it.hasNext(); ) {
    final Actor block = it.next();
    if (block.isInContactRadius(buggy)) {
      buggy.collide(block);
      block.collide(buggy);
      it.remove();
    } 
  }
 
  // draw
  
  background(0);

  gamecam.view();
  
   // draw moon on its own
  GL2 gl = pgl.beginPGL().gl.getGL2();

  loadMatrix(gl);
  moon.draw(gl);

  // draw the rest of the actors

  lights();

  for (int i = 0; i < bases.size(); i++) {
    ((Actor)bases.get(i)).draw(gl);
  }
  
  for (int i = 0; i < blocks.size(); i++) {
    ((Actor)blocks.get(i)).draw(gl);
  } 

  for (int i = 0; i < outposts.size(); i++) {
    ((Actor)outposts.get(i)).draw(gl);
  }

  for (int i = 0; i < miners.size(); i++) {
    ((Actor)miners.get(i)).draw(gl);
  }


  buggy.draw(gl);
  
  radio.draw(gl);

  pgl.endPGL();

}

// Pick a point near the contact radius of the given actor
public PVector somewhereNextTo(Actor actor) {
  float dir = 45; //random(360);
  float dx = actor.contactRadius * cos(dir);
  float dz = actor.contactRadius * sin(dir);
  float y = moon.getAltitudeAt(dx, dz);
  return new PVector(actor.location.x + dx, y, actor.location.z + dz);
}

void loadMatrix(GL2 gl) {
  gl.glMatrixMode(GL2.GL_PROJECTION);
  projMatrix[0] = pgl.projection.m00;
  projMatrix[1] = pgl.projection.m10;
  projMatrix[2] = pgl.projection.m20;
  projMatrix[3] = pgl.projection.m30;
 
  projMatrix[4] = pgl.projection.m01;
  projMatrix[5] = pgl.projection.m11;
  projMatrix[6] = pgl.projection.m21;
  projMatrix[7] = pgl.projection.m31;
 
  projMatrix[8] = pgl.projection.m02;
  projMatrix[9] = pgl.projection.m12;
  projMatrix[10] = pgl.projection.m22;
  projMatrix[11] = pgl.projection.m32;
 
  projMatrix[12] = pgl.projection.m03;
  projMatrix[13] = pgl.projection.m13;
  projMatrix[14] = pgl.projection.m23;
  projMatrix[15] = pgl.projection.m33;
 
  gl.glLoadMatrixf(projMatrix, 0);
 
  gl.glMatrixMode(GL2.GL_MODELVIEW);
  mvMatrix[0] = pgl.modelview.m00;
  mvMatrix[1] = pgl.modelview.m10;
  mvMatrix[2] = pgl.modelview.m20;
  mvMatrix[3] = pgl.modelview.m30;
 
  mvMatrix[4] = pgl.modelview.m01;
  mvMatrix[5] = pgl.modelview.m11;
  mvMatrix[6] = pgl.modelview.m21;
  mvMatrix[7] = pgl.modelview.m31;
 
  mvMatrix[8] = pgl.modelview.m02;
  mvMatrix[9] = pgl.modelview.m12;
  mvMatrix[10] = pgl.modelview.m22;
  mvMatrix[11] = pgl.modelview.m32;
 
  mvMatrix[12] = pgl.modelview.m03;
  mvMatrix[13] = pgl.modelview.m13;
  mvMatrix[14] = pgl.modelview.m23;
  mvMatrix[15] = pgl.modelview.m33;
  gl.glLoadMatrixf(mvMatrix, 0);
  
}


