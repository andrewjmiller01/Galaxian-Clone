/*
*/
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;
import ddf.minim.*;

// Game Configuration Varaibles
int monsterCols = 10;
int monsterRows = 5;
long mmCounter = 0;
int mmStep = 1;
int round = 0;
double upRadians = 4.71238898; //Straight up on the screen
double downRadians = 1.57079632; //Straight down on the screen
double fmRightAngle = 0.3490;
double fmLeftAngle = 2.79253;
double fmSpeed = 150;
float chargeUpHeight = 0;
boolean charged = false;

boolean quit = false;
boolean retry = true;

PImage img;
int mGrowl = 0;

// Game Operational Variables
Sprite ship;
Sprite rocket;
Sprite monsters[][] = new Sprite[monsterCols][monsterRows];
Sprite flyingMonster;
Sprite flyingMonster2;
Sprite flyingMonster3;
Sprite explosion;
Sprite gameOverSprite;
Sprite monsterRocket;
Sprite monsterRocket2;
Sprite monsterRocket3;
Sprite heart;
Sprite bombReloader;
boolean gameOver = false;
int difficulty = 100;
int health = 33;
int powerupSpawnTime;
final int SPAWN_TIME = 30000; //Every 30 seconds
final int BOMBER_DURATION = 3000; //3 seconds
int grabbedBombPowerupTime;

//Keeping track of achievements
int numOfAchievements = 0;

int score = 0;
int killCount = 0;
int shotCount = 0;
int chargedShotCount = 0;
int fallingMonsterKillCount = 0;

boolean killCount5 = false;
boolean killCount25 = false;
boolean killCount100 = false;
boolean killCount500 = false;

boolean shotCount10 = false;
boolean shotCount100 = false;
boolean shotCount500 = false;
boolean shotCount1000 = false;

boolean chargedShotCount1 = false;
boolean chargedShotCount5 = false;
boolean chargedShotCount20 = false;
boolean chargedShotCount50 = false;

boolean fallingMonsterKillCount1 = false;
boolean fallingMonsterKillCount10 = false;
boolean fallingMonsterKillCount30 = false;
boolean fallingMonsterKillCount75 = false;

boolean score100 = false;
boolean score500 = false;
boolean score2500 = false;
boolean score10000 = false;


//Variables for displaying achievements
int startTime;
final int DISPLAY_DURATION = 2500; //2.5 seconds
String title = "";
String subtitle = "";

KeyboardController kbController = new KeyboardController(this);
SoundPlayer soundPlayer;
StopWatch stopWatch = new StopWatch();

Minim minimplay;
AudioSample soundPlayer1;
AudioSample backgroundMusic;
AudioSample monsterGrowl;
AudioSample alienCry;

void setup() 
{
  registerMethod("pre", this); //Create a method that will run before every game loop
  size(775, 500); //Set size of window
  frameRate(50);
  buildSprites(); //Create all the sprites that are needed for the game
  resetMonsters(); //Puts all monsters back once they've been killed
  soundPlayer = new SoundPlayer(this);
  
  minimplay = new Minim(this); 

  soundPlayer1 = minimplay.loadSample("explode.wav",1024);
  
  backgroundMusic = minimplay.loadSample("backgroundMusic1.mp3",1024);
  
  monsterGrowl = minimplay.loadSample("monsterGrowl.mp3",1024);
  
  alienCry = minimplay.loadSample("alienCry1.mp3",1024);
  
  img = loadImage("spaceBackground1.png");
  
  backgroundMusic.trigger();
}

void buildSprites()
{
  // The Ship
  ship = buildShip();

  // The Rocket
  rocket = buildRocket();

  // The Grid Monsters 
  buildMonsterGrid();
  
  //Ship explosion
  explosion = new Sprite(this, "explosion_strip16.png", 17, 1, 90);
  explosion.setScale(1);
  
  //Game over screen
  gameOverSprite = new Sprite(this, "gameOver.png", 100);
  gameOverSprite.setDead(true);
  
  //Monster Rocket 1
  monsterRocket = new Sprite(this, "monsterRocket.png", 10);
  monsterRocket.setDead(true);
  monsterRocket.setScale(0.05);
  
  //Monster Rocket 2
  monsterRocket2 = new Sprite(this, "monsterRocket.png", 10);
  monsterRocket2.setDead(true);
  monsterRocket2.setScale(0.05);
  
  //Monster Rocket 3
  monsterRocket3 = new Sprite(this, "monsterRocket.png", 10);
  monsterRocket3.setDead(true);
  monsterRocket3.setScale(0.05);
  
  //Heart
  heart = new Sprite(this, "heart.png", 10);
  heart.setDead(true);
  heart.setScale(0.1);
  
  //Bomb Reloader
  bombReloader = new Sprite(this, "bombReloader.png", 10);
  bombReloader.setDead(true);
  bombReloader.setScale(1);
}

//Create the ship
Sprite buildShip()
{
  Sprite ship = new Sprite(this, "spaceShip1.png", 50);
  ship.setXY(width/2, height - 30);
  ship.setVelXY(0.0f, 0);
  ship.setScale(0.5);
  //Set how far the ship can go
  ship.setDomain(0, 0, width - 75, height, Sprite.HALT);
  return ship;
}

//Create the rocket
Sprite buildRocket()
{
  Sprite rocket = new Sprite(this, "bullet1.png", 50);
  rocket.setScale(0.5);
  rocket.setDead(true);
  return rocket;
}

// Populate the monsters grid 
void buildMonsterGrid() 
{
  for (int idx = 0; idx < monsterCols; idx++ ) {
    for (int idy = 0; idy < monsterRows; idy++ ) {
      Sprite newMonster = buildMonster();
      monsters[idx][idy] = newMonster;
    }
  }
}

//Spawn powerups
void spawnPowerups(){
  if(millis() - powerupSpawnTime > SPAWN_TIME){
    heart.setDead(true);
    bombReloader.setDead(true);
    powerupSpawnTime = millis();
    if(int(random(2)) == 1){
      drawHeart();
    } else{
      drawBombReloader();
    }
  }
}

//Draw heart
void drawHeart(){
  heart.setX(int(random(660)));
  heart.setY(int(random(460)));
  heart.setDead(false);
}

//Draw bomb reloader
void drawBombReloader(){
  bombReloader.setX(int(random(700)));
  bombReloader.setY(int(random(500)));
  bombReloader.setDead(false);
}

// Build individual monster
Sprite buildMonster() 
{
  Sprite monster = new Sprite(this, "alien1.png", 30);
  monster.setScale(0.5);
  monster.setDead(false);
  return monster;
}

// Reset the monster grid along with the inital monster's 
// positions and direction of movement.
void resetMonsters() 
{
  for (int idx = 0; idx < monsterCols; idx++ ) {
    for (int idy = 0; idy < monsterRows; idy++ ) {
      // Move Monsters back to first positions
      Sprite monster = monsters[idx][idy];
      double mwidth = monster.getWidth() + 20;
      double totalWidth = mwidth * monsterCols;
      double start = (width - totalWidth)/2 - 50;
      double mheight = monster.getHeight();  
      monster.setXY((idx*mwidth)+start, (idy*mheight)+50);
      
      // Re-enable monsters that were previously marked dead.
      monster.setDead(false);
    }
  }
  mmCounter = 0;
  mmStep = 1;
  if (difficulty>10)
  {
    difficulty -=10;
  }
  round++;
  if (round == 11)
  {
    gameOver = true;
  }
}

// Executed before draw() is called 
public void pre() 
{
  if(!ship.isDead()){
    checkHealth();
  }
  checkAchievements();
  if(millis() - grabbedBombPowerupTime < BOMBER_DURATION){
    chargeUpHeight = 350;
  }
  //Checks to see if the flying monster is off the screen
  if(flyingMonster != null && !flyingMonster.isOnScreem()){
    flyingMonster.setDirection(0);
    flyingMonster.setSpeed(0);
    flyingMonster.setDead(true);
    flyingMonster = null;
  }
  //check to see if flying monster 2 is off screen
  if (flyingMonster2 != null && !flyingMonster2.isOnScreem()) {
    flyingMonster2.setDirection(0);
    flyingMonster2.setSpeed(0);
    flyingMonster2.setDead(true);
    flyingMonster2 = null;
  }
  //check to see if flying monster 3 is off screen
  if (flyingMonster3 != null && !flyingMonster3.isOnScreem()) {
    flyingMonster3.setDirection(0);
    flyingMonster3.setSpeed(0);
    flyingMonster3.setDead(true);
    flyingMonster3 = null;
  }
  //If all monsters are dead, reset the grid
  if(pickNonDeadMonster() == null && flyingMonster == null && flyingMonster2 == null && flyingMonster3 == null){
    resetMonsters();
  }
  //Checks to see if the rocket goes off the screen
  if(!rocket.isDead() && !rocket.isOnScreem()){
    chargeUpHeight = 0;
    stopRocket();
  }
  //Checks if the monster rocket is off the screen
  if(!monsterRocket.isDead() && !monsterRocket.isOnScreem()){
    monsterRocket.setSpeed(0, downRadians);
    monsterRocket.setDead(true);
  }
  //Checks if the monster rocket 2 is off the screen
  if(!monsterRocket2.isDead() && !monsterRocket2.isOnScreem()){
    monsterRocket2.setSpeed(0, downRadians);
    monsterRocket2.setDead(true);
  }
  //Checks if the monster rocket 3 is off the screen
  if(!monsterRocket3.isDead() && !monsterRocket3.isOnScreem()){
    monsterRocket3.setSpeed(0, downRadians);
    monsterRocket3.setDead(true);
  }
  //Checks to see if a monster is already falling
  if(flyingMonster == null) {
    flyingMonster = pickNonDeadMonster();
    if (flyingMonster == null){
      for (int idx = 0; idx < monsterCols; idx++ ) {
        for (int idy = 0; idy < monsterRows; idy++ ) {
           monsters[idx][idy] = null;
        }
      }
      buildMonsterGrid();
      flyingMonster = pickNonDeadMonster();
    }
    if (flyingMonster != null)
    {
      double direction = (int(random(2)) == 1) ? fmRightAngle : fmLeftAngle;
      flyingMonster.setSpeed(fmSpeed, direction);
      flyingMonster.setDomain(0, 0, width - 75, height + 100, Sprite.REBOUND);
    }
  }
  //Checks to see if a flying monster 2 is already falling
  if (flyingMonster2 == null && round >3) {
    flyingMonster2 = pickNonDeadMonster();
    if (flyingMonster == null && flyingMonster2 == null && flyingMonster3 == null) {
      for (int idx = 0; idx < monsterCols; idx++ ) {
        for (int idy = 0; idy < monsterRows; idy++ ) {
          monsters[idx][idy] = null;
        }
      }
      buildMonsterGrid();
      flyingMonster2 = pickNonDeadMonster();
    }
    if (flyingMonster2 != null)
    {
      double direction = (int(random(2)) == 1) ? fmRightAngle : fmLeftAngle;
      flyingMonster2.setSpeed(fmSpeed, direction);
      flyingMonster2.setDomain(0, 0, width - 75, height + 100, Sprite.REBOUND);
    }
  }
  //Checks to see if a flying monster 3 is already falling
  if (flyingMonster3 == null && round > 6) {
    flyingMonster3 = pickNonDeadMonster();
    if (flyingMonster == null && flyingMonster2 == null && flyingMonster3 == null) {
      for (int idx = 0; idx < monsterCols; idx++ ) {
        for (int idy = 0; idy < monsterRows; idy++ ) {
          monsters[idx][idy] = null;
        }
      }
      buildMonsterGrid();
      flyingMonster3 = pickNonDeadMonster();
    }
    if (flyingMonster3 != null)
    {
      double direction = (int(random(2)) == 1) ? fmRightAngle : fmLeftAngle;
      flyingMonster3.setSpeed(fmSpeed, direction);
      flyingMonster3.setDomain(0, 0, width - 75, height + 100, Sprite.REBOUND);
    }
  }
  checkKeys();
  processCollisions();
  S4P.updateSprites(stopWatch.getElapsedTime());
  if(chargeUpHeight < 350 && !ship.isDead()){
    chargeUpHeight += 1;
  } else {
    chargeUpHeight = 350;
    charged = true;
  }
  
  mGrowl++;
  if(mGrowl%400 == 0)
  {
    monsterGrowl.trigger();
  }
} 

//Super explosion for when the bar is completely charged up
void superExplosion(){
  if(!ship.isDead()){
    chargedShotCount++;
    soundPlayer.playChargeShot();
    chargeUpHeight = 0;
    explosion.setXY((int)(random(700)), (int)(random(200)) + 25);
    explosion.setFrameSequence(0, 6, 0.1, 1);
    if(!flyingMonster.isDead() && flyingMonster.bb_collision(explosion) && !explosion.isDead()){
          flyingMonster.setDead(true);
          score += 10;
          killCount++;
        }
        if(flyingMonster2 != null && !flyingMonster2.isDead() && flyingMonster2.bb_collision(explosion) && !explosion.isDead()){
          flyingMonster2.setDead(true);
          score += 10;
          killCount++;
        }
        if(flyingMonster3 != null && !flyingMonster3.isDead() && flyingMonster3.bb_collision(explosion) && !explosion.isDead()){
          flyingMonster3.setDead(true);
          score += 10;
          killCount++;
        }
    for(int idy = monsterRows; idy > 0; idy--){
      for(int idx = monsterCols; idx > 0; idx--){
        Sprite monster = monsters[idx-1][idy-1];
        if(!monster.isDead() && monster.bb_collision(explosion) && !explosion.isDead()){
          monster.setDead(true);
          score += 10;
          killCount++;
        }
      }
    }
  }
}

//Stops the rocket when it goes off screen
void stopRocket(){
  rocket.setSpeed(0, upRadians);
  rocket.setDead(true);
}

//Checks to see if there is even a single monster that is still standing
Sprite pickNonDeadMonster(){
    for(int idy = monsterRows; idy > 0; idy--){
      for(int idx = monsterCols; idx > 0; idx--){
        Sprite monster = monsters[idx-1][idy-1];
        if(!monster.isDead() && monster!= flyingMonster && monster!= flyingMonster2 && monster!= flyingMonster3){
          return monster;
        }
      }
    }
    return null;
  }

void checkKeys() 
{
  if(focused) {
    if(kbController.isLeft()){
      ship.setX(ship.getX() - 7);
    }
    if (kbController.isRight()){
      ship.setX(ship.getX() + 7);
    }
    if(kbController.isSpace()) {
      if(!charged){
        fireRocket();
      } else {
        superExplosion();
        charged = false;
      }
    }
    if(kbController.isDown()){
      ship.setY(ship.getY() + 7);
    }
    if(kbController.isUp()){
      ship.setY(ship.getY() - 7);
    }
  }
}

//Launch monster rocket 1
void fireMonsterRocket(double x, double y){
  if(monsterRocket.isDead()){
    monsterRocket.setX(x);
    monsterRocket.setY(y);
    int monsterRocketSpeed = 250;
    monsterRocket.setSpeed(monsterRocketSpeed, downRadians);
    monsterRocket.setDead(false);
  }
}
//Launch monster rocket 2
void fireMonsterRocket2(double x, double y){
  if(monsterRocket2.isDead()){
    monsterRocket2.setX(x);
    monsterRocket2.setY(y);
    int monsterRocketSpeed = 250;
    monsterRocket2.setSpeed(monsterRocketSpeed, downRadians);
    monsterRocket2.setDead(false);
  }
}
//Launch monster rocket 3
void fireMonsterRocket3(double x, double y){
  if(monsterRocket3.isDead()){
    monsterRocket3.setX(x);
    monsterRocket3.setY(y);
    int monsterRocketSpeed = 250;
    monsterRocket3.setSpeed(monsterRocketSpeed, downRadians);
    monsterRocket3.setDead(false);
  }
}

//Launch rocket
void fireRocket(){
  //Checks to make sure there isn't already a rocket being launched
  if(rocket.isDead() && !ship.isDead()){
    rocket.setPos(ship.getPos());
    int rocketSpeed = 500;
    rocket.setSpeed(rocketSpeed, upRadians);
    rocket.setDead(false);
    shotCount++;
  }
}

// Detect collisions between game pieces
void processCollisions() 
{
  //Check falling monster for collision first
  if(flyingMonster != null && !flyingMonster.isDead() && !rocket.isDead() && rocket.bb_collision(flyingMonster)){
    flyingMonster.setDirection(0);
    flyingMonster.setSpeed(0);
    flyingMonster.setDead(true);
    rocket.setDead(true);
    chargeUpHeight += 20;
    flyingMonster = null;
    score += 20;
    alienCry.trigger();
    killCount++;
    fallingMonsterKillCount++;
  }
  //Check falling monster 2 for collision
  if (flyingMonster2 != null && !flyingMonster2.isDead() && !rocket.isDead() && rocket.bb_collision(flyingMonster2)) {
    flyingMonster2.setDirection(0);
    flyingMonster2.setSpeed(0);
    flyingMonster2.setDead(true);
    rocket.setDead(true);
    chargeUpHeight += 20;
    flyingMonster2 = null;
    score += 20;
    alienCry.trigger();
    killCount++;
    fallingMonsterKillCount++;
  }
  //Check falling monster 3 for collision first
  if (flyingMonster3 != null && !flyingMonster3.isDead() && !rocket.isDead() && rocket.bb_collision(flyingMonster3)) {
    flyingMonster3.setDirection(0);
    flyingMonster3.setSpeed(0);
    flyingMonster3.setDead(true);
    rocket.setDead(true);
    chargeUpHeight += 20;
    flyingMonster3 = null;
    score += 20;
    alienCry.trigger();
    killCount++;
    fallingMonsterKillCount++;
  }
  for(int x = 0; x < monsterCols; x++){
    for(int y = 0; y < monsterRows; y++){
      Sprite monster = monsters[x][y];
      if(!monster.isDead() && !ship.isDead() && monster.bb_collision(ship)){
        monster.setDead(true);
        explodeShip();
        gameOver = true;
      }
    }
  }
  //Check if falling monster has hit the ship
  if(flyingMonster != null && !ship.isDead() && flyingMonster.bb_collision(ship)) {
    explodeShip();
    monsterHit(flyingMonster);
    flyingMonster = null;
    gameOver = true;
  }
  //Check if falling monster 2 has hit the ship
  if (flyingMonster2 != null && !ship.isDead() && flyingMonster2.bb_collision(ship)) {
    explodeShip();
    monsterHit(flyingMonster2);
    flyingMonster2 = null;
    gameOver = true;
  }
  //Check if falling monster 3 has hit the ship
  if (flyingMonster3 != null && !ship.isDead() && flyingMonster3.bb_collision(ship)) {
    explodeShip();
    monsterHit(flyingMonster3);
    flyingMonster3 = null;
    gameOver = true;
  }
  //For loops will check each instance of the monsters
  for(int x = 0; x < monsterCols; x++){
    for(int y = 0; y < monsterRows; y++){
      Sprite monster = monsters[x][y];
      //Destroy both rocket and monster if they collide
      if(!monster.isDead() && !rocket.isDead() && rocket.bb_collision(monster)){
        monster.setDead(true);
        rocket.setDead(true);
        chargeUpHeight+=5;
        score += 10;
        alienCry.trigger();
        killCount++;
      }
    }
  }
  //Check if monster rocket has hit the ship
  if(!monsterRocket.isDead() && !ship.isDead() && monsterRocket.bb_collision(ship)){
    soundPlayer.playDamage();
    health -= 10;
    monsterRocket.setDead(true);
  }
  //Check if monster rocket 2 has hit the ship
  if(!monsterRocket2.isDead() && !ship.isDead() && monsterRocket2.bb_collision(ship)){
    soundPlayer.playDamage();
    health -= 10;
    monsterRocket2.setDead(true);
  }
  //Check if monster rocket 3 has hit the ship
  if(!monsterRocket3.isDead() && !ship.isDead() && monsterRocket3.bb_collision(ship)){
    soundPlayer.playDamage();
    health -= 10;
    monsterRocket3.setDead(true);
  }
  //Check for powerups
  if(!heart.isDead() && !ship.isDead() && heart.bb_collision(ship)){
    health = 33;
    heart.setDead(true);
  }
  if(!bombReloader.isDead() && !ship.isDead() && bombReloader.bb_collision(ship)){
    grabbedBombPowerupTime = millis();
    chargeUpHeight = 350;
    bombReloader.setDead(true);
  }
}

//Draws the health bar
void drawHealthBar(){
  if(!ship.isDead()){
    strokeWeight(1);
    stroke(255);
    noFill();
    float healthX = (float)(ship.getX() - 17);
    float healthY = (float)(ship.getY() + 20);
    rect(healthX, healthY, 35, 5);
    stroke(#ff0000);
    fill(#ff0000);
    rect(healthX + 1, healthY + 1, health, 3);
  }
}

//The ship will explode if the falling monster hits the ship
void explodeShip(){
  //explosion.setDead(false);
  explosion.setScale(1);
  soundPlayer1.trigger();
  soundPlayer.playExplosion();
  explosion.setPos(ship.getPos());
  explosion.setFrameSequence(0, 16, 0.1, 1);
  ship.setDead(true);
}

//Kills monster
void monsterHit(Sprite fm){
  fm.setDead(true);
}

//Check if the player's health is at 0
void checkHealth(){
  if(health <= 0){
    explodeShip();
    gameOver = true;
  }
}

//March monsters back and forth
void moveMonsters() 
{
  //Move all of the monsters back and forth in the grid
  if((++mmCounter % 100) == 0){
    mmStep *= -1;
  }
  for(int idx = 0; idx < monsterCols; idx++){
    for(int idy = 0; idy < monsterRows; idy++){
      Sprite monster = monsters[idx][idy];
      if(!monster.isDead()){
        monster.setXY(monster.getX() + mmStep, monster.getY());
      }
    }
  }
  //Randomly move only the flying monster
  if(flyingMonster != null){
    flyingMonster.setSpeed(fmSpeed);
    if(int(random(difficulty)) == 1 && !ship.isDead()){
      soundPlayer.playMonsterRocket();
      fireMonsterRocket(flyingMonster.getX(), flyingMonster.getY());
    }
    if(int(random(difficulty)) == 1){
      double newSpeed = flyingMonster.getSpeed() + random(-40, 40);
      flyingMonster.setSpeed(newSpeed);
      //Reverses the direction of the flying monster
      if(flyingMonster.getDirection() == fmRightAngle){
        flyingMonster.setDirection(fmLeftAngle);
      }
      else{
        flyingMonster.setDirection(fmRightAngle);
      }
    }
  }
  //Randomly move the flying monster 2
  if (flyingMonster2 != null) {
    flyingMonster2.setSpeed(fmSpeed);
    if(int(random(difficulty)) == 1 && !ship.isDead()){
      soundPlayer.playMonsterRocket();
      fireMonsterRocket2(flyingMonster2.getX(), flyingMonster2.getY());
    }
    if (int(random(difficulty)) == 1) {
      double newSpeed = flyingMonster2.getSpeed() + random(-40, 40);
      flyingMonster2.setSpeed(newSpeed);
      //Reverses the direction of the flying monster
      if (flyingMonster2.getDirection() == fmRightAngle) {
        flyingMonster2.setDirection(fmLeftAngle);
      } else {
        flyingMonster2.setDirection(fmRightAngle);
      }
    }
  }
    if (flyingMonster3 != null) {
      flyingMonster3.setSpeed(fmSpeed);
      if(int(random(difficulty)) == 1 && !ship.isDead()){
        soundPlayer.playMonsterRocket();
      fireMonsterRocket3(flyingMonster3.getX(), flyingMonster3.getY());
    }
    if (int(random(difficulty)) == 1) {
      double newSpeed = flyingMonster3.getSpeed() + random(-40, 40);
      flyingMonster3.setSpeed(newSpeed);
      //Reverses the direction of the flying monster
      if (flyingMonster3.getDirection() == fmRightAngle) {
        flyingMonster3.setDirection(fmLeftAngle);
      } else {
        flyingMonster3.setDirection(fmRightAngle);
      }
    }
  }
}

//Checks for achievements
void checkAchievements(){
  if(killCount >= 5 && !killCount5){
    numOfAchievements++;
    startTime = millis();
    killCount5 = true;
    title = "Novice Killer";
    subtitle = "Kill 5 monsters";
  }
  if(killCount >= 25 && !killCount25){
    numOfAchievements++;
    startTime = millis();
    killCount25 = true;
    title = "Serial Killer";
    subtitle = "Kill 25 monsters";
  }
  if(killCount >= 100 && !killCount100){
    numOfAchievements++;
    startTime = millis();
    killCount100 = true;
    title = "Centuplicate Kill";
    subtitle = "Kill 100 monsters";
  }
  if(killCount >= 500 && !killCount500){
    numOfAchievements++;
    startTime = millis();
    killCount500 = true;
    title = "You Have a Problem";
    subtitle = "Kill 500 monsters";
  }
  if(shotCount >= 10 && !shotCount10){
    numOfAchievements++;
    startTime = millis();
    shotCount10 = true;
    title = "Novice Shooter";
    subtitle = "Shoot 10 rockets";
  }
  if(shotCount >= 100 && !shotCount100){
    numOfAchievements++;
    startTime = millis();
    shotCount100 = true;
    title = "Trigger Happy";
    subtitle = "Shoot 100 rockets";
  }
  if(shotCount >= 500 && !shotCount500){
    numOfAchievements++;
    startTime = millis();
    shotCount500 = true;
    title = "Rocket Spammer";
    subtitle = "Shoot 500 rockets";
  }
  if(shotCount >= 1000 && !shotCount1000){
    numOfAchievements++;
    startTime = millis();
    shotCount1000 = true;
    title = "Broken Spacebar";
    subtitle = "Shoot 1000 rockets";
  }
  if(chargedShotCount >= 1 && !chargedShotCount1){
    numOfAchievements++;
    startTime = millis();
    chargedShotCount1 = true;
    title = "Novice Bomber";
    subtitle = "Launch 1 bomb";
  }
  if(chargedShotCount >= 5 && !chargedShotCount5){
    numOfAchievements++;
    startTime = millis();
    chargedShotCount5 = true;
    title = "Bomb(Dot)Com";
    subtitle = "Launch 5 bombs";
  }
  if(chargedShotCount >= 20 && !chargedShotCount20){
    numOfAchievements++;
    startTime = millis();
    chargedShotCount20 = true;
    title = "Bomberman";
    subtitle = "Launch 20 bombs";
  }
  if(chargedShotCount >= 50 && !chargedShotCount50){
    numOfAchievements++;
    startTime = millis();
    chargedShotCount50 = true;
    title = "Bomb Squad";
    subtitle = "Launch 50 bombs";
  }
  if(score >= 100 && !score100){
    numOfAchievements++;
    startTime = millis();
    score100 = true;
    title = "N00b";
    subtitle = "Get 100 points";
  }
  if(score >= 500 && !score500){
    numOfAchievements++;
    startTime = millis();
    score500 = true;
    title = "Starship Pilot";
    subtitle = "Get 500 points";
  }
  if(score >= 2500 && !score2500){
    numOfAchievements++;
    startTime = millis();
    score2500 = true;
    title = "High Score Hunter";
    subtitle = "Get 2500 points";
  }
  if(score >= 10000 && !score10000){
    numOfAchievements++;
    startTime = millis();
    score10000 = true;
    title = "Please Get a Life";
    subtitle = "Get 10000 points";
  }
  if(fallingMonsterKillCount >= 1 && !fallingMonsterKillCount1){
    numOfAchievements++;
    startTime = millis();
    fallingMonsterKillCount1 = true;
    title = "Novice Sniper";
    subtitle = "Shoot 1 Falling Monster";
  }
  if(fallingMonsterKillCount >= 10 && !fallingMonsterKillCount10){
    numOfAchievements++;
    startTime = millis();
    fallingMonsterKillCount10 = true;
    title = "Sharp Shooter";
    subtitle = "Shoot 10 Falling Monsters";
  }
  if(fallingMonsterKillCount >= 30 && !fallingMonsterKillCount30){
    numOfAchievements++;
    startTime = millis();
    fallingMonsterKillCount30 = true;
    title = "Hawk Eye";
    subtitle = "Shoot 30 Falling Monsters";
  }
  if(fallingMonsterKillCount >= 75 && !fallingMonsterKillCount75){
    numOfAchievements++;
    startTime = millis();
    fallingMonsterKillCount75 = true;
    title = "Time Waster";
    subtitle = "Shoot 75 Falling Monsters";
  }
}

//Draw the score every frame
void drawScore(){
  textSize(32);
  String msg = "Score: " + score;
  text(msg, 10, 30);
}

//Draw game over
void drawGameOver(){
  heart.setDead(true);
  bombReloader.setDead(true);
  gameOverSprite.setXY(width / 2, height / 2);
  gameOverSprite.setDead(false);
}

//Draws the number of achievements
void drawAchievements(){
  if(ship.isDead()){
    textSize(30);
    String msg = "You got " + numOfAchievements + " out of 20 achievements!";
    text(msg, 125, 350);
  }
}

//Draws the charge up shot
void drawChargeUpShot(){
  stroke(255);
  noFill();
  rect(700, 50, 65, 352);
  stroke(#ffff00);
  fill(#ffff00);
  rect(701, 401 - chargeUpHeight, 63, chargeUpHeight);
  fill(255);
}

void drawControl()//adds controls legend to the right 
{
  textSize(17);
  fill(255);
  String control = "P-pause";
  text(control, 700, 450);
  drawRetry();
  drawQuit();
}

void drawPause()//tells the user game is paused
{
  textSize(35);
  String msg = "Press 'P' again to resume";
  fill(255);
  text(msg, 140, 250);
}

void drawRetry()
{
  textSize(17);
  String msg = "R-retry";
  fill(255);
  text(msg,700,465);
}

void drawQuit()
{
  textSize(17);
  String msg = "esc-quit";
  fill(255);
  text(msg,700,480);
}

void keyPressed()//pauses game
{
  final int pause = keyCode;
  final int quit1 = keyCode;
  final int retry1 = keyCode;
  
  if(pause=='P')
  if(looping){ 
  flyingMonster.setSpeed(0,0);
  if(flyingMonster2 != null)
  flyingMonster2.setSpeed(0,0);
  if(flyingMonster3 != null)
  flyingMonster3.setSpeed(0,0);
  noLoop();
  drawPause();
  }
  else 
  loop();
  
  if(quit1 == 27)
  {
    quit = true;
    gameOver = true;
    ship.setDead(true);
  }
  
  if(retry1 == 'R')
  {
    retry = true;
    gameOver = false;
    quit = false;
    ship.setDead(false);
    resetMonsters();
    score = 0;
    chargeUpHeight = 0;
    round = 0;
    gameOverSprite.setDead(true);
    ship.setXY(width/2, height - 30);
    charged = false;
  }
}

public void draw() 
{
  moveMonsters();
    if(ship.isDead()){
      drawGameOver();
      for(int idx = 0; idx < monsterCols; idx++){
        for(int idy = 0; idy < monsterRows; idy++){
           Sprite monster = monsters[idx][idy];
           monster.setDead(true);
        }
      }
     }
  background(img);
  if(millis() - startTime <= DISPLAY_DURATION){
    stroke(255);
    strokeWeight(2);
    noFill();
    rect(1, 440, 200, 59, 5);
    textSize(25);
    text(title, 3, 470);
    stroke(#7e7e7e);
    textSize(13);
    text(subtitle, 3, 490);
  }
  drawAchievements();
  spawnPowerups();
  drawControl();
  drawHealthBar();
  drawChargeUpShot();
  drawScore();
  S4P.drawSprites();
}