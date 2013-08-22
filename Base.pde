class Base extends Actor {

 public void setup() {
   shape = loadShape("astro_base.obj");
   shape.scale(0.5, 0.5, 0.5);
   shape.translate(-47, 6, 37);
   shape.setFill(color(200, 255, 200));
   bounds = new PVector(60, 25, 60);
   contactRadius = 100;
 }

}
