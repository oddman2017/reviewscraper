//
//  ScraperAppDelegate.h
//  Scraper
//
//  Created by David Perry on 20/01/2009.
//  Copyright Didev Studios 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class App;

@interface ScraperAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, strong) NSMutableArray *apps;

- (void)saveApps;
- (void)deleteApp:(App *)appToDelete;
- (void)addApp:(App *)appToAdd;

+ (void) setEdgesForExtendedLayout:(UIViewController *)ctrl;

@end

