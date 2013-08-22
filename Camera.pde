class Camera extends GameObject {
  
  float eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ;
  Actor target = null;

  public void setup() {
     eyeX = 0;
     eyeY = 0;
     eyeZ = 0;
     centerX = 1;
     centerY = 0;
     centerZ = 1;
     upX = 0;
     upY = -1;
     upZ = 0;
  }
  
  public void update(float deltaTime) {
     if (null == target) return;
     centerX = target.location.x;
     centerY = target.location.y + target.bounds.y + 10;
     centerZ = target.location.z; 
     eyeX = centerX - (100 * cos(target.rot.y));
     eyeZ = centerZ - (100 * sin(target.rot.y));     
     eyeY = centerY + 10;
  }
  
  public void follow(Actor actor) {
     target = actor;
  }
  
  public void view() {
     camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
  }
  
}
