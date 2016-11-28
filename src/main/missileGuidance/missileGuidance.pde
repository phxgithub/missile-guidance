// Application Missile Guidance Control
// 11-28-2016
// James Zuckerman and Matt Evans

#include <IOShieldOled.h>
#include <string.h>

// set pin numbers:
const int BTN1 = 4; // the number of the pushbutton pin
const int BTN2 = 78; //***** Note: label on the board is for Uno32, this is MAX32, see MAX32 Reference Manual

const int ledPin = 13;
const int LD1 = 70; //***** Note: label on the board is for Uno32, this is MAX32, see MAX32 Reference Manual
const int LD2 = 71; // ******** LD pins are corrected here.

// variables:
int BTN1_state = 0; // variable for reading the pushbutton status
int BTN2_state = 0; // variable for reading the pushbutton status

double m; // slope
double distance; // sqrt(pow(y2-y1,2)+pow(x2-x1,2))
double velocity; // distance/time
double elapsedTime = 1.23;
const double missileSpeed = 0.4267;
double theta2 = 0.0000;
double speed;
double theta1;
double droneX;
double Vx;

char elapsedTimeArray[5];
char theta2AngleArray[7];

//declare and initialize OLED display strings
String displayElapsedTime;
char displayElapsedTimeArray[20];
String displayTheta2Angle;
char displayTheta2AngleArray[20];

void setup() {

    // initialize the LED pin as an output:
    pinMode(LD1, OUTPUT);
    pinMode(LD2, OUTPUT);


    // initialize the pushbutton pin as an input:
    pinMode(BTN1, INPUT);

    // Turn OFF all LEDs
    digitalWrite(LD1, LOW);
    digitalWrite(LD2, LOW);

    // Initialize OLED
    IOShieldOled.begin();
    IOShieldOled.displayOn();

} // end setup()

void loop() {
    // -------------------------------------
    //	
    //Local vars
    double count;

    // Coordinates
    int x1 = 5;
    int y1 = 6;
    int x2 = 7;
    int y2 = 8;

    double m; // slope

    double distance; // sqrt(pow(y2-y1,2)+pow(x2-x1,2))
    double speed; // distance/time
    double theta1;
    double Vx;
    double angle;

    BTN1_state = digitalRead(BTN1);
    BTN2_state = digitalRead(BTN2);

    if (BTN1_state == HIGH) { //Is BTN1 i pressed??
        delay(5); //wait 5 mS for any pushbutton bounce to disappear
        BTN1_state = digitalRead(BTN1); //read the value on the pushbutton pin again

        if (BTN1_state == HIGH) //is it still HIGH (pressed)
        {
            digitalWrite(LD1, HIGH); //Light LD1>
            digitalWrite(LD2, LOW);
        }
            //otherwise
        else {
            BTN2_state = digitalRead(BTN2);
            while (BTN2_state == LOW) {                 
               // rely on delay to count seconds.  we want to display seconds and ms, so we delay by 1/10th of second and divide count by 10 to get seconds/ms. 
               // We set 1/9.14th of a second for precision (results from testing).
                delay(91.4);
                count++;
                double timer = count / 10;
 
                //clear the display and reset the cursor to zero
                IOShieldOled.clearBuffer();

                //set the cursor to display elapsed time
                IOShieldOled.setCursor(0, 0);
                //create a string to display the elapsed time on the OLED screen
                displayElapsedTime = "Time: ";
                displayElapsedTime.toCharArray(displayElapsedTimeArray, 7);
                //display it @OLED:
                IOShieldOled.putString(displayElapsedTimeArray);
                //convert the value to a char[] because we're using putString() :: also use sprintf() because we're converting a double :: see http://stackoverflow.com/questions/7462349/convert-double-value-to-a-char-array-in-c
                sprintf(elapsedTimeArray, "%2.2f", timer);
                //append the elapsed time value to the string & display it @OLED:
                IOShieldOled.putString(elapsedTimeArray);
                IOShieldOled.updateDisplay();

                BTN1_state = digitalRead(BTN1);
                BTN2_state = digitalRead(BTN2);

                if (BTN2_state == HIGH) {
                    digitalWrite(LD2, HIGH);
                    m = calculateSlope(x1, y1, x2, y2);
                    distance = calculateDistance(x1, y1, x2, y2);
                    setSpeed(distance,timer);
                    speed = getSpeed();
                    theta1 = calculateAngle(m);
                    setVx(speed, theta1);
                    Vx = getVx();
                    setDroneX(Vx, timer);
                    droneX = getDroneX();
                    theta2 = calculateAngle(Vx, missileSpeed);
                    double d1 = getd1();
                    double d2 = getd2();
                    double InterceptionX1 = InterceptionX();
                    double t1 = getd1() / speed;
                    double t2 = getd2() / missileSpeed;
                    double d1x = InterceptionX() - 7;
                    double d1y = InterceptionY() - 8;
                    double d2x = InterceptionX() - 7;
                    double d2y = InterceptionY();
                    //set the cursor to display launch angle
                    IOShieldOled.setCursor(0, 1);
                    //create a string to display the elapsed time on the OLED screen
                    displayTheta2Angle = "Angle: ";
                    displayTheta2Angle.toCharArray(displayTheta2AngleArray, 8);
                    //display it @OLED:
                    IOShieldOled.putString(displayTheta2AngleArray);
                    //convert the value to a char[] because we're using putString() :: also use sprintf() because we're converting a double :: see http://stackoverflow.com/questions/7462349/convert-double-value-to-a-char-array-in-c
                    sprintf(theta2AngleArray, "%2.2f", theta2);
                    //append the elapsed time value to the string & display it @OLED:
                    IOShieldOled.putString(theta2AngleArray);
                    //lets display t1 and t2 so we can compare its' value to 1
                    char displayT1Array[8];
                    sprintf(displayT1Array, "%2.2f", t1);
                    IOShieldOled.setCursor(0, 2);
                    IOShieldOled.putString(displayT1Array);
                    char displayT2Array[8];
                    double verify = verifyHit();
                    sprintf(displayT2Array, "%2.2f", verify);                    
                    IOShieldOled.setCursor(0, 3);
                    IOShieldOled.putString(displayT2Array);
                     
                    if(timer < 4.7)
                    {
                      delay(5000);
                        for (int ii = 0; ii < 3; ii++){
                          delay(1000);
                          IOShieldOled.clearBuffer();
                          IOShieldOled.updateDisplay();
                          delay(1000);
                          String displayTooFast = "Drone is 2 fast!";
                          char displayTooFastArray[20];
                          displayTooFast.toCharArray(displayTooFastArray, 19);
                          IOShieldOled.setCursor(0, 1);                          
                          IOShieldOled.putString(displayTooFastArray);
                      
                    }
                     delay(1000);
                    digitalWrite(LD1, LOW);
                    delay(1000);
                    digitalWrite(LD2, LOW);
                    break;
                    }
                   
                   if (verifyHit()) {
                        delay(5000);
                        for (int ii = 0; ii < 3; ii++){
                          delay(1000);
                          IOShieldOled.clearBuffer();
                          IOShieldOled.updateDisplay();
                          delay(1000);
                          String displayHit = "HIT!";
                          char displayHitArray[20];
                          displayHit.toCharArray(displayHitArray, 5);
                          IOShieldOled.setCursor(8, 1);                          
                          IOShieldOled.putString(displayHitArray);
                        }
                    delay(1000);
                    digitalWrite(LD1, LOW);
                    delay(1000);
                    digitalWrite(LD2, LOW);
                    break;
                }

                }
            }
        }
    }
}

double InterceptionX() {
    double val = PI / 180.0;
    return (tan(theta2 * val) * 7 + 1) / (tan(theta2 * val) - 1);
}

double InterceptionY() {
    return InterceptionX() + 1;
}

//missile path B to target
double getd2() {
    double d2x = InterceptionX() - 7;
    double d2y = InterceptionY();
    return sqrt(pow((d2x), 2) + pow((d2y), 2));
}

//drone path P2 to target
double getd1() {
    double d1x = InterceptionX() - 7;
    double d1y = InterceptionY() - 8;
    return sqrt(pow((d1x), 2) + pow((d1y), 2));
}

double verifyHit() {  
    double t1 = getd1() / speed;   //Time for the drone to travel from P2 to target 
    double t2 = getd2() / missileSpeed; //Time for the missile to travel from B to target
    return (fabs(t1-t2)<.01);
}

void setSpeed(double distance, double timer){
  speed = calculateSpeed(distance, timer);
}

double getSpeed(){
  return speed;
}

//v1x = v1 * cos(theta1) :: v1 = distance/time, theta1 = tan-1(m1) :: m1 =  (y2-y1)/(x2-x1)
double getVx() {
    return Vx;
}

double setVx(double speed, double theta1) {
    double val = PI / 180.0;
    Vx = speed * cos(theta1 * val);
}

double getDroneX() {
    return droneX;
}

double setDroneX(double Vx, double time) {
    droneX = Vx;
}

double calculateSlope(int x1, int y1, int x2, int y2) {
    return m = (y2 - y1) / (x2 - x1);
}

double calculateDistance(int x1, int y1, int x2, int y2) {
    return sqrt(pow((x1 - x2), 2) + pow((y1 - y2), 2));
}

double calculateSpeed(double distance, double time) {
    return distance / time;
}

double calculateAngle(double m) {
    double val = 180.0 / PI;
    return atan(m) * val;
}

double calculateAngle(double velocityx, double velocity2) {
    return acos(velocityx / velocity2) * 180 / PI;
}
