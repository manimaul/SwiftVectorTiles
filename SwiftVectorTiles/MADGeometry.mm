//
//  MADGeometry.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//


#include "ogr_core.h"
#include "cpl_conv.h"
#include <memory>

#import <Foundation/Foundation.h>
#import "MADGeometry.hh"
#import "MADGeometry+Private.hh"
#import "MADCoordinate.hh"

using namespace std;

@implementation MADGeometry

-(OGRwkbGeometryType) getwkbGemotryType {
    return static_cast<OGRwkbGeometryType>([self getGeometryType]);
}

-(instancetype) initWithGeometry:(OGRGeometry*)geometry {
    if (self = [super init]) {
        _geometry = geometry;
        return self;
    }
    return nil;
}

-(instancetype) initWithWellKnownText:(NSString *)text {
    if (self = [super init]) {
        _wkt = text;
        auto wkt = strdup([text UTF8String]);
        auto geometry = OGRGeometryFactory::createGeometry([self getwkbGemotryType]);
        auto result = geometry->importFromWkt(&wkt);
        if (OGRERR_NONE == result) {
            [self setGeometry:geometry];
            return self;
        }
    };
    return nil;
}

-(instancetype) initWithWellKnownBinary:(NSData *)data; {
    if (self = [super init]) {
        const void *wkb = [data bytes];
        unsigned char wkbBytes[data.length];
        memcpy(wkbBytes, wkb, [data length]);
        auto geometry = OGRGeometryFactory::createGeometry([self getwkbGemotryType]);
        auto result = geometry->importFromWkb(wkbBytes);
        if (OGRERR_NONE == result) {
            [self setGeometry:geometry];
            return self;
        }
    };
    return nil;
}

-(void) dealloc {
    if (nullptr != _geometry) {
        delete _geometry;
    }
}

-(BOOL) covers:(MADGeometry*)other {
    return NO;
}

-(BOOL) intersects:(MADGeometry*)other {
    return _geometry->Intersect(other.geometry);
}
-(BOOL) empty {
    return _geometry->IsEmpty();
}

-(NSString*)getWellKnownText {
    if (_wkt == NULL) {
        char *wktPtr = NULL;
        self.geometry->exportToWkt(&wktPtr);
        _wkt = [[NSString alloc] initWithUTF8String:wktPtr];
        CPLFree(wktPtr);
    }
    return _wkt;
}

-(MADGeometryType)getGeometryType {
    return MADwkbUnknown;
}

@end
