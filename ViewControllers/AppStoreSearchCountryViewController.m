//
//  AppStoreSearchCountryViewController.m
//  Scraper
//
//  Created by David Perry on 20/02/2009.
//  Copyright 2009 Didev Studios. All rights reserved.
//

#import "AppStoreSearchCountryViewController.h"
#import "CountryManager.h"

@implementation AppStoreSearchCountryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"SearchCountry", nil);
    selectedRow = [[NSUserDefaults standardUserDefaults] integerForKey:@"iTunesSearchCountry"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[CountryManager sharedManager] sortedCountryCodesByName] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppStoreSearchCountryCell"];
	
    if(cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AppStoreSearchCountryCell"];
    }
    
	NSString *countryCode = [[[CountryManager sharedManager] sortedCountryCodesByName] objectAtIndex:indexPath.row];
	cell.textLabel.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:countryCode];
		
	if(indexPath.row == selectedRow)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor colorWithRed:0.196f green:0.309f blue:0.521f alpha:1.0f];
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *tmp = [NSIndexPath indexPathForRow:selectedRow inSection:0];
	[[tableView cellForRowAtIndexPath:tmp] setAccessoryType:UITableViewCellAccessoryNone];
    [[tableView cellForRowAtIndexPath:tmp].textLabel setTextColor:[UIColor blackColor]];
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	[[tableView cellForRowAtIndexPath:indexPath].textLabel setTextColor:[UIColor colorWithRed:0.196f green:0.309f blue:0.521f alpha:1.0f]];
	
	selectedRow = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedRow forKey:@"iTunesSearchCountry"];
    [[NSUserDefaults standardUserDefaults] synchronize];

	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end

