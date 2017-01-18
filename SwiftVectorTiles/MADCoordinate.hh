//
//  MADCoordinate.h
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MADCoordinate : NSObject

typedef MADCoordinate* (^MADCoordinateTransform)(MADCoordinate*);

-(instancetype)initWithX:(double)x andY:(double)y;

@property double x;
@property double y;

@end
