//import serial and sound libraries

import processing.serial.*;

import processing.sound.*;

int distancemapped;           // received from arduino
Serial myPort;                       // The serial port
int[] serialInArray = new int[3];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // To determine whether contact has been made with arduino
int numRows = 6; //Number of bricks per row
int numColumns = 6; //Number of numColumns
int total = numRows * numColumns; //Total number of bricks
int numHits = 0; //How many bricks have been hit by the player
int gameScore = 0; //The player's score which displays on the screen.
int maxGameScore=total*10;
int lives = 5; //lives
float xpaddle; //x position of paddle on scree
int screenw=1800;// screen width
int screenh=1000; //screen height
int laserReading;//received from arduino
int startReading;//received from arduino
int streak = 0;  //How many bricks in a row the player has hit without the ball touching the paddle or using a missile.
int maxStreak = 0; //Max streak in any given round
int numLasers=0;//number of lasers shot by the player
int maxLasers=25;//max number of lasers available to the player
//num lasers used to calculate laser power
float numLasers1=0;
float maxLasers1=25;
float laserPower=100;//shows user number of lasers remaining as a percentage
boolean gamePlay=true;// tells whether the game is in play or not
boolean gameOverSoundPlayed=false; //ensures the sound is only played once
//Images
PImage gameOverImg;
PImage winImg;
//Sounds
SoundFile laserSound;
SoundFile pingSound;
SoundFile pongSound;
SoundFile wallSound;
SoundFile gameOverSound;



Paddle paddle = new Paddle(); //initialize paddle
Ball ball = new Ball(); //initialize ball 
Brick[] boxes = new Brick[total]; //Initialize the array that will hold all the bricks
Laser[] lasers = new Laser[maxLasers]; //Initialize the array that will hold all the bricks

void setup()
{
  size(1800, 1000);   
  background(255);
  smooth();
  //load Images
  gameOverImg = loadImage("gameOver.png");
  winImg = loadImage("win.png");
  //load sounds
  laserSound = new SoundFile(this, "laser.mp3.mp3");
  pingSound = new SoundFile(this, "ping.mp3.mp3");
  pongSound = new SoundFile(this, "pong.mp3.mp3");
  wallSound = new SoundFile(this, "wall.mp3.mp3");
  gameOverSound = new SoundFile(this, "gameOver.mp3.mp3");


  // Print a list of the serial ports for debugging purposes
  // if using Processing 2.1 or later, use Serial.printArray()
  println(Serial.list());

  // I know that the first port in the serial list on my Mac is always my FTDI
  // adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);

  //Setup array of all bricks on screen
  for (int i = 0; i < numRows; i++)
  {
    for (int j = 0; j< numColumns; j++)
    {
      boxes[i*numRows + j] = new Brick((i+1) *width/(numRows+1), (j+1) * 100); //places all the bricks into the array, properly labelled.
    }
  }
}


void draw()
{
  background(255);

  //Draw bricks from the array of bricks
  for (int i = 0; i<total; i++)
  {
    boxes[i].update();
  }

  //Draw paddle, ball
  paddle.update();
  ball.update();
  
  //If the game is in play and user has not used all of the lasers, create new laser when laser button is pressed
  if ((numHits != total || lives > 0) && laserReading==1 && numLasers<maxLasers && gamePlay==true) {

    lasers[numLasers]=new Laser();
    numLasers+=1;
    numLasers1+=1;
    laserSound.play(); //play laser sound
  }

  //update all the lasers
  if (numLasers>0) {

    for (int i=0; i<numLasers; i++) {
      lasers[i].update();
      laserPower=100-((numLasers1/maxLasers1)*100); //calculate the amount of lasers remaining as a percentage
    }
  }


  //BALL AND PADDLE/WALL INTERACTIONS

  //If the ball hits the paddle, it goes the other direction
  //If the ball hits the left of the paddle, it goes to the left
  //If the ball hits the right of the paddle, it goes to the right

  //if the ball hits left side of paddle
  if (ball.y == paddle.y && ball.x > paddle.x && ball.x <= paddle.x + (paddle.w / 2) )
  {
    ball.goLeft();
    ball.changeY();
    pongSound.play();
  }

  //if the ball hits right side of paddle
  if (ball.y == paddle.y && ball.x > paddle.x + (paddle.w/2) && ball.x <= paddle.x + paddle.w )
  {
    ball.goRight();
    ball.changeY();
    pongSound.play();
  }

  //If the ball hits the RIGHT wall, go in same y direction, but go left  
  if ((ball.x + ball.D / 2 >= width)&& gamePlay==true)
  {
    ball.goLeft();
    wallSound.play();
  }

  //If the ball hits the LEFT wall, go in same y direction, but go right
  if (ball.x - ball.D / 2 <= 0 && gamePlay==true)
  {
    ball.goRight();
    wallSound.play();
  }

  //If the ball hits the ceiling, go down in a different direction
  if (ball.y - ball.D / 2 <= 0 && gamePlay==true)
  {
    ball.changeY();
    wallSound.play();
  }
  
  //BALL and BRICK INTERACTIONS

  for (int i = 0; i < total; i ++)
  {
    //If ball hits bottom of brick, ball moves down, increment score
    if (ball.y - ball. D / 2 <= boxes[i].y + boxes[i].h &&  ball.y - ball.D/2 >= boxes[i].y && ball.x >= boxes[i].x && ball.x <= boxes[i].x + boxes[i].w  && boxes[i].hit == false )
    {
      ball.changeY();
      boxes[i].gotHit();
      numHits += 1;
      gameScore += 10;
      streak+=1;
      pingSound.play();
      if (streak>maxStreak)
      {
        maxStreak = streak;
      }
    } 

    //If ball hits top of brick ball moves up, increment score
    if (ball.y + ball.D / 2 >= boxes[i].y && ball.y - ball.D /2 <= boxes[i].y + boxes[i].h/2 && ball.x >= boxes[i].x && ball.x <= boxes[i].x + boxes[i].w && boxes[i].hit == false ) 
    {
      ball.changeY();
      boxes[i].gotHit();
      numHits += 1;
      gameScore += 10;
      streak+=1;
      pingSound.play();
      if (streak>maxStreak)
      {
        maxStreak = streak;
      }
    }

    //if ball hits the left of the brick, ball switches to the right, and moves in same direction, increment score
    if (ball.x + ball.D / 2 >= boxes[i].x && ball.x + ball.D / 2 <= boxes[i].x + boxes[i].w / 2 && ball.y >= boxes[i].y && ball.y <= boxes[i].y + boxes[i].h  && boxes[i].hit == false)
    {
      ball.goLeft();
      boxes[i].gotHit();
      numHits += 1;
      gameScore += 10;
      streak+=1;
      pingSound.play();
      if (streak>maxStreak)
      {
        maxStreak = streak;
      }
    }

    //if ball hits the right of the brick, ball switches to the left, and moves in same direction, increment score
    if (ball.x - ball.D/2 <= boxes[i].x + boxes[i].w && ball.x +ball.D / 2 >= boxes[i].x + boxes[i].w / 2 && ball.y >= boxes[i].y && ball.y <= boxes[i].y + boxes[i].h  && boxes[i].hit == false)
    {
      ball.goRight();
      boxes[i].gotHit();
      numHits += 1;
      gameScore += 10;
      streak+=1;
      pingSound.play();
      if (streak>maxStreak)
      {
        maxStreak = streak;
      }
    }

    //LASER BRICK INTERACTIONS

    //If the laser hits the bottom of a brick and it has not been already used, set box as hit
    if (numLasers>0) {
      for (int j=0; j<numLasers; j++) {

        if (lasers[j].y <=boxes[i].y+boxes[i].h && lasers[j].x >= boxes[i].x  && lasers[j].x <= boxes[i].x+boxes[i].w  && boxes[i].hit == false && lasers[j].used==false)
        {
          boxes[i].gotHit();
          lasers[j].laserUsed();
          gameScore += 10;
          streak += 1;
        }
      }
    }
  }



  //If ball goes off the screen, reset the ball, and lose a life.
  if (ball.y > height)
  {
    ball.reset();
    lives -= 1;
    streak=0;
  }




  //Displays score in top left corner!
  textSize(32);
  text(gameScore, 10, 30);

  //Displays lives and laser power in top right corner
  textSize(25);
  text("LIVES: ", width-150, 30);
  text(lives, width-50, 30);
  text("LASER POWER:", width-300, 55);
  text(laserPower, width-120, 55);
  text("%", width-35, 55);

  //If the player wins/loses, he/she has to press the start buton to restart the game
  if ((gameScore==maxGameScore || lives <= 0) && startReading==1)
  {
    resetGame();
  } 


  //Once the score is equal to the total, bring up the "win" screen.
  if (gameScore == maxGameScore)
  {
    gameWon();
  }

  //If no more lives are left, game ends
  if (lives <= 0)
  {
    gameLost();
  }
}


//Function that displays the game screen after the player loses.
void gameLost()
{
  //Says "Game over", displays score, max streak, and allows user to click screen to play again. 
  background(255);
  textSize(32);
  text("GAME OVER", 100, 200);
  text("Score: ", 100, 300);
  text(gameScore, 300, 300);
  text("Max Streak: ", 100, 400); 
  text(maxStreak, 300, 400);
  text("Press Start to Play again!", 100, 500);
  image(gameOverImg, width/2, 150, gameOverImg.width*2, gameOverImg.height*2); //display gameover image
  gamePlay=false;
  if (gameOverSoundPlayed==false) { //only play the gameOver sound once
    gameOverSound.play();
    gameOverSoundPlayed=true;
  }

  //The game is still technically playing when this screen is brought up, 
  //so these steps help to isolate the ball and  s.
  ball.x = -10;
  ball.y = -10;
  ball.vx = 0;
  ball.vy = 0;
}





//Function that displays the gameOver screen
void gameWon()
{ 

  //Says "You win!", displays score, max streak, and allows user to click screen to play again. 
  background(255);
  textSize(32);
  text("YOU WIN!", 100, 200);
  text("Score: ", 100, 300);
  text(gameScore, 300, 300);
  text("Max Streak: ", 100, 400); 
  text(maxStreak, 300, 400);
  text("Press Start to Play again!", 100, 700);
  image(winImg, width/2, 150, winImg.width*2, winImg.height*2);


  //The game is still technically playing when this screen is brought up, 
  //so these steps help to isolate the ball and  s.
  ball.x = -10;
  ball.y = -10;
  ball.vx = 0;
  ball.vy = 0;
}

//Function that Resets the game
void resetGame()
{

  //Setup array of all bricks on screen
  for (int i = 0; i < numRows; i++)
  {
    for (int j = 0; j< numColumns; j++)
    {
      boxes[i*numRows + j] = new Brick((i+1) *width/(numRows+1), (j+1) * 100); //places all the bricks into the array, properly labelled.
    }
  }

  //Reset all the game values
  numHits = 0;
  gameScore = 0;
  lives = 5;
  streak=0;
  numLasers=0;
  gamePlay=true;
  laserPower=100;
  gameOverSoundPlayed=false;

  //Reset the ball as well
  ball.reset();
}

//LASER CLASS
class Laser {

  float x; //x pos  
  float y;  //y pos
  float l;   //length of laser
  float vy;  //laser speed
  float r;   //red in rgb
  boolean used;  //has the laser been used to destroy a block?
  int alpha;  //transparency of laser

  Laser() {
    x=paddle.x+paddle.w/2;    //x=middle of the paddle
    y=paddle.y-paddle.h;      //laser starts at the top of the paddle
    l=40;                     //length of paddle
    vy=1;                     
    used=false;                //laser not used
    r=255;
    alpha=255;                 //laser is opaque
  }
  
  //draw laser
  void update() {
    y-=vy;
    strokeWeight(3);
    stroke(r, 0, 0, alpha);
    line(x, y, x, y+l);
  }
  
  //when laser hits box, make the laser transparent and set as used
  void laserUsed() {
    used=true;
    r = 255;
    alpha=0;
    stroke(r, 0, 0, alpha);
  }
}
//end of Laser class



//PADDLE CLASS
class Paddle
{
  float x; //paddle x
  float y; //padlle y
  float w; //paddle width
  float h; //paddle height
  float r; //paddle red val
  float g; //paddle green val
  float b; //paddle blue val

  //Paddle constructor
  Paddle()
  {
    x = width/2;
    y = 900;
    w = 150;
    h = 20;
    r=0;
    g=0;
    b=0;
  }

  void update()
  {
    //Paddle follows the disance from ultrasonic sensor
    x = xpaddle;    

    //Draw paddle
    noStroke();
    fill(r, g, b);
    rect(x, y, w, h);
  }
}
//end of paddle class

//BALL CLASS
class Ball
{

  float x;  //ball x
  float y; //ball y
  float vx; //ball velocity in x
  float vy; //ball velocity in y 
  float D; //ball diameter

  //Ball constructor
  Ball()
  {
    x = 900;
    y = 400;
    vx = 0; //Initially, ball just falls straight down
    vy = 4; 
    D = 40;
  }

  //Update the ball
  void update()
  {
    noStroke();
    fill(0);
    ellipse(x, y, D, D);

    y += vy; //increment y
    x += vx; //increment x
  }

  //Ball goes left
  void goLeft()
  {
    vx = -4.5; //decrement x
  }

  //Ball goes right
  void goRight()
  {
    vx = 4.5; //increment x
  }

  //Ball changes in y direction
  void changeY()
  {
    vy *= -1;
  }

  //If ball goes below paddle, reset the ball to middle of the screen
  void reset()
  {
    x = screenw/2;
    y = 500;
    vx = 0;
    vy = 4;
  }
}
//end of ball class

//BRICK CLASS
class Brick
{
  float x; //brick x
  float y; //brick y
  float w; //brick width
  float h; //brich height
  float r; //brick red val
  float g; //grick green val
  float b; //brick blue val

  boolean hit; //whether or not the brick has been hit


  Brick(float x0, float y0) //initialize bricks at x0,y0
  {
    x = x0;
    y = y0;

    //darker colors that show up on white background
    r = random(0, 155);
    g = random(0, 155);
    b = random(0, 155);
    w = 80; //brick width
    h = 50; //brick height

    hit = false; //brick is initially not hit
  }

  //Draws the brick
  void update()
  {
    noStroke();
    fill(r, g, b);
    rect(x, y, w, h);
  }

  //What happens to the brick once it gets hit
  void gotHit()
  {
    hit = true; //brick recognizes that it has been hit
    
    //turn brick white (colour of background)

    r = 255;
    g = 255;
    b = 255;
    rect(x, y, w, h);
  }
} //end of brick class

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A, clear the serial
  // buffer and note that you've had first contact from the microcontroller.
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    if (inByte == 'A') {
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('A');       // ask for more
    }
  } else {
    // Add the latest byte from the serial port to array:
    serialInArray[serialCount] = inByte;
    serialCount++;

    // If we have 3 bytes:
    if (serialCount > 2 ) {
      distancemapped = serialInArray[0]; //
      xpaddle = map(distancemapped, 5, 250, screenw, 0); //map distance value received from arduino to the width of screen
      laserReading= serialInArray[1]; //laser Button pressed?
      startReading=serialInArray[2];  //startButoon pressed?



      // print the values (for debugging purposes only):
      println(distancemapped, "     ", xpaddle, "           ", numLasers);

      // Send a capital A to request new sensor readings:
      myPort.write('A');
      // Reset serialCount:
      serialCount = 0;
    }
  }
}