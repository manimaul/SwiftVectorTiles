//
//  MADGeometryType.h
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#ifndef MADGeometryType_h
#define MADGeometryType_h

typedef enum
{
    MADwkbUnknown = 0,             /* non-standard */
    MADwkbPoint = 1,               /* rest are standard WKB type codes */
    MADwkbLineString = 2,
    MADwkbPolygon = 3,
    MADwkbMultiPoint = 4,
    MADwkbMultiLineString = 5,
    MADwkbMultiPolygon = 6,
    MADwkbGeometryCollection = 7,
    MADwkbLinearRing = 101
} MADGeometryType;

#endif /* MADGeometryType_h */
