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
        auto polygon = dynamic_cast<OGRPolygon*>(self.geometry);
        auto exteriorRing = polygon->getExteriorRing();
        _exteriorRing = [[MADLinearRing alloc] initWithGeometry:exteriorRing];
    }
    return _exteriorRing;
}

-(NSArray<MADLinearRing*>*)getInteriorRings {
    if (_interiorRings == NULL) {
        auto polygon = dynamic_cast<OGRPolygon*>(self.geometry);
        auto count = polygon->getNumInteriorRings();
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            MADLinearRing *interiorRing = [[MADLinearRing alloc] initWithGeometry:polygon->getInteriorRing(i)];
            [array setObject:interiorRing atIndexedSubscript:i];
        }
        _interiorRings = [NSArray arrayWithArray:array];
    }
    return _interiorRings;
}

-(MADPolygon*)intersection:(MADGeometry*)other {
    return nil;
}

@end

