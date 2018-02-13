//
//  CountryCell.m
//  Scraper
//
//  Created by David Perry on 10/01/2009.
//  Copyright 2009 Didev Studios. All rights reserved.
//

#import "CountryCell.h"


@implementation CountryCell

@synthesize flagView, countryLabel, reviewLabel, reviewCountLabel, ratingView;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		self.flagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 32)];
		self.flagView.contentMode = UIViewContentModeCenter;
		self.flagView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 44, 13)];
		self.countryLabel.font = [UIFont systemFontOfSize:9.0];
		self.countryLabel.textAlignment = NSTextAlignmentCenter;
		self.countryLabel.text = @"N/A";
		self.countryLabel.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.reviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 100, 30)];
		self.reviewLabel.font = [UIFont boldSystemFontOfSize:26.0];
		self.reviewLabel.textAlignment = NSTextAlignmentLeft;
		self.reviewLabel.text = @"88888";
		
		self.reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 100, 13)];
		self.reviewCountLabel.font = [UIFont systemFontOfSize:9.0];
		self.reviewCountLabel.textAlignment = NSTextAlignmentLeft;
		self.reviewCountLabel.text = NSLocalizedString(@"REVIEWS", nil);
		
		self.ratingView = [[UIImageView alloc] initWithFrame:CGRectMake(130, 8, 134, 25)];
    }
	
	[self.contentView addSubview:reviewCountLabel];
	[self.contentView addSubview:reviewLabel];
	[self.contentView addSubview:flagView];
	[self.contentView addSubview:countryLabel];
	[self.contentView addSubview:ratingView];
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
