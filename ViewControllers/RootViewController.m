//
//  RootViewController.m
//  Scraper
//
//  Created by David Perry on 20/01/2009.
//  Copyright Didev Studios 2009. All rights reserved.
//

#import "RootViewController.h"
#import "ScraperAppDelegate.h"
#import "AppsViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"

@implementation RootViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Views Scraper", nil);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Got memory warning!");
	[super didReceiveMemoryWarning];
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
	{
		return 1;
	}
	else if(section == 1)
	{
		return 2;
	}
	
	return 0;
}


- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
		return NSLocalizedString(@"Reviews", nil);
	}
	
	return NSLocalizedString(@"Configuration", nil);
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"RootCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if(cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	if(section == 0)
	{
		if(row == 0)
		{
			[cell.textLabel setText:NSLocalizedString(@"Apps", nil)];
			[cell.imageView setImage:[UIImage imageNamed:@"View.png"]];
		}
	}
	else if(section == 1)
	{
		if(row == 0)
		{
			[cell.textLabel setText:NSLocalizedString(@"Settings", nil)];
			[cell.imageView setImage:[UIImage imageNamed:@"Settings.png"]];
		}
		else if(row == 1)
		{
			[cell.textLabel setText:NSLocalizedString(@"About", nil)];
			[cell.imageView setImage:[UIImage imageNamed:@"About.png"]];
		}
	}
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	if(section == 0)
	{
		if(row == 0)
		{
            AppsViewController *avc = [[AppsViewController alloc] initWithStyle:UITableViewStylePlain];
			[self.navigationController pushViewController:avc animated:YES];
		}
	}
	else if(section == 1)
	{
		if(row == 0)
		{
			SettingsViewController *svc = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
			[self.navigationController pushViewController:svc animated:YES];
		}
		else if(row == 1)
		{
            AboutViewController *about = [[AboutViewController alloc] init];
			[self.navigationController pushViewController:about animated:YES];
		}
	}
}


@end

