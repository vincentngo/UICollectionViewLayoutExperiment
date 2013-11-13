//
//  AppDelegate.m
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSLog(@"document %@", documentsDirectoryPath);
    NSString *plistFilePathInDocumentsDirectory = [documentsDirectoryPath stringByAppendingPathComponent:@"news.plist"];
    
    // Instantiate a modifiable dictionary and initialize it with the content of the plist file
    NSMutableDictionary *newsData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFilePathInDocumentsDirectory];
    
    if (!newsData) {
        
        /*
         In this case, the myPoints.plist file does not exist in the documents directory.
         This will happen when the user launches the app for the very first time.
         Therefore, read the plist file from the main bundle to show the user some example favorite cities.
         
         Get the file path to the CountryCities.plist file in application's main bundle.
         */
        NSString *plistFilePathInMainBundle = [[NSBundle mainBundle] pathForResource:@"news" ofType:@"plist"];
        
        // Instantiate a modifiable dictionary and initialize it with the content of the plist file in main bundle
        newsData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFilePathInMainBundle];
        
        
    }
    
    self.newsDataDict = newsData;
    
    return YES;
}



@end
