float boxMin = -500;
float boxMax = -boxMin;
float diag = sqrt(boxMin*boxMin+boxMax*boxMax)*2;

float turnspeed = 600;

float energy = 0;
float[] energyLog = new float[600];
float depletedUranium = 0;

int uraniumAmount = 50000;
float[][] uraniumPos = new float[uraniumAmount][3];
float[] uraniumState = new float[uraniumAmount];

int rodAmount = 50000;
float[][] rodPos = new float[rodAmount][3];

int neutronAmount = 0;
float[] neutronPosX = new float[neutronAmount];
float[] neutronPosY = new float[neutronAmount];
float[] neutronPosZ = new float[neutronAmount];
float[] neutronVel = new float[neutronAmount];
float[] neutronAngle1 = new float[neutronAmount];
float[] neutronAngle2 = new float[neutronAmount];
float neutronSpeed = 6;

int uraniumRadius = 10;
int neutronRadius = 2;



//Make one real atom bomb and one with virtually no decay
//Also try different u amounts with no r (critical mass)


void setup(){
  //size(1920,1080, P3D);
  fullScreen(P3D);
  
  for(int i=0; i<uraniumAmount; i++){
    uraniumPos[i][0] = random(boxMin, boxMax);
    uraniumPos[i][1] = random(boxMin, boxMax);
    uraniumPos[i][2] = random(boxMin, boxMax);
    uraniumState[i] = 1;
  }
  for(int i=0; i<rodAmount; i++){
    rodPos[i][0] = random(boxMin, boxMax);
    rodPos[i][1] = random(boxMin, boxMax);
    rodPos[i][2] = random(boxMin, boxMax);
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
  //print(energy, "\n");
  if(energy < 1){
    checkCollisions();
    decayUranium();
  }
  
  drawNeutrons();
  drawUranium();
  drawRods();
  showBox();
  showBottom();
  
  updateEnergy();
  //drawGraph();
  
  float centre = (boxMax+boxMin)/2;
  camera(sin(float(frameCount)/turnspeed)*diag, centre, cos(float(frameCount)/turnspeed)*diag, centre, centre, centre, 0.0, 1.0, 0.0);
  
  saveFrame("output3D/u50000r50000/frame####.png");
  if(frameCount == 600){
    String[] energyLogString = new String[energyLog.length];
    for(int i=0; i<energyLog.length; i++){
      energyLogString[i] = str(energyLog[i]);
    }
    saveStrings("output3D/u50000r50000/energy.txt", energyLogString);
    exit();
  }
}










void wiggleUranium(){
  float wiggleSpeed = 1;
  for(int i=0; i<uraniumAmount; i++){
    uraniumPos[i][0] += random(-wiggleSpeed,wiggleSpeed);
    uraniumPos[i][1] += random(-wiggleSpeed,wiggleSpeed);
    uraniumPos[i][2] += random(-wiggleSpeed,wiggleSpeed);
    
    uraniumPos[i][0] = max(min(uraniumPos[i][0], boxMax), boxMin);
    uraniumPos[i][1] = max(min(uraniumPos[i][1], boxMax), boxMin);
    uraniumPos[i][2] = max(min(uraniumPos[i][2], boxMax), boxMin);
  }
}



void moveNeutrons(){
  for(int i=0; i<neutronAmount; i++){
    neutronPosX[i] += sin(neutronAngle1[i])*cos(neutronAngle2[i])*neutronVel[i];
    neutronPosY[i] += sin(neutronAngle1[i])*sin(neutronAngle2[i])*neutronVel[i];
    neutronPosZ[i] += cos(neutronAngle1[i])*neutronVel[i];
  }
  
  
  for(int i=0; i<neutronAmount; i++){
    if(neutronPosX[i] > boxMax || neutronPosX[i] < boxMin || neutronPosY[i] > boxMax || neutronPosY[i] < boxMin || neutronPosZ[i] > boxMax || neutronPosZ[i] < boxMin){
      deleteNeutron(i);
    }
  }
}



void checkCollisions(){
  for(int n=0; n<neutronAmount; n++){
    for(int r=0; r<rodAmount; r++){
      if(abs(neutronPosX[n]-rodPos[r][0]) < uraniumRadius-neutronRadius && abs(neutronPosY[n]-rodPos[r][1]) < uraniumRadius-neutronRadius && abs(neutronPosZ[n]-rodPos[r][2]) < uraniumRadius-neutronRadius){
        deleteNeutron(n);
        break;
      }
    }
  }
  if(neutronAmount > 0){
    for(int u=0; u<uraniumAmount; u++){
      if(uraniumState[u] == 1){
        for(int n=0; n<neutronAmount; n++){
          if(abs(neutronPosX[n]-uraniumPos[u][0]) < uraniumRadius-neutronRadius && abs(neutronPosY[n]-uraniumPos[u][1]) < uraniumRadius-neutronRadius && abs(neutronPosZ[n]-uraniumPos[u][2]) < uraniumRadius-neutronRadius){
            uraniumState[u] = 0;
            deleteNeutron(n);
            for(int i=0; i<3; i++){
              addNeutron(uraniumPos[u][0], uraniumPos[u][1], uraniumPos[u][2]);
            }
            depletedUranium += 1;
            energy = depletedUranium/float(uraniumAmount);
            break;
          }
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
        addNeutron(uraniumPos[u][0], uraniumPos[u][1], uraniumPos[u][2]);
      }
      depletedUranium += 1;
      energy = depletedUranium/float(uraniumAmount);
    }
  }
}










void updateEnergy(){
  if(frameCount<energyLog.length){
    energyLog[frameCount-1] = energy;
    //print(energy, "\n");
  }
}



void drawGraph(){
  strokeWeight(4);
  stroke(255);
  fill(255);
  for(int i=1; i<min(frameCount-1, energyLog.length)-1; i++){
    line((i-1)*float(width)/float(energyLog.length), height-height*energyLog[i-1]-1, (i)*float(width)/float(energyLog.length), height-height*energyLog[i]-1);
  }
}




void drawNeutrons(){
  noStroke();
  fill(120);
  for(int i=0; i<neutronAmount; i++){
    translate(neutronPosX[i], neutronPosY[i], neutronPosZ[i]);
    sphere(neutronRadius);
    translate(-neutronPosX[i], -neutronPosY[i], -neutronPosZ[i]);
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
    translate(uraniumPos[i][0], uraniumPos[i][1], uraniumPos[i][2]);
    sphere(uraniumRadius);
    translate(-uraniumPos[i][0], -uraniumPos[i][1], -uraniumPos[i][2]);
  }
}



void drawRods(){
  noStroke();
  fill(0);
  for(int i=0; i<rodAmount; i++){
    translate(rodPos[i][0], rodPos[i][1], rodPos[i][2]);
    sphere(uraniumRadius);
    translate(-rodPos[i][0], -rodPos[i][1], -rodPos[i][2]);
  }
}


void showBox(){
  stroke(0);
  strokeWeight(4);
  
  line(boxMin,boxMin,boxMin,  boxMax,boxMin,boxMin);
  line(boxMin,boxMin,boxMin,  boxMin,boxMax,boxMin);
  line(boxMin,boxMin,boxMin,  boxMin,boxMin,boxMax);
  
  line(boxMax,boxMin,boxMin,  boxMax,boxMax,boxMin);
  line(boxMax,boxMin,boxMin,  boxMax,boxMin,boxMax);
  
  line(boxMin,boxMax,boxMin,  boxMax,boxMax,boxMin);
  line(boxMin,boxMax,boxMin,  boxMin,boxMax,boxMax);
  
  line(boxMin,boxMin,boxMax,  boxMax,boxMin,boxMax);
  line(boxMin,boxMin,boxMax,  boxMin,boxMax,boxMax);
  
  line(boxMax,boxMax,boxMax,  boxMin,boxMax,boxMax);
  line(boxMax,boxMax,boxMax,  boxMax,boxMin,boxMax);
  line(boxMax,boxMax,boxMax,  boxMax,boxMax,boxMin);
}



void showBottom(){
  stroke(20);
  strokeWeight(2);
  float lineSpace = 200;
  for(float x = 5*(boxMin-boxMax); x <= 5*(boxMax-boxMin); x+=lineSpace){
    line(x, boxMax-boxMin, 5*(boxMin-boxMax),  x, boxMax-boxMin, 5*(boxMax-boxMin));
  }
  for(float z = 5*(boxMin-boxMax); z <= 5*(boxMax-boxMin); z+=lineSpace){
    line(5*(boxMin-boxMax), boxMax-boxMin, z,  5*(boxMax-boxMin), boxMax-boxMin, z);
  }

  /*translate(-5*(boxMax-boxMin),boxMax-boxMin,-5*(boxMax-boxMin));
  sphere(100);
  translate(5*(boxMax-boxMin),-boxMax+boxMin,5*(boxMax-boxMin));*/
  
  //line(-5*(boxMax-boxMin),boxMax-boxMin,-5*(boxMax-boxMin)-lineSpace,  -5*(boxMax-boxMin),boxMax-boxMin,-5*(boxMax-boxMin)+lineSpace);
  //line(-5*(boxMax-boxMin)-lineSpace,boxMax-boxMin,-5*(boxMax-boxMin),  -5*(boxMax-boxMin)-lineSpace,boxMax-boxMin,-5*(boxMax-boxMin));
}












void addNeutron(float x, float y, float z){
  neutronPosX = append(neutronPosX, x);
  neutronPosY = append(neutronPosY, y);
  neutronPosZ = append(neutronPosZ, z);
  neutronVel = append(neutronVel, random(0.9*neutronSpeed,1.1*neutronSpeed));
  neutronAngle1 = append(neutronAngle1, random(2*PI));
  neutronAngle2 = append(neutronAngle2, random(PI));
  neutronAmount += 1;
}


void deleteNeutron(int position){
  neutronPosX[position] = neutronPosX[neutronPosX.length-1];
  neutronPosY[position] = neutronPosY[neutronPosY.length-1];
  neutronPosZ[position] = neutronPosZ[neutronPosY.length-1];
  neutronVel[position] = neutronVel[neutronPosX.length-1];
  neutronAngle1[position] = neutronAngle2[neutronPosY.length-1];
  neutronAngle2[position] = neutronAngle2[neutronPosY.length-1];
  
  neutronPosX = shorten(neutronPosX);
  neutronPosY = shorten(neutronPosY);
  neutronPosZ = shorten(neutronPosZ);
  neutronVel = shorten(neutronVel);
  neutronAngle1 = shorten(neutronAngle1);
  neutronAngle2 = shorten(neutronAngle2);
  
  neutronAmount -= 1;
}
