//
//  ViewController.h
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

//This dictionary contains all the article numbers with keys:(000, 001, 002, 003, etc)
//Direct the compiler to declare and implement the getter and setter methods for the instance variable _newsDataDict
//pointing to a static (unchangable) dictionary object to hold the entire data contained in news.plist XML file.
@property (nonatomic, strong) NSDictionary *newsDataDict;

//Based on the key obtained from newsDataDict, every key has an array that contains information about the cell's type.
//Direct the compiler to declare and implement the getter and setter methods for the instance variable _articleInfoList
// pointing to a static (unchangable) array object to hold the information of an article
@property (nonatomic, strong) NSArray *articleInfoList;

//This stores all the newsDataDict keys, so we can access the article's key
//Direct the compiler to declare and implement the getter and setter methods for the instance variable _articleList
// pointing to a static (unchangable array object to hold the list of article keys.
@property (nonatomic, strong) NSArray *articleList;

//The selected news article that will be sent to another view to be displayed upon.
@property (nonatomic, strong) NSString *selectedArticle;

@end

