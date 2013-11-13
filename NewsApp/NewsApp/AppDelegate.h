//
//  AppDelegate.h
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//Global Data newsDataDict is used by classes in this project. (Always name your variables with meaning. Dict represents a Dictionary)
@property (strong, nonatomic) NSMutableDictionary *newsDataDict;

@property (strong, nonatomic) UIWindow *window;

@end
