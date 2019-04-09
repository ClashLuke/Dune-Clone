int h = 1080;
int w = 1920;
int hillWidth = 500;

void settings() {
  size (w, h);
}

void setup() {
  frameRate(30);
  background (0);
  stroke(1);
  strokeWeight(1);
}

int hillCount = w/hillWidth; 
int hiHeight = h-h/4;
int loHeight = h-h/10;
int precalc = 2*hillCount;
color ground = color(1);
int[][] hillHi = new int[precalc*2+2][2];
int[][] hillLo = new int[precalc*2+2][2];
int playerX = 100;
int playerY = 100;
int velocityX = 0;
int velocityY = 0;
int accelerationY = 1;
int direction = 1;

int newHiHillX(int hillNumber) {
  return(hillLo[hillNumber-1][0] + int(hillWidth * sin(random(HALF_PI/6, HALF_PI/2))));
}
int newHiHillY() {
  return(hiHeight);
}
int newLoHillX(int hillNumber) {
  return(hillHi[hillNumber][0] + int(hillWidth * sin(random(HALF_PI/3, HALF_PI))));
}
int newLoHillY() {
  return(loHeight*int(2*sin(random(HALF_PI/3, HALF_PI))));
}
void newHiHill(int hillNumber) {
  hillHi[hillNumber][0] = newHiHillX(hillNumber);
  hillHi[hillNumber][1] = newHiHillY();
}
void newLoHill(int hillNumber) {
  hillLo[hillNumber][0] = newLoHillX(hillNumber);
  hillLo[hillNumber][1] = newLoHillY();
}

void newHill(int hillNumber) {
  newHiHill(hillNumber);
  newLoHill(hillNumber);
}

void genHills(int start, int count) {
  for (int i=start; i<count+start; i++) {
    newHill(i);
  }
}

void init() {
  genHills(1, precalc);
}

void drawHill(int hillNumber) {
  // P(t) = P0*t^2 + P1*2*t*(1-t) + P2*(1-t)^2
  fill(255);
  bezier(hillHi[hillNumber][0], hillHi[hillNumber][1], 
    hillLo[hillNumber][0], hillLo[hillNumber][1], 
    hillLo[hillNumber][0], hillLo[hillNumber][1], 
    hillHi[hillNumber+1][0], hillHi[hillNumber+1][1]);
  fill(0);
}

void drawMap() {
  for (int i=0; i<hillCount+2; i++) {
    drawHill(i);
  }
}
void genLastHill() {
  newHill(precalc+1);
}

void moveArray(int num) {
  for (int j=0; j<num; j++) {
    for (int i=1; i<precalc+1; i++) {
      hillHi[i-1][0] = hillHi[i][0];
      hillHi[i-1][1] = hillHi[i][1];
      hillLo[i-1][0] = hillLo[i][0];
      hillLo[i-1][1] = hillLo[i][1];
    }
  }
}

void move(int pixel) {
  for (int i=0; i<precalc; i++) {
    hillHi[i][0] -= pixel;
    hillLo[i][0] -= pixel;
  }
  if (hillLo[1][0] < 0) {
    moveArray(1);
    newHill(precalc-1);
  }
}

int checkCollision() {
  loadPixels();
  for (int i=playerY; i<playerY+15; i++) 
    for (int j=-15; j<16; j++) {
      try {
        if (pixels[i*w+playerX+j] == ground) playerY++;
      } 
      catch (Exception e) { 
        ;
      }
    }
  for (int i=playerY; i<playerY+19; i++) {
    if (pixels[i*w+playerX+20*direction] == ground) {
      try {
        return 0;
      }
      catch(Exception e) {
        ;
      }
    }
    if (pixels[i*w+playerX-20*direction] == ground) {
      try {
        return -1;
      }
      catch(Exception e) {
        ;
      }
    }
  }
  return 1;
}

void gravity() {
  int check = checkCollision();
  if (check==0)  velocityY = 2;
  if (check==1)  velocityY += accelerationY;
  if (check==-1) {
    velocityX += velocityY/hillWidth; 
    velocityY -= 2;
  }
  playerY += velocityY;
  playerX += velocityX;
  fill(0);
  if (playerY > loHeight) playerY = hiHeight;
  ellipse(playerX, playerY, 20, 20);
  noFill();
}


int rounds = 0;
void draw() {
  background(1);
  fill(255);
  rect(0, 0, w, hiHeight);
  fill(0);
  if (rounds==0) {
    init();
  } else {
    move(10);
    drawMap();
    if (rounds > 100)
      gravity();
  }
  rounds++;
}
