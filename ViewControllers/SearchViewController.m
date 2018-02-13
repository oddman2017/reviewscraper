//
//  SearchViewController.m
//  Scraper
//
//  Created by David Perry on 28/01/2009.
//  Copyright 2009 Didev Studios. All rights reserved.
//

#import "SearchViewController.h"
#import "AppCell.h"
#import "AppsViewController.h"
#import "App.h"
#import "SearchDownloader.h"
#import "RemoteAppCell.h"
#import "RemoteAppMoreCell.h"
#import "ImageCache.h"
#import "ProgressActivityView.h"
#import "RemoteAppDidYouMeanCell.h"
#import "UIImage+Mask.h"
#import "ScraperAppDelegate.h"

@interface SearchViewController (Private) <UISearchDisplayDelegate>
- (void)loadContentForCells:(NSArray *)cells;
@end


@implementation SearchViewController {
    __weak ScraperAppDelegate *_appDelegate;

    ProgressActivityView *_progressActivityView;

    SearchDownloader *_searchDownloader;

    UISearchDisplayController *_searchDisplayController;
    UISearchBar *_searchBar;

    UITableView *_resultsView;

    NSIndexPath *_cellToDelete;
    NSMutableArray *_searchHints;
    NSMutableArray *_searchResults;
}

- (instancetype) initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];

    if (self) {
        _searchHints = [[NSMutableArray alloc] init];
        _searchResults = [[NSMutableArray alloc] init];
        _searchDownloader = [[SearchDownloader alloc] init];

        _appDelegate = (ScraperAppDelegate *)[UIApplication sharedApplication].delegate;
    }

	return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [ScraperAppDelegate setEdgesForExtendedLayout:self];

    self.title = NSLocalizedString(@"Search", nil);
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	_searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.tableView.tableHeaderView = _searchBar;

    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [_searchBar becomeFirstResponder];
}


- (void)viewDidDisappear:(BOOL)animated
{	
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
	[_searchResults removeAllObjects];
	[_searchHints removeAllObjects];
	_searchBar.text = @"";
	[self.tableView reloadData];
	
	[_resultsView removeFromSuperview];
	
	[[ImageCache sharedCache] flushCache];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Got memory warning!");
	[[ImageCache sharedCache] flushCache];
	
	[super didReceiveMemoryWarning];
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
	
	if(aTableView == self.tableView)
	{
		count = [_searchHints count];
	}
	else
	{
		count = [_searchResults count];
	}
	
	if(count == 0)
	{
		if(_searchBar.text.length > 0)
		{
			count = 1;
		}
	}
	
	return count;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if(aTableView == self.tableView)
	{		
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"HintCell"];
		
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HintCell"];
		}
	
		if([_searchHints count] > 0)
		{
			NSDictionary *aHint = [_searchHints objectAtIndex:indexPath.row];
	
			cell.textLabel.text = [aHint objectForKey:@"term"];
			cell.userInteractionEnabled = YES;
		}
		else
		{
			cell.textLabel.text = @"No results found";
			cell.userInteractionEnabled = NO;
		}

		return cell;
	}
	
	if([_searchResults count] == 0)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
		
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.text = @"No results found";
		cell.textLabel.font = [UIFont italicSystemFontOfSize:18];
		cell.userInteractionEnabled = NO;
		
		return cell;
	}
	
	NSDictionary *aResult = [_searchResults objectAtIndex:indexPath.row];
	
	NSString *type = [aResult objectForKey:@"type"];
	
	if([type isEqualToString:@"link"])
	{	
		NSString *linkType = [aResult objectForKey:@"link-type"];
		
		if([linkType isEqualToString:@"software"])
		{
			RemoteAppCell *cell = [[RemoteAppCell alloc] initWithFrame:CGRectZero];
		
			NSArray *artworkURLS = [aResult objectForKey:@"artwork-urls"];
			NSDictionary *dict = [artworkURLS objectAtIndex:0];
			
			NSNumber *needsShine = [dict objectForKey:@"needs-shine"];
			cell.needsShine = [needsShine boolValue];
		
			[cell setURL:[dict objectForKey:@"url"]];
		
			cell.artistView.text = [aResult objectForKey:@"artist-name"];
			cell.titleView.text = [aResult objectForKey:@"title"];
		
			NSNumber *ratingCount = [aResult objectForKey:@"user-rating-count"];
			cell.reviewView.text = [NSString stringWithFormat:@"%d reviews", [ratingCount intValue]];
		
			NSNumber *rating = [aResult objectForKey:@"average-user-rating"];
		
			NSInteger trueRating = (NSInteger)(5 * [rating floatValue]);
		
			switch(trueRating)
			{
				case 5:
					[cell.ratingView setImage:[UIImage imageNamed:@"5stars_16.png"]];
					break;
				
				case 4:
					[cell.ratingView setImage:[UIImage imageNamed:@"4stars_16.png"]];
					break;
				
				case 3:
					[cell.ratingView setImage:[UIImage imageNamed:@"3stars_16.png"]];
					break;
				
				case 2:
					[cell.ratingView setImage:[UIImage imageNamed:@"2stars_16.png"]];
					break;
				
				case 1:
					[cell.ratingView setImage:[UIImage imageNamed:@"1star_16.png"]];
					break;
				
				case 0:
					[cell.ratingView setImage:[UIImage imageNamed:@"0star_16.png"]];
					break;
				
				default:
					break;
			}
		
			return cell;
		}
		else
		{
			RemoteAppDidYouMeanCell *cell = [[RemoteAppDidYouMeanCell alloc] initWithFrame:CGRectZero];
			
			cell.textLabel.text = [aResult objectForKey:@"title"];
			
			return cell;
		}
	}
	else if([type isEqualToString:@"more"])
	{		
		RemoteAppMoreCell *cell = [[RemoteAppMoreCell alloc] initWithFrame:CGRectZero];
		
		cell.textLabel.text = [aResult objectForKey:@"title"];
		
		return cell;
	}
	else if([type isEqualToString:@"separator"])
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
		
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.text = [aResult objectForKey:@"title"];
		cell.textLabel.font = [UIFont italicSystemFontOfSize:18];
		
		return cell;
	}
	else
	{
		NSLog(@"%@", [aResult description]);
	}
	
	return nil;
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(aTableView == self.tableView)
	{
		return 30.0f;
	}
	
	return 70.0f;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(aTableView == self.tableView)
	{
		if([_searchHints count] == 0)
		{
			return;
		}
		
		[_searchBar resignFirstResponder];
		
		NSDictionary *aHint = [_searchHints objectAtIndex:indexPath.row];
		
		NSString *urlString = [aHint objectForKey:@"url"];
		
		_progressActivityView = [[ProgressActivityView alloc] initWithFrame:self.tableView.frame];
		
		[self.view addSubview:_progressActivityView];
		
		[_searchResults removeAllObjects];
		[_searchDownloader requestWithUrl:urlString delegate:self type:kSearchResults];
		
		return;
	}
	
	if([_searchResults count] == 0)
	{
		return;
	}
	
	NSDictionary *aResult = [_searchResults objectAtIndex:indexPath.row];
	
	NSString *type = [aResult objectForKey:@"type"];
		
	if([type isEqualToString:@"link"])
	{
		NSString *linkType = [aResult objectForKey:@"link-type"];
		
		if([linkType isEqualToString:@"software"])
		{
			[_searchDownloader cancel];
		
			NSInteger appID = [[aResult objectForKey:@"item-id"] integerValue];
		
			NSArray *artworkURLS = [aResult objectForKey:@"artwork-urls"];
			NSDictionary *dict = [artworkURLS objectAtIndex:0];
			
			NSNumber *needsShine = [dict objectForKey:@"needs-shine"];
				
			App *newApp = [[App alloc] initWithName:[aResult objectForKey:@"title"] appCode:[NSString stringWithFormat: @"%ld", (long)appID] appArtist:[aResult objectForKey:@"artist-name"]];
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"url"]]]];
			newApp.image = [image imageWithRoundedCorners:[needsShine boolValue]];
			newApp.sortIndex = [_appDelegate.apps count];
			[_appDelegate addApp:newApp];

            if (_callbackRefresh) {
                _callbackRefresh();
            }

			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
		else
		{
			[_searchDownloader cancel];
			
			[_searchDownloader requestWithUrl:[aResult objectForKey:@"url"] delegate:self type:kSearchResults];
			[_searchResults removeAllObjects];
			
			RemoteAppMoreCell *cell = (RemoteAppMoreCell *)[_resultsView cellForRowAtIndexPath:indexPath];
			[cell.contentView addSubview:cell.activityIndicator];
		}
	}
	else if([type isEqualToString:@"more"])
	{
		[_searchDownloader cancel];
		
		[_searchDownloader requestWithUrl:[aResult objectForKey:@"url"] delegate:self type:kSearchResults];
		_cellToDelete = indexPath;
		
		RemoteAppMoreCell *cell = (RemoteAppMoreCell *)[_resultsView cellForRowAtIndexPath:indexPath];
		[cell.contentView addSubview:cell.activityIndicator];
	}
}

#pragma mark - SearchBar Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{	
	NSString *urlString = [NSString stringWithFormat:@"http://ax.search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?media=software&q=%@", [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[_searchDownloader requestWithUrl:urlString delegate:self type:kSearchHints];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	[_searchBar resignFirstResponder];
	
	[_searchResults removeAllObjects];
	
	_progressActivityView = [[ProgressActivityView alloc] initWithFrame:self.tableView.frame];
	
	[self.view addSubview:_progressActivityView];

    NSString *url = [NSString stringWithFormat:@"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?submit=edit&term=%@&media=software",
                     [theSearchBar.text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

	[_searchDownloader requestWithUrl:url delegate:self type:kSearchResults];
}

#pragma mark - ScrollView Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self loadContentForCells:[_resultsView visibleCells]];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
	{
		[self loadContentForCells:[_resultsView visibleCells]];
    }
}

#pragma mark - Private Methods

- (void)addResultsView
{
	if(!_resultsView)
	{
		CGRect frame = self.tableView.frame;
		CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 416);
		_resultsView = [[UITableView alloc] initWithFrame:newFrame];
		_resultsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_resultsView.userInteractionEnabled = YES;
		_resultsView.delegate = self;
		_resultsView.dataSource = self;
	
		[self.view insertSubview:_resultsView belowSubview:_progressActivityView];
		[_resultsView reloadData];
	}
	
	[self loadContentForCells:[_resultsView visibleCells]];
	
	[_progressActivityView fadeOut];
}


- (void)didFinishDownloadSearchHints:(NSData *)data
{	
	if([data length] > 0)
	{
		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary *dict = [dataString propertyList];

		_searchHints = [dict objectForKey:@"hints"];
		
		[self.tableView reloadData];
	}
}


- (void)didFinishDownloadSearchResults:(NSData *)data
{	
	if([data length] > 0)
	{
		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

		NSDictionary *dict = [dataString propertyList];

		[_searchResults addObjectsFromArray:[dict objectForKey:@"items"]];
		
		if(_cellToDelete)
		{
			[_searchResults removeObjectAtIndex:_cellToDelete.row];
			
			NSArray *paths = [NSArray arrayWithObject:_cellToDelete];
			[_resultsView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
			_cellToDelete = nil;
		}
		else
		{
			[_resultsView reloadData];
		}
		
		[self addResultsView];		
	}
}

- (void)loadContentForCells:(NSArray *)cells
{
    for(int i = 0;i < [cells count];i++)
	{
        RemoteAppCell *cell = [cells objectAtIndex:i];
		
        if([cell respondsToSelector:@selector(fetchImage)])
		{
            [cell fetchImage];
		}
		
        cell = nil;
    }
}

#pragma mark - ProgressActivityView Delegate Methods

- (void)fadeOutDidFinish
{
	[_progressActivityView removeFromSuperview];
}

#pragma mark -
- (BOOL)     searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
//    [_results removeAllObjects];
//
//    // Perform the search
//    NSArray *datas = nil;
//    if ([_mainCtrl isRootView]) {
//        NSMutableArray *tmp;
//        tmp = [NSMutableArray arrayWithArray:[_mainCtrl.keyDB ksCoreDatasFromDatabase:0 recursive:YES]];
//        //[tmp addObjectsFromArray:_mainCtrl.keyDB.categoriesFromDatabase];
//        datas = tmp;
//    } else {
//        datas = _mainCtrl.records;
//    }
//    for (KsCoreData *ksCoreData in datas) {
//        if ([ksCoreData matchesSearchText:searchString]) {
//            [_results addObject:ksCoreData];
//        }
//    }
//
//    // Sort the results
//    [_results sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [((KsCoreData*)obj1).title localizedCompare:((KsCoreData*)obj2).title];
//    }];

    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    if (_progressActivityView) {
        [_progressActivityView removeFromSuperview];
    }

    [_searchDownloader cancel];

    [_searchBar resignFirstResponder];

    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
