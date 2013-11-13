//
//  WebViewController.m
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Loads the url on to the UIWebView
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}


//When the user exits the article, we must check if the orientation did not change.
-(void)viewDidDisappear:(BOOL)animated{
    
    if (self.currentOrientationOfiPad != [self checkOrientationOfiPad]){
        
        //Re organize the layout.
        [self.referenceToCollectionView.collectionViewLayout invalidateLayout];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate Methods

-(void)webViewDidStartLoad:(UIWebView *)webView{
    //Starting to load the web page. Show the activity indicator in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //Finished loading the web page. Hide the activity indicator in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //An error occurred during the web page load. Hide the activity indicator in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //Report the error inside the webview.
    NSString *errorString = [NSString stringWithFormat:@"<html><center><font size = +5 color='red'>An error occurred:<br>%@</font></center></html>", error.localizedDescription];
    
    [self.webView loadHTMLString:errorString baseURL:nil];
}

#pragma mark - Helper methods

//Check the iPad's orientation. If the user changed the orientation, we must reorganize the custom cells.
-(NSString *)checkOrientationOfiPad{
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown){
        
        NSLog(@"i am in portrait mode");
        
        return @"portrait";
        
    }else{
        NSLog(@"i am in landscape mode");
        
        return @"landscape";
    }
    
}


@end
