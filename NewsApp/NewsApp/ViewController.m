//
//  ViewController.m
//  CollectionViewNews
//
//  Created by Vincent Ngo on 2/11/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "VideoCustomCell.h"
#import "NewsArticleCell.h"
#import "WebViewCell.h"
#import "WebViewController.h"

#import "MultipleCombinationLayout.h"                                     //*********UNCOMMENT AFTER YOU REACH CUSTOM LAYOUT SECTION

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewCell *cellType;


@property (strong, nonatomic) UICollectionViewCell *currentVideoCellPlaying;
@property (strong, nonatomic) NSString *currentVideoEmbedURL;

@property (strong, nonatomic) UIImage *imageHeaderCell;

@property (strong, nonatomic) MultipleCombinationLayout *layout1;         //***********UNCOMMENT AFTER YOU REACH CUSTOM LAYOUT SECTION

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Grabbing the plist data
    
    //Obtain an object reference to the App Delegate object
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //data structure created in the App delegate object
    self.newsDataDict = appDelegate.newsDataDict;
    
    self.articleList = (NSMutableArray *)[[self.newsDataDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    self.layout1 = [[MultipleCombinationLayout alloc]init];               //*********UNCOMMENT AFTER YOU REACH CUSTOM LAYOUT SECTION
    self.collectionView.collectionViewLayout = self.layout1;              //*********UNCOMMENT AFTER YOU REACH CUSTOM LAYOUT SECTION
    
    
    //First need to register an exitfullScreenNotification, this is so when a youtube video is closed from full screen we want to rearrange the layout since the user
    //rotated to landscape or portrait mode.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youTubeVideoExit:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification"
                                               object:nil];
    
    
    
    
}


#pragma mark - Dealing with iPad rotation



//This method gets called when the notification center detects that the user exit from full screen.
//We don't know if the user has rotated the iPad to landscape or portarit mode. So we need to relayout the cells, depending on where the user rotated.
- (void)youTubeVideoExit:(id)sender {
    
    // rearrange the cells to landscape/portarit mode.
    [self.collectionView.collectionViewLayout invalidateLayout];

}


//This method gets called when the user rotates the iPad, to reorganize the layout. This is the case where the user is not
//playing a video in full screen mode and just want to rotate the collection view.
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - UICollectionView Data Source

/*
 
 numberOfItemsInSection
 
 This basically returns the number of cells displayed in a given section.
 */

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.newsDataDict count];
}


/*
 
 the data source ask how many sections are in the collection view. (The Default value will be 1 if you don't implement this. )
 
 */
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}


/*
 
 cellForItemAtIndexPath
 
 Similar to UITableView, this is where you return the cell for a given index path. Here is where you can call the dequeueReusableCellWithReuseIdentifier method.
 This method basically checks if there is already a cell that can be reused, by specifying the identifier. But this is different compared to UITableViewCell.
 Unlike UITableViewCell, UICollectionViewCell doesn't have a default cell style, so the layout of the cell has to be specified by the programmer.
 
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger rowNumber = [indexPath row];
    
    //Gets the article key e.g. 01, 02, 03, 04 etc
    NSString *articleName = [self.articleList objectAtIndex:rowNumber];
    
    //Grabs the array for one article in a dictionary. The array can be of type (video, newsArticle, scrollableWeb)
    self.articleInfoList = [self.newsDataDict objectForKey:articleName];
    
    //Extract the information from article's array
    NSString *newsTitle = [self.articleInfoList objectAtIndex:2];   //The news description
    
    NSString *typeOfArticle = [self.articleInfoList objectAtIndex:1];   //The type of article, is it a video? scrollableWebInCell? news article?
    
    NSString *urlString = [self.articleInfoList objectAtIndex:3];       //Grabs the image/video URL to be displayed in a UICollectionView cell.
    
    
    //Next we will check what type of cell are we going to use. Remember we created three different custom cells. One for Video, one for image, and one for a UIWebView.
    
    //Cell is of type Video
    if([typeOfArticle isEqualToString:@"video"]){
        
        VideoCustomCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"VideoContent" forIndexPath:indexPath];
        
        //Stores the cell in cellType, this is so I can specify which custom cell I want to use. You can have many custom cells, but how would you be able to reuse the right cell? They have different identifiers.
        self.cellType = cell;
        
        //Embed HTML
        NSString *embedHTML = [NSString stringWithFormat:@"<iframe width=\"970\" title=\"YouTube video player\" src=\"%@?HD=1;rel=0;showinfo=0;controls=1\" height=\"600\" frameborder=\"0\"></iframe>", urlString];
        
        //Caution check to see if the embed code is empty.
        if (![embedHTML isEqualToString:@""]){
            
            [cell.webView loadHTMLString:embedHTML baseURL:nil];
            cell.webView.scrollView.scrollEnabled = NO;
            
            //Scale the YouTube video
            cell.webView.scalesPageToFit = YES;
            
            //Turn transparency off
            [cell.webView setOpaque:NO];
            
            //Set the background color to black.
            cell.webView.backgroundColor = [UIColor blackColor];
            
            //loads the embed youtube video on to the webview.
            [cell.webView loadHTMLString:embedHTML baseURL:nil];
            
            //set the newsTitle of the cell
            cell.videoTitle.text = newsTitle;
            
        }
        
        //Cell is of type newsArticle
        //In the news.plist file
    }else if([typeOfArticle isEqualToString:@"newsArticle"]){
        
        
        NewsArticleCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"articleContent" forIndexPath:indexPath];
        
        //The technique below is called Grand Central Dispatch, which is a low level API, that is not part of the Cocoa's framework. The function call below will give you a little taste of concurrent programming.
        
        //This is a useful technique for when you have large amount of data which you have to retrive.
        //Everyone that handles events, e.g. touch by the user is handled by the main thread. Also the main thread handles pretty much most of the execution on your code. So if you have to retrive large amount of data, there will be a delay caused with handling events on your application. So you may see that scrolling up is delaying and not really smooth.
        // This is because the main thread works like a queue, you have to finish the current job before you do the next job. You would have to retrieve all your images for example, before you would lay them on the view.
        // So this is why we have to use dispatch_async, this method basically takes in a queue where you can specify a priority, HIGH for when you want to execute this first. This queue is defered from the main thread, creating a seperate thread to run retriveing data in the background. So the main thread will do it's thing handling the main events, while the background thread will retrieve data, and set values necessary, and gets returned immediately. Dispatch_async basically fires out a block and forgets it afterwards by returning it immediately.
        
        //To read more about Grand Central Dispatch please follow these links
        
        /*
         *http://www.mikeash.com/pyblog/friday-qa-2009-08-28-intro-to-grand-central-dispatch-part-i-basics-and-dispatch-queues.html
         *
         * Also watch WWDC 2011 Video to get an intro of blocks and Grand Central Dispatch.
         */
        
        
        //Creating a background thread to handle retrieving data in the background. 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           
            //Retrive the url of the particular news article's image.
            NSURL *url = [NSURL URLWithString:urlString];
            
            //grabs the content from the url and store it in a data object
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            //We are going to call the main queue which the main thread uses, to update the necessary UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                UIImage *image = [[UIImage alloc]initWithData: data];

                //Set the UIImageView object's image.
                [cell.imageView setImage:image];
                
                //Set article description label.
                cell.articleDescription.text = newsTitle;
                
                
            });
            
        });
        // Set the cellType to be returned. (Depending on the article's type, we need to return the correct cell)
        //The cell could be of type Video content, web content, or news article content.
        self.cellType = cell;

        
        
        //cell is of type scrollableWebInCell.
    }else if([typeOfArticle isEqualToString:@"scrollableWebInCell"]){
        
        WebViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"webContent" forIndexPath:indexPath];
        
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlString];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //Load the request in the UIWebView.
        [cell.webView loadRequest:requestObj];
        
        
        
        self.cellType = cell;
    }
    
    
    return self.cellType;
}


#pragma mark – UICollectionViewDelegateFlowLayout

//******* ATTENTION! This method can be removed after you have created a custom layout. The UICollectionView Custom Layout also handles the orientation of the header. So this method would be unnecessary.

/*
 
 sizeForItemAtIndexPath's job is to tell the layout what is the size of a cell. (In this method you can determine the different heights and width of a particular image,
 and specify the width and height for the cell. Therefore you can create different size cells in a UICollectionView based on the size of the image itself.
 
 
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //This is the case where we want the first cell to be the header. The user can rotate to landscape or Portrait
    //mode
    
    //Checks to see if it's the first cell, and check the iPad's orientation to see if it's portrait
    if ([indexPath row] == 0 && ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown )){
        
        //Set the header cell's width and height to be Portrait mode
        return CGSizeMake(768, 400);
        
        
        //Checks to see if it's the first cell, and check the iPad's orientation to see if it's landscape.
    }else if ([indexPath row] == 0 && ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)){
        
        //Set the header cell's width and height to Landscape mode
        return CGSizeMake(1024, 400);
        
    }
    
    //If the two conditions above fail, we know its just a normal cell, and just specify the default cell size.
    return CGSizeMake(255, 200);
    
}


#pragma mark - UICollectionViewDelegate

//didSelectItemAtIndexPath method is called everytime the user taps on a cell. When the user taps on the cell, we may want to perform some actions such as: going to another view, pop up an image, or display an alert. 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    
    NSUInteger rowNumber = [indexPath row];
    
    //Gets the article key e.g. 01, 02, 03, 04 etc
    NSString *articleName = [self.articleList objectAtIndex:rowNumber];
    
    //Grabs the array for one article.
    self.articleInfoList = [self.newsDataDict objectForKey:articleName];
    
    //clickable or unclickable
    NSString *isClickable = [self.articleInfoList objectAtIndex:0];
    
    //grabs the type of article, is it a video? newsArticle? scrollableWebInCell?
    NSString *typeOfArticle = [self.articleInfoList objectAtIndex:1];
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //The Cell clicked is of Video
    if([typeOfArticle isEqualToString:@"video"]){
        
        //Do nothing, because the video is going to play within a cell. The youtube embed video is of type html 5 video, which uses the MPMoviePlayerController to play the video. 
        
        //The Cell clicked is of type newsArticle
    }else if([typeOfArticle isEqualToString:@"newsArticle"]){
        
        if([isClickable isEqualToString:@"clickable"]){
            
            
            //Grabs the article link
            NSString *articleUrl = [self.articleInfoList objectAtIndex:4];
            
            //Sets the current article selected
            self.selectedArticle = articleUrl;
            
            // Perform the segue named ShowWebView
            [self performSegueWithIdentifier:@"ShowWebView" sender:self];
        }
        
        
        //The Cell clicked is of type scrollableWebInCell
    }else if([typeOfArticle isEqualToString:@"scrollableWebInCell"]){
        
        //Scrollable website within a cell, we don't require any action to push another view on the screen. Do nothing!
        
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark - Preparing for Segue

// This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
// You never call this method. It is invoked by the system.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //Checks to see if the segue call is identified to be ShowWebView
    if ([[segue identifier] isEqualToString:@"ShowWebView"]) {
        
        // Obtain the object reference of the destination view controller
        WebViewController *webViewController = (WebViewController *)[segue destinationViewController];
        
        //Sets the object's urlString to be the selected article
        webViewController.urlString = self.selectedArticle;
        
        //Sends a reference to the collection view, because the user may rotate the iPad and exit the web view, and we then need to reorganize the cells.
        webViewController.referenceToCollectionView = self.collectionView;
        
        //Obtains the current orientation of the iPad
        webViewController.currentOrientationOfiPad = [self checkOrientationOfiPad];
        
        
    }
}


//Checks the orientation of the iPad.
-(NSString *)checkOrientationOfiPad{
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown){
        
        return @"portrait";
        
    }else{
        
        return @"landscape";
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
