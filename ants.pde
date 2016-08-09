Nest nest;

float nestX;
float nestY;

int MAXSUGAR = 20;
Sugar[] sugar = new Sugar[MAXSUGAR];

int MAXPHELOMONE = 10000;
Phelomone[] phelomone = new Phelomone[MAXPHELOMONE];
int phelomoneNum = 0;

void setup() {
  frameRate(24);
  size(640, 640);
  nestX = float(width / 2);
  nestY = float(height / 2);
  nest = new Nest(nestX, nestY, 0.1);
  
  for (int i = 0; i < MAXSUGAR; i++) {
    sugar[i] = new Sugar(0, 0, 0);
  }
  
  for (int i = 0; i < MAXPHELOMONE; i++) {
    phelomone[i] = new Phelomone(0, 0, 0);
  }
  
  for (int i = 0; i < 5; i++) {
    makeSugar();
  }
  
}

void draw() {
  background(255, 204, 0);
  
  if (random(1000) < 3){
    makeSugar();
  }

  for (int i = 0; i < MAXSUGAR; i++) {
    sugar[i].update();
  }
    
  nest.update();
  
}

boolean overUnder(){
  return random(0, 2) > 1;
}

void makeSugar() {
    
    for (int i = 0; i < MAXSUGAR; i++) {
      if(sugar[i].getAmount() <= 0){
        
        float x = random(0, width);
        float y =random(0, height);
        float d = getDistance(x, y, nestX, nestY);
        while(d > width * 0.45 || d < width * 0.15){
          x = random(0, width);
          y = random(0, height);
          d = getDistance(x, y, nestX, nestY);
        }
        
        int a = int(random(300, 1000));
        sugar[i] = new Sugar(x, y, a);
        return;
      }
    }
    
  

}

class Sugar{

  float posX, posY;
  int amount;
  
  Sugar(float x, float y, int a) {
    posX = x;
    posY = y;
    amount = a;
  }
  
  void update() {
    
    if(amount > 0){
      fill(200, 30, 30);
      stroke(230);
      ellipse(posX, posY, amount * 0.01, amount * 0.01);     
    }
    
  }
  
  public boolean isInsight(float x, float y, float range){
    if(amount <= 0){return false;}
     boolean r;
     r = (getDistance(x, y, posX, posY) < range);
     return r;
  }
  
  public void eat(){
    amount-=10;
    if(amount < 0){amount = 0;}
  }
  
  public float getX(){
    return posX; 
  }
  
  public float getY(){
    return posY; 
  }
  
  public float getAmount(){
    return amount; 
  }
  
}

class Nest {
  
  float posX, posY;
  float spawnRate;
  
  int antsNum = 0;
  int MAXANTS = 2000;
  
  Ant[] ant = new Ant[MAXANTS];
  
  Nest(float x, float y, float rate) {
    posX = x;
    posY = y;
    spawnRate = rate;
    
    for (int i = 0; i < MAXANTS; i++) {
      ant[i] = new Ant(0, 0, 0, 0 ,0 , 0, false);
    }
  
  }
  
  void update() {
    
    fill(20);
    stroke(10);
    ellipse(posX, posY, random(2) + 5, random(2) + 5); 
    
    if (random(0, 1) < spawnRate) {
      float rX = random(-1, 1);
      float rY = random(-1, 1);
      ant[antsNum] = new Ant(posX, posY, rX, rY, random(1, 3), int(random(100, 500)), true);
      antsNum ++;
      if (antsNum == MAXANTS){
        antsNum = 0;
      }
    }
    
    for (int i = 0; i < MAXANTS; i++) {
      ant[i].update();      
    }
    
  } 
  
}

float getDistance(float currentX,float currentY, float destX, float destY){
  float r = sqrt(pow(destX - currentX, 2) + pow(destY - currentY, 2));
  return r;
}



class Ant { 
  float posX, posY, speed;
  float vectorX, vectorY;
  float destX, destY;
  int stamina;
  
  float sense = 30;
  
  int MODE_SEARCH = 0;
  int MODE_DEST = 1;
  int MODE_PHELOMONE = 2;
  
  int mode = MODE_SEARCH;
  
  float noiseScale = 0.02;
  
  boolean dropPhelomone = false;
  float phelomoneStrength = 1;
  
  float temptation = 0;
  
  boolean live = false;
  
  Ant(float x, float y, float vX, float vY, float sp, int st, boolean l) {
    posX = x;
    posY = y;
    vectorX = vX;
    vectorY = vY;
    speed = sp;
    stamina = st;
    live = l;
  }
  
  void update() {
    if(!live){return;}
    float speedX = 0, speedY = 0;
    float noiseX = 1;
    float noiseY = 1;

    if (mode == MODE_SEARCH){
      
      speedX = speed * (vectorX / (abs(vectorX) + abs(vectorY)));
      speedY = speed * (vectorY / (abs(vectorX) + abs(vectorY)));
      
      if(!detectSugar()){
        if(random(0, 1) > 0.7){        
          if(detectPhelomone()){
            mode = MODE_PHELOMONE;
          }
        }
      }
      
     } else if (mode == MODE_PHELOMONE){
      
      speedX = speed * getVectorX();
      speedY = speed * getVectorY();
      
      if(random(0, 1.2) > temptation){
        mode = MODE_SEARCH;
      }
      
     } else if (mode == MODE_DEST){
      
      speedX = speed * getVectorX();
      speedY = speed * getVectorY();
      
      if(dropPhelomone && phelomoneStrength > 0 && random(0, 1) > 0.1){
        drop();
      }
      
      if(getDistance(posX, posY, nestX, nestY) < 1 && stamina <= 0){
        live = false;
      }
       
    }
    
    noiseX = noise(speedX * noiseScale) * 2;
    noiseY = noise(speedY * noiseScale) * 2;
     
    float dX = posX + speedX * noiseX + random(-noiseX, noiseX) * 2;
    float dY = posY + speedY * noiseY  + random(-noiseY, noiseY) * 2;
    line(posX, posY, dX, dY); 
    posX = dX; 
    posY = dY;

    if(stamina > 0){
      stamina--;
    } else if(stamina <= 0){
      setTarget(nestX, nestY, 0);
    }
    
    noiseScale += 0.01;
    
  }
  
  void setTarget(float x, float y , float randomScale){
    
      mode = MODE_DEST;
      destX = x + random(-randomScale, randomScale);
      destY = y + random(-randomScale, randomScale);
    
  }
  
  float getVectorX(){
    float dX = destX - posX;
    float dY = destY - posY;
    float r = dX / (abs(dX) + abs(dY));
    return r;
  }
  
  float getVectorY(){
    float dX = destX - posX;
    float dY = destY - posY;
    float r = dY / (abs(dX) + abs(dY));
    return r;
  }
  
  boolean detectSugar(){
    boolean r = false;
    
    for (int i = 0; i < MAXSUGAR; i++) {
      if(sugar[i].isInsight(posX, posY, sense)){
        setTarget(sugar[i].getX(), sugar[i].getY(), sugar[i].getAmount() * 0.005);
        dropPhelomone = true;
        sugar[i].eat();
        r = true;
      };
    }
    
    return r;
  }
  
  boolean detectPhelomone(){
    boolean r = false;
    float maxStr = 0;
    for (int i = 0; i < MAXPHELOMONE; i++) {
      if(phelomone[i].getStrength() > 0){
        if(phelomone[i].isInsight(posX, posY, sense)){
          float str = phelomone[i].getStrength();
          if(str > maxStr){
            maxStr = str;
            setTarget(phelomone[i].getX(), phelomone[i].getY(), 20);
            r = true;
          }
        }
      }
    }
    
    temptation = maxStr;
    
    return r;
  }
  
  void drop(){
    phelomone[phelomoneNum] = new Phelomone(posX, posY, phelomoneStrength);
    phelomoneStrength -= 0.001;
    phelomoneNum++;
    if(phelomoneNum == MAXPHELOMONE){
      phelomoneNum = 0;
    }
  }
  
} 

class Phelomone {
  
  float posX, posY;
  float strength;
  
  Phelomone(float x, float y, float s) {
    posX = x;
    posY = y;
    strength = s;
  }

  public float getX(){
    return posX; 
  }
  
  public float getY(){
    return posY; 
  }
  
  public float getStrength(){
    return strength; 
  }
  
  public boolean isInsight(float x, float y, float range){
     boolean r;
     r = (getDistance(x, y, posX, posY) < range);
     return r;
  }

  public void update(){
    if(strength <= 0){return;}
    strength -= 0.003;
  }
  
}