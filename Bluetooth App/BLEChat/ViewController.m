//
//  ViewController.m
//  BLEChat
//
//  Created by Cheong on 15/8/12.
//  Modified by Eric Larson, 2014
//  Copyright (c) 2012 RedBear Lab., All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *peripheralLabel;
@property (weak, nonatomic) IBOutlet UISlider *servoSlider;
@property (weak, nonatomic) IBOutlet UISwitch *proximityAwarenessSwitch;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation ViewController

NSString* servoStartValue = @"0";
NSString* servoEndValue = @"20";
NSTimer* timer;
NSDate* dateTillTimer;

//void) sendMultiServo();

int BUFFER_SIZE = 20;

NSInteger proximityBuffer[20];
int proximityIndex = 0;

//UIDatePicker* datePicker = [[UIDatePicker alloc]init];

- (void)sendMultiServo
{
    NSString *s;
    NSData *d;
    
    
    s = [NSString stringWithFormat: @"MultiServo %d %d %d;", servoStartValue.intValue,servoEndValue.intValue,servoStartValue.intValue];
    
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending: %@", s);
    [self.bleShield write:d];
}

// lazy instantiation
-(BLE*)bleShield
{
    if (!_bleShield) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _bleShield = appDelegate.bleShield;
    }
    return _bleShield;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for(int i = 0; i<BUFFER_SIZE; i += 1) {
        proximityBuffer[i] = -200;
    }
    
    
    _datePicker = [[UIDatePicker alloc]init];
    _datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    [self.timeTextField setInputView:_datePicker];
    
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(showSelectedDate)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    
    [self.timeTextField setInputAccessoryView:toolBar];
    

    
    //add subscription to notifications from the app delegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidConnect:) name:kBleConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidDisconnect:) name:kBleDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidUpdateRSSI:) name:kBleRSSINotification object:nil];
    
    // this example function "onBLEDidReceiveData:" is done
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (onBLEDidReceiveData:) name:kBleReceivedDataNotification object:nil];
    
    //Looks for single or multiple taps.
//    UITapGestureRecognizer *tap  = [UITabGestureRecognizer init:target:]
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismissKeyboard:)];
    
    //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
    //tap.cancelsTouchesInView = false
    
    [self.view addGestureRecognizer:tap];
    
//    _bleShield


}

- (void) showSelectedDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    self.timeTextField.inputView value
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    dateTillTimer = [_datePicker date];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:dateTillTimer];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    
    NSString *s;
    NSData *d;
    
//    s = [NSString stringWithFormat: @"MultiSchedule %ld %d %d %d;", hour*60*60+minute*60+second, servoStartValue.intValue,servoEndValue.intValue,servoStartValue.intValue];
    
    s = [NSString stringWithFormat: @"Schedule %ld;", hour*60*60+minute*60+second];
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Sending Schedule: %@", s);
    [self.bleShield write:d];
    
//    [self.timeTextField setText: [dateFormatter stringFromDate: [_datePicker date]] ];
    [self.view endEditing:true];
    
    if( timer ) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    
    NSLog(@"SHOW SELECTED DATE");
}

- (void) updateLabel
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    self.timeTextField.inputView value
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    NSString *text = [dateFormatter stringFromDate: dateTillTimer];
    [self.timeTextField setText: text ];
    
    if( [text isEqual:@"00:00:00"] ) {
        NSLog(@"Done!");
        [timer invalidate];
    }
//    NSLog(text);
    dateTillTimer = [dateTillTimer dateByAddingTimeInterval:-1];
    
//    if( dateTillTimer )
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}



-(void) dismissKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:true];
    
    NSString *startVal = [self.servoStartField text];
    NSString *endVal = [self.servoEndField text];
    
    if (startVal.intValue < 0 || startVal.intValue > 180) {
        [self.servoStartField setText:servoStartValue];
    } else {
        servoStartValue = [self.servoStartField text];
    }
    if (endVal.intValue < 0 || endVal.intValue > 180) {
        [self.servoEndField setText:servoEndValue];
    } else {
        servoEndValue = [self.servoEndField text];
    }
//    NSNumber *rssi =[notification.userInfo objectForKey:@"RSSI"];
//    self.labelRSSI.text = rssi.stringValue; // when RSSI read is complete, display it
}


//setup auto rotation in code
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - RSSI timer
NSTimer *rssiTimer;
-(void) readRSSITimer:(NSTimer *)timer
{
    [self.bleShield readRSSI]; // be sure that the RSSI is up to date
}

#pragma mark - BLEdelegate protocol methods
-(void) onBLEDidUpdateRSSI:(NSNotification *)notification
{
    NSNumber *rssi =[notification.userInfo objectForKey:@"RSSI"];
    
    if( rssi.stringValue ) {
        self.labelRSSI.text = rssi.stringValue; // when RSSI read is complete, display it
        NSLog(@"RSSI: %@",rssi.stringValue);
        self.label.text = [@"RSSI: " stringByAppendingString: rssi.stringValue];
        proximityBuffer[proximityIndex%BUFFER_SIZE] = rssi.integerValue;
        if( _proximityAwarenessSwitch.isOn ) {
            if( rssi.intValue > -59 ) {
                NSLog(@"NEAR!!");
                int count = 0;
                for(int i = 0; i<BUFFER_SIZE; i += 1) {
                    if( proximityBuffer[i] > -59 ) {
                        count += 1;
                    }
                }
                if( count <= 1 ) {
                    [self sendMultiServo];
                }
                NSLog(@"count: %d",count);
            }
        }
        proximityIndex += 1;
    }
}


// NEW FUNCTION EXAMPLE: parse the received data from NSNotification
-(void) onBLEDidReceiveData:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSArray *array = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([array[0]  isEqual: @"BTN"]) {
        
        if ([array[1] isEqual:@"HOLD"]) {

        }
    } else if ([array[0]  isEqual: @"POT"]) {

    }
    
}

// we disconnected, stop running
- (void) onBLEDidDisconnect:(NSNotification *)notification
{
    //CHANGE 5.b: remove all instances of the button at top
//    [self.buttonConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [rssiTimer invalidate];
    NSLog(@"DISCONNECTED!!!"); // should now go back to tableviewcontroller
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Gizmo Disconnected"
                                 message:@"Lost connection to the Gizmo. Returning to menu."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    NSLog(@"OKAY!");
                                    
                                    [self performSegueWithIdentifier:@"unwindToMenuSegue" sender:self];
                                }];
    
//    UIAlertAction* noButton = [UIAlertAction
//                               actionWithTitle:@"No, thanks"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                   //Handle no, thanks button
//                               }];
    
    [alert addAction:yesButton];
//    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Cancel Tapped.");
    }
    else if (buttonIndex == 1) {
        NSLog(@"OK Tapped. Hello World!");
    }
}

//CHANGE 7: create function called from "BLEDidConnect" notification (you can change the function below)
// in this function, update a label on the UI to have the name of the active peripheral
// you might be interested in the following method:
// NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
// now just wait to send or receive
-(void) onBLEDidConnect:(NSNotification *)notification
{
    //CHANGE 5.a: Remove all usage of the connect button and remove from storyboard
    [self.spinner stopAnimating];
//    [self.buttonConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    self.peripheralLabel.text = deviceName;
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}



#pragma mark - UI operations storyboard
- (IBAction)BLEShieldSend:(id)sender
{
    
    //Note: this function only needs a name change, the BLE writing does not change
    NSString *s;
    NSData *d;
    
    if (self.textField.text.length > 16)
        s = [self.textField.text substringToIndex:16];
    else
        s = self.textField.text;

    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleShield write:d];
}


- (IBAction)servoChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger sliderValue;
    sliderValue = (int)[slider value];
    NSString *s;
    NSData *d;
    
    
    s = [NSString stringWithFormat: @"Servo %ld;", (long)sliderValue];

    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Sending SErvo: %@", s);
    [self.bleShield write:d];
}



- (IBAction)activateButtonPressed:(id)sender {
    [self sendMultiServo];
}

@end
