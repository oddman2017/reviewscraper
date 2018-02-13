//
//  SettingsViewController.m
//  Scraper
//
//  Created by David Perry on 20/01/2009.
//  Copyright 2009 Didev Studios. All rights reserved.
//

#import "SettingsViewController.h"
#import "OrientationSettings.h"
#import "CountryManager.h"
#import "AppStoreSearchCountryViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Settings", nil);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Got memory warning!");
	[super didReceiveMemoryWarning];
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
        return NSLocalizedString(@"AppStoreSearchCountry", nil);
	}
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
	
    if(cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SettingsCell"];
    }
    
	if(indexPath.section == 0)
	{
		NSInteger country = [[NSUserDefaults standardUserDefaults] integerForKey:@"iTunesSearchCountry"];
		NSString *countryCode = [[[CountryManager sharedManager] sortedCountryCodesByName] objectAtIndex:country];
		cell.textLabel.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:countryCode];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(indexPath.section == 0)
	{
        AppStoreSearchCountryViewController *appStoreSearchCountryViewController =
        [[AppStoreSearchCountryViewController alloc] initWithStyle:UITableViewStylePlain];

		[self.navigationController pushViewController:appStoreSearchCountryViewController animated:YES];
	}
}

@end
