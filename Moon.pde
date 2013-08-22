class Moon extends GameObject {
  
  int VERTEX_BUFFER = 0;
  int NORMAL_BUFFER = 1;
  int INDEX_BUFFER = 2;
  
  float scale = 5;
  PImage map;
  int[] buffers = new int[3];
  int nvertices;
  int nindices;

  FloatBuffer scratch;

  PVector center;
  PVector q1;
  PVector q2;
  PVector q3;
  PVector q4;
 
  public PVector getCenter() {
    return center;
  }

  public PVector getQ1() {
    return q1;
  }

  public PVector getQ2() {
    return q2;
  }

  public PVector getQ3() {
    return q3;
  }

  public PVector getQ4() {
    return q4;
  }
  
  public PVector getRandom() {
    int ix = (int) random(map.width / 2) + map.width / 4;
    int iz = (int) random(map.height / 2) + map.height / 4;
    float cx = ix * scale;
    float cz = iz * scale;
    return new PVector(cx, altitude(ix, iz), cz);
  }
  
  public float getAltitudeAt(float x, float z) {
    
    // bilinear interpolation of altitude
    
    float sx = x / scale;
    float sz = z / scale;
    int i = (int) sx;
    int j = (int) sz;
    float dx = sx - i;
    float dz = sz - j;
    
    float q11 = altitude(i, j);
    if ((dx + dz) < 0.01) return q11;
    
    float q21 = altitude(i + 1, j);
    float q12 = altitude(i, j + 1);
    float q22 = altitude(i + 1, j + 1);  
    float q = ((q11 * (1f - dx) * (1f - dz)) +
              (q21 * (dx) * (1f - dz)) + 
              (q12 * (1f - dx) * (dz)) + 
              (q22 * (dx) * (dz))); 
         
    return q;
    
  }

  public void normal(int i, int j, PVector up) {
    up.x = altitude(i - 1, j) - altitude(i + 1, j);
    up.z = altitude(i, j - 1) - altitude(i, j + 1);
    up.y = 2;
    up.normalize();
  }
  
  private float altitude(int i, int j) {
    float r1 = red(map.get(i, j));
    return constrain(r1, 0, 255);
  }

  private float digAt(float x, float z, float depth) {
    
    // modify heightmap and vertex buffer at given location
    
    int i = (int) (x / scale);
    int j = (int) (z / scale);
    float a = altitude(i, j);
    float dug = a - depth;
    if (dug < 0) return 0;
    
    int index = (i * map.height * 3) + j * 3 + 1;

    map.set(i, j, color(depth, depth, depth));

    scratch.clear();
    scratch.put(depth);
    scratch.rewind();
    
    GL2 gl = pgl.beginPGL().gl.getGL2();
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, buffers[VERTEX_BUFFER]);
    gl.glBufferSubData(GL2.GL_ARRAY_BUFFER, index * SIZEOF_FLOAT, SIZEOF_FLOAT, scratch);
    pgl.endPGL();
    
    return dug;
    
  }
 
  public void setup() {
    
    // get height map
    this.map = loadImage("moon.jpg");
    this.nvertices = map.width * map.height * 3;
    this.nindices = (((map.width - 1) * map.height) + map.width - 2) * 2;

    // allocate vertex buffers
    int vsize = nvertices * SIZEOF_FLOAT;
    FloatBuffer vbo = ByteBuffer.allocateDirect(vsize).order(ByteOrder.nativeOrder()).asFloatBuffer();
    FloatBuffer nbo = ByteBuffer.allocateDirect(vsize).order(ByteOrder.nativeOrder()).asFloatBuffer();
    scratch = ByteBuffer.allocateDirect(SIZEOF_FLOAT).order(ByteOrder.nativeOrder()).asFloatBuffer();
    
    PVector up = new PVector(0, 0, 0);
    for (int i = 0; i < (map.width); i++) {
      for (int j = 0; j < (map.height); j++) {
        
        vbo.put(scale * i);
        vbo.put(altitude(i, j));
        vbo.put(scale * j);

        normal(i, j, up);
        nbo.put(up.x);
        nbo.put(up.y);
        nbo.put(up.z);
        
      }
    }
    vbo.rewind();
    nbo.rewind();

    // allocate index buffer
    int isize = nindices * SIZEOF_INT;
    IntBuffer ibo = ByteBuffer.allocateDirect(isize).order(ByteOrder.nativeOrder()).asIntBuffer();
    int nexti = map.height;
    int idx = -1;
    for (int i = 0; i < (map.width - 1); i++) {
      if (i > 0) {
        ibo.put(idx + nexti);
        ibo.put(idx + 1);
      }
      for (int j = 0; j < (map.height); j++) {
        idx++;
        ibo.put(idx);
        ibo.put(idx + nexti);
      }
    }
    ibo.rewind();
    
    // bind vbos
    GL2 gl = pgl.beginPGL().gl.getGL2();
    gl.glGenBuffers(buffers.length, buffers, 0);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, buffers[VERTEX_BUFFER]);
    gl.glBufferData(GL2.GL_ARRAY_BUFFER, vsize, vbo, GL2.GL_DYNAMIC_DRAW);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, 0);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, buffers[NORMAL_BUFFER]);
    gl.glBufferData(GL2.GL_ARRAY_BUFFER, vsize, nbo, GL2.GL_STATIC_DRAW);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, 0);
    gl.glBindBuffer(GL2.GL_ELEMENT_ARRAY_BUFFER, buffers[INDEX_BUFFER]);
    gl.glBufferData(GL2.GL_ELEMENT_ARRAY_BUFFER, isize, ibo, GL2.GL_STATIC_DRAW);
    gl.glBindBuffer(GL2.GL_ELEMENT_ARRAY_BUFFER, 0);
    pgl.endPGL();

    // calc center
    int ix = map.width / 2;
    int iz = map.height / 2;
    float cx = ix * scale;
    float cz = iz * scale;
    this.center = new PVector(cx, altitude(ix, iz), cz);
    this.q1 = new PVector(cx / 2, altitude(ix / 2, iz / 2), cz / 2);
    this.q2 = new PVector(cx + cx / 2, altitude(ix + ix / 2, iz / 2), cz / 2);
    this.q3 = new PVector(cx / 2, altitude(ix / 2, iz + iz / 2), cz + cz / 2);
    this.q4 = new PVector(cx + cx / 2, altitude(ix + ix / 2, iz + iz / 2), cz + cz / 2);
    
  }
  
  public void draw(GL2 gl) {
    
    // draw terrain using vertex buffers
    
    gl.glDisable(GL2.GL_TEXTURE_2D);
    gl.glEnableClientState(GL2.GL_INDEX_ARRAY);
    gl.glEnableClientState(GL2.GL_VERTEX_ARRAY);
    gl.glEnableClientState(GL2.GL_NORMAL_ARRAY);
    
    float[] light_ambient = { 0.1f, 0.1f, 0.1f, 1.0f };
    float[] light_diffuse = { 0.75f, 0.75f, 0.75f, 1.0f };
    float[] light_specular = { 0.1f, 0.1f, 0.1f, 1.0f };
    float[] light_position = { 1.0f, 1.0f, 1.0f, 0.0f };
    
    gl.glShadeModel(GL2.GL_SMOOTH);

    gl.glLightfv(GL2.GL_LIGHT1, GL2.GL_AMBIENT, light_ambient, 0);
    gl.glLightfv(GL2.GL_LIGHT1, GL2.GL_DIFFUSE, light_diffuse, 0);
    gl.glLightfv(GL2.GL_LIGHT1, GL2.GL_SPECULAR, light_specular, 0);
    gl.glLightfv(GL2.GL_LIGHT1, GL2.GL_POSITION, light_position, 0); 
    gl.glEnable(GL2.GL_LIGHT1);
    gl.glEnable(GL2.GL_LIGHTING);
    gl.glEnable(GL2.GL_COLOR_MATERIAL);
    gl.glColorMaterial(GL2.GL_FRONT_AND_BACK, GL2.GL_AMBIENT_AND_DIFFUSE);
     
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, buffers[VERTEX_BUFFER]);
    gl.glVertexPointer(3, GL2.GL_FLOAT, 0, 0);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, buffers[NORMAL_BUFFER]);
    gl.glNormalPointer(GL2.GL_FLOAT, 0, 0);
    gl.glBindBuffer(GL2.GL_ELEMENT_ARRAY_BUFFER, buffers[INDEX_BUFFER]);  
    gl.glDrawElements(GL2.GL_TRIANGLE_STRIP, nindices, GL2.GL_UNSIGNED_INT, 0);

    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, 0);
    gl.glBindBuffer(GL2.GL_ELEMENT_ARRAY_BUFFER, 0);
    gl.glDisableClientState(GL2.GL_INDEX_ARRAY);
    gl.glDisableClientState(GL2.GL_VERTEX_ARRAY);
    gl.glDisableClientState(GL2.GL_NORMAL_ARRAY);

  } 

}
