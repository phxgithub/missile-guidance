//test
// EX-SimpleStateMachine-Starter
// 6-19-2014
// Coach

#include <IOShieldOled.h>

// set pin numbers:
const int BTN1 = 4;     // the number of the pushbutton pin
const int BTN2 = 78;    //***** Note: label on the board is for Uno32, this is MAX32, see MAX32 Reference Manual

const int ledPin =  13;     
const int LD1 =  70;     //***** Note: label on the board is for Uno32, this is MAX32, see MAX32 Reference Manual
const int LD2 =  71;     // ******** LD pins are corrected here.
			
const int LD3 =  72;
const int LD4 =  73;
const int LD5 =  74;
const int LD6 =  75;
const int LD7 =  76;
const int LD8 =  77;	 // System Operational LED

const int SW1 = 2;
const int SW2 = 7;
const int SW3 = 8;
const int SW4 = 79;     //***** Note: label on the I/O board is 35 for uno32 only

// variables:
int BTN1_state = 0;         // variable for reading the pushbutton status
int BTN2_state = 0;         // variable for reading the pushbutton status
int SW1_state = 0; 
int SW2_state = 0; 
int SW3_state = 0; 
int SW4_state = 0; 

double m;// slope
double distance;// sqrt(pow(y2-y1,2)+pow(x2-x1,2))
double velocity;// distance/time
double elapsedTime = 1.23;
double theta2Angle = 0.0000;
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
  pinMode(ledPin, OUTPUT);  
  pinMode(LD1, OUTPUT);  
  pinMode(LD2, OUTPUT);    
  pinMode(LD3, OUTPUT);  
  pinMode(LD4, OUTPUT);     
  pinMode(LD5, OUTPUT);  
  pinMode(LD6, OUTPUT);    
  pinMode(LD7, OUTPUT);  
  pinMode(LD8, OUTPUT);     

  // initialize the pushbutton pin as an input:
  pinMode(BTN1, INPUT);  

  // initialize switches as inputs:
   pinMode(SW1, INPUT);  
   pinMode(SW2, INPUT);
   pinMode(SW3, INPUT);
   pinMode(SW4, INPUT); 
   
  // Turn OFF all LEDs
 digitalWrite(LD1, LOW); 
 digitalWrite(LD2, LOW); 
 digitalWrite(LD3, LOW); 
 digitalWrite(LD4, LOW);  

 digitalWrite(LD5, LOW); 
 digitalWrite(LD6, LOW); 
 digitalWrite(LD7, LOW); 
 digitalWrite(LD8, LOW); 
  
	// Initialize OLED
	IOShieldOled.begin();
	IOShieldOled.displayOn();

}  // end setup()

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
        
        double m;// slope
        
        double distance;// sqrt(pow(y2-y1,2)+pow(x2-x1,2))
        double speed;// distance/time
        double theta1;
        double Vx;

        BTN1_state = digitalRead(BTN1);
        BTN2_state = digitalRead(BTN2);
	
            if (BTN1_state == HIGH){ //Is BTN1 i pressed??
              delay(5); //wait 5 mS for any pushbutton bounce to disappear
              BTN1_state = digitalRead(BTN1); //read the value on the pushbutton pin again
          
              if(BTN1_state == HIGH) //is it still HIGH (pressed)
              {
                digitalWrite(LD1, HIGH); //Light LD1>
                digitalWrite(LD2, LOW);
              }
          
            //otherwise
            else {
              BTN2_state = digitalRead(BTN2);
                while (BTN2_state == LOW){
                    delay(1000);
                    count++; 
                   
                    //clear the display and reset the cursor to zero
            	    IOShieldOled.clearBuffer();
                    
                    //set the cursor to display elapsed time
            	    IOShieldOled.setCursor(0,0);
                    //create a string to display the elapsed time on the OLED screen
                    displayElapsedTime="Time: ";
                    displayElapsedTime.toCharArray(displayElapsedTimeArray,7);
                    //display it @OLED:
                    IOShieldOled.putString(displayElapsedTimeArray);
                    //convert the value to a char[] because we're using putString() :: also use sprintf() because we're converting a double :: see http://stackoverflow.com/questions/7462349/convert-double-value-to-a-char-array-in-c
                    sprintf(elapsedTimeArray, "%2.2f", count);
                    //append the elapsed time value to the string & display it @OLED:
                    IOShieldOled.putString(elapsedTimeArray);
                    IOShieldOled.updateDisplay(); 
                    
                    BTN1_state = digitalRead(BTN1);
                    BTN2_state = digitalRead(BTN2);
                
    	            if (BTN2_state == HIGH){
                        digitalWrite(LD2, HIGH);
        	        m = calculateSlope(x1, y1, x2, y2);
        		distance = calculateDistance(x1, y1, x2, y2);
        		speed = calculateSpeed(distance, count);
        		theta1 = calculateAngle(m);
                        setVx(speed, theta1);
                        Vx = getVx();
                        setDroneX(Vx, count);
                        droneX = getDroneX();
                        //set the cursor to display launch angle
              	        IOShieldOled.setCursor(0,2);
                        //create a string to display the elapsed time on the OLED screen
                        displayTheta2Angle="Angle: ";
                        displayTheta2Angle.toCharArray(displayTheta2AngleArray,8);
                        //display it @OLED:
                        IOShieldOled.putString(displayTheta2AngleArray);
                        //convert the value to a char[] because we're using putString() :: also use sprintf() because we're converting a double :: see http://stackoverflow.com/questions/7462349/convert-double-value-to-a-char-array-in-c
                        sprintf(theta2AngleArray, "%2.4f", droneX);
                        //append the elapsed time value to the string & display it @OLED:
                        IOShieldOled.putString(theta2AngleArray);
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

//v1x = v1 * cos(theta1) = 0.1885 * cos(450)= 0.1885 * 0.7071 = 0.1333 miles  seconds
double getVx(){   
   return Vx;
}

double setVx(double speed, double theta1){
  double val = PI / 180.0;
  Vx = speed * cos( theta1 * val );
}


double getDroneX(){
  return droneX;
}

double setDroneX(double Vx, double time){
 droneX =  7 + Vx * time;
}

double calculateSlope(int x1, int y1, int x2, int y2){
    return m = (y2 - y1) / (x2 - x1);
}

double calculateDistance(int x1, int y1, int x2, int y2){
    return sqrt ( pow((x1-x2), 2) + pow((y1-y2), 2) );
}

double calculateSpeed(double distance, double time){
    return distance / time;
}

double calculateAngle(double m){
   double val = 180.0 / PI;
   return atan (m) * val;
}
