//
//  VideoCustomCell.h
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCustomCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UILabel *videoTitle;

@end
