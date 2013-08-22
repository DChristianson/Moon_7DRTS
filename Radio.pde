
class Message {
  
  String text;
  float timeLeft;
  
  public Message(String text, float displayTime) {
    this.text = text;
    this.timeLeft = displayTime;
  }
  
  void decrement(float deltaTime) {
    timeLeft -= deltaTime; 
  }
  
  boolean isExpired() {
    return timeLeft <= 0; 
  }
  
}

class Radio extends GameObject {

  Message message = null;
  Queue<Message> messages;
  boolean consoleOnly = false;
  
  public void setup() {
    messages = new LinkedList<Message>();
    addMessage("I Dig the Moon", 5);
    addMessage("Use arrow keys to navigate", 5);
    addMessage("Pick up moonbricks from the surface miner for moonbucks", 5);
    addMessage("Enjoy your life on the Moon!", 5);
  }
 
  public void addMessage(String text, float displayTime) {
    messages.add(new Message(text, displayTime));
  }
  
  public void clear() {
    message = null;
    messages.clear();  
  }
  
  public void update(float deltaTime) {
    if (null != message) {
      message.decrement(deltaTime);
      if (message.isExpired()) {
        message = null;
      } 
    } else {
      message = messages.poll();
      if (null != message) {
        println(message.text);  
      }
    }
    
  }
  
  public void draw(GL2 gl) {
    if (null != message && !consoleOnly) {
      fill(255, 255, 255);
      translate(buggy.location.x, buggy.location.y + 50, buggy.location.z);
      rotateY(-(buggy.rot.y - PI / 2));
      rotateX(PI);
      textAlign(CENTER);
      scale(0.5);
      text(message.text, 0, 0, 0); 
    }
  }

}
