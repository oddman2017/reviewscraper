//
//  ScraperAppDelegate.m
//  Scraper
//
//  Created by David Perry on 20/01/2009.
//  Copyright Didev Studios 2009. All rights reserved.
//

#import "ScraperAppDelegate.h"
#import "RootViewController.h"
#import "CountryManager.h"
#import "App.h"

@interface ScraperAppDelegate (Private)
- (void)resetAppStoreSearchCountry;
- (NSString *)currentLocaleName;
@end

@implementation ScraperAppDelegate {
    UINavigationController *_navigationController;
    NSString *_docPath;
}

+ (void) setEdgesForExtendedLayout:(UIViewController *)ctrl {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wdeprecated"
    // http://www.ifun.cc/blog/2014/02/08/gua-pei-ios7kai-fa-1/
    if ([ctrl respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [ctrl setEdgesForExtendedLayout:UIRectEdgeNone];
    }
#pragma clang diagnostic pop
}

- (void) applicationDidFinishLaunching:(UIApplication *)application {
    _docPath = [self getDocPath];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *testValue = [userDefaults stringForKey:@"LocaleName"];
		
	if(testValue == nil)
	{
		[userDefaults setInteger:0 forKey:@"AllowedOrientation"];
		[userDefaults setInteger:0 forKey:@"iTunesSearchCountry"];
		
		[self resetAppStoreSearchCountry];
		
		[userDefaults synchronize];
	}
	else
	{		
		if(![[userDefaults objectForKey:@"LocaleName"] isEqualToString:[self currentLocaleName]])
		{			
			[self resetAppStoreSearchCountry];
			
			[userDefaults synchronize];
		}
	}
	
	NSInteger orientation = [userDefaults integerForKey:@"AllowedOrientation"];
	
	if(orientation > 0)
	{
		[UIApplication sharedApplication].statusBarOrientation = orientation;
	}
	
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.backgroundColor = [UIColor blackColor];
	[_window makeKeyAndVisible];

    RootViewController *root = [[RootViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:root];
    self.window.rootViewController = _navigationController;

    [self _initApps];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    [self saveApps];
}

#pragma mark - Private Methods

- (void)resetAppStoreSearchCountry
{
	NSString *localeName = [self currentLocaleName];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:localeName forKey:@"LocaleName"];
	
	for(int i = 0;i < [[[CountryManager sharedManager] sortedCountryCodesByName] count]; i++)
	{
		NSString *countryName = [[[CountryManager sharedManager] sortedCountryCodesByName] objectAtIndex:i];
		
		if([localeName isEqualToString:countryName])
		{
			[userDefaults setInteger:i forKey:@"iTunesSearchCountry"];
		}
	}
}

			
- (NSString *)currentLocaleName
{
	NSLocale *locale = [NSLocale currentLocale];
	return [[locale objectForKey:NSLocaleCountryCode] lowercaseString];
}

#pragma mark - Class Methods

- (void) _initApps {
    _apps = [[NSMutableArray alloc] init];

    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_docPath error:nil];
    for (NSString *fileName in fileNames) {
        if (![[fileName pathExtension] isEqualToString:@"dat"]) {
            continue;
        }
        NSString *fullPath = [_docPath stringByAppendingPathComponent:fileName];

        App *app = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        if (app) {
            [_apps addObject:app];
        }
    }

    [_apps sortUsingComparator:^NSComparisonResult(App *app1, App *app2) {
        NSInteger v1 = app1.sortIndex;
        NSInteger v2 = app2.sortIndex;
        if (v1 < v2) {
            return NSOrderedAscending;
        } else if (v1 > v2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}


- (NSString *) getDocPath {
    static NSString *documentsDirectory = nil;
    if (!documentsDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
    }
    return documentsDirectory;
}


- (void) saveApps {
    [_apps enumerateObjectsUsingBlock:^(App *app, NSUInteger idx, BOOL *stop) {
        app.sortIndex = idx;
        NSString *fullPath = [_docPath stringByAppendingPathComponent:[app filename]];
        [NSKeyedArchiver archiveRootObject:app toFile:fullPath];
    }];
}


- (void) deleteApp:(App *)appToDelete {
    NSString *fullPath = [_docPath stringByAppendingPathComponent:[appToDelete filename]];
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:NULL];

    [_apps removeObject:appToDelete];
}

- (void) addApp:(App *)appToAdd {
    [_apps addObject:appToAdd];
}

@end
