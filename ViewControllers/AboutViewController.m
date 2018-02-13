//
//  AboutViewController.m
//  Scraper
//
//  Created by David Perry on 20/01/2009.
//  Copyright 2009 Didev Studios. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController () <UIWebViewDelegate>
@end

@implementation AboutViewController {
    UIWebView *_webView;
}

- (void)viewDidLoad
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    self.view = _webView;

	self.title = NSLocalizedString(@"About", nil);
		
	NSString *helpPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	NSURL *helpURL = [NSURL fileURLWithPath:helpPath];
	[_webView loadRequest:[NSURLRequest requestWithURL:helpURL]];
	_webView.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_webView.scalesPageToFit = NO;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Got memory warning!");
	[super didReceiveMemoryWarning];
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	if(navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		_webView.scalesPageToFit = YES;
		
		if([[[request URL] absoluteString] hasPrefix:@"http://phobos.apple.com"])
		{			
			NSString *search = @"Didev Studios";
			
			NSString *sstring = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZSearch.woa/wa/search?term=%@&media=software", [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString:sstring]];
						
			return NO;
		}
		else
		{			
			[[UIApplication sharedApplication] openURL:[request URL]];
			
			return NO;
		}
	}

	return YES;
}

@end
