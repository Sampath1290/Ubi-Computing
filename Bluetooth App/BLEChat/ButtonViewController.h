//
//  ButtonViewController.h
//  BLE Chat
//
//  Created by Travis Siems on 5/6/17.
//  Copyright © 2017 Red Bear Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface ButtonViewController : UIViewController

@property (strong, nonatomic) BLE* bleShield;

@end
