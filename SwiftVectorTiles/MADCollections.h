//
//  OGRCoordinateCollection.h
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import "MADGeometry.hh"

@protocol MADMultiGeometry <NSObject>

-(NSArray<MADGeometry*>*)geometries;

@end
