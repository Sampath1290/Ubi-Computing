//
//  ButtonViewController.m
//  BLE Chat
//
//  Created by Travis Siems on 5/6/17.
//  Copyright © 2017 Red Bear Company Limited. All rights reserved.
//

#import "ButtonViewController.h"
#import "SettingsTableViewController.h"


@interface ButtonViewController ()
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityAwarenessLabel;
@property (weak, nonatomic) IBOutlet UILabel *activatedLabel;


@end

@implementation ButtonViewController

int PROX_BUFFER_SIZE = 8;
NSInteger proxBuffer[8];
int proxIndex = 0;

bool isProxSensing = false;

int servoStartVal = 0;
int servoEndVal = 20;



- (void)sendMultiServo
{
    NSString *s;
    NSData *d;
    
    
    s = [NSString stringWithFormat: @"MServ %d %d %d;", servoStartVal,servoEndVal,servoStartVal];
    
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending: %@", s);
    [self.bleShield write:d];
}

- (void)requestData
{
    NSString *s;
    NSData *d;
    
    s = [NSString stringWithFormat: @"Req_PROX;"];
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending: %@", s);
    [self.bleShield write:d];
    
    s = [NSString stringWithFormat: @"Req_SERV;"];
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending: %@", s);
    [self.bleShield write:d];
    
    s = [NSString stringWithFormat: @"Req_SCHE;"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_proximityAwarenessLabel setHidden:true];
    self.activatedLabel.alpha = 0.0;
    
    for(int i = 0; i<PROX_BUFFER_SIZE; i += 1) {
        proxBuffer[i] = -200;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //add subscription to notifications from the app delegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidConnect:) name:kBleConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidDisconnect:) name:kBleDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidUpdateRSSI:) name:kBleRSSINotification object:nil];
    
    // this example function "onBLEDidReceiveData:" is done
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (onBLEDidReceiveData:) name:kBleReceivedDataNotification object:nil];
    
    [self requestData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //remove subscription to notifications from the app delegate
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [rssiReadTimer invalidate];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - RSSI timer
NSTimer *rssiReadTimer;
-(void) readRSSITimer:(NSTimer *)timer
{
    [self.bleShield readRSSI]; // be sure that the RSSI is up to date
}

#pragma mark - BLEdelegate protocol methods
-(void) onBLEDidUpdateRSSI:(NSNotification *)notification
{
    NSNumber *rssi =[notification.userInfo objectForKey:@"RSSI"];
    
    if( rssi.stringValue ) {
        self.rssiLabel.text = [@"RSSI: " stringByAppendingString: rssi.stringValue];
        
        if( isProxSensing ) {
            proxBuffer[ proxIndex % PROX_BUFFER_SIZE ] = rssi.integerValue;
            if( rssi.intValue > -59 ) {
                NSLog(@"NEAR!!");
                int count = 0;
                for(int i = 0; i<PROX_BUFFER_SIZE; i += 1) {
                    if( proxBuffer[i] > -59 ) {
                        count += 1;
                    }
                }
                if( count <= 1 ) {
                    [self sendMultiServo];
                    [self activateServoFromLocation];
                }
                NSLog(@"count: %d",count);
            }
            proxIndex += 1;
        }
        
    }
}

-(void) activateServoFromLocation {
    
    [self.activatedLabel.layer removeAllAnimations];
//    self.activatedLabel.transform = CGAffineTransformIdentity;
    self.activatedLabel.alpha = 1.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        self.activatedLabel.alpha = 0.0;
//        self.activatedLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    }];
    
//    UIView animate(withDuration: 2.0,
//                   delay: 0.0,
//                   options: [.curveEaseOut],
//                   animations: { [weak self] in
//                       self?.cueLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
//                       self?.cueLabel.alpha = 0.0
//                   }, completion: nil)
}


// NEW FUNCTION EXAMPLE: parse the received data from NSNotification
-(void) onBLEDidReceiveData:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSArray *array = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([array[0]  isEqual: @"SCHEDULE"]) {
        NSLog(@"SCHEDULE: %@",array[1]);
    } else if ([array[0]  isEqual: @"PROXCHECK"]) {
        NSLog(@"PROXCHECK: %@",array[1]);
        isProxSensing = [array[1] isEqualToString:@"1"];
        [_proximityAwarenessLabel setHidden: !isProxSensing];
    } else if ([array[0] isEqual: @"SERVOVALS"]) {
        NSLog(@"SERVOVALS: %@ %@",array[1],array[2]);
        servoStartVal = (int)[array[1] integerValue];
        servoEndVal = (int)[array[2] integerValue];
    }
    
    NSLog(@"ARRAY: %@",array);
    
}

// we disconnected, stop running
- (void) onBLEDidDisconnect:(NSNotification *)notification
{
    [rssiReadTimer invalidate];
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
                                    
                                    [self performSegueWithIdentifier:@"unwindToDevicesSegue" sender:self];
                                }];
    
    [alert addAction:yesButton];
    
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

// update a label on the UI to have the name of the active peripheral
-(void) onBLEDidConnect:(NSNotification *)notification
{
    NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    self.title = deviceName;
    
    // Schedule to read RSSI every 1 sec.
    rssiReadTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
    [self requestData];
}

- (IBAction)activateButtonPressed:(id)sender {
    [self sendMultiServo];
}

- (IBAction)cancelToButtonViewController:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Cancel back at ButtonView");
}

- (IBAction)saveToButtonViewController:(UIStoryboardSegue *)unwindSegu
{
    NSLog(@"Save back at ButtonView");
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if( [segue.identifier isEqualToString:@"goToSettingsSegue"] )
    {
        UINavigationController* vc = [segue destinationViewController];
        SettingsTableViewController *childController = (SettingsTableViewController *)vc.childViewControllers.lastObject;
        childController.servoStartingValue = [NSString stringWithFormat:@"%d",servoStartVal ];
        childController.servoEndingValue = [NSString stringWithFormat:@"%d",servoEndVal ];
        NSLog(@"Setting prox sensing switch: %d",isProxSensing);
        childController.isProximitySensing = isProxSensing;
    }
}




@end
