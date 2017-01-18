//
//  MADCoordinate.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import "MADCoordinate.hh"

@implementation MADCoordinate

-(instancetype)initWithX:(double)x andY:(double)y {
    if (self = [super init]) {
        _x = x;
        _y = y;
        return self;
    }
    return nil;
}

@end
