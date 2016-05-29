//
//  AppDelegate.m
//  Save
//
//  Created by Jonathan Schober on 1/23/16.
//  Copyright © 2016 Jonathan Schober. All rights reserved.
//

#import "AppDelegate.h"
#define kTIXMailgunDomain @"sandbox4d9e0cac46ab454fb9bc75d92d2c1add.mailgun.org"
#define kTIXMailgunAPIKey @"key-a6e2f0dacaa1ed1d23edaa7691213d48"
#define kSaverServer @"https://saver.schober.org"
@implementation NSDictionary (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
+(void)sendEmailWithAmount:(float)amount{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [NSString stringWithFormat:@"%@/sendEmail", kSaverServer];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path ]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *bodyString = [NSString stringWithFormat:@"email=%@&name=%@&phone=%@&amount=%.2f",[defaults objectForKey:@"email"],[defaults objectForKey:@"name"],[defaults objectForKey:@"phone"],amount];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [urlRequest setHTTPBody:bodyData];
    NSLog(@"%@",[[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
    NSURLSession *session = [NSURLSession sharedSession];
    NSLog(@"%@",path);
    
    [[session dataTaskWithRequest:urlRequest
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    
                }] resume];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"application:didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSString *path = [NSString stringWithFormat:@"%@/notification_tokens.json",kSaverServer];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path ]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *bodyString = [NSString stringWithFormat:@"{\"notification_token\" :{\"token\": \"%@\"}, \"defaults\": %@}",deviceToken,[dict bv_jsonStringWithPrettyPrint:false]];
    NSLog(@"%@",bodyString);
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:bodyData];
        NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:urlRequest
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    
                }] resume];
    
    // Register the device token with a webservice
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}
@end
