class Block extends Actor {

 public void setup() {
   shape = createShape(BOX, 30, 15, 30);
   shape.setFill(color(128, 255, 128));
   shape.setStroke(false);
   bounds = new PVector(30, 15, 30);
   contactRadius = 60;
 }
 
}
