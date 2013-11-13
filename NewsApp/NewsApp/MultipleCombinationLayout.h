//
//  MultipleCombinationLayout.h
//  News Application
//
//  Created by iOS Developer on 2/27/13.
//  Copyright (c) 2013 Vincent Ngo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultipleCombinationLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;

// This keeps track of the size of an item such as a cell using CGSizeMake method to specify the width and the height
@property (nonatomic) CGSize itemSize;

//This keeps track of the spacing between items such as cells in the Y Direction.
@property (nonatomic) CGFloat interItemSpacingY;

//Don't really need to keep track of the number of columns...
@property (nonatomic) NSInteger numberOfColumns;



@end