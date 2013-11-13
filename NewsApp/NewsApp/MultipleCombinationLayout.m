//
//  MultipleCombinationLayout.m
//  News Application
//
//  Created by iOS Developer on 2/27/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import "MultipleCombinationLayout.h"

static NSString * const MultipleCombinationCellKind = @"PhotoCell";

@interface MultipleCombinationLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;

//Keeps track of the current width's content [][][][][][]
@property int currentContentWidth;

//This keeps track of the current X and Y
@property int currentContentPlacementX;
@property int currentContentPlacementY;

@property int numberOfCellsInPattern;

//Random x value position each time for a 2 x 1 cell or 1 x 2 cell
@property int specialCellX;

//Pattern Counts

@property int onebyOnePatternCount;
@property int twobyOneCellCount;
@property int onebyTwoCellCount;

//check if the 2x1 cell is already placed.
@property bool isTwoByOneCellPlaced;

//check if the 1 x 2 cell is already place
@property bool isOneByTwoCellPlaced;


//check if the header cell is first placed
@property bool isHeaderCellPlaced;

//These are set whenever the iPad rotates, or the first time prepareLayout is called.
@property int iPadHeight;
@property int iPadWidth;


@end

@implementation MultipleCombinationLayout

#pragma mark - Lifecycle

// http://what-when-how.com/ios-4/ioss-methods/
- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

// Used by the OS when un-archiving XIB files;
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

//Initial set up for the layout.
- (void)setup
{
    
    [self checkiPadOrientation];
    self.currentContentWidth = 0;
    
    //Initalizing all the variables
    
    //This is really the ONe byOne cell count, we are keeping track of how many cells we want in the pattern.
    self.onebyOnePatternCount = 0;
    self.twobyOneCellCount = 0;
    self.onebyTwoCellCount = 0;
    
    self.currentContentPlacementX = 0;
    self.currentContentPlacementY = 0;
    
    self.itemInsets = UIEdgeInsetsMake(0, 0, 0, 0);//UIEdgeInsetsMake(22.0f, 22.0f, 22.0f, 22.0f);
    
    //Specifies the default size for each cell.
    //This is the best combination, because it fits exactly in to the iPad's width and height..
    //If you change it to anything else, integers may become unequal.
    //Use numbers to the power of 2. 2^k,  64 128, 256,
    self.itemSize = CGSizeMake(256.0f, 200.0f);
    
    //The bottom spacing between the cell below it.
    self.interItemSpacingY = 0;
    
    self.isTwoByOneCellPlaced = NO;
    self.isOneByTwoCellPlaced = NO;
    self.isHeaderCellPlaced = NO;
    
    
}

//Checks the iPad orientation
//Everytime we set up the layout, we must check if the iPad is in landscape or portrait mode. This will determine how many cells will be in positioned in a row or column. We keep track of the iPad's Height and width, this is so we can reorganize the layout when rotated. If we don't keep track of the width and height of the iPad, the layout will be completely out of place.
-(void) checkiPadOrientation{
    
    //The ipad is currently in portrait mode.
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown){
        self.iPadHeight = 1024;
        self.iPadWidth = 768;
        
        //The ipad is in landscape mode
    }else{
        self.iPadHeight = 768;
        self.iPadWidth = 1024;
    }
    
    //This calculates how many cells are allowed in a single row.
    self.numberOfColumns = self.iPadWidth/self.itemSize.width;
    
    //Multiple the columns by 2 to get double the the amount of cells
    self.numberOfCellsInPattern = self.numberOfColumns * 2;
    
    
    
}

#pragma mark - Layout

- (void)prepareLayout
{
    //Whenever the iPad rotates, willRotateToInterfaceOrientation: is called. But since we are not in the view controller we can't really know the width and height
    //of the ipad based on it's orientation. Therefor this method, basically checks the orientation to see if its portrait or landscape mode.
    [self checkiPadOrientation];
    
    [self setup];
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    
    //stores every cell layout attributes such as it's x and y and CGSize
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    //grabs the number of sections
    NSInteger sectionCount = [self.collectionView numberOfSections];
    //initalize the indexPath starting at section 0, with item 0
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    //Going to loop through each section
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        //Numbers of items in the section
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        //NSLog(@"item count is: %d",itemCount);
        
        //loop through each item in the particular section.
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            //NSLog(@"indexPath item is %d, indexPath section is %d", indexPath.row, indexPath.section);
            
            //Setting the frame of the cell.
            itemAttributes.frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
            
            //Add the cell attribute to the list of cell attributes in a section
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[MultipleCombinationCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}




- (CGRect)placeHeaderCell{
    CGFloat originX = self.currentContentPlacementX;
    CGFloat originY = self.currentContentPlacementY;
    
    self.currentContentPlacementX = 0;
    self.currentContentPlacementY = self.itemSize.height * 2;
    
    
    return CGRectMake(originX, originY, self.iPadWidth, self.itemSize.height * 2);
}


//This method calculates the position of where the place the one by one cell.
/*
 * CurrentPlacementX and CurrentPlacementY is the top left coordinate to form a CGRect you need 4 parameters, (X, Y, width, Height)
 *          (x,y)--------------------------|
 *          |                              |
 *          |                              |
 *          |                              |
 *          |------------------------------|
 *  total of 6 cells in this pattern.
 */

- (CGRect)placeOnebyOneCells
{
    //Checks to see if the current content width is within the bounds of the iPad width
    if (self.currentContentWidth < self.iPadWidth){
        
        //for organization, i'm just going to place the current X and Y coordinates to be originX and originY
        CGFloat originX = self.currentContentPlacementX;
        CGFloat originY = self.currentContentPlacementY;
        
        //Increment the X placement for the next one by one cell by a cell's width
        self.currentContentPlacementX += self.itemSize.width;
        //increment the currentContentWidth by a cell's width
        self.currentContentWidth += self.itemSize.width;
        
        //increments the onebyOnePatternCount. (this could be better named as a particular pattern count.
        //self.onebyOnePatternCount ++;
        
        //Returns the rectangular frame of the coordinates and size of a particular cell to be added to the dictionary.
        return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
        
        //So the current contentWidth is either equal to or greater than the iPad's width. We need to increment the y coordinate by a cell's height, and reset
        //the content width and placementX to zero so we can start placing the cells from left to right again.
    }else{
        
        //CASE:
        //          [] [] [] [] [] []   currentContentWidth >= iPadWidth
        //
        //          | new line (0, currentContentPlacementY + cell height)
        
        //reset to zero, because we are starting on a new line to place cells.
        self.currentContentWidth = 0;
        //Reset to zero, so we can place the first cell of a row in the first column
        self.currentContentPlacementX = 0;
        
        //increment the currentContentplacement Y by a cell's height
        self.currentContentPlacementY += self.itemSize.height;
        
        //Store the X and Y coordinates for a new cell
        CGFloat originX = self.currentContentPlacementX;
        CGFloat originY = self.currentContentPlacementY;
        
        //again increment the currentContentWidth and coordinate X by cell's width for the next cell to be placed
        self.currentContentPlacementX += self.itemSize.width;
        self.currentContentWidth += self.itemSize.width;
        
        //increment the pattern cell count.
        //self.onebyOnePatternCount ++;
        
        return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
    }
}

//This helper method places one two by one cell on the view, randomly based on the number of columns.
/*
 *  [ ][][]
 *  [ ][][]
 *  pattern looks like the above, 2 by 1 cell, followed by one by one cells.
 * this means that in portarit mode there is 5 cells total in this pattern.
 */
-(CGRect)placeTwobyOneCell
{
    
    //Check if the two by one cell is placed
    if(!self.isTwoByOneCellPlaced){
        
        //We are goign to randomize the position of the cell.
        //int r = arc4random() % self.numberOfColumns;
        
        int r = 0;
        //The case where the randomizer generates a number that is equal to the number of columns. Meaning r will be out of bounds since we start at 0, then 1, then 2 etc. So we must subtract 1.
        if (r == self.numberOfColumns){
            r--;
        }
        
        //Next we are going to set the x coordinate of the two by one cell by multiplying the column we have selected.
        self.specialCellX = r * self.itemSize.width;
        
        //Since we already placed the cell,
        self.isTwoByOneCellPlaced = YES;
        
        //Increase the Y placement, we are starting on a new line (we don't want to overlap the previous cells.
        self.currentContentPlacementY += self.itemSize.height;
        
        //Set the placement back to zero, for the one by one cells to start getting placed.
        self.currentContentPlacementX = 0;
        
        //set the current content width to zero
        self.currentContentWidth = 0;
        
        //Store them in a local variable
        CGFloat originX = self.specialCellX;
        CGFloat originY = self.currentContentPlacementY;
        
        //Since we placed the 2 by 1 cell, we need to increase the current contentWidth.
        self.currentContentWidth += self.itemSize.width;
        
        //increment the cell counter
        self.twobyOneCellCount++;
        
        return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height * 2);
        
    }else if (self.currentContentWidth == self.iPadWidth){
        
        self.currentContentPlacementY += self.itemSize.height;
        self.currentContentWidth = self.itemSize.width;
        self.currentContentPlacementX = 0;
        
        return [self placeTwobyOneCell];
        
        
        //this condition checks to see if the currentContnetPlacement is on the special two by one cell.,
        //if not it is safe to place a cell.
    }else if (self.specialCellX != self.currentContentPlacementX){
        
        //increment the special pattern cell count
        self.twobyOneCellCount++;
        //place a normal one by one cell.
        return [self placeOnebyOneCells];
        
        //Equal to the special cell, move one position
    }else{
        //increase the currentContentplacementX by the cell's width to shift it from the special cell's width.
        self.currentContentPlacementX += self.itemSize.width;
        
        //increment the special pattern cell count.
        self.twobyOneCellCount++;
        
        //place a normal one by one cell.
        return [self placeOnebyOneCells];
    }
}

/*
 *  [  ][][]
 *  [][][][]
 */
-(CGRect)placeOnebyTwoCells
{
    if(!self.isOneByTwoCellPlaced){
        
        //We are goign to randomize the position of the cell.
        // We are subtracting negative 2 from the number of columns, this is because we don't want to draw a rect outside the iPad screen. (unless we are scrolling horizontally
        int r = arc4random() % (self.numberOfColumns - 2);
        
        // Keep track of specialCellX's X Location
        //Based on the random r value chosen, we are going to multiple it by a one by one cell's width to get to the location.
        //We want to keep track of this specialCellX coordinate so we prevent other cells from overlapping.
        self.specialCellX = r * self.itemSize.width;
        
        //Since we already placed the cell, set it to YES
        self.isOneByTwoCellPlaced = YES;
        
        
        //Set the placement back to zero, for the one by one cells to start getting placed.
        self.currentContentPlacementX = 0;
        
        //set the current content width to zero
        self.currentContentWidth = 0;
        
        //Increase the Y placement, we are starting on a new line (we don't want to overlap the previous cells.
        self.currentContentPlacementY += self.itemSize.height;
        
        
        //Store them in a local variable
        CGFloat originX = self.specialCellX;
        CGFloat originY = self.currentContentPlacementY;
        
        
        //Since we placed the 1 by 2 cell, we need to increase the current contentWidth.
        //This time we need to increase the content width by 2 since its a 2 column, 1 row type of cell.
        self.currentContentWidth += self.itemSize.width * 2;
        
        //increment the cell counter
        self.onebyTwoCellCount++;
        
        return CGRectMake(originX, originY, self.itemSize.width * 2, self.itemSize.height);
        
    }else if (self.specialCellX != self.currentContentPlacementX){
        
        self.onebyTwoCellCount++;
        return [self placeOnebyOneCells];
        
        
    }else{
        self.currentContentPlacementX += self.itemSize.width * 2;
        
        self.onebyTwoCellCount++;
        return [self placeOnebyOneCells];
    }
    
    
    
}

//This method basically resets the pattern once it ends.
//Reseting all the boolean variables to NO again, setting the cell counts to zero.
//THis method only gets called once the pattern ends to restart.
-(CGRect)resetCellPattern
{
    //Set the cell counts to zero
    self.twobyOneCellCount = 0;
    self.onebyTwoCellCount = 0;
    
    //Since we starting from pattern 1 (1 x 1 cells), we are going to go ahead and place the first cell.
    //Starting the count at 1 instead of zero.
    self.onebyOnePatternCount = 1;
    
    //Turn the special cell placed off
    self.isTwoByOneCellPlaced = NO;
    self.isOneByTwoCellPlaced = NO;
    
    //Let the first pattern of the sequence to handle the placement.
    return [self placeOnebyOneCells];
}


#pragma mark - Private

- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    
    //The very first cell of a section, make it the header cell
    if ([indexPath row] == 0){
        return [self placeHeaderCell];
        
        //Pattern One
    }else if (self.onebyOnePatternCount != self.numberOfCellsInPattern/2){
        
        self.onebyOnePatternCount ++;
        return [self placeOnebyOneCells];
        
        //Pattern Two (Displays a two by one cell in the mix)
    }else if (self.twobyOneCellCount != self.numberOfCellsInPattern - 1){
        
        return [self placeTwobyOneCell];
        
        //Pattern Three (Displays a one by two cell in the mix.
    }else if (self.onebyTwoCellCount != self.numberOfCellsInPattern/2 - 1){
        
        return [self placeOnebyTwoCells];
        
        //Reset the pattern to start at Pattern One again.
    }else{
        return [self resetCellPattern];
    }
    
}



//layoutAttributesForElementsInRect returns the attribute for every cell, section, footer etc.
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    
    //Using block code to enumerate each key in the layoutInfo dictionary and set each cell's attributes.
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[MultipleCombinationCellKind][indexPath];
}


- (CGSize)collectionViewContentSize
{
    NSInteger rowCount = [self.collectionView numberOfItemsInSection:0]/ self.numberOfColumns;

    // make sure we count another row if one is only partially filled
    if ([self.collectionView numberOfSections] % self.numberOfColumns) rowCount++;
    
    CGFloat height = self.itemInsets.top +
    rowCount * self.itemSize.height + (rowCount - 1) * self.interItemSpacingY +
    self.itemInsets.bottom + self.itemSize.height*2;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}




@end