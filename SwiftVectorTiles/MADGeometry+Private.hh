//
//  MADGeometry+Private.hh
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#include "geos_c.h"

#import <Foundation/Foundation.h>
#import "MADGeometry.hh"

static GEOSContextHandle_t GeosContext = GEOS_init_r();

@interface MADGeometry()

-(instancetype) initWithGeometry:(GEOSGeometry *)geometry;
-(GEOSGeometry*) geometry;

@property GEOSGeometry* geometry;
@property NSString* wkt;


@end
