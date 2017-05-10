//
//  SettingsTableViewController.h
//  BLE Chat
//
//  Created by Travis Siems on 5/6/17.
//  Copyright © 2017 Red Bear Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "AppDelegate.h"

@interface SettingsTableViewController : UITableViewController {
//    public NSString* servoStartingValue;
//    public NSString* servoEndingValue;
}
@property (weak, nonatomic) IBOutlet UITextField *servoStartField;
@property (weak, nonatomic) IBOutlet UITextField *servoEndField;
@property (weak, nonatomic) IBOutlet UISlider *servoSlider;
@property (weak, nonatomic) IBOutlet UISwitch *proximityAwarenessSwitch;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UILabel *servoValueLabel;

@property (nonatomic) NSString* servoStartingValue;
@property (nonatomic) NSString* servoEndingValue;
@property (nonatomic) bool isProximitySensing;


@property (strong, nonatomic) BLE* bleShield;

@end
