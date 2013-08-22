class Buggy extends Actor  {
 
 float steer = 0;
 float drive = 0;
 int moonbucks = 0;

 public void setup() {
   shape = loadShape("astro_ute.obj");  
   shape.rotateY(PI);
   shape.scale(0.2, 0.2, 0.2);
   shape.translate(-50, 17.5, 30);
   shape.setFill(color(128, 128, 255));
   bounds = new PVector(25, 12.5, 17.5);
   maxVelocity = 200;
 }
 
 public void accelerate() {
   drive = 2000;
 }
 
 public void brake() {
   drive = -1000;
 }

 public void coast() {
   drive = 0; 
 }

 public void steerRight() {
   steer = -PI;
 }

 public void steerLeft() {
   steer = PI;
 }

 public void steerNeutral() {
   steer = 0;
 }
  
 public void update(float deltaTime) {
   
    if (steer != 0) {
      rot.y = rot.y + steer * deltaTime;
    }
    
    if (drive != 0) {
      acceleration.x = drive * cos(rot.y);
      acceleration.z = drive * sin(rot.y);
    }
    
    super.update(deltaTime);
    
    drive *= .99;
    steer *= 0;
    
 }

 public void collide(Actor a) { 
   // always a block
   Block block = (Block) a;
   moonbucks += block.getVolume() / 1000;
   radio.clear();
   radio.addMessage("Got the cheese!", 5);
   radio.addMessage("You've got " + moonbucks + " moonbucks", 5);
 }

}
