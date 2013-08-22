class Outpost extends Actor {
  
 public void setup() {
   shape = loadShape("astro_tower.obj");
   shape.scale(0.5, 0.5, 0.5);
   shape.translate(0, 0, 0);
   shape.setFill(color(200, 255, 200));
   bounds = new PVector(50, 25, 50);
   contactRadius = 100;
 }
 
}
