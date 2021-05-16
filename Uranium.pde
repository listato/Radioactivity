float energy = 0;
float[] energyLog = new float[1440];
float depletedUranium = 0;

int uraniumAmount = 50000;
float[][] uraniumPos = new float[uraniumAmount][2];
float[] uraniumState = new float[uraniumAmount];

int rodAmount = 0;
float[][] rodPos = new float[rodAmount][2];

int neutronAmount = 0;
float[] neutronPosX = new float[neutronAmount];
float[] neutronPosY = new float[neutronAmount];
float[] neutronVel = new float[neutronAmount];
float[] neutronAngle = new float[neutronAmount];
float neutronSpeed = 0.8;

int uraniumRadius = 10;
int neutronRadius = 2;



//Make one real atom bomb and one with virtually no decay
//Also try different u amounts with no r (critical mass)


void setup(){
  size(3840,2160);
  //fullScreen();
  
  for(int i=0; i<uraniumAmount; i++){
    uraniumPos[i][0] = random(width*0.1, 0.9*width);
    uraniumPos[i][1] = random(height*0.1, 0.9*height);
    uraniumState[i] = 1;
  }
  for(int i=0; i<rodAmount; i++){
    rodPos[i][0] = random(width*0.1, 0.9*width);
    rodPos[i][1] = random(height*0.1, 0.9*height);
  }
  
  /*int starter = round(random(uraniumAmount));
  uraniumState[starter] = 0;
  for(int i=0; i<3; i++){
    addNeutron(uraniumPos[starter][0], uraniumPos[starter][1]);
  }*/
}







void draw(){
  background(50);
  
  wiggleUranium();
  moveNeutrons();
  print(energy, "\n");
  if(energy < 1){
    checkCollisions();
    decayUranium();
  }
  
  drawNeutrons();
  drawUranium();
  drawRods();
  
  drawGraph();
  
  saveFrame("output/4k/u50000r0_5/frame####.png");
  if(frameCount == 1440){
    exit();
  }
}










void wiggleUranium(){
  float wiggleSpeed = 1;
  for(int i=0; i<uraniumAmount; i++){
    uraniumPos[i][0] += random(-wiggleSpeed,wiggleSpeed);
    uraniumPos[i][1] += random(-wiggleSpeed,wiggleSpeed);
    
    uraniumPos[i][0] = (uraniumPos[i][0]+width)%width;
    uraniumPos[i][1] = (uraniumPos[i][1]+height)%height;
    
    uraniumPos[i][0] = max(min(uraniumPos[i][0], 0.9*width), 0.1*width);
    uraniumPos[i][1] = max(min(uraniumPos[i][1], 0.9*height),0.1*height);
  }
}



void moveNeutrons(){
  for(int i=0; i<neutronAmount; i++){
    neutronPosX[i] += cos(neutronAngle[i])*neutronVel[i];
    neutronPosY[i] += sin(neutronAngle[i])*neutronVel[i];
  }
  
  
  for(int i=0; i<neutronAmount; i++){
    if(neutronPosX[i] > width || neutronPosX[i] < 0 || neutronPosY[i] > height || neutronPosY[i] < 0){
      deleteNeutron(i);
    }
  }
}



void checkCollisions(){
  for(int n=0; n<neutronAmount; n++){
    for(int r=0; r<rodAmount; r++){
      if(abs(neutronPosX[n]-rodPos[r][0]) < uraniumRadius-neutronRadius && abs(neutronPosY[n]-rodPos[r][1]) < uraniumRadius-neutronRadius){
        deleteNeutron(n);
        break;
      }
    }
  }
  for(int u=0; u<uraniumAmount; u++){
    if(uraniumState[u] == 1){
      for(int n=0; n<neutronAmount; n++){
        if(abs(neutronPosX[n]-uraniumPos[u][0]) < uraniumRadius-neutronRadius && abs(neutronPosY[n]-uraniumPos[u][1]) < uraniumRadius-neutronRadius){
          uraniumState[u] = 0;
          deleteNeutron(n);
          for(int i=0; i<3; i++){
            addNeutron(uraniumPos[u][0], uraniumPos[u][1]);
          }
          depletedUranium += 1;
          energy = depletedUranium/float(uraniumAmount);
          break;
        }
      }
    }
  }
}



void decayUranium(){
  for(int u=0; u<uraniumAmount; u++){
    if(random(1000) < 0.1 && uraniumState[u] == 1){
      uraniumState[u] = 0;
      for(int i=0; i<3; i++){
        addNeutron(uraniumPos[u][0], uraniumPos[u][1]);
      }
      depletedUranium += 1;
      energy = depletedUranium/float(uraniumAmount);
    }
  }
}











void drawGraph(){
  stroke(255);
  fill(255);
  if(frameCount<energyLog.length){
    energyLog[frameCount-1] = energy;
    //print(energy, "\n");
  }
  for(int i=1; i<min(frameCount-1, energyLog.length)-1; i++){
    line((i-1)*float(width)/float(energyLog.length), height-height*energyLog[i-1]-1, (i)*float(width)/float(energyLog.length), height-height*energyLog[i]-1);
  }
}




void drawNeutrons(){
  noStroke();
  fill(120);
  for(int i=0; i<neutronAmount; i++){
    ellipse(neutronPosX[i], neutronPosY[i], neutronRadius, neutronRadius);
  }
}

void drawUranium(){
  noStroke();
  for(int i=0; i<uraniumAmount; i++){
    if(uraniumState[i] == 1){
      fill(0,230,40);
    }
    else{
      fill(100,20,20);
    }
    ellipse(uraniumPos[i][0], uraniumPos[i][1], uraniumRadius, uraniumRadius);
  }
}



void drawRods(){
  noStroke();
  fill(0);
  for(int i=0; i<rodAmount; i++){
    ellipse(rodPos[i][0], rodPos[i][1], uraniumRadius, uraniumRadius);
  }
}



















void addNeutron(float x, float y){
  neutronPosX = append(neutronPosX, x);
  neutronPosY = append(neutronPosY, y);
  neutronVel = append(neutronVel, random(0.9*neutronSpeed,1.1*neutronSpeed));
  neutronAngle = append(neutronAngle, random(2*PI));
  neutronAmount += 1;
}


void deleteNeutron(int position){
  neutronPosX[position] = neutronPosX[neutronPosX.length-1];
  neutronPosY[position] = neutronPosY[neutronPosY.length-1];
  neutronVel[position] = neutronVel[neutronPosX.length-1];
  neutronAngle[position] = neutronAngle[neutronPosY.length-1];
  
  neutronPosX = shorten(neutronPosX);
  neutronPosY = shorten(neutronPosY);
  neutronVel = shorten(neutronVel);
  neutronAngle = shorten(neutronAngle);
  
  neutronAmount -= 1;
}
