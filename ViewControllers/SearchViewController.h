//
//  SearchViewController.h
//  Scraper
//
//  Created by David Perry on 28/01/2009.
//  Copyright 2009 Didev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController
@property (nonatomic, strong) dispatch_block_t callbackRefresh;
@end
