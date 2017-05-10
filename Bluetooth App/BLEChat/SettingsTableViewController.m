//
//  SettingsTableViewController.m
//  BLE Chat
//
//  Created by Travis Siems on 5/6/17.
//  Copyright © 2017 Red Bear Company Limited. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation SettingsTableViewController


//NSString* servoStartingValue = @"0";
//NSString* servoEndingValue = @"20";
NSTimer* secondTimer;
NSDate* scheduledDateCountDown;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    _datePicker = [[UIDatePicker alloc]init];
    _datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    [self.timeTextField setInputView:_datePicker];
    
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(showSelectedDate)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    
    [self.timeTextField setInputAccessoryView:toolBar];
    
    //Looks for single or multiple taps.
    //    UITapGestureRecognizer *tap  = [UITabGestureRecognizer init:target:]
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismissKeyboard:)];

    [self.view addGestureRecognizer:tap];
    
    NSInteger sliderValue = (int)[_servoSlider value];
    _servoValueLabel.text = [NSString stringWithFormat:@"%ld", (long)sliderValue];
    
    self.servoStartField.text = self.servoStartingValue;
    self.servoEndField.text = self.servoEndingValue;
    [self.proximityAwarenessSwitch setOn:self.isProximitySensing];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [secondTimer invalidate];
    
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

-(NSString*)servoStartingValue
{
    if (!_servoStartingValue) {
        _servoStartingValue = @"0";
    }
    return _servoStartingValue;
}

-(NSString*)servoEndingValue
{
    if (!_servoStartingValue) {
        _servoEndingValue = @"0";
    }
    return _servoEndingValue;
}

-(bool)isProximitySensing
{
    if (!_isProximitySensing) {
        _isProximitySensing = false;
    }
    return _isProximitySensing;
}

- (void) showSelectedDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    self.timeTextField.inputView value
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    scheduledDateCountDown = [_datePicker date];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:scheduledDateCountDown];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    
    NSString *s;
    NSData *d;
    
    //    s = [NSString stringWithFormat: @"MultiSchedule %ld %d %d %d;", hour*60*60+minute*60+second, servoStartValue.intValue,servoEndValue.intValue,servoStartValue.intValue];
    
    s = [NSString stringWithFormat: @"Schedule %ld;", (long)hour*60*60+minute*60+second];
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Sending Schedule: %@", s);
    [self.bleShield write:d];
    
    //    [self.timeTextField setText: [dateFormatter stringFromDate: [_datePicker date]] ];
    [self.view endEditing:true];
    
    if( secondTimer ) {
        [secondTimer invalidate];
    }
    secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    
    NSLog(@"SHOW SELECTED DATE");
}

- (void) updateLabel
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    self.timeTextField.inputView value
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    NSString *text = [dateFormatter stringFromDate: scheduledDateCountDown];
    [self.timeTextField setText: text ];
    
    if( [text isEqual:@"00:00:00"] ) {
        NSLog(@"Done!");
        [secondTimer invalidate];
    }
    //    NSLog(text);
    scheduledDateCountDown = [scheduledDateCountDown dateByAddingTimeInterval:-1];
    
    //    if( dateTillTimer )
}

-(void) dismissKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:true];
    
    NSString *startVal = [self.servoStartField text];
    NSString *endVal = [self.servoEndField text];
    
    if (startVal.intValue < 0 || startVal.intValue > 180) {
        [self.servoStartField setText:self.servoStartingValue];
    } else {
        _servoStartingValue = [self.servoStartField text];
    }
    if (endVal.intValue < 0 || endVal.intValue > 180) {
        [self.servoEndField setText:self.servoEndingValue];
    } else {
        _servoEndingValue = [self.servoEndField text];
    }
    //    NSNumber *rssi =[notification.userInfo objectForKey:@"RSSI"];
    //    self.labelRSSI.text = rssi.stringValue; // when RSSI read is complete, display it
}

- (IBAction)servoChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger sliderValue = (int)[slider value];
    _servoValueLabel.text = [NSString stringWithFormat:@"%ld", (long)sliderValue];
    
    
    NSString *s;
    NSData *d;
    
    
    s = [NSString stringWithFormat: @"Servo %ld;", (long)sliderValue];
    
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Sending SErvo: %@", s);
    [self.bleShield write:d];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return 5;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if( [segue.identifier isEqualToString:@"cancelSettingChangesSegue"] )
    {
        
    }
    else if( [segue.identifier isEqualToString:@"saveSettingChangesSegue"] )
    {
        NSLog(@"SAVING VALUES:");
        [self saveProximityValue];
        [self saveServoValues];
    }
}

- (void)saveProximityValue
{
    NSString *s;
    NSData *d;
    
    s = [NSString stringWithFormat: @"S_PROX %d;", _proximityAwarenessSwitch.isOn];
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending: %@", s);
    [self.bleShield write:d];
}

- (void)saveServoValues
{
    NSString *s;
    NSData *d;
    
    s = [NSString stringWithFormat: @"S_SERV %@ %@ %@;", self.servoStartingValue, self.servoEndingValue, self.servoStartingValue];
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending: %@", s);
    [self.bleShield write:d];
}


@end
