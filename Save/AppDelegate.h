//
//  AppDelegate.h
//  Save
//
//  Created by Jonathan Schober on 1/23/16.
//  Copyright © 2016 Jonathan Schober. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+(void)sendEmailWithAmount:(float)amount;

@end

