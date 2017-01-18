//
//  MADGeometry+Private.hh
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#include "ogr_geometry.h"

#import <Foundation/Foundation.h>
#import "MADGeometry.hh"

@interface MADGeometry()

-(instancetype) initWithGeometry:(OGRGeometry*)geometry;
-(instancetype) initWithWellKnownText:(NSString *)text;
-(instancetype) initWithWellKnownBinary:(NSData *)data;

@property OGRGeometry* geometry;
@property NSString* wkt;

@end
