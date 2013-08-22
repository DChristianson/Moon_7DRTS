class Miner extends Actor {

  PVector miningPlace;
  float miningRadius;
  
  Stack waypoints;
  boolean digging;
  float dug = 0;
  float capacity = 1000;
  float efficiency = .1f;
  
  public void setup() {
    shape = loadShape("cold_planer.obj");
    shape.scale(4, 4, 6);
    shape.translate(0, 10, 0);
    shape.setFill(color(255, 128, 128));
    bounds = new PVector(125, 60, 60);
    contactRadius = 100;
    waypoints = new Stack();
    digging = false;
    maxVelocity = 25;
  }
  
  public void survey(PVector target, float radius, PVector topLeft, PVector bottomRight) {
    topLeft.x = target.x - radius;
    topLeft.z = target.z - radius;
    bottomRight.x = target.x + radius;
    bottomRight.z = target.z + radius;
  }
  
  public void mine(PVector target, float radius) {
    miningPlace = target;
    miningRadius = radius;
    PVector topLeft = new PVector();
    PVector bottomRight = new PVector();
    survey(target, radius, topLeft, bottomRight);
    while (topLeft.x <= bottomRight.x) {
      PVector w1 = topLeft;
      w1.y = moon.getAltitudeAt(w1.x, w1.z);
      waypoints.add(w1);
      PVector w2 = new PVector(w1.x, w1.y, bottomRight.z);
      w2.y = moon.getAltitudeAt(w2.x, w2.z);
      waypoints.add(w2);
      PVector w3 = new PVector(w2.x + bounds.z, w2.y, w2.z);
      w3.y = moon.getAltitudeAt(w3.x, w3.z);
      waypoints.add(w3);
      PVector w4 = new PVector(w3.x, w3.y, w1.z);
      w4.y = moon.getAltitudeAt(w4.x, w4.z);
      waypoints.add(w4);
      topLeft = new PVector(w4.x + bounds.z, w4.y, w4.z);
    }
  }

  public PVector nextWaypoint() {
    while (!waypoints.isEmpty()) { 
      PVector waypoint = (PVector) waypoints.peek(); 
      if (location.dist(waypoint) > bounds.x) {
        return waypoint;
      }
      digging = true;
      waypoints.pop();

    }
    digging = false;
    
    if (null == miningPlace) {
      return null;
    }
    
    // replan
    mine(miningPlace, miningRadius);
    return nextWaypoint();
    
  }

  public void draw(GL2 gl) {
    super.draw(gl);
   
    if (showBounds) {
      stroke(color(0, 255, 0));
      PVector last = null;
      for (final PVector waypoint : (List<PVector>) waypoints) {
        if (null != last) {
          line(last.x, last.y, last.z, waypoint.x, waypoint.y, waypoint.z);
        }
        last = waypoint;
      }
      if (null != last) {
        line(last.x, last.y, last.z, location.x, location.y, location.z);
      }
    } 
  }

  public void update(float deltaTime) {
    
    PVector waypoint = nextWaypoint();
    if (null != waypoint) {
      PVector heading = PVector.sub(waypoint, location);
      heading.y = 0;
      heading.normalize();
      heading.mult(500);
      float a = ((heading.z > 0) ? -1 : 1) * acos(heading.x / heading.mag());
      rot.y = rot.y + (a - rot.y) * deltaTime;
      acceleration.x = heading.x;
      acceleration.z = heading.z;
    }   

    if (digging) {
      PVector digVector = new PVector(0, bounds.z / 2);
      digVector.rotate(-rot.y);
      PVector digPoint = new PVector(location.x - digVector.x, location.z - digVector.y);
      digVector.normalize();
      digVector.mult(moon.scale);
      float digDepth = location.y - 5;
      for (int i = 0; i < (int)(bounds.z / moon.scale); i++) {
        dug += moon.digAt(digPoint.x, digPoint.y, digDepth) * efficiency;
        digPoint.add(digVector);
      }
      
      while (dug > capacity) {
        dug -= capacity;
        Block block = new Block();
        block.setup();
        block.place(location);
        blocks.add(block);
      }
    }
    
    
    super.update(deltaTime);
        
 }

}

