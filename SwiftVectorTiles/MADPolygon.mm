//
//  MADPolygon.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import "MADPolygon.hh"
#import "MADLinearRing.hh"
#import "MADGeometry+Private.hh"

@interface MADPolygon()

@property NSArray<MADLinearRing*>* interiorRings;
@property MADLinearRing* exteriorRing;

@end

@implementation MADPolygon

-(double)area {
    return 0;
}

-(MADLinearRing *)getExteriorRing {
    if (_exteriorRing == NULL) {
        const GEOSGeometry* er = GEOSGetExteriorRing_r(GeosContext, self.geometry);
        GEOSGeometry* erc = GEOSGeom_clone_r(GeosContext, er);
        _exteriorRing = [[MADLinearRing alloc] initWithGeometry:erc];
    }
    return _exteriorRing;
}

-(NSArray<MADLinearRing*>*)getInteriorRings {
    if (_interiorRings == NULL) {
        auto count = GEOSGetNumInteriorRings_r(GeosContext, self.geometry);
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            const GEOSGeometry* ir = GEOSGetInteriorRingN_r(GeosContext, self.geometry, i);
            GEOSGeometry* irc = GEOSGeom_clone_r(GeosContext, ir);
            MADLinearRing *interiorRing = [[MADLinearRing alloc] initWithGeometry:irc];
            [array setObject:interiorRing atIndexedSubscript:i];
        }
        _interiorRings = [NSArray arrayWithArray:array];
    }
    return _interiorRings;
}

@end

