//
//  WebViewController.h
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import "ViewController.h"

@interface WebViewController : ViewController

//UIWebView reference
@property (weak, nonatomic) IBOutlet UIWebView *webView;

//The web address stored in an NSString
@property (nonatomic, strong) NSString *urlString;

//We need a reference to the collectionview because if the user rotates the iPad while viewing the article, we also need to reorient the layout.
@property (weak, nonatomic) UICollectionView *referenceToCollectionView;

//From the  collection view, we will obtain the iPad Orientation. To check if the user rotated the iPad.
@property (nonatomic, strong) NSString *currentOrientationOfiPad;

@end
