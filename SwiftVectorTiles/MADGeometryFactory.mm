//
//  MADGeometryFactory.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/18/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#include "geos_c.h"

#import "MADGeometryFactory.hh"
#import "MADGeometry+Private.hh"
#import "MADPoint.hh"
#import "MADMultiPoint.hh"
#import "MADLineString.hh"
#import "MADMultiLineString.hh"
#import "MADLinearRing.hh"
#import "MADPolygon.hh"
#import "MADMultiPolygon.hh"

@implementation MADGeometryFactory

+(MADGeometry*) geometryWithGeometry:(GEOSGeom_t*)geometry {
//    switch (geometry->getGeometryType()) {
//        case wkbPoint:
//            return [[MADPoint alloc] initWithGeometry:geometry];
//        case wkbMultiPoint:
//            return [[MADMultiPoint alloc] initWithGeometry:geometry];
//        case wkbLineString:
//            return [[MADLineString alloc] initWithGeometry:geometry];
//        case wkbMultiLineString:
//            return [[MADMultiLineString alloc] initWithGeometry:geometry];
//        case wkbLinearRing:
//            return [[MADLinearRing alloc] initWithGeometry:geometry];
//        case wkbPolygon:
//            return [[MADPolygon alloc] initWithGeometry:geometry];
//        case wkbMultiPolygon:
//            return [[MADMultiPolygon alloc] initWithGeometry:geometry];
//        case wkbGeometryCollection:
//        default:
//            break;
//    }
    return nil;
}


+(MADGeometry*) geometryWithWellKnownText:(NSString *)text {
//    auto wkt = strdup([text UTF8String]);
//    OGRGeometry* geometry;
//    if (OGRERR_NONE == OGRGeometryFactory::createFromWkt(&wkt, NULL, &geometry)) {
//        return [MADGeometryFactory geometryWithGeometry:geometry];
//    }
    return nil;
}

+(MADGeometry*) geometryWithWellKnownBinary:(NSData *)data {
//    const void *wkb = [data bytes];
//    unsigned char wkbBytes[data.length];
//    memcpy(wkbBytes, wkb, [data length]);
//    OGRGeometry* geometry;
//    if (OGRERR_NONE == OGRGeometryFactory::createFromWkb(wkbBytes, NULL, &geometry)) {
//        return [MADGeometryFactory geometryWithGeometry:geometry];
//    }
    return nil;
}


@end
