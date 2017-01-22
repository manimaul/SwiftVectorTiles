//
//  MADGeometry.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#include "geos_c.h"

#import <Foundation/Foundation.h>
#import "MADGeometry.hh"
#import "MADGeometry+Private.hh"
#import "MADCoordinate.hh"

using namespace std;


@implementation MADGeometry

-(GEOSGeomTypes) getwkbGemotryType {
    return static_cast<GEOSGeomTypes>([self getGeometryType]);
}

-(instancetype) initWithGeometry:(GEOSGeometry*)geometry {
    if (self = [super init]) {
        _geometry = geometry;
        return self;
    }
    return nil;
}

-(void) dealloc {
    if (_geometry != NULL) {
        GEOSGeom_destroy_r(GeosContext, _geometry);
    }
}

-(BOOL) covers:(MADGeometry*)other {
    return GEOSCovers_r(GeosContext, self.geometry, other.geometry) == '1';
}

-(BOOL) intersects:(MADGeometry*)other {
    return GEOSIntersects_r(GeosContext, self.geometry, other.geometry) == '1';
}
-(BOOL) empty {
    return GEOSisEmpty_r(GeosContext, self.geometry) == '1';
}

-(NSString*)getWellKnownText {
    if (_wkt == NULL) {
        auto wktWriter = GEOSWKTWriter_create_r(GeosContext);
        char* wkt = GEOSWKTWriter_write_r(GeosContext, wktWriter, self.geometry);
        _wkt = [[NSString alloc] initWithUTF8String:wkt];
        GEOSFree_r(GeosContext, wkt);
        GEOSWKTWriter_destroy_r(GeosContext, wktWriter);
    }
    return _wkt;
}

-(MADGeometry*)intersection:(MADGeometry*)other {
    return nil;
}

-(MADGeometryType)getGeometryType {
    return MADwkbUnknown;
}

-(MADGeometry*)transform:(MADCoordinateTransform)transform {
    return nil;
}

-(NSArray<MADCoordinate*>*)coordinates {
    return nil;
}

@end
