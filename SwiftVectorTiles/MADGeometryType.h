//
//  MADGeometryType.h
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#ifndef MADGeometryType_h
#define MADGeometryType_h

typedef enum {
    MADwkbUnknown = -1,
    MADwkbPoint,
    MADwkbLineString,
    MADwkbLinearRing,
    MADwkbPolygon,
    MADwkbMultiPoint,
    MADwkbMultiLineString,
    MADwkbMultiPolygon,
    MADwkbGeometryCollection,
    
} MADGeometryType;

/*
 enum GEOSGeomTypes {
 GEOS_POINT,
 GEOS_LINESTRING,
 GEOS_LINEARRING,
 GEOS_POLYGON,
 GEOS_MULTIPOINT,
 GEOS_MULTILINESTRING,
 GEOS_MULTIPOLYGON,
 GEOS_GEOMETRYCOLLECTION
 };
 */

#endif /* MADGeometryType_h */
